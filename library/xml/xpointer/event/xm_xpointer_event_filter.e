indexing

	description:

		"Objects that filter an event stream according to an XPointer"

	library: "Gobo Eiffel XML Library"
	copyright: "Copyright (c) 2005, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPOINTER_EVENT_FILTER

inherit

	XM_DTD_CALLBACKS_FILTER
		rename
			make_null as make_dtd_null,
			set_next as set_next_dtd,
			next as dtd_callbacks
		redefine
			on_attribute_declaration
		end

	XM_CALLBACKS_FILTER
		rename
			make_null as make_filter_null,
			set_next as set_next_filter,
			next as callbacks
		redefine
			on_start, on_finish, on_processing_instruction, on_comment, on_start_tag,
			on_attribute, on_start_tag_finish, on_end_tag, on_content
		end

	XM_MARKUP_CONSTANTS

	KL_IMPORTED_STRING_ROUTINES

	UC_SHARED_STRING_EQUALITY_TESTER

	-- TODO: Extend the filter to accept element() scheme. (?)

creation

	make

feature {NONE} -- Initialization

	make (an_xpointer: STRING; a_media_type: UT_MEDIA_TYPE; a_callback: XM_CALLBACKS; a_dtd_callback: XM_DTD_CALLBACKS) is
			-- Establish invariant.
		require
			xpointer_not_void: an_xpointer /= Void
			default_media_type_not_void: a_media_type /= Void
			callbacks_not_void: a_callback /= Void
			dtd_callbacks_not_void: a_dtd_callback /= Void
		do
			media_type := a_media_type
			callbacks := a_callback
			dtd_callbacks := a_dtd_callback
			set_xpointer (an_xpointer)
		ensure
			media_type_set: media_type = a_media_type
			filtering: is_filtering
		end

feature -- Status report

	is_filtering: BOOLEAN
			-- Are we actually doing any XPointer filtering?

feature -- Status setting

	set_no_filtering is
			-- Change this into a pure pass-through filter
		do
			is_filtering := False
			is_error := False
		ensure
			not_filtering: not is_filtering
		end

	set_xpointer (an_xpointer: STRING) is
			-- Use `an_xpointer' as the XPointer
		require
			xpointer_not_void: an_xpointer /= Void
		local
			a_parser: XM_XPOINTER_PARSER
		do
			is_error := False
			create a_parser.make
			a_parser.parse (an_xpointer)
			if a_parser.is_error or else not a_parser.is_shorthand then
				is_error := True
				error_message := STRING_.concat (an_xpointer, " is not a shorthand pointer")
			else
				shorthand := a_parser.shorthand
			end
			create attribute_types.make_with_equality_testers (7, Void, string_equality_tester)
			is_filtering := True
		ensure
			filtering: is_filtering
		end

feature -- Document type definition callbacks

	on_attribute_declaration (an_element_name, a_name: STRING; a_model: XM_DTD_ATTRIBUTE_CONTENT) is
			-- Attribute declaration, one event per attribute.
		local
			an_attribute_table: DS_HASH_TABLE [XM_DTD_ATTRIBUTE_CONTENT, STRING]
			a_message: STRING
		do
			if is_filtering then
				if not attribute_types.has (an_element_name) then
					create an_attribute_table.make_with_equality_testers (7, Void, string_equality_tester)
					attribute_types.force (an_attribute_table, an_element_name)
				end
				an_attribute_table := attribute_types.item (an_element_name)
				check
					attribute_table_not_void: an_attribute_table /= Void
					-- because has() returned `True'
				end
				if an_attribute_table.has (a_name) then
					a_message := "Attribute "
					a_message.append_string (a_name)
					a_message.append_string (" already present for element ")
					a_message.append_string (an_element_name)
					on_error (a_message)
				else
					an_attribute_table.force (a_model, a_name)
				end
			end
			Precursor (an_element_name, a_name, a_model)
		end

