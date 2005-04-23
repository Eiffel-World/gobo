indexing

	description:

		"XPath Filter Expressions"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_FILTER_EXPRESSION

inherit

	XM_XPATH_COMPUTED_EXPRESSION
		redefine
			compute_dependencies, compute_special_properties, simplify, promote, sub_expressions,
			same_expression, create_iterator, is_repeated_sub_expression, is_filter_expression,
			as_filter_expression
		end

	XM_XPATH_TOKENS

	XM_XPATH_SHARED_EXPRESSION_FACTORY
	
	XM_XPATH_NAME_UTILITIES

	KL_SHARED_PLATFORM

creation

	make

feature {NONE} -- Initialization

	make (a_start: XM_XPATH_EXPRESSION; a_filter: XM_XPATH_EXPRESSION) is
			-- Establish invariant.
		require
			start_not_void: a_start /= Void
			filter_not_void: a_filter /= Void
		local
			are_void: BOOLEAN
		do
			base_expression := a_start
			filter := a_filter

			-- the reason we simplify the filter 
			-- is to ensure that functions like name() are expanded to use the
			-- context node as an implicit argument, before checking its dependencies.

			filter.simplify
			if filter.is_error then
				set_replacement (filter)
			else
				if filter.was_expression_replaced then
					set_filter (filter.replacement_expression)
				end
				if not filter.are_dependencies_computed and then filter.is_computed_expression then
					filter.as_computed_expression.compute_dependencies
				end
				filter_dependencies := filter.dependencies
			end
			compute_static_properties
			adopt_child_expression (base_expression)
			adopt_child_expression (filter)
			initialized := True
		ensure
			static_properties_computed: are_static_properties_computed
			base_expression_set: base_expression = a_start
		end

feature -- Access
	
	item_type: XM_XPATH_ITEM_TYPE is
			--Determine the data type of the expression, if possible
		do
			Result := base_expression.item_type
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

	filter: XM_XPATH_EXPRESSION
			-- Filter

	base_expression: XM_XPATH_EXPRESSION
			-- Base expression

	is_filter_expression: BOOLEAN is
			-- Is `Current' a filter expression?
		do
			Result := True
		end

	as_filter_expression: XM_XPATH_FILTER_EXPRESSION is
			-- `Current' seen as a filter expression
		do
			Result := Current
		end

	sub_expressions: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION] is
			-- Immediate sub-expressions of `Current'
		do
			create Result.make (2)
			Result.set_equality_tester (expression_tester)
			Result.put (base_expression, 1)
			Result.put (filter, 2)
		end

	
	is_repeated_sub_expression (a_child: XM_XPATH_EXPRESSION): BOOLEAN is
			-- Is `a_child' a repeatedly-evaluated sub-expression?
		do
			Result := a_child = filter
		end

feature -- Comparison

	same_expression (other: XM_XPATH_EXPRESSION): BOOLEAN is
			-- Are `Current' and `other' the same expression?
		local
			a_filter: XM_XPATH_FILTER_EXPRESSION
		do
			if other.is_filter_expression then
				a_filter := other.as_filter_expression
				Result := base_expression.same_expression (a_filter.base_expression)
					and then filter.same_expression (a_filter.filter)
			end
		end

feature -- Status report

	is_positional: BOOLEAN is
			-- Is `Current' a positional filter?
		do
			Result := is_positional_filter (filter)
		end

	display (a_level: INTEGER) is
			-- Diagnostic print of expression structure to `std.error'
		local
			a_string: STRING
		do
			a_string := STRING_.appended_string (indentation (a_level), "filter []")
			std.error.put_string (a_string)
			if is_error then
				std.error.put_string (" in error%N")
			else
				std.error.put_new_line
				base_expression.display (a_level + 1)
				filter.display (a_level + 1)
			end
		end


