indexing

	description:

		"Objects that enumerate the preceding-or-ancestor internal Axis"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_TREE_PRECEDING_OR_ANCESTOR_ENUMERATION
	
inherit

	XM_XPATH_AXIS_ITERATOR [XM_XPATH_TREE_NODE]
		redefine
			start
		end

	XM_XPATH_TREE_ENUMERATION

creation

	make
	
feature {NONE} -- Initialization

	make (a_starting_node: XM_XPATH_TREE_NODE; a_node_test: XM_XPATH_NODE_TEST) is
			-- Establish invariant
		require
			starting_node_not_void: a_starting_node /= Void
			node_test_not_void: a_node_test /= Void
		do
			make_enumeration (a_starting_node, a_node_test)
			next_node := starting_node
			advance
		ensure
			starting_node_set: starting_node = a_starting_node
			test_set: node_test = a_node_test
		end

feature -- Cursor movement

	start is
			-- Move to next position
		do
			index := 1
			current_item := next_node
		end

	forth is
			-- Move to next position
		do
			index := index + 1
			advance
			current_item := next_node
		end

feature -- Duplication

	another: like Current is
			-- Another iterator that iterates over the same items as the original;
			-- The new iterator will be repositioned at the start of the sequence
		do
			create Result.make (starting_node, node_test)
		end

feature {NONE} -- Implemnentation

	advance_one_step is
			-- Move to the next candidate node
		do
			next_node := next_node.previous_node_in_document_order
		end

end
	
