indexing

	description:

		"Decimal number parsers"

	library: "Gobo Eiffel Decimal Arithmetic Library"
	copyright: "Copyright (c) 2004, Paul G. Crismer and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"

deferred class MA_DECIMAL_PARSER

feature -- Access

	last_decimal: MA_DECIMAL
			-- Last decimal parsed

feature -- Status report

	error : BOOLEAN is
			-- Has an error occurred during the last call to `parse'?
		deferred
		end

feature -- Basic operations

	parse (a_string: STRING) is
			-- Parse `a_string'.
		require
			a_string_not_void: a_string /= Void
		deferred
		ensure
			last_decimal_not_void_when_no_error: not error implies last_decimal /= Void
		end

end
