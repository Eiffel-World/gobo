indexing

	description:

		"Feature comparators by name"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_FEATURE_COMPARATOR_BY_NAME

inherit

	KL_COMPARATOR [ET_FEATURE]

creation

	make

feature {NONE} -- Initialization

	make is
			-- Create a new comparator.
		do
		end

feature -- Status report

	less_than (u, v: ET_FEATURE): BOOLEAN is
			-- Is `u' considered less than `v'?
		do
			Result := u.name.name < v.name.name
		end

end