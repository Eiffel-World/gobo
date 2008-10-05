indexing

	description:

		"Error: Default rule can be matched %
		%despite the nodefault or -s option"

	library: "Gobo Eiffel Lexical Library"
	copyright: "Copyright (c) 1999, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class LX_DEFAULT_RULE_CAN_BE_MATCHED_ERROR

inherit

	UT_ERROR

create

	make

feature {NONE} -- Initialization

	make (filename: STRING) is
			-- Create a new error reporting that the rule
			-- default can be matched despite the "nodefault"
			-- or -s option.
		require
			filename_not_void: filename /= Void
		do
			create parameters.make (1, 1)
			parameters.put (filename, 1)
		end

feature -- Access

	default_template: STRING is "Warning, %"$1%": nodefault or -s option given but default rule can be matched"
			-- Default template used to built the error message

	code: STRING is "LX0031"
			-- Error code

invariant

	-- dollar0: $0 = program name
	-- dollar1: $1 = filename

end
