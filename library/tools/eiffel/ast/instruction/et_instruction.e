indexing

	description:

		"Eiffel instructions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_INSTRUCTION

inherit

	ET_AST_NODE

feature -- Initialization

	reset is
			-- Reset instruction as it was when it was first parsed.
		do
		end

feature -- Status report

	is_semicolon: BOOLEAN is
			-- Is current node a semicolon?
		do
			-- Result := False
		end

end