feature -- Status setting

	compute_dependencies is
			-- Compute dependencies on context.
		do
			if not are_intrinsic_dependencies_computed then compute_intrinsic_dependencies end

			if not base_expression.are_dependencies_computed then
				if base_expression.is_computed_expression then
					base_expression.as_computed_expression.compute_dependencies
				end
			end
			set_dependencies (base_expression.dependencies)

			-- If filter depends upon XSLT context then so does `Current'.
			-- (not all dependencies in the filter expression matter, because the context node,
			-- position, and size are not dependent on the outer context.)

			if filter_dependencies.item (1) then
				set_depends_upon_current_item
			end
			if filter_dependencies.item (6) then
				set_depends_upon_current_group
			end
			if filter_dependencies.item (7) then
				set_depends_upon_regexp_group
			end
			are_dependencies_computed := True
		end

feature -- Optimization

	simplify is
			-- Perform context-independent static optimizations
		local
			an_empty_sequence: XM_XPATH_EMPTY_SEQUENCE
			a_boolean_value: XM_XPATH_BOOLEAN_VALUE
			an_is_last_expression: XM_XPATH_IS_LAST_EXPRESSION
		do
			base_expression.simplify
			if base_expression.is_error then
				set_last_error (base_expression.error_value)
			else
				if base_expression.was_expression_replaced then
					set_base_expression (base_expression.replacement_expression)
				end
				filter.simplify
				if filter.is_error then
					set_last_error (filter.error_value)
				else
					if filter.was_expression_replaced then
						set_filter (filter.replacement_expression)
					end

					-- Ignore the filter if `base_expression' is an empty sequence.
					
					if base_expression.is_empty_sequence then
						set_replacement (base_expression.as_empty_sequence)
					else
						
						-- Check whether the filter is a constant true() or false().
						
						if filter.is_value and then not filter.is_numeric_value then
							filter.calculate_effective_boolean_value (Void)
							a_boolean_value := filter.last_boolean_value
							if a_boolean_value.is_error then
								set_last_error (a_boolean_value.error_value)
							elseif  a_boolean_value.value then
								set_replacement (base_expression)
							else
								create an_empty_sequence.make
								set_replacement (an_empty_sequence)
							end
						else
							
							-- Check whether the filter is [last()].
							-- (note, position()=last() is handled during analysis)
							
							if filter.is_last_function then
								create an_is_last_expression.make (True)
								set_filter (an_is_last_expression)
							end
						end
					end
				end
			end
		end

	analyze (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Perform static analysis of an expression and its subexpressions
		do
			mark_unreplaced
			base_expression.analyze (a_context)
			if base_expression.was_expression_replaced then
				set_base_expression (base_expression.replacement_expression)
			end
			if base_expression.is_error then
				set_last_error (base_expression.error_value)
			else
				filter.analyze (a_context)
				if filter.was_expression_replaced then
					set_filter (filter.replacement_expression)
				end

				if filter.is_error then
					set_last_error (filter.error_value)
				else
					optimize (a_context)
				end
			end
		end

	promote (an_offer: XM_XPATH_PROMOTION_OFFER) is
			-- Promote this subexpression.
		local
			a_promotion: XM_XPATH_EXPRESSION
		do
			an_offer.accept (Current)
			a_promotion := an_offer.accepted_expression
			if a_promotion /= Void then
				set_replacement (a_promotion)
			else
				if not (an_offer.action = Unordered and then filter_is_positional) then
					base_expression.promote (an_offer)
					if base_expression.was_expression_replaced then set_base_expression (base_expression.replacement_expression) end
				end
				if an_offer.action = Inline_variable_references then

					-- Don't pass on other requests. We could pass them on, but only after augmenting
					--  them to say we are interested in subexpressions that don't depend on either the
					--  outer context or the inner context.

					filter.promote (an_offer)
					if filter.was_expression_replaced then set_filter (filter.replacement_expression) end
				end
			end
		end	

feature -- Evaluation

	create_iterator (a_context: XM_XPATH_CONTEXT) is
			-- Iterate over the values of a sequence
		local
			a_number: XM_XPATH_NUMERIC_VALUE
			a_position: INTEGER
			finished: BOOLEAN
			a_position_range: XM_XPATH_POSITION_RANGE
			a_base_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]
		do

			-- Fast path where both operands are constants

			if base_expression.is_sequence_value and then filter.is_integer_value
				and then filter.as_integer_value.is_platform_integer then
				a_position := filter.as_integer_value.as_integer
				create {XM_XPATH_SINGLETON_ITERATOR [XM_XPATH_ITEM]} last_iterator.make (base_expression.as_sequence_value.item (a_position))
			else
				
				-- Get an iterator over the base nodes

				base_expression.create_iterator (a_context)
				a_base_iterator := base_expression.last_iterator

				-- Quick exit for an empty sequence

				if  a_base_iterator.is_error then
					last_iterator := a_base_iterator
				else
					if a_base_iterator.is_empty_iterator then
						create {XM_XPATH_EMPTY_ITERATOR} last_iterator.make
					else
						
						-- Test whether the filter is a constant value
						
						if filter.is_value then
							finished := True
							if filter.is_numeric_value then a_number := filter.as_numeric_value end
							create_constant_value_iterator (a_number, a_base_iterator, a_context)
						end
						
						-- Construct the FilterIterator to do the actual filtering
						
						if not finished then
							
							-- Test whether the filter is a position range, e.g. [position()>$x]
							-- TODO: handle all such cases with a TailExpression

							if filter.is_position_range then
								a_position_range := filter.as_position_range
								if a_base_iterator.is_node_iterator then
									last_iterator := expression_factory.created_node_position_iterator (a_base_iterator.as_node_iterator, a_position_range.minimum_position, a_position_range.maximum_position)
								else
									last_iterator := expression_factory.created_item_position_iterator (a_base_iterator, a_position_range.minimum_position, a_position_range.maximum_position)
								end
							else
								if filter_is_positional then
									if a_base_iterator.is_node_iterator then
										create {XM_XPATH_NODE_FILTER_ITERATOR} last_iterator.make (a_base_iterator.as_node_iterator, filter, a_context)
									else
										create {XM_XPATH_FILTER_ITERATOR} last_iterator.make (a_base_iterator, filter, a_context)
									end
								else
									if a_base_iterator.is_node_iterator then
										create {XM_XPATH_NODE_FILTER_ITERATOR} last_iterator.make_non_numeric (a_base_iterator.as_node_iterator, filter, a_context)
									else
										create {XM_XPATH_FILTER_ITERATOR} last_iterator.make_non_numeric (a_base_iterator, filter, a_context)
									end			
								end
							end
						end
					end
				end
			end
		end
	
