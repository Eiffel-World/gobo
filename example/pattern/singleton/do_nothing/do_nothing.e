indexing

	description:

		"Use singleton which does nothing"

	library: "Gobo Eiffel Pattern Library"
	copyright: "Copyright (c) 2003, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class DO_NOTHING

inherit

	SHARED_NULL_SINGLETON

	KL_SHARED_STANDARD_FILES

creation

	make

feature {NONE} -- Initialization

	make is
			-- Use the singleton.
		do
			singleton.do_nothing
			std.output.put_line ("Used singleton")
			if singleton_created then
				std.output.put_line ("Singleton created")
			end
			singleton.do_nothing
			std.output.put_line ("Used singleton again")
		end

end
