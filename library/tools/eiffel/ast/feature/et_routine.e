indexing

	description:

		"Eiffel routines"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_ROUTINE

inherit

	ET_FEATURE
		redefine
			arguments,
			preconditions,
			postconditions,
			reset_preconditions,
			reset_postconditions,
			obsolete_message
		end

feature -- Access

	arguments: ET_FORMAL_ARGUMENT_LIST
			-- Formal arguments

	is_keyword: ET_KEYWORD
			-- 'is' keyword

	obsolete_message: ET_OBSOLETE
			-- Obsolete message

	preconditions: ET_PRECONDITIONS
			-- Preconditions

	postconditions: ET_POSTCONDITIONS
			-- Postconditions

	end_keyword: ET_KEYWORD
			-- 'end' keyword

	last_leaf: ET_AST_LEAF is
			-- Last leaf node in current node
		do
			Result := end_keyword
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			Result := end_keyword.break
		end

feature -- Setting

	set_is_keyword (an_is: like is_keyword) is
			-- Set `is_keyword' to `an_is'.
		require
			an_is_not_void: an_is /= Void
		do
			is_keyword := an_is
		ensure
			is_keyword_set: is_keyword = an_is
		end

	set_end_keyword (an_end: like end_keyword) is
			-- Set `end_keyword' to `an_end'.
		require
			an_end_not_void: an_end /= Void
		do
			end_keyword := an_end
		ensure
			end_keyword_set: end_keyword = an_end
		end

	reset_preconditions is
			-- Set `preconditions' to Void.
		do
			preconditions := Void
		end

	reset_postconditions is
			-- Set `postconditions' to Void.
		do
			postconditions := Void
		end

invariant

	is_keyword_not_void: is_keyword /= Void
	end_keyword_not_void: end_keyword /= Void

end
