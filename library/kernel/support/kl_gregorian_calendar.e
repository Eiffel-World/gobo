indexing

	description:

		"Gregorian calendar properties"

	library: "Gobo Eiffel Kernel Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class KL_GREGORIAN_CALENDAR

inherit

	ANY -- Needed for SE 2.1b1.

feature -- Year

	leap_year (y: INTEGER): BOOLEAN is
		-- Is `y' a leap year?
		do
			Result := (y \\ 4 = 0) and ((y \\ 100 /= 0) or (y \\ 400 = 0))
		end

	Months_in_year: INTEGER is 12
			-- Number of months in a year
--		ensure
--			definition: Result = (December - Januray + 1)

	Days_in_year: INTEGER is 365
	Days_in_leap_year: INTEGER is 366
			-- Number of days in a (leap) year

	Days_in_400_years: INTEGER is 146097
	Days_in_100_years: INTEGER is 36524
	Days_in_4_years: INTEGER is 1461
	Days_in_3_years: INTEGER is 1095
	Days_in_3_leap_years: INTEGER is 1096
	Days_in_2_years: INTEGER is 730
	Days_in_2_leap_years: INTEGER is 731
			-- Number of days in multiple years

feature -- Month

	January: INTEGER is 1
	February: INTEGER is 2
	March: INTEGER is 3
	April: INTEGER is 4
	May: INTEGER is 5
	June: INTEGER is 6
	July: INTEGER is 7
	August: INTEGER is 8
	September: INTEGER is 9
	October: INTEGER is 10
	November: INTEGER is 11
	December: INTEGER is 12
			-- Months

	days_in_month (m, y: INTEGER): INTEGER is
			-- Number of days in month `m' of year `y'
		require
			m_large_enough: m >= January
			m_small_enough: m <= December
		do
			inspect m
			when January, March, May, July, August, October, December then
				Result := 31
			when April, June, September, November then
				Result := 30
			when February then
				if leap_year (y) then
					Result := 29
				else
					Result := 28
				end
			end
		ensure
			at_least_one: Result >= 1
			max_days_in_month: Result <= Max_days_in_month
		end

	Max_days_in_month: INTEGER is 31
			-- Maximum number of days in a month

	days_at_month (m, y: INTEGER): INTEGER is
			-- Number of days from beginning of year
			-- `y' until beginning of month `m'
		require
			m_large_enough: m >= January
			m_small_enough: m <= December
		do
			inspect m
			when January then
				Result := 0
			when February then
				Result := 31
			when March then
				Result := 59
			when April then
				Result := 90
			when May then
				Result := 120
			when June then
				Result := 151
			when July then
				Result := 181
			when August then
				Result := 212
			when September then
				Result := 243
			when October then
				Result := 273
			when November then
				Result := 304
			when December then
				Result := 334
			end
			if m > February and then leap_year (y) then
				Result := Result + 1
			end
		ensure
			days_positive: Result >= 0
		end

feature -- Week day

	Sunday: INTEGER is 1
	Monday: INTEGER is 2
	Tuesday: INTEGER is 3
	Wednesday: INTEGER is 4
	Thursday: INTEGER is 5
	Friday: INTEGER is 6
	Saturday: INTEGER is 7
			-- All the above are obsolete - use DT_WEEK_DAY instead

	Days_in_week: INTEGER is 7
			-- Obsolete - use DT_WEEK_DAY instead
--		ensure
--			definition: Result = (Saturday - Sunday + 1)

	next_day (d: INTEGER): INTEGER is
			obsolete "{DT_WEEK_DAY}.next_day instead"
		require
			d_large_enough: d >= Sunday
			d_small_enough: d <= Saturday
		do
			if d = Saturday then
				Result := Sunday
			else
				Result := d + 1
			end
		ensure
			sunday_definition: (d = Sunday) implies (Result = Monday)
			monday_definition: (d = Monday) implies (Result = Tuesday)
			tuesday_definition: (d = Tuesday) implies (Result = Wednesday)
			wednesday_definition: (d = Wednesday) implies (Result = Thursday)
			thursday_definition: (d = Thursday) implies (Result = Friday)
			friday_definition: (d = Friday) implies (Result = Saturday)
			saturday_definition: (d = Saturday) implies (Result = Sunday)
		end

	previous_day (d: INTEGER): INTEGER is
		obsolete "{DT_WEEK_DAY}.previous_day instead"
		require
			d_large_enough: d >= Sunday
			d_small_enough: d <= Saturday
		do
			if d = Sunday then
				Result := Saturday
			else
				Result := d - 1
			end
		ensure
			sunday_definition: (d = Sunday) implies (Result = Saturday)
			monday_definition: (d = Monday) implies (Result = Sunday)
			tuesday_definition: (d = Tuesday) implies (Result = Monday)
			wednesday_definition: (d = Wednesday) implies (Result = Tuesday)
			thursday_definition: (d = Thursday) implies (Result = Wednesday)
			friday_definition: (d = Friday) implies (Result = Thursday)
			saturday_definition: (d = Saturday) implies (Result = Friday)
		end

feature -- Time

	Seconds_in_minute: INTEGER is 60
			-- Number of seconds in a minute

	Seconds_in_hour: INTEGER is 3600
			-- Number of seconds in an hour

	Seconds_in_day: INTEGER is 86400
			-- Number of seconds in a day
 
	Milliseconds_in_day: INTEGER is 86400000
			-- Number of milliseconds in a day
 
	Minutes_in_hour: INTEGER is 60
			-- Number of minutes in an hour

	Hours_in_day: INTEGER is 24
			-- Number of hours in a day

feature -- Epoch

	Epoch_year: INTEGER is 1970
	Epoch_month: INTEGER is 1
	Epoch_day: INTEGER is 1
			-- Epoch date (1 Jan 1970)

	epoch_days (y, m, d: INTEGER): INTEGER is
			-- Number of days since epoch date (1 Jan 1970)
		require
			m_large_enough: m >= January
			m_small_enough: m <= December
			d_large_enough: d >= 1
			d_small_enough: d <= days_in_month (m, y)
		do
			Result := (y - Epoch_year) * Days_in_year +
				((((y - 1) // 4) - ((y - 1) // 100) +
				((y - 1) // 400)) - Epoch_leap_years) +
				(days_at_month (m, y) - Epoch_days_at_month) +
				(d - Epoch_day)
		end

feature {NONE} -- Epoch

	Epoch_leap_years: INTEGER is
			-- Number of leap years between year '1'
			-- and year 'Epoch_year - 1'
		once
			Result := ((Epoch_year - 1) // 4) -
				((Epoch_year - 1) // 100) + ((Epoch_year - 1) // 400)
		end

	Epoch_days_at_month: INTEGER is
			-- Number of days from beginning of year `Epoch_year'
			-- until beginning of month `Epoch_month' exclusive
		once
			Result := days_at_month (Epoch_month, Epoch_year)
		ensure
			days_positive: Result >= 0
		end

	Epoch_to_Y2K_days: INTEGER is
			-- Number of days between epoch (1 Jan 1970)
			-- and Y2K (1 Jan 2000)
		once
			Result := epoch_days (2000, 1, 1)
		end

end
