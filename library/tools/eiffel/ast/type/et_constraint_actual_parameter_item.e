indexing

	description:

		"Eiffel actual parameters which appear in a comma-separated list %
		%of types in constraints of formal generic parameters. %
		%The names of the types have not been resolved yet, they %
		%may be names of classes or of formal generic parameters."

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2003, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_CONSTRAINT_ACTUAL_PARAMETER_ITEM

feature -- Access

	actual_parameter: ET_CONSTRAINT_ACTUAL_PARAMETER is
			-- Actual parameter in comma-separated list
		deferred
		ensure
			actual_parameter_not_void: Result /= Void
		end

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		deferred
		ensure
			position_not_void: Result /= Void
		end

feature -- Conversion

	resolved_syntactical_constraint (a_formals: ET_FORMAL_PARAMETER_LIST;
		a_parser: ET_EIFFEL_PARSER_SKELETON): ET_ACTUAL_PARAMETER_ITEM is
			-- Version of current actual parameter, appearing in the constraint
			-- of one of the formal generic parameters in `a_formals', where
			-- class names and formal generic parameter names have been
			-- resolved (i.e. replaced by the corresponding Class_type,
			-- Tuple_type and Formal_parameter_type)
		require
			a_formals_not_void: a_formals /= Void
			a_parser_not_void: a_parser /= Void
		deferred
		end

end
