indexing

	description:

		"XPath Expressions that test whether a position() is within a certain range"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_POSITION_RANGE

inherit

	XM_XPATH_COMPUTED_EXPRESSION
		redefine
			compute_intrinsic_dependencies, evaluate_item
		end

creation

	make

feature {NONE} -- Initialization

	make (an_integer, another_integer: INTEGER) is
			-- Establish invariant.
		require
			strictly_positive_lower_bound: an_integer > 0
			valid_upper_bound: another_integer >= an_integer
		do
			minimum_position := an_integer
			maximum_position := another_integer
			compute_static_properties
			initialize
		ensure
			static_properties_computed: are_static_properties_computed
			minumum_set: minimum_position = an_integer
			maxumum_set: maximum_position = another_integer
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

	minimum_position: INTEGER
			-- Minimum position

	maximum_position: INTEGER
			-- Maximum position

feature -- Status report

	display (level: INTEGER) is
			-- Diagnostic print of expression structure to `std.error'
		local
			a_string: STRING
		do
			a_string := STRING_.appended_string (indentation (level), "positionRange(")
			a_string := STRING_.appended_string (a_string, minimum_position.out)
			a_string := STRING_.appended_string (a_string, ",")
			a_string := STRING_.appended_string (a_string, maximum_position.out)
			a_string := STRING_.appended_string (a_string, ")")
			std.error.put_string (a_string)
			if is_error then
				std.error.put_string (" in error%N")
			else
				std.error.put_new_line
			end
		end

feature -- Status setting

	compute_intrinsic_dependencies is
			-- Determine the intrinsic dependencies of an expression.
		do
			set_intrinsically_depends_upon_position			
		end

feature -- Optimization

	analyze (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Perform static analysis of `Current' and its subexpressions
		do
			mark_unreplaced
		end

feature -- Evaluation

	evaluate_item (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate `Current' as a single item
		local
			p: INTEGER
		do
			p := a_context.context_position
			create {XM_XPATH_BOOLEAN_VALUE} last_evaluated_item.make (p >= minimum_position and then p <= maximum_position)	
		end

feature {NONE} -- Implementation
	
	compute_cardinality is
			-- Compute cardinality.
		do
			set_cardinality_exactly_one
		end

invariant

	minimum_position: minimum_position > 0
	proper_range: maximum_position >= minimum_position 

end
