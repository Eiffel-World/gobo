indexing

	description:

		"Error: syntax error in regular expression given as command-line option"

	library: "Gobo Eiffel Test Library"
	copyright: "Copyright (c) 2000, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class TS_OPTION_REGEXP_SYNTAX_ERROR

inherit

	UT_ERROR

creation

	make

feature {NONE} -- Initialization

	make (an_option: STRING; a_regexp: STRING) is
			-- Create a new error reporting a syntax error
			-- in regular expression `a_regexp'.
		require
			an_option_not_void: an_option /= Void
			a_regexp_not_void: a_regexp /= Void
		do
			!! parameters.make (1, 2)
			parameters.put (an_option, 1)
			parameters.put (a_regexp, 2)
		end

feature -- Access

	default_template: STRING is "option %"$1%": syntax error in regular expression %"$2%""
			-- Default template used to built the error message

	code: STRING is "TS0003"
			-- Error code

invariant

	-- dollar0: $0 = program name
	-- dollar1: $1 = option name
	-- dollar2: $2 = regexp

end
