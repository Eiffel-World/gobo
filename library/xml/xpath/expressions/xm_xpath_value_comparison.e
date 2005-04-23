indexing

	description:

		"XPath value comparisons"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_VALUE_COMPARISON

inherit

	XM_XPATH_BINARY_EXPRESSION
		rename
			make as make_binary_expression
		redefine
			analyze, evaluate_item, calculate_effective_boolean_value
		end

	XM_XPATH_COMPARISON_ROUTINES

	XM_XPATH_NAME_UTILITIES

	XM_XPATH_ROLE

	MA_DECIMAL_MATH

	MA_DECIMAL_CONSTANTS

	KL_SHARED_PLATFORM

		-- TODO - the rules for a value comparison have changed a little - stop using the comparison checker

creation

	make

feature {NONE} -- Initialization

	make (an_operand_one: XM_XPATH_EXPRESSION; a_token: INTEGER; an_operand_two: XM_XPATH_EXPRESSION; a_collator: ST_COLLATOR) is
			-- Establish invariant
		require
			operand_1_not_void: an_operand_one /= Void
			operand_2_not_void: an_operand_two /= Void
			value_comparison_operator: is_value_comparison_operator (a_token)
		do
			make_binary_expression (an_operand_one, a_token, an_operand_two)
			create atomic_comparer.make (a_collator)
			initialized := True
		ensure
			static_properties_computed: are_static_properties_computed
			operator_set: operator = a_token
			operand_1_set: first_operand /= Void and then first_operand.same_expression (an_operand_one)
			operand_2_set: second_operand /= Void and then second_operand.same_expression (an_operand_two)
		end

feature -- Access

	item_type: XM_XPATH_ITEM_TYPE is
			-- Determine the data type of the expression, if possible
		do
			Result := type_factory.boolean_type
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

