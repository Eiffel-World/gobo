indexing

	description:

		"Eiffel expressions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_EXPRESSION

inherit

	ET_EXPRESSION_ITEM
		rename
			expression as expression_item
		end

	ET_CONDITIONAL
		rename
			expression as expression_item
		end

	ET_ASSERTION
		rename
			expression as expression_item
		undefine
			reset
		end

	ET_ACTUAL_ARGUMENTS
		rename
			count as actual_argument_count,
			is_empty as is_empty_actual_argument
		end

	ET_TARGET

	ET_AGENT_ACTUAL_ARGUMENT

	ET_AGENT_TARGET
		undefine
			reset
		end

feature -- Access

	actual_argument (i: INTEGER): ET_EXPRESSION is
			-- Actual argument at index `i'
		do
			Result := Current
		ensure then
			definition: Result = Current
		end

	expression_item: ET_EXPRESSION is
			-- Current expression
		do
			Result := Current
		ensure then
			definition: Result = Current
		end

feature -- Measurement

	actual_argument_count: INTEGER is 1
			-- Number of actual arguments

end