feature -- Element change

	set_base_expression (a_base_expression: XM_XPATH_EXPRESSION) is
			-- Set `base_expression.
		require
			base_expression_not_void: a_base_expression /= Void
		do
			base_expression := a_base_expression
			base_expression.mark_unreplaced
			adopt_child_expression (base_expression)
		ensure
			base_expression_set: base_expression = a_base_expression
			base_expression_not_marked_for_replacement: not base_expression.was_expression_replaced
		end

	set_filter (a_filter: XM_XPATH_EXPRESSION) is
			-- Set `filter'.
		require
			filter_not_void: a_filter /= Void
		do
			filter := a_filter
			filter.mark_unreplaced
			adopt_child_expression (filter)
		ensure
			filter_set: filter = a_filter
			filter_not_marked_for_replacement: not filter.was_expression_replaced
		end

feature {NONE} -- Implementation
	
	compute_cardinality is
			-- Compute cardinality.
		local
			a_position_range: XM_XPATH_POSITION_RANGE
		do
			if filter.is_numeric_value then
				set_cardinality_optional
			elseif not base_expression.cardinality_allows_many then
				set_cardinality_optional
			else
				if filter.is_position_range then
					a_position_range := filter.as_position_range
					if a_position_range.minimum_position = a_position_range.maximum_position then
						set_cardinality_optional
					end
				end
			end
			if not are_cardinalities_computed then
				if filter.is_last_expression then
					set_cardinality_optional
				elseif base_expression.cardinality_allows_one_or_more then
					set_cardinality_zero_or_more
				elseif base_expression.cardinality_exactly_one then
					set_cardinality_optional
				else
					set_cardinality (base_expression.cardinality)
				end
			end
		end

	filter_is_positional: BOOLEAN
			-- `True' if the value of the filter might depend on the context position

	filter_dependencies: ARRAY [BOOLEAN]
			-- Dependencies of the original (but simplifed) filter

	is_positional_filter (an_expression: XM_XPATH_EXPRESSION): BOOLEAN is
			-- Is `an_expression', when used as a filter, positional?
		require
			expression_not_void: an_expression /= Void
		local
			type: XM_XPATH_ITEM_TYPE
		do
			type := an_expression.item_type
			Result := type = type_factory.any_atomic_type or else type = any_item
				or else is_sub_type (type, type_factory.numeric_type)
				or else is_explicitly_positional_filter (an_expression)
		end

	is_explicitly_positional_filter (an_expression: XM_XPATH_EXPRESSION): BOOLEAN is
			-- Is `an_expression', explicitly dependant on position() or last()?
		require
			expression_not_void: an_expression /= Void
		do
			Result := an_expression.depends_upon_position
				or else an_expression.depends_upon_last
		end

	force_to_boolean (an_expression: XM_XPATH_EXPRESSION; a_context: XM_XPATH_STATIC_CONTEXT): XM_XPATH_EXPRESSION is
			-- A warpping of the boolean() function around `an_expression'.
		require
			expression_not_void: an_expression /= Void
			static_context_not_void: a_context /= Void
		local
			a_function_library: XM_XPATH_FUNCTION_LIBRARY
			args: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION]
		do
			create args.make (1)
			args.put (an_expression, 1)
			a_function_library := a_context.available_functions
			a_function_library.bind_function (Boolean_function_type_code, args, False)
			Result := a_function_library.last_bound_function
		end
	
	compute_special_properties is
			-- Compute special properties.
		do
			set_special_properties (base_expression.special_properties)
		end

	
	create_constant_value_iterator (a_number: XM_XPATH_NUMERIC_VALUE; a_base_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM];
											  a_context: XM_XPATH_CONTEXT) is
			-- Create an iterator over a constant numeric value
		require
			base_iterator_not_void: a_base_iterator /= void
		local
			a_position: INTEGER
			a_boolean_value: XM_XPATH_BOOLEAN_VALUE
		do
			if a_number /= Void then
				if a_number.is_platform_integer then
					a_position := a_number.as_integer
					if a_position >= 1 then
						if a_base_iterator.is_node_iterator then
							last_iterator := expression_factory.created_node_position_iterator (a_base_iterator.as_node_iterator, a_position, a_position)
						else
							last_iterator := expression_factory.created_item_position_iterator (a_base_iterator, a_position, a_position)
						end
					else
					
						-- Index is less than one, no items will be selected
					
						create {XM_XPATH_EMPTY_ITERATOR} last_iterator.make
					end
				else
					
					-- A non-integer value will never be equal to position()
					
					create {XM_XPATH_EMPTY_ITERATOR} last_iterator.make
				end
			else
				
				-- Filter is a constant that we can treat as boolean

				filter.calculate_effective_boolean_value (a_context)
				a_boolean_value := filter.last_boolean_value
				if a_boolean_value.is_error then
					create {XM_XPATH_INVALID_ITERATOR} last_iterator.make (a_boolean_value.error_value)
				elseif a_boolean_value.value then
					last_iterator := a_base_iterator
				else
					create {XM_XPATH_EMPTY_ITERATOR} last_iterator.make
				end
			end
		end

	optimize (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Optimize `Current'
		local
			a_position_range: XM_XPATH_POSITION_RANGE
			a_min, a_max: INTEGER
			an_expression: XM_XPATH_EXPRESSION
		do
						
			--	The filter expression usually need not be sorted.
			
			filter.set_unsorted_if_homogeneous (False)
						
			-- Detect head expressions (E[1]) and tail expressions (E[position()!=1])
			-- and treat them specially.

			if filter.is_integer_value and then filter.as_integer_value.is_platform_integer
				and then filter.as_integer_value.as_integer = 1 then
				create {XM_XPATH_FIRST_ITEM_EXPRESSION} an_expression.make (base_expression)
				set_replacement (an_expression)
			else
				if filter.is_position_range then
					a_position_range := filter.as_position_range
					a_min := a_position_range.minimum_position
					a_max := a_position_range.maximum_position
					if a_min = 1 and then a_max = 1 then
						create {XM_XPATH_FIRST_ITEM_EXPRESSION} an_expression.make (base_expression)
						set_replacement (an_expression)
					elseif a_max = Platform.Maximum_integer then
						create {XM_XPATH_TAIL_EXPRESSION} an_expression.make (base_expression, a_min)
						set_replacement (an_expression)
					end
				end
				if not was_expression_replaced then
					optimize_positional_filter (a_context)
				end
				if not was_expression_replaced then
					promote_sub_expressions (a_context)
				end
			end
		end

	optimize_positional_filter (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Determine whether the filter might depend on position.
		local
			another_expression, a_third_expression: XM_XPATH_EXPRESSION
			a_filter, another_filter: XM_XPATH_FILTER_EXPRESSION
			a_boolean_filter: XM_XPATH_BOOLEAN_EXPRESSION
		do
			filter_is_positional := is_positional_filter (filter)

			-- If the filter is positional, try changing f[a and b] to f[a][b] to increase
			-- the chances of finishing early.

			if filter_is_positional and then filter.is_boolean_expression then
				a_boolean_filter := filter.as_boolean_expression
				if a_boolean_filter.operator = And_token then
					if is_explicitly_positional_filter (a_boolean_filter.first_operand)
						and then not is_explicitly_positional_filter (a_boolean_filter.second_operand) then
						another_expression := force_to_boolean (a_boolean_filter.first_operand, a_context)
						a_third_expression := force_to_boolean (a_boolean_filter.second_operand, a_context)
						create a_filter.make (base_expression, another_expression)
						create another_filter.make (a_filter, a_third_expression)
						another_filter.analyze (a_context)
						if another_filter.was_expression_replaced then
							set_replacement (another_filter.replacement_expression)
						else
							set_replacement (another_filter)
						end
					elseif is_explicitly_positional_filter (a_boolean_filter.second_operand)
						and then not is_explicitly_positional_filter (a_boolean_filter.first_operand) then
						another_expression := force_to_boolean (a_boolean_filter.first_operand, a_context)
						a_third_expression := force_to_boolean (a_boolean_filter.second_operand, a_context)
						create a_filter.make (base_expression, a_third_expression)
						create another_filter.make (a_filter, another_expression)
						another_filter.analyze (a_context)
						if another_filter.was_expression_replaced then
							set_replacement (another_filter.replacement_expression)
						else
							set_replacement (another_filter)
						end
					end
				end
			end
		end

	promote_sub_expressions  (a_context: XM_XPATH_STATIC_CONTEXT) is				
			-- This causes them to be evaluated once, outside the path  expression.
		local
			an_offer: XM_XPATH_PROMOTION_OFFER
			a_let_expression: XM_XPATH_LET_EXPRESSION
		do
			create an_offer.make (Focus_independent, Void, Current, False, base_expression.context_document_nodeset)
			filter.promote (an_offer)
			if filter.was_expression_replaced then set_filter(filter.replacement_expression) end
			if an_offer.containing_expression.is_let_expression then
				a_let_expression := an_offer.containing_expression.as_let_expression
				a_let_expression.analyze (a_context)
				if a_let_expression.is_error then
					set_last_error (a_let_expression.error_value)
				elseif a_let_expression.was_expression_replaced then
					an_offer.set_containing_expression (a_let_expression.replacement_expression)
				end
			end
			if not is_error and then an_offer.containing_expression /= Current then
				set_replacement (an_offer.containing_expression)
			end
		end

invariant

	base_expression_not_void: base_expression /= Void
	filter_not_void: filter /= Void
	filter_dependencies_not_void: filter_dependencies /= Void

end
