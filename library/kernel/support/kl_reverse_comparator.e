indexing

	description:

		"Reverse total order comparators"

	library: "Gobo Eiffel Kernel Library"
	copyright: "Copyright (c) 2001-2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class KL_REVERSE_COMPARATOR [G]

inherit

	KL_REVERSE_PART_COMPARATOR [G]
		redefine
			comparator
		end

	KL_COMPARATOR [G]

creation

	make

feature -- Access

	comparator: KL_COMPARATOR [G]
			-- Base comparator

end
