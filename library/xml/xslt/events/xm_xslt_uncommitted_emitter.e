indexing

	description:

	"Emitters that write (X)HTML or XML accoridng to the document element."

library: "Gobo Eiffel XSLT Library"
copyright: "Copyright (c) 2004, Colin Adams and others"
license: "Eiffel Forum License v2 (see forum.txt)"
date: "$Date$"
revision: "$Revision$"

class XM_XSLT_UNCOMMITTED_EMITTER

inherit

	UC_SHARED_STRING_EQUALITY_TESTER

	XM_XSLT_EMITTER
		rename
			outputter as encoder
		end

	XM_XPATH_STANDARD_NAMESPACES

	XM_XPATH_TYPE

	XM_XSLT_STRING_ROUTINES

creation

	make

feature {NONE} -- Initialization

	make (a_transformer: XM_XSLT_TRANSFORMER; an_outputter: XM_OUTPUT; some_output_properties: XM_XSLT_OUTPUT_PROPERTIES; a_character_map_expander: XM_XSLT_CHARACTER_MAP_EXPANDER) is
			-- Establish invariant.
		require
			transformer_not_void: a_transformer /= Void
			outputter_not_void: an_outputter /= Void
			output_properties_not_void: some_output_properties /= Void
		do
			transformer := a_transformer
			outputter := an_outputter
			output_properties := some_output_properties
			character_map_expander := a_character_map_expander
			system_id := "" -- TODO - set_system_id
		ensure
			not_yet_committed: not committed
			transformer_set: transformer = a_transformer
			outputter_set: outputter = an_outputter
			output_properties_set: output_properties = some_output_properties
			character_map_expander_set: character_map_expander = a_character_map_expander
		end

feature -- Events

	start_document is
			-- New document
		do
			is_document_started := True
		ensure then
			not_yet_committed: not committed
		end

	end_document is
			-- Notify the end of the document
		do
			if not committed then

				-- empty output: must send a beginDocument()/endDocument() pair to the content handler

				switch_to_xml
			end
			check
				committed: committed
			end
			base_receiver.end_document
		ensure then
			committed: committed
		end

	notify_characters (chars: STRING; properties: INTEGER) is
			-- Notify character data.
		local
			a_pending_event: XM_XSLT_PENDING_EVENT
		do
			if not committed then
				check_pending_event_list
				create a_pending_event.make (chars, "", Text_node, properties)
				pending_event_list.force_last (a_pending_event)
				if not is_all_whitespace (chars) then
					switch_to_xml
				end
			else
				base_receiver.notify_characters (chars, properties)
			end
		end

	notify_processing_instruction (a_name: STRING; a_data_string: STRING; properties: INTEGER) is
			-- Notify a processing instruction.
		local
			a_pending_event: XM_XSLT_PENDING_EVENT
		do
			if not committed then
				check_pending_event_list
				create a_pending_event.make (a_data_string, a_name, Processing_instruction_node, properties)
				pending_event_list.force_last (a_pending_event)
			else
				base_receiver.notify_processing_instruction (a_name, a_data_string, properties)
			end
		end

	notify_comment (a_content_string: STRING; properties: INTEGER) is
			-- Notify a comment.
		local
			a_pending_event: XM_XSLT_PENDING_EVENT
		do
			if not committed then
				check_pending_event_list
				create a_pending_event.make (a_content_string, "", Comment_node, properties)
				pending_event_list.force_last (a_pending_event)
			else
				base_receiver.notify_comment (a_content_string, properties)
			end
		end	

	start_element (a_name_code: INTEGER; a_type_code: INTEGER; properties: INTEGER) is
			-- Notify the start of an element
		local
			a_name: STRING
			a_uri_code: INTEGER
		do
			if not committed then
				a_name := shared_name_pool.local_name_from_name_code (a_name_code)
				a_uri_code := shared_name_pool.uri_code_from_name_code (a_name_code)
				if a_uri_code = Xhtml_uri_code and then STRING_.same_string (a_name, "html") then
					switch_to_xhtml
				else
					a_name.to_lower
					if a_uri_code = Default_uri_code and then STRING_.same_string (a_name, "html") then
						switch_to_html
					else
						switch_to_xml
					end
				end
			end
			check
				committed: committed
			end
			base_receiver.start_element (a_name_code, a_type_code, properties)
		ensure then
			committed: committed			
		end

	notify_namespace (a_namespace_code: INTEGER; properties: INTEGER) is
			-- Notify a namespace declaration.
		do
			check
				committed: committed
			end
			base_receiver.notify_namespace (a_namespace_code, properties)
		ensure then
			committed: committed
		end

	notify_attribute (a_name_code: INTEGER; a_type_code: INTEGER; a_value: STRING; properties: INTEGER) is
			-- Notify an attribute.
		do
			check
				committed: committed
			end
			base_receiver.notify_attribute (a_name_code, a_type_code, a_value, properties)
		ensure then
			committed: committed
		end

	start_content is
			-- Notify the start of the content, that is, the completion of all attributes and namespaces.
		do
			check
				committed: committed
			end
			base_receiver.start_content
		ensure then
			committed: committed
		end

	end_element is
			-- Notify the end of an element.
		do
			check
				committed: committed
			end
			base_receiver.end_element
		ensure then
			committed: committed
		end

