indexing

	description:

		"Objects that format dates and times"

	library: "Gobo Eiffel Time Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class DT_DATE_TIME_FORMAT

inherit

	DT_DATE_TIME_PARSER

feature -- Conversion

	date_to_string (a_date: DT_DATE): STRING is
			-- Formatted date
		require
			date_not_void: a_date /= Void
		deferred
		ensure
			valid_date_string: is_date (Result)
		end

	zoned_date_to_string (a_date: DT_ZONED_DATE): STRING is
			-- Formatted date with time zone
		require
			zoned_date_not_void: a_date /= Void
		deferred
		ensure
			valid_zoned_date_string: is_zoned_date (Result)
		end

	date_time_to_string (a_date_time: DT_DATE_TIME): STRING is
			-- Formatted date-time
		require
			date_time_not_void: a_date_time /= Void
		deferred
		ensure
			valid_date_time_string: is_date_time (Result)
		end

	zoned_date_time_to_string (a_date_time: DT_ZONED_DATE_TIME): STRING is
			-- Formatted date-time with time zone
		require
			zoned_date_time_not_void: a_date_time /= Void
		deferred
		ensure
			valid_zoned_date_time_string: is_zoned_date_time (Result)
		end

	time_to_string (a_time: DT_TIME): STRING is
			-- Formatted time
		require
			time_not_void: a_time /= Void
		deferred
		ensure
			valid_time_string: is_time (Result)
		end

	zoned_time_to_string (a_time: DT_ZONED_TIME): STRING is
			-- Formatted time with time zone
		require
			zoned_time_not_void: a_time /= Void
		deferred
		ensure
			valid_zoned_time_string: is_zoned_time (Result)
		end

end
