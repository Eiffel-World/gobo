indexing

	description:

		"EiffelBase ARRAYED_LIST_CURSOR class interface"

	library: "Gobo Eiffel Structure Library"
	copyright: "Copyright (c) 1999, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ARRAYED_LIST_CURSOR

inherit

	CURSOR

create

	make

feature {NONE} -- Initialization

	make (p: INTEGER) is
			-- Set `position' to `p'.
		do
			position := p
		ensure
			position_set: position = p
		end

feature -- Access

	position: INTEGER
			-- Internal position in arrayed list

end