feature {NONE} -- Implementation

	committed: BOOLEAN
			-- Have we committed yet?

	base_receiver: XM_XPATH_RECEIVER
			-- Emitter/indenter to which events are forwarded

	outputter: XM_OUTPUT
			-- Writer of encoded strings

	pending_event_list: DS_ARRAYED_LIST [XM_XSLT_PENDING_EVENT]
			-- Pending events

	check_pending_event_list is
			-- Ensure `pending_event_list' is created.
		do
			if pending_event_list = Void then
				create pending_event_list.make_default
			end
		ensure
			pending_event_list_not_void: pending_event_list /= Void
		end

	switch_to_xml is
			-- Switch to an XML emitter.
		require
			not_yet_committed: not committed
		local
			an_xml_emitter: XM_XSLT_XML_EMITTER
			an_xml_indenter: XM_XSLT_XML_INDENTER
		do
			output_properties.set_xml_defaults (0)
			create an_xml_emitter.make (transformer, outputter, output_properties, character_map_expander)
			base_receiver := an_xml_emitter
			if output_properties.indent then
				create an_xml_indenter.make (transformer, an_xml_emitter, output_properties)
				base_receiver := an_xml_indenter
			end
			-- TODO: CDATA filter

			switch
		ensure
			committed: committed
		end

	switch_to_html is
			-- Switch to an HTML emitter.
		require
			not_yet_committed: not committed
		local
			an_html_emitter: XM_XSLT_HTML_EMITTER
			an_html_indenter: XM_XSLT_HTML_INDENTER
		do
			output_properties.set_html_defaults (0)
			create an_html_emitter.make (transformer, outputter, output_properties, character_map_expander)
			base_receiver := an_html_emitter
			if output_properties.indent then
				create an_html_indenter.make (transformer, an_html_emitter, output_properties)
				base_receiver := an_html_indenter
			end
			switch
		ensure
			committed: committed
		end

	switch_to_xhtml is
			-- Switch to an XHTML emitter.
		require
			not_yet_committed: not committed
		local
			an_xhtml_emitter: XM_XSLT_XHTML_EMITTER
			an_html_indenter: XM_XSLT_HTML_INDENTER
		do
			output_properties.set_xhtml_defaults (0)
			create an_xhtml_emitter.make (transformer, outputter, output_properties, character_map_expander)
			base_receiver := an_xhtml_emitter
			if output_properties.indent then
				create an_html_indenter.make (transformer, an_xhtml_emitter, output_properties)
				base_receiver := an_html_indenter
			end

			switch
		ensure
			committed: committed
		end

	switch is
			-- Switch to using `base_receiver'.
		require
			base_receiver_not_void: base_receiver /= Void
			not_yet_committed: not committed
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XSLT_PENDING_EVENT]
			an_event: XM_XSLT_PENDING_EVENT
		do
			committed := True
			base_receiver.start_document
			if pending_event_list /= Void then
				from
					a_cursor := pending_event_list.new_cursor a_cursor.start
				variant
					pending_event_list.count + 1 - a_cursor.index
				until
					a_cursor.after
				loop
					an_event := a_cursor.item
					inspect
						an_event.node_type
					when Comment_node then
						base_receiver.notify_comment (an_event.content, an_event.properties)
					when Processing_instruction_node then
						base_receiver.notify_processing_instruction (an_event.name, an_event.content, an_event.properties)
					when Text_node then
						base_receiver.notify_characters (an_event.content, an_event.properties)
					end
					a_cursor.forth	
				end
				pending_event_list := Void
			end
		ensure
			committed: committed
		end

invariant

	committed: committed implies base_receiver /= Void
	outputter: outputter /= Void

end

				
