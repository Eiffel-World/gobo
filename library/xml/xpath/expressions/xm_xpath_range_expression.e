indexing

	description:

		"XPath range expressons"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_RANGE_EXPRESSION

inherit

	XM_XPATH_BINARY_EXPRESSION
		redefine
			analyze, compute_cardinality, create_iterator
		end

	XM_XPATH_ROLE

creation

	make

		-- The sequence must be ascending; if the end-point is less
		--  than the start-point, an empty sequence is returned. This is to allow
		--  expressions of the form "for $i in 1 to count($seq) return ...."

feature -- Access

	item_type: XM_XPATH_ITEM_TYPE is
			--Determine the data type of the expression, if possible
		do
			Result := type_factory.integer_type
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

	lower_bound: XM_XPATH_EXPRESSION is
			-- Inclusive lower bound
		do
			Result := first_operand
		end

	upper_bound: XM_XPATH_EXPRESSION is
			-- Inclusive upper bound
		do
			Result := second_operand
		end

feature -- Optimization	

	analyze (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Perform static analysis of an expression and its subexpressions
		local
			a_role, another_role: XM_XPATH_ROLE_LOCATOR
			a_sequence_type: XM_XPATH_SEQUENCE_TYPE
			a_type_checker: XM_XPATH_TYPE_CHECKER
		do
			mark_unreplaced
			first_operand.analyze (a_context)
			if first_operand.was_expression_replaced then
				set_first_operand (first_operand.replacement_expression)
			end
			if first_operand.is_error then
				set_last_error (first_operand.error_value)
			else
				second_operand.analyze (a_context)
				if second_operand.was_expression_replaced then
					set_second_operand (second_operand.replacement_expression)
				end
				if second_operand.is_error then
					set_last_error (second_operand.error_value)
				else
					create a_sequence_type.make_optional_integer
					create a_role.make (Binary_expression_role, "to", 1)
					create a_type_checker
					a_type_checker.static_type_check (a_context, first_operand, a_sequence_type, False, a_role)
					if a_type_checker.is_static_type_check_error then
						set_last_error_from_string (a_type_checker.static_type_check_error_message, Xpath_errors_uri, "XP0004", Type_error)
					else
						set_first_operand (a_type_checker.checked_expression)
						create another_role.make (Binary_expression_role, "to", 2)
						a_type_checker.static_type_check (a_context, second_operand, a_sequence_type, False, another_role)
						if a_type_checker.is_static_type_check_error then
							set_last_error_from_string (a_type_checker.static_type_check_error_message, Xpath_errors_uri, "XP0004", Type_error)
						else
							set_second_operand (a_type_checker.checked_expression)
							simplify
						end
					end
				end
			end
		end

feature -- Evaluation

	create_iterator (a_context: XM_XPATH_CONTEXT) is
			-- Iterator over the values of a sequence
		local
			an_integer_value, another_integer_value: XM_XPATH_INTEGER_VALUE 
		do
			first_operand.evaluate_item (a_context)
			if first_operand.last_evaluated_item.is_error then
				create {XM_XPATH_INVALID_ITERATOR} last_iterator.make (first_operand.last_evaluated_item.error_value)
			else
				an_integer_value ?= first_operand.last_evaluated_item
				if an_integer_value = Void then
					create {XM_XPATH_EMPTY_ITERATOR [XM_XPATH_ITEM]} last_iterator.make
				else
					second_operand.evaluate_item (a_context)
					if second_operand.last_evaluated_item /= Void and then second_operand.last_evaluated_item.is_error then
						create {XM_XPATH_INVALID_ITERATOR} last_iterator.make (second_operand.last_evaluated_item.error_value)
					else
						another_integer_value ?= second_operand.last_evaluated_item
						if another_integer_value = Void then
							create {XM_XPATH_EMPTY_ITERATOR [XM_XPATH_ITEM]} last_iterator.make
						elseif an_integer_value.value > another_integer_value.value then
							create {XM_XPATH_EMPTY_ITERATOR [XM_XPATH_ITEM]} last_iterator.make
						elseif an_integer_value.is_platform_integer and then another_integer_value.is_platform_integer then
							create {XM_XPATH_RANGE_ITERATOR} last_iterator.make (an_integer_value.as_integer, another_integer_value.as_integer)
						else
							todo ("iterator - large integers", True)
						end
					end
				end
			end
		end

feature {NONE} -- Implementation

	compute_cardinality is
			-- Compute cardinality.
		do
			set_cardinality_zero_or_more
		end
	
end
