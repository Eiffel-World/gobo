indexing

	description:

		"Eiffel external routines"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_EXTERNAL_ROUTINE

inherit

	ET_ROUTINE

feature -- Access

	language: ET_EXTERNAL_LANGUAGE
			-- External language

	alias_clause: ET_EXTERNAL_ALIAS
			-- Alias clause

feature -- Built-in

	is_builtin: BOOLEAN is
			-- Is current feature built-in?
		do
			Result := (builtin_code /= tokens.builtin_not_builtin)
		end

	builtin_code: INTEGER
			-- Built-in feature code

	set_builtin_code (a_code: INTEGER) is
			-- Set `builtin_code' to `a_code'.
		do
			builtin_code := a_code
		ensure
			builtin_code_set: builtin_code = a_code
		end

invariant

	language_not_void: language /= Void

end
