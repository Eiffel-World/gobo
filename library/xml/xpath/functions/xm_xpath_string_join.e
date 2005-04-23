indexing

	description:

		"Objects that implement the XPath string-join() function"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_STRING_JOIN

inherit

	XM_XPATH_SYSTEM_FUNCTION
		redefine
			analyze, evaluate_item
		end

	XM_XPATH_CARDINALITY

creation

	make

feature {NONE} -- Initialization

	make is
			-- Establish invariant
		do
			name := "string-join"; namespace_uri := Xpath_standard_functions_uri
			minimum_argument_count := 2
			maximum_argument_count := 2
			create arguments.make (2)
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
		do
			if argument_number = 1 then
				create Result.make (type_factory.string_type, Required_cardinality_zero_or_more)
			else
				create Result.make_single_string
			end
		end

feature -- Optimization

	analyze (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Perform static analysis of an expression and its subexpressions
		local
			an_expression: XM_XPATH_EXPRESSION 
		do
			mark_unreplaced
			Precursor (a_context)
			if not is_error then
				if not was_expression_replaced then
					an_expression := simplified_singleton
					if an_expression /= Current then
						set_replacement (an_expression)
					end
				end
			end
		end

feature -- Evaluation

	evaluate_item (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate as a single item
		local
			an_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]
			a_result, a_string, a_separator: STRING
		do

			-- We ensure that we don't evaluate the
			--  separator argument unless there are at least two items in the sequence.

			arguments.item (1).create_iterator (a_context)
			an_iterator := arguments.item (1).last_iterator
			if an_iterator.is_error then
				create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make (an_iterator.error_value)
			else
				an_iterator.start
				if an_iterator.after then
				create {XM_XPATH_STRING_VALUE} last_evaluated_item.make ("")	
				else
					a_string := an_iterator.item.string_value
					an_iterator.forth
					if an_iterator.after then
						create {XM_XPATH_STRING_VALUE} last_evaluated_item.make (a_string)
					else
						
						-- Type checking ensured that the separator was not an empty sequence.
						
						arguments.item (2).evaluate_item (a_context)
						a_separator := arguments.item (2).last_evaluated_item.string_value
						a_result := STRING_.concat (a_string, a_separator)
						from
						until
							an_iterator.after
						loop
							a_string := an_iterator.item.string_value
							a_result := STRING_.appended_string (a_result, a_separator)
							a_result := STRING_.appended_string (a_result, a_string)
							an_iterator.forth
						end
						create {XM_XPATH_STRING_VALUE} last_evaluated_item.make (a_result)
					end
				end
			end
		end

feature {XM_XPATH_EXPRESSION} -- Restricted

	compute_cardinality is
			-- Compute cardinality.
		do
			set_cardinality_exactly_one
		end

feature {NONE} -- Implementation

	simplified_singleton: XM_XPATH_EXPRESSION is
			-- Simplified version of `Current' when first argument is a singleton;
			-- Important as this is common for attribute value templates.
		require
			not_in_error: not is_error
		do
			if arguments.item (1).cardinality_allows_many then
				Result := Current
			else
				Result := arguments.item (1)
			end
		ensure
			result_not_void: Result /= Void
		end

end
	