feature -- Document

	on_start is
			-- Called when parsing starts.
		do
			if is_filtering then
				is_forwarding := False
				is_forwarding_processing_instructions := True
				is_shorthand_found := False
				if is_error then
					on_error (error_message)
				else
					-- TODO: check media type is OK for ID or XPointer processing
					Precursor
					
					-- We forward comments PIs prior to the document element,
					--  as they might be needed for other purposes.
					
					is_forwarding := True 
				end
			end
		end

	on_finish is
			-- Called when parsing finished
		do
			if not is_error then Precursor end
			is_error := False
			is_shorthand_found := False
		end

feature -- Meta

	on_processing_instruction (a_name: STRING; a_content: STRING) is
			-- Processing instruction.
		do
			if not is_filtering or else (is_forwarding_processing_instructions and then not is_error) then
				Precursor (a_name, a_content)
			end
		end

	on_comment (a_content: STRING) is
			-- Processing a comment.
		do
			if not is_filtering or else (is_forwarding and then is_shorthand_found and then not is_error) then
				Precursor (a_content)
			end
		end

feature -- Tag

	on_start_tag (a_namespace: STRING; a_prefix: STRING; a_local_part: STRING) is
			-- Start of start tag.
		local
			an_element_qname, an_xml_prefix: STRING
		do
			if not is_filtering then
				Precursor (a_namespace, a_prefix, a_local_part)
			elseif not is_error then
				pending_namespace := Void; pending_prefix := Void; pending_local_part := Void
				if not is_shorthand_found then
					if a_prefix = Void then
						an_xml_prefix := ""
					else
						an_xml_prefix := a_prefix
					end
					is_forwarding := False
					pending_namespace := a_namespace; pending_prefix := a_prefix; pending_local_part := a_local_part
					create pending_attribute_namespaces.make
					create pending_attribute_prefixes.make
					create pending_attribute_local_parts.make
					create pending_attribute_values.make
					if an_xml_prefix.count = 0 then
						an_element_qname := a_local_part
					else
						an_element_qname := clone (an_xml_prefix)
						an_element_qname := STRING_.appended_string (an_element_qname, ":")
						an_element_qname := STRING_.appended_string (an_element_qname, a_local_part)
					end
					current_element_name := an_element_qname
				elseif is_forwarding then
					Precursor (a_namespace, a_prefix, a_local_part)
				end
			end
		end

	on_attribute (a_namespace: STRING; a_prefix: STRING; a_local_part: STRING; a_value: STRING) is
			-- Start of attribute.
		local
			an_attribute_table: DS_HASH_TABLE [XM_DTD_ATTRIBUTE_CONTENT, STRING]
			an_attribute_model: XM_DTD_ATTRIBUTE_CONTENT
			an_attribute_qname, an_xml_prefix: STRING
		do
			if not is_filtering or else is_forwarding then
				Precursor (a_namespace, a_prefix, a_local_part, a_value)
			elseif not is_shorthand_found then
				if a_prefix /= Void and then Xml_prefix.is_equal (a_prefix) and then Xml_id.is_equal (a_local_part) then
					is_shorthand_found := STRING_.same_string (shorthand, a_value)
				else
					if attribute_types.has (current_element_name) then
						an_attribute_table := attribute_types.item (current_element_name)
						check
							attribute_table_not_void: an_attribute_table /= Void
							-- because `has' returned `True'
						end
						if a_prefix = Void then
							an_xml_prefix := ""
						else
							an_xml_prefix := a_prefix
						end
						if an_xml_prefix.count = 0 then
							an_attribute_qname := clone (a_local_part)
						else
							an_attribute_qname := clone (an_xml_prefix)
							an_attribute_qname := STRING_.appended_string (an_attribute_qname, ":")
							an_attribute_qname := STRING_.appended_string (an_attribute_qname, a_local_part)
						end
						if an_attribute_table.has (an_attribute_qname) then
							an_attribute_model := an_attribute_table.item (an_attribute_qname)
							check
								attribute_model_not_void: an_attribute_model /= Void
								-- because `has' returned `True'
							end
							if an_attribute_model.is_id then
								is_shorthand_found := STRING_.same_string (shorthand, a_value)
							end
						end
					end
				end
				if is_shorthand_found then
					is_forwarding := True
					on_start_tag (pending_namespace, pending_prefix, pending_local_part)
					from
					until
						pending_attribute_namespaces.is_empty
					loop
						on_attribute (pending_attribute_namespaces.item, pending_attribute_prefixes.item, pending_attribute_local_parts.item, pending_attribute_values.item)
						pending_attribute_namespaces.remove; pending_attribute_prefixes.remove; pending_attribute_local_parts.remove; pending_attribute_values.remove
					end
					Precursor (a_namespace, a_prefix, a_local_part, a_value)
				else
					pending_attribute_namespaces.force (a_namespace); pending_attribute_prefixes.force (a_prefix);
					pending_attribute_local_parts.force (a_local_part); pending_attribute_values.force (a_value)
				end
			end
		end

	on_start_tag_finish is
			-- End of start tag.
		do
			if not is_filtering or else is_forwarding then Precursor end
		end

	on_end_tag (a_namespace: STRING; a_prefix: STRING; a_local_part: STRING) is
			-- End tag.
		local
			an_element_qname, an_xml_prefix: STRING		
		do
			if not is_filtering then
				Precursor (a_namespace, a_prefix, a_local_part)
			elseif is_forwarding then
				Precursor (a_namespace, a_prefix, a_local_part)
				if a_prefix = Void then
					an_xml_prefix := ""
				else
					an_xml_prefix := a_prefix
				end
				if an_xml_prefix.count = 0 then
					an_element_qname := a_local_part
				else
					an_element_qname := clone (an_xml_prefix)
					an_element_qname := STRING_.appended_string (an_element_qname, ":")
					an_element_qname := STRING_.appended_string (an_element_qname, a_local_part)
				end
				if STRING_.same_string (an_element_qname, current_element_name) then
					is_forwarding := False
					is_forwarding_processing_instructions := False
				end
			end
		end

