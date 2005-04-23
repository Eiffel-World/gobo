indexing

	description:

		"Tiny tree Text nodes"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_TINY_TEXT

inherit

	XM_XPATH_TEXT
		undefine
			is_tiny_node, as_tiny_node
		end

	XM_XPATH_TINY_NODE
		undefine
			local_part
		end

creation

	make

feature {NONE} -- Initialization

	make (a_document: XM_XPATH_TINY_DOCUMENT; a_node_number: INTEGER) is
		require
			valid_document: a_document /= Void
			valid_node_number: a_node_number > 1 and a_node_number <= a_document.last_node_added
		do
			document := a_document
			node_number := a_node_number
			node_type := Text_node
		ensure
			document_set: document = a_document
			node_number_set: node_number = a_node_number
		end

feature -- Access

	string_value: STRING is
			-- String-value
		local
			start, length: INTEGER
		do
			start := document.alpha_value (node_number)
			length := document.beta_value (node_number)
			Result := document.character_buffer.substring (start + 1, start + length)
		end

feature -- Duplication

	copy_node (a_receiver: XM_XPATH_RECEIVER; which_namespaces: INTEGER; copy_annotations: BOOLEAN) is
			-- Copy `Current' to `a_receiver'.
		local
			a_start_index: INTEGER
		do
			a_start_index := document.alpha_value (node_number)
			a_receiver.notify_characters (document.character_buffer.substring (a_start_index, a_start_index + document.beta_value (node_number)), 0)
		end

feature {XM_XPATH_NODE} -- Restricted

	is_possible_child: BOOLEAN is
			-- Can this node be a child of a document or element node?
		do
			Result := True
		end

end
