indexing

	description:

		"Eiffel AST nodes"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002-2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_AST_NODE

inherit

	ET_SHARED_TOKEN_CONSTANTS

feature -- Access

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		deferred
		ensure
			position_not_void: Result /= Void
		end

	first_leaf: ET_AST_LEAF is
			-- First leaf node in current node
		deferred
		end

	last_leaf: ET_AST_LEAF is
			-- Last leaf node in current node
		deferred
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		deferred
		end

feature -- Status report

	has_break: BOOLEAN is
			-- Is there a break after current node?
		do
			Result := (break /= Void)
		ensure
			definition: Result = (break /= Void)
		end

	has_comment: BOOLEAN is
			-- Is there a comment after current node?
		local
			a_break: like break
		do
			a_break := break
			if a_break /= Void then
				Result := a_break.text.has ('-')
			end
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		require
			a_processor_not_void: a_processor /= Void
		deferred
		end

end
