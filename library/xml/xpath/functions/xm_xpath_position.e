indexing

	description:

		"Objects that mplement the XPath position() function"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_POSITION

inherit
	
	XM_XPATH_SYSTEM_FUNCTION
		redefine
			pre_evaluate, evaluate_item, compute_intrinsic_dependencies
		end

	creation

	make

feature {NONE} -- Initialization

	make is
			-- Establish invariant.
		do
			name := "position"
			minimum_argument_count := 0
			maximum_argument_count := 0
			create arguments.make (0)
			arguments.set_equality_tester (expression_tester)
			compute_static_properties
		end

feature -- Access

	item_type: XM_XPATH_ITEM_TYPE is
			-- Determine the data type of the expression, if possible
		do
			Result := type_factory.integer_type
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

feature -- Status report

	required_type (argument_number: INTEGER): XM_XPATH_SEQUENCE_TYPE is
			-- Type of argument number `argument_number'
		do
			-- This cannot be called for `Current', as it has no arguments.
			-- Therefore the pre-condition cannot be met, so we will not
			--  attempt to meet the post-condition.

			do_nothing
		end

feature -- Status setting

	compute_intrinsic_dependencies is
			-- Determine the intrinsic dependencies of an expression.
		do
			create intrinsic_dependencies.make (1, 6)
			-- Now all are `False'
			intrinsic_dependencies.put (True, 3) -- Depends_upon_position
			are_intrinsic_dependencies_computed := True
		end

feature -- Evaluation

	evaluate_item (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate as a single item
		local
			a_context_position: INTEGER
		do
			if a_context = Void then
				create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string ("Dynamic context is Void", "FONC0001", Dynamic_error)
			elseif not a_context.is_context_position_set then
				create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string ("Context position is not available",  "FONC0001", Dynamic_error)
			else
				a_context_position := a_context.context_position
				if a_context_position = 0 then
					create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string ("Context position cannot be zero", "FONC0001", Dynamic_error)
				else
					create {XM_XPATH_INTEGER_VALUE} last_evaluated_item.make_from_integer (a_context_position)
				end
			end
		ensure then
			possible_dynamic_error: last_evaluated_item.is_error implies
				last_evaluated_item.error_value.type = Dynamic_error
		end


	pre_evaluate (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Pre-evaluate `Current' at compile time.
			-- This forces pre-evaluation not to occur, as
			--  the value of `Current' depends upon the dynamic context.
		do
			do_nothing
		end
	
feature {XM_XPATH_EXPRESSION} -- Restricted

	compute_cardinality is
			-- Compute cardinality.
		do
			set_cardinality_exactly_one
		end
		
end