feature -- Content

	on_content (a_content: STRING) is
			-- Text content.
		do
			if not is_filtering or else is_forwarding then Precursor (a_content) end
		end

feature {NONE} -- Implementation

	error_message: STRING
			-- Error message from XPointer processing

	attribute_types: DS_HASH_TABLE [DS_HASH_TABLE [XM_DTD_ATTRIBUTE_CONTENT, STRING], STRING]
			-- Stored attribute-type definitions per element name

	current_element_name: STRING
			-- QName of the current element;
			-- Used for tracking attribute types

	pending_namespace, pending_prefix, pending_local_part: STRING
			-- Start tag of shorthand element

	pending_attribute_namespaces: DS_LINKED_QUEUE [STRING]
			-- Namespaces of pending attributes

	
	pending_attribute_prefixes: DS_LINKED_QUEUE [STRING]
			-- prefixes of pending attributes

	
	pending_attribute_local_parts: DS_LINKED_QUEUE [STRING]
			-- Local parts of pending attributes
	
	pending_attribute_values: DS_LINKED_QUEUE [STRING]
			-- Values of pending attributes

	media_type: UT_MEDIA_TYPE
			-- Media type

	shorthand: STRING
			-- parsed shorthand pointer

	is_forwarding, is_forwarding_processing_instructions: BOOLEAN
			-- Are we forwarding non-DTD events?

	is_shorthand_found: BOOLEAN
			-- Have we found the shorthand element?

	is_error: BOOLEAN
			-- Did XPointer processing flag an error?
	
invariant

	media_type_not_void: media_type /= Void
	xpointer_error: is_error implies error_message /= Void
	attribute_types_not_void: attribute_types /= Void

end
	
