indexing

	description:

		"Interface for character buffers"

	library: "Gobo Eiffel Kernel Library"
	copyright: "Copyright (c) 2001, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class KI_CHARACTER_BUFFER

inherit

	KI_BUFFER [CHARACTER]
		undefine
			put
		redefine
			fill_from_stream
		end

feature {NONE} -- Initialization

	make (n: INTEGER) is
			-- Create a new character buffer being able
			-- to contain `n' characters.
		require
			non_negative_n: n >= 0
		deferred
		ensure
			count_set: count = n
		end

	make_from_string (a_string: STRING) is
			-- Create a new character buffer with
			-- characters from `a_string'.
			-- (The newly created buffer and `a_string'
			-- may not share internal representation.)
		require
			a_string_not_void: a_string /= Void
		do
			make (a_string.count)
			fill_from_string (a_string, 1)
		ensure
			count_set: count = a_string.count
			charaters_set: to_string.is_equal (a_string)
		end

feature -- Access

	substring (s, e: INTEGER): STRING is
			-- New string made up of characters held in
			-- buffer between indexes `s' and `e'
		require
			s_large_enough: s >= 1
			e_small_enough: e <= count
			valid_interval: s <= e + 1
		deferred
		ensure
			substring_not_void: Result /= Void
			count_set: Result.count = e - s + 1
		end

feature -- Conversion

	to_string: STRING is
			-- New string made up of characters held in buffer
		do
			Result := substring (1, count)
		ensure
			as_string_not_void: Result /= Void
			same_count: Result.count = count
		end

feature -- Element change

	append_substring_to_string (s, e: INTEGER; a_string: STRING) is
			-- Append string made up of characters held in buffer
			-- between indexes `s' and `e' to `a_string'.
		require
			a_string_not_void: a_string /= Void
			s_large_enough: s >= 1
			e_small_enough: e <= count
			valid_interval: s <= e + 1
		do
			if s <= e then
				a_string.append_string (substring (s, e))
			end
		ensure
			count_set: a_string.count = old (a_string.count) + (e - s + 1)
			characters_set: s <= e implies equal (a_string.substring (old (a_string.count) + 1, a_string.count), substring (s, e))
		end

	fill_from_string (a_string: STRING; pos: INTEGER) is
			-- Copy characters of `a_string' to buffer
			-- starting at position `pos'.
		require
			a_string_not_void: a_string /= Void
			pos_large_enough: pos >= 1
			enough_space: (pos + a_string.count - 1) <= count
		local
			nb: INTEGER
			i, j: INTEGER
		do
			nb := a_string.count
			if nb > 0 then
				j := pos
				from i := 1 until i > nb loop
					put (a_string.item (i), j)
					j := j + 1
					i := i + 1
				end
			end
		ensure
			charaters_set: substring (pos, a_string.count + pos - 1).is_equal (a_string)
		end

	fill_from_stream (a_stream: KI_CHARACTER_INPUT_STREAM; pos, nb: INTEGER): INTEGER is
			-- Fill buffer, starting at position `pos', with
			-- at most `nb' items read from `a_stream'.
			-- Return the number of items actually read.
		do
			Result := a_stream.read_to_buffer (Current, pos, nb)
		end

end -- class KI_CHARACTER_BUFFER
