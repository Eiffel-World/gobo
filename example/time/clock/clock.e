indexing

	description:

		"System clock example"

	copyright: "Copyright (c) 2001-2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class CLOCK

inherit

	DT_SHARED_SYSTEM_CLOCK
	KL_SHARED_STANDARD_FILES

creation

	execute

feature -- Execution

	execute is
			-- Print current date and time.
		do
			std.output.put_string ("Time Now: ")
			std.output.put_line (system_clock.time_now.precise_out)
			std.output.put_string ("Date Now: ")
			std.output.put_line (system_clock.date_now.out)
			std.output.put_string ("DateTime Now: ")
			std.output.put_line (system_clock.date_time_now.precise_out)
			std.output.put_string ("UTC Time Now: ")
			std.output.put_line (utc_system_clock.time_now.precise_out)
			std.output.put_string ("UTC Date Now: ")
			std.output.put_line (utc_system_clock.date_now.out)
			std.output.put_string ("UTC DateTime Now: ")
			std.output.put_line (utc_system_clock.date_time_now.precise_out)
		end

end
