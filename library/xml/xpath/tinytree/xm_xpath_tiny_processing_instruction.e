indexing

	description:

		"Tiny tree Processing-instruction nodes"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_TINY_PROCESSING_INSTRUCTION

inherit

	XM_XPATH_PROCESSING_INSTRUCTION
		undefine
			base_uri
		end

	XM_XPATH_TINY_NODE
		redefine
			base_uri
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
			node_type := Processing_instruction_node
		ensure
			document_set: document = a_document
			node_number_set: node_number = a_node_number
		end

feature -- Access

	string_value: STRING is
			-- String-value
		local
			start, length: INTEGER
			buffer: STRING
		do
			length := document.beta_value (node_number)
			start := document.alpha_value (node_number)
			Result := document.comment_buffer.substring (start, start + length)
		end

	base_uri: STRING is
			-- Base URI
		do
			Result := document.system_id_for_node (node_number)
		end

feature -- Duplication

	copy_node (a_receiver: XM_XPATH_RECEIVER; which_namespaces: INTEGER; copy_annotations: BOOLEAN) is
			-- Copy `Current' to `a_receiver'.
		do
			a_receiver.notify_processing_instruction (node_name, string_value, 0)
		end

feature {XM_XPATH_NODE} -- Restricted

	is_possible_child: BOOLEAN is
			-- Can this node be a child of a document or element node?
		do
			Result := True
		end

end
