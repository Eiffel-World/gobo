indexing

	description:

		"EiffelBase CELL class interface"

	library: "Gobo Eiffel Structure Library"
	copyright: "Copyright (c) 1999-2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class CELL [G]

inherit

	DS_CELL [G]

creation

	put

feature -- Element change

	replace (v: G) is
			-- Insert `v' in cell.
		do
			item := v
		ensure
			inserted: item = v
		end

end
