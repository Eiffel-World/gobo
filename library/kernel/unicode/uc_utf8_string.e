indexing

	description:

		"Unicode strings with UTF-8 encoding"

	note:

		"Unless specified otherwise, STRING and CHARACTER are %
		%supposed to contain characters whose code follows the %
		%unicode character set. In other words characters whose %
		%code is between 128 and 255 should follow the ISO 8859-1 %
		%Latin-1 character set."

	library: "Gobo Eiffel Kernel Library"
	copyright: "Copyright (c) 2001-2002, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class UC_UTF8_STRING

inherit

	UC_STRING

creation

	make, make_empty, make_from_string, make_from_utf8,
	make_filled, make_filled_code, make_filled_unicode,
	make_from_substring, make_from_utf16

end
