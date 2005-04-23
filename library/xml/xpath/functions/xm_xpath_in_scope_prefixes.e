indexing

	description:

		"Objects that implement the XPath in-scope-prefixes() function"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_IN_SCOPE_PREFIXES

inherit

	XM_XPATH_SYSTEM_FUNCTION
		redefine
			create_iterator
		end

creation

	make

feature {NONE} -- Initialization

	make is
			-- Establish invariant
		do
			name := "in-scope-prefixes"; namespace_uri := Xpath_standard_functions_uri
			minimum_argument_count := 1
			maximum_argument_count := 1
			create arguments.make (1)
			arguments.set_equality_tester (expression_tester)
			compute_static_properties
			initialized := True
		end

feature -- Access

	item_type: XM_XPATH_ITEM_TYPE is
			-- Data type of the expression, where known
		do
			Result := type_factory.string_type
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

feature -- Status report

	required_type (argument_number: INTEGER): XM_XPATH_SEQUENCE_TYPE is
			-- Type of argument number `argument_number'
		local
			an_element_test: XM_XPATH_NODE_KIND_TEST
		do
			create an_element_test.make_element_test
			create Result.make (an_element_test, Required_cardinality_exactly_one)
		end

feature -- Evaluation

	create_iterator (a_context: XM_XPATH_CONTEXT) is
			-- An iterator over the values of a sequence
		local
			an_item: XM_XPATH_ITEM
		do
			arguments.item (1).evaluate_item (a_context)
			an_item := arguments.item (1).last_evaluated_item
			if an_item.is_element then
				an_item.as_element.ensure_namespace_nodes
				last_iterator := an_item.as_element.prefixes_in_scope
			else
				create {XM_XPATH_INVALID_ITERATOR} last_iterator.make_from_string ("First argument is not an element", Xpath_errors_uri, "FORG0006", Dynamic_error)
			end
		end
		

feature {XM_XPATH_EXPRESSION} -- Restricted

	compute_cardinality is
			-- Compute cardinality.
		do
			set_cardinality_zero_or_more
		end

end
	