feature -- Optimization

	analyze (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Perform static analysis of `Current' and its subexpressions
		local
			an_atomic_type: XM_XPATH_SEQUENCE_TYPE
			a_role, another_role: XM_XPATH_ROLE_LOCATOR
			a_type, another_type: XM_XPATH_ATOMIC_TYPE
			a_type_checker: XM_XPATH_TYPE_CHECKER
			a_message: STRING
			a_primitive_type, another_primitive_type: INTEGER
			is_first_optional, is_second_optional: BOOLEAN
		do
			mark_unreplaced
			create a_type_checker
			first_operand.analyze (a_context)
			if first_operand.was_expression_replaced then set_first_operand (first_operand.replacement_expression) end
			if first_operand.is_error then set_last_error (first_operand.error_value) end
			if not is_error then
				second_operand.analyze (a_context)
				if second_operand.was_expression_replaced then set_second_operand (second_operand.replacement_expression) end
				if second_operand.is_error then set_last_error (second_operand.error_value)	end
			end
			if not is_error then
				create an_atomic_type.make (type_factory.any_atomic_type, Required_cardinality_optional)
				create a_role.make (Binary_expression_role, token_name (operator), 1, Xpath_errors_uri, "XPTY0004")
				a_type_checker.static_type_check (a_context, first_operand, an_atomic_type, False, a_role)
				if a_type_checker.is_static_type_check_error then
					set_last_error (a_type_checker.static_type_check_error)
				else
					set_first_operand (a_type_checker.checked_expression)
					create another_role.make (Binary_expression_role, token_name (operator), 2, Xpath_errors_uri, "XPTY0004")
					a_type_checker.static_type_check (a_context, second_operand, an_atomic_type, False, a_role)
					if a_type_checker.is_static_type_check_error then
						set_last_error (a_type_checker.static_type_check_error)
					else
						set_second_operand (a_type_checker.checked_expression)
						a_type := first_operand.item_type.atomized_item_type; a_primitive_type := a_type.primitive_type
						another_type := second_operand.item_type.atomized_item_type; another_primitive_type := another_type.primitive_type
						if a_primitive_type = Untyped_atomic_type_code then a_primitive_type := String_type_code end
						if another_primitive_type = Untyped_atomic_type_code then another_primitive_type := String_type_code end

						if not are_types_comparable (a_primitive_type, another_primitive_type) then
							is_first_optional := first_operand.cardinality_allows_zero
							is_second_optional := second_operand.cardinality_allows_zero
							if is_first_optional or else is_second_optional then
								warn_comparison_failure (a_context, is_first_optional, is_second_optional, a_type, another_type)
							else
								a_message := STRING_.appended_string (a_message, another_type.conventional_name)
								set_last_error_from_string (a_message, Xpath_errors_uri, "XPTY0004", Type_error)
							end
						end
						if not is_error then optimize (a_context) end
					end
				end
			end
			if not was_expression_replaced and then not is_error then
				evaluate_now
			end
		end

feature -- Evaluation

	calculate_effective_boolean_value (a_context: XM_XPATH_CONTEXT) is
			-- Effective boolean value
		local
			an_item, another_item: XM_XPATH_ITEM
			an_atomic_value, another_atomic_value: XM_XPATH_ATOMIC_VALUE
			a_comparison_checker: XM_XPATH_COMPARISON_CHECKER
		do
			first_operand.evaluate_item (a_context)
			an_item := first_operand.last_evaluated_item
			if an_item = Void then

				-- empty sequence

				create last_boolean_value.make (False)
			elseif an_item.is_error then
				create last_boolean_value.make (False)
				last_boolean_value.set_last_error (an_item.error_value)
			else
				second_operand.evaluate_item (a_context)
				another_item := second_operand.last_evaluated_item
				if another_item.is_error then
					create last_boolean_value.make (False)
					last_boolean_value.set_last_error (another_item.error_value)
				else
					if not an_item.is_atomic_value then
						create last_boolean_value.make (False)
						last_boolean_value.set_last_error_from_string ("Atomization failed for second operand of value comparison", Xpath_errors_uri, "XPTY0004", Type_error)
					elseif not another_item.is_atomic_value then
						create last_boolean_value.make (False)
						last_boolean_value.set_last_error_from_string ("Atomization failed for second operand of value comparison", Xpath_errors_uri, "XPTY0004", Type_error)
					else
						an_atomic_value := an_item.as_atomic_value
						if an_atomic_value.is_untyped_atomic then
							an_atomic_value := an_atomic_value.convert_to_type (type_factory.string_type)
						end
						another_atomic_value := another_item.as_atomic_value
						if another_atomic_value.is_untyped_atomic then
							another_atomic_value := another_atomic_value.convert_to_type (type_factory.string_type)
						end
						create a_comparison_checker
						a_comparison_checker.check_correct_value_relation (an_atomic_value, operator, atomic_comparer, another_atomic_value)
						if a_comparison_checker.is_comparison_type_error then
							create last_boolean_value.make (False)
							last_boolean_value.set_last_error (a_comparison_checker.last_type_error)
						elseif a_comparison_checker.last_check_result then
							create last_boolean_value.make (True)
						else
							create last_boolean_value.make (False)
						end
					end
				end
			end
		end

	evaluate_item (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate `Current' as a single item
		local
			an_atomic_value, another_atomic_value: XM_XPATH_ATOMIC_VALUE
			a_comparison_checker: XM_XPATH_COMPARISON_CHECKER
		do
			first_operand.evaluate_item (a_context)
			if first_operand.last_evaluated_item = Void then
				last_evaluated_item := Void
			elseif first_operand.last_evaluated_item.is_error then
				last_evaluated_item := first_operand.last_evaluated_item
			else
				check
					atomic_value: first_operand.last_evaluated_item.is_atomic_value
				end
				an_atomic_value := first_operand.last_evaluated_item.as_atomic_value
				if an_atomic_value.is_untyped_atomic then
					an_atomic_value := an_atomic_value.convert_to_type (type_factory.string_type)
				end				
				second_operand.evaluate_item (a_context)
				if second_operand.last_evaluated_item = Void then
					last_evaluated_item := Void
				elseif second_operand.last_evaluated_item.is_error then
					last_evaluated_item := second_operand.last_evaluated_item
				else
					check
						second_atomic_value: second_operand.last_evaluated_item.is_atomic_value
					end				
					another_atomic_value := second_operand.last_evaluated_item.as_atomic_value
					if another_atomic_value.is_untyped_atomic then
						another_atomic_value := another_atomic_value.convert_to_type (type_factory.string_type)
					end
					create a_comparison_checker
					a_comparison_checker.check_correct_value_relation (an_atomic_value, operator, atomic_comparer, another_atomic_value)
					if a_comparison_checker.is_comparison_type_error then
						create last_boolean_value.make (False)
						last_boolean_value.set_last_error (a_comparison_checker.last_type_error)
					elseif a_comparison_checker.last_check_result then
						create last_boolean_value.make (True)
					else
						create last_boolean_value.make (False)
					end
					last_evaluated_item := last_boolean_value
				end
			end
		end

feature {NONE} -- Implementation

	atomic_comparer: XM_XPATH_ATOMIC_COMPARER
			-- Comparer for atomic values

	is_zero (an_expression: XM_XPATH_EXPRESSION): BOOLEAN is
			-- Is `an_expression' a constant zero?
		require
			expression_not_void: an_expression /= Void
		local
			an_atomic_value: XM_XPATH_ATOMIC_VALUE
		do
			if an_expression.is_atomic_value then
				an_atomic_value := an_expression.as_atomic_value
				if an_atomic_value.is_integer_value then
					Result := an_atomic_value.as_integer_value.is_zero
				elseif an_atomic_value.is_convertible (type_factory.integer_type) then
					Result := an_atomic_value.convert_to_type (type_factory.integer_type).as_integer_value.is_zero
				end
			end
		end

	optimize (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Perform context-dependent optimizations.
		do
			optimize_count (a_context)
			if not was_expression_replaced then
				
				-- We haven't managed to optimize anything yet, so:
				
				if second_operand.is_count_function and then is_zero (first_operand) then
					optimize_count_second_operand (a_context, second_operand.as_count_function)
				else
					
					-- Optimise string-length(x) = 0, >0, !=0 etc.
					
					if first_operand.is_string_length_function and then is_zero (second_operand) then
						first_operand.as_string_length_function.set_test_for_zero
					else
						
						-- Optimise 0 = string-length(x), etc.
						
						if second_operand.is_string_length_function and then is_zero (first_operand) then
							second_operand.as_string_length_function.set_test_for_zero
						end
					end
					optimize_position (a_context)
					if not was_expression_replaced then
						optimize_last (a_context)
						if not was_expression_replaced then

							-- We haven't managed to optimize anything yet, so:

							optimize_generate_id (a_context)
						end
					end
				end
			end
		end

	optimize_generate_id (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Optimize generate-id(X) eq generate-id(Y) as "X is Y".
			-- This construct is often used in XSLT 1.0 stylesheets.
			-- Only do this if we know the arguments are singletons, because "is" doesn't
			-- do first-value extraction.
		local
			a_function, another_function: XM_XPATH_SYSTEM_FUNCTION
			an_identity_comparison: XM_XPATH_IDENTITY_COMPARISON
			an_expression: XM_XPATH_EXPRESSION
		do
			if operator = Fortran_equal_token then
				if first_operand.is_generate_id_function and then second_operand.is_generate_id_function then
					a_function := first_operand.as_system_function;	another_function := second_operand.as_system_function
					if a_function.supplied_argument_count = 1 and then another_function.supplied_argument_count = 1
						and then not a_function.arguments.item (1).cardinality_allows_many
						and then not another_function.arguments.item (1).cardinality_allows_many then
						create an_identity_comparison.make (a_function.arguments.item (1), Is_token, another_function.arguments.item (1))
						an_identity_comparison.set_generate_id_emulation
						an_identity_comparison.simplify
						if an_identity_comparison.was_expression_replaced then
							an_expression := an_identity_comparison.replacement_expression
						else
							an_expression := an_identity_comparison
						end
						an_expression.analyze (a_context)
						if an_expression.was_expression_replaced then
							an_expression := an_expression.replacement_expression
						end
						set_replacement (an_expression)
					end
				end
			end
		end									

	optimize_count (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Optimise count(x) eq 0 (or gt 0, ne 0, eq 0, etc).
		local
			a_count_function: XM_XPATH_COUNT
			an_integer_value: XM_XPATH_INTEGER_VALUE
			new_arguments: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION]
			an_integer: MA_DECIMAL
			a_filter_expression: XM_XPATH_FILTER_EXPRESSION
			an_expression: XM_XPATH_EXPRESSION
			a_function_library: XM_XPATH_FUNCTION_LIBRARY
		do
			if first_operand.is_count_function and then second_operand.is_atomic_value then
				a_count_function := first_operand.as_count_function
				if a_count_function.arguments.count = 1 then
					a_function_library := a_context.available_functions
					if is_zero (second_operand.as_atomic_value) then
						if operator = Fortran_equal_token or else operator = Fortran_less_equal_token then
							
							-- Rewrite count(x)=0 as empty(x).
							
							a_function_library.bind_function (Empty_function_type_code, a_count_function.arguments, False)
							an_expression := a_function_library.last_bound_function.as_empty_function
						elseif operator = Fortran_not_equal_token or else operator = Fortran_greater_than_token then
							
							-- Rewrite count(x)!=0, count(x)>0 as exists(x)
							
							a_function_library.bind_function (Exists_function_type_code, a_count_function.arguments, False)
							an_expression := a_function_library.last_bound_function.as_exists_function
						elseif operator = Fortran_greater_equal_token then
							
							-- Rewrite count(x)>=0 as true()
							
							create {XM_XPATH_BOOLEAN_VALUE} an_expression.make (True)
						else
							check
								less_then_or_equal_to: operator = Fortran_less_equal_token
							end
							
							-- Rewrite count(x)<0 as false()
							
							create {XM_XPATH_BOOLEAN_VALUE} an_expression.make (False)
							
						end
					else
						if second_operand.is_integer_value and then (operator = Fortran_greater_than_token or else operator = Fortran_greater_equal_token) then
							
							-- Rewrite count(x) gt n as exists(x[n+1])
							--  and count(x) ge n as exists(x[n])
							
							an_integer := second_operand.as_integer_value.value
							if operator = Fortran_greater_than_token then an_integer := an_integer + one	end
							create new_arguments.make (1)
							create an_integer_value.make (an_integer)
							create a_filter_expression.make (a_count_function.arguments.item(1), an_integer_value)
							new_arguments.put (a_filter_expression, 1)
							a_function_library.bind_function (Exists_function_type_code, new_arguments, False)
							an_expression := a_function_library.last_bound_function.as_exists_function
							
						end
					end
					if an_expression /= Void then set_replacement (an_expression) end
				end
			end
		end			

	optimize_count_second_operand (a_context: XM_XPATH_STATIC_CONTEXT; a_count_function: XM_XPATH_COUNT) is
			-- Optimise (0 eq count(x)), etc. by inversion
		local
			an_expression: XM_XPATH_EXPRESSION
		do		
			create {XM_XPATH_VALUE_COMPARISON} an_expression.make (a_count_function, inverse_operator (operator), first_operand, atomic_comparer.collator)
			an_expression.analyze (a_context)
			if an_expression.was_expression_replaced then
				set_replacement (an_expression.replacement_expression)
			else
				set_replacement (an_expression)
			end
		end


	optimize_position (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Optimise position() < n etc.
		local
			an_integer: MA_DECIMAL
			an_expression: XM_XPATH_EXPRESSION
		do
			if first_operand.is_position_function and then second_operand.is_integer_value then
				an_integer := second_operand.as_integer_value.value
				if an_integer.is_negative then an_integer := zero end
				if an_integer <= Maximum_integer_as_decimal then
					inspect
						operator
					when Fortran_equal_token then
						create {XM_XPATH_POSITION_RANGE} an_expression.make (an_integer.to_integer, an_integer.to_integer)
					when Fortran_greater_equal_token then
						create {XM_XPATH_POSITION_RANGE} an_expression.make (an_integer.to_integer, Platform.Maximum_integer)
					when Fortran_not_equal_token then
						if an_integer.to_integer = 1 then
							create {XM_XPATH_POSITION_RANGE} an_expression.make (2, Platform.Maximum_integer)
						end
					when Fortran_less_than_token then
						create {XM_XPATH_POSITION_RANGE} an_expression.make (1, an_integer.to_integer - 1)
					when Fortran_greater_than_token then
						create {XM_XPATH_POSITION_RANGE} an_expression.make (an_integer.to_integer + 1, Platform.Maximum_integer)
					when Fortran_less_equal_token then
						create {XM_XPATH_POSITION_RANGE} an_expression.make (1, an_integer.to_integer)													
					end
					set_replacement (an_expression)
				end
			elseif second_operand.is_position_function and then first_operand.is_integer_value then
				an_integer := first_operand.as_integer_value.value
				if an_integer.is_negative then an_integer := zero end
				if an_integer <= Maximum_integer_as_decimal then
					inspect
						operator
					when Fortran_equal_token then
						create {XM_XPATH_POSITION_RANGE} an_expression.make (an_integer.to_integer, an_integer.to_integer)
					when Fortran_less_equal_token then
						create {XM_XPATH_POSITION_RANGE} an_expression.make (an_integer.to_integer, Platform.Maximum_integer)
					when Fortran_not_equal_token then
						if an_integer.to_integer = 1 then
							create {XM_XPATH_POSITION_RANGE} an_expression.make (2, Platform.Maximum_integer)
						end
					when Fortran_greater_than_token then
						create {XM_XPATH_POSITION_RANGE} an_expression.make (1, an_integer.to_integer - 1)
					when Fortran_less_than_token then
						create {XM_XPATH_POSITION_RANGE} an_expression.make (an_integer.to_integer + 1, Platform.Maximum_integer)
					when Fortran_greater_equal_token then
						create {XM_XPATH_POSITION_RANGE} an_expression.make (1, an_integer.to_integer)													
					end
					set_replacement (an_expression)
				end
			end
		end

	optimize_last (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Optimize position()=last(), last()=position(), etc.
		local
			an_expression: XM_XPATH_EXPRESSION
		do
			if first_operand.is_position_function and then second_operand.is_last_function then
				
				-- Optimise position()=last() etc.
				
				inspect
					operator
				when Fortran_equal_token, Fortran_greater_equal_token then
					create {XM_XPATH_IS_LAST_EXPRESSION} an_expression.make (True)
				when Fortran_not_equal_token, Fortran_less_than_token then
					create {XM_XPATH_IS_LAST_EXPRESSION} an_expression.make (False)
				when Fortran_greater_than_token then
					create {XM_XPATH_BOOLEAN_VALUE} an_expression.make (False)
				when Fortran_less_equal_token then
					create {XM_XPATH_BOOLEAN_VALUE} an_expression.make (True)													
				end
				set_replacement (an_expression)
			end
			
			if not was_expression_replaced then
				if second_operand.is_position_function and then first_operand.is_last_function then
					
					-- Optimise last()=position() etc.
					
					inspect
						operator
					when Fortran_equal_token, Fortran_less_equal_token then
						create {XM_XPATH_IS_LAST_EXPRESSION} an_expression.make (True)
					when Fortran_not_equal_token, Fortran_greater_than_token then
						create {XM_XPATH_IS_LAST_EXPRESSION} an_expression.make (False)
					when Fortran_less_than_token then
						create {XM_XPATH_BOOLEAN_VALUE} an_expression.make (False)
					when Fortran_greater_equal_token then
						create {XM_XPATH_BOOLEAN_VALUE} an_expression.make (True)													
					end
					set_replacement (an_expression)
				end
			end
		end

	evaluate_now is
			-- Evaluate the expression now if both arguments are constant.
		local
			an_invalid_value: XM_XPATH_INVALID_VALUE
		do
			if first_operand.is_value and then second_operand.is_value then
				evaluate_item (Void)
				check
					empty_sequence_not_possible: last_evaluated_item /= Void
					-- boolean comparison
				end
				if last_evaluated_item.is_error then
					create an_invalid_value.make (last_evaluated_item.error_value)
					set_replacement (an_invalid_value)
				else
					set_replacement (last_evaluated_item.as_boolean_value)
				end
			end
		end

	warn_comparison_failure (a_context: XM_XPATH_STATIC_CONTEXT;
									 is_first_optional, is_second_optional: BOOLEAN;
									 a_type, another_type: XM_XPATH_ATOMIC_TYPE) is
			-- Warn of probable comparison failure.
		require
			context_not_void: a_context /= Void
			first_type_not_void: a_type /= Void
			second_type_not_void: another_type /= Void
		local
			a_message: STRING
		do
			
			-- This is a comparison such as (xs:integer? eq xs:date?).
			-- This is almost certainly an error, but we need to let it through
			--  because it will work if one of the operands is an empty sequence.
			
			a_message := STRING_.concat ("Comparison of ", a_type.conventional_name)
			if is_first_optional then
				a_message := STRING_.appended_string (a_message, "?")
			end
			a_message := STRING_.appended_string (a_message, " with ")
			a_message := STRING_.appended_string (a_message, another_type.conventional_name)
			if is_second_optional then
				a_message := STRING_.appended_string (a_message, "?")
			end
			a_message := STRING_.appended_string (a_message, " will fail unless ")
			if is_first_optional and then is_second_optional then
				a_message := STRING_.appended_string (a_message, "one or both operands are")
			elseif is_first_optional then
				a_message := STRING_.appended_string (a_message, "the first operand is")
			else
				a_message := STRING_.appended_string (a_message, "the second operand is")
			end
			a_message := STRING_.appended_string (a_message, " empty.")
			a_context.issue_warning (a_message)
		end

end
	
