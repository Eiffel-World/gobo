indexing
	description:	"A tree based XML Parser using any XM_EVENT_PARSER implementation as back end."
	status:	"See notice at end of class."
	author:	"Andreas Leitner"
	note:	"Although it is not DOM (Level 1) conforming, it has %
	%been writen with DOM in mind. I prefer to have this %
	%parser follow the Eiffel design guide lines";
class
	XT_TREE_PARSER

inherit
	XI_TREE_PARSER

	XM_EVENT_PARSER
		rename
			implementation as event_implementation,
			make_from_implementation as make_from_implementation_event
		undefine
			is_equal,
			copy
		redefine
			on_start_tag,
			on_content,
			on_end_tag,
			on_processing_instruction,
			on_comment,
			parse_from_stream
		end

creation
	make_from_implementation

feature {NONE} -- Initialisation

	make_from_implementation (a_imp: XI_EVENT_PARSER) is
		do
			make_from_implementation_event (a_imp)
			reset
		end

feature {ANY} -- Access

	document: XM_DOCUMENT


	is_position_table_enabled: BOOLEAN is
		do
			Result := last_position_table /= Void
		end

	last_position_table: XM_POSITION_TABLE

feature {ANY} -- Basic Opertations

	enable_position_table is
		do
			!! last_position_table.make
		end

	disable_position_table is
		do
			last_position_table := Void
		end

feature {ANY} 

	reset is
		local
			toe_document: XT_DOCUMENT
		do
			!! toe_document.make
			!! document.make_from_implementation (toe_document)
			if is_position_table_enabled then
				enable_position_table
			end
			current_node := Void
			current_open_composite := Void
		end

	parse_from_stream (a_stream: like INPUT_STREAM_TYPE) is
			-- Parse XML Document from GOBO input stream.
		do
			reset
			Precursor (a_stream)
		end



feature {NONE} -- call backs
	--FIXME: Set current_element to Current before first callback is
	--beeing called (creation procedure?)
	on_start_tag (name, ns_prefix: UC_STRING; attributes: DS_BILINEAR [DS_PAIR [DS_PAIR [UC_STRING, UC_STRING], UC_STRING]]) is
			-- called whenever the parser findes a start element
		local
			element: XM_ELEMENT
			toe_element: XT_ELEMENT
		do
			check
				document_not_finished: document.root_element /= Void implies current_open_composite /= Void
			end

			if
				document.root_element = Void
			then
				-- this is the first element in the document
				!! toe_element.make_root (name, ns_prefix)
				!! element.make_from_implementation (toe_element)
				-- add root element
				document.force_last (element)
			else
				-- this is not the first element in the document
				!! toe_element.make_child (current_open_composite, name, ns_prefix)
				!! element.make_from_implementation (toe_element)
				current_open_composite.force_last (element)
			end

			handle_position (element)
			-- add attributes
			-- TODO: handle positions of attributes
			element.add_attributes (attributes)

			check
				element_not_void: element /= Void
			end
			current_node := element
			current_open_composite := element
		end

	on_content (chr_data: UC_STRING) is
			-- called whenever the parser findes character data
		local
			xml: XM_CHARACTER_DATA
			toe: XT_CHARACTER_DATA
		do
			check
				not_finished: current_open_composite /= Void
			end
			!! toe.make (current_open_composite, chr_data)
			!! xml.make_from_implementation (toe)
			current_open_composite.force_last (xml)

			handle_position (xml)

			current_node := xml
		end

	on_end_tag (name, ns_prefix: UC_STRING) is
			-- called whenever the parser findes an end element
		do
			check
				open_composite_exists: current_open_composite /= Void
			end

			current_open_composite := next_open_composite (current_open_composite)
			current_node := current_node.parent
		end

	on_processing_instruction (target, data: UC_STRING) is
			-- called whenever the parser findes a processing instruction.
		local
			toe: XT_PROCESSING_INSTRUCTION
			xml: XM_PROCESSING_INSTRUCTION
		do
			!! toe.make (target, data)
			!! xml.make_from_implementation (toe)
			if
				current_open_composite = Void
			then
				document.force_last (xml)
			else
				current_open_composite.force_last (xml)
			end

			handle_position (xml)

			current_node := xml
		end

	on_comment (com: UC_STRING) is
			-- called whenever the parser finds a comment.
		local
			toe: XT_COMMENT
			xml: XM_COMMENT
		do
			!! toe.make (current_open_composite, com)
			!! xml.make_from_implementation (toe)
			if
				current_open_composite = Void
			then
				document.force_last (xml)
			else
				current_open_composite.force_last (xml)
			end

			handle_position (xml)

			current_node := xml
		end

feature {NONE} -- Implementation
	current_node: XM_NODE
	current_open_composite: XM_COMPOSITE

	next_open_composite (composite: XM_COMPOSITE): XM_COMPOSITE is
		require
			composite /= Void
		do
			Result := composite.parent
		end

	handle_position (node: XM_NODE) is
			-- If desired, store position information of
			-- node `node' in position table
		require
			node_not_void: node /= Void
		do
			if
				is_position_table_enabled
			then
				last_position_table.put (position, node)
			end
		end

invariant
	--TODO:
	--inv1: (root_element /= Void) implies (current_node /= Void)
	--inv2: (current_open_element = Void) implies (current_node = root_element)
	--inv3: ((root_element /= Void) and then (current_node = root_element)) implies current_node.is_root


end -- class XT_TREE_PARSER
--|-------------------------------------------------------------------------
--| eXML, Eiffel XML Parser Toolkit
--| Copyright (C) 1999	Andreas Leitner and others
--| See the file forum.txt included in this package for licensing info.
--|
--| Comments, Questions, Additions to this library? please contact:
--|
--| Andreas Leitner
--| Arndtgasse 1/3/5
--| 8010 Graz
--| Austria
--| email: andreas.leitner@chello.at
--| www: http://exml.dhs.org
--|-------------------------------------------------------------------------
