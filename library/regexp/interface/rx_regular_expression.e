indexing

	description:

		"Regular expressions"

	library: "Gobo Eiffel Regexp Library"
	copyright: "Copyright (c) 2001-2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class RX_REGULAR_EXPRESSION

inherit

	RX_PATTERN_MATCHER

	UT_CHARACTER_CODES
		export {NONE} all end

feature -- Replacement

	replacement (a_replacement: STRING): STRING is
			-- Copy of `a_replacement' where all occurrences of \n\ have
			-- been replaced by the corresponding n-th captured substrings
			-- if any
		require
			is_matching: is_matching
			a_replacement_not_void: a_replacement /= Void
			same_type: a_replacement.same_type (subject)
		do
			Result := STRING_.new_empty_string (a_replacement, a_replacement.count)
			append_replacement_to_string (Result, a_replacement)
		ensure
			replacement_not_void: Result /= Void
			same_type: Result.same_type (a_replacement)
		end

	append_replacement_to_string (a_string, a_replacement: STRING) is
			-- Append to `a_string' a copy of `a_replacement' where all occurrences
			-- of \n\ have been replaced by the corresponding n-th captured substrings
			-- if any.
		require
			is_matching: is_matching
			a_string_not_void: a_string /= Void
			a_replacement_not_void: a_replacement /= Void
			a_replacement_same_type: a_replacement.same_type (subject)
			a_string_same_type: a_string.same_type (a_replacement)
		local
			i, j, nb, ref: INTEGER
			c: CHARACTER
		do
			nb := a_replacement.count
			from i := 1 until i > nb loop
				c := a_replacement.item (i)
				if c = '\' then
					from
						i := i + 1
						j := i
						ref := 0
					until
						i > nb or else
						(a_replacement.item_code (i) < Zero_code or a_replacement.item_code (i) > Nine_code)
					loop
						c := a_replacement.item (i)
						ref := ref * 10 + c.code - Zero_code
						i := i + 1
					end
					if i <= nb then
						c := a_replacement.item (i)
						if c = '\' then
							if i > j then
									-- Minimal one digit readed,
								if ref < match_count then
									append_captured_substring_to_string (a_string, ref)
								end
							else
									-- Double backslash means one \\ => \.
								a_string.append_character (c)
							end
							i := i + 1
						else
								-- Backslash followed by optional digits without the final backslash
								-- put the backslash in and process the following characters by the
								-- normal way.
							a_string.append_character ('\')
							i := j
						end
					else
							-- Backslash followed by options digit fill the rest of line, we put the
							-- backslash in an processes the may following characters on the normal way.
						a_string.append_character ('\')
						i := j
					end
				else
						-- Simply put the character in.
					a_string.append_character (c)
					i := i + 1
				end
			end
		end

	replace (a_replacement: STRING): STRING is
			-- Substring of `subject' between `subject_start' and `subject_end'
			-- where the whole matched string has been replaced by `a_replacement';
			-- All occurrences of \n\ in `a_replacement' will have been replaced
			-- by the corresponding n-th captured substrings if any
		require
			is_matching: is_matching
			a_replacement_not_void: a_replacement /= Void
			same_type: a_replacement.same_type (subject)
		do
			Result := STRING_.new_empty_string (subject, subject_end - subject_start)
			append_replace_to_string (Result, a_replacement)
		ensure
			replace_not_void: Result /= Void
			same_type: Result.same_type (subject)
		end

	append_replace_to_string (a_string, a_replacement: STRING) is
			-- Append to `a_string' a substring of `subject' between `subject_start'
			-- and `subject_end' where the whole matched string has been replaced by
			-- `a_replacement'. All occurrences of \n\ in `a_replacement' will have
			-- been replaced by the corresponding n-th captured substrings if any.
		require
			is_matching: is_matching
			a_string_not_void: a_string /= Void
			a_replacement_not_void: a_replacement /= Void
			a_replacement_same_type: a_replacement.same_type (subject)
			a_string_same_type: a_string.same_type (a_replacement)
		do
			if match_count > 0 then
				STRING_.append_substring_to_string (a_string, subject, subject_start, captured_start_position (0) - 1)
				append_replacement_to_string (a_string, a_replacement)
				STRING_.append_substring_to_string (a_string, subject, captured_end_position (0) + 1, subject_end)
			else
				STRING_.append_substring_to_string (a_string, subject, subject_start, subject_end)
			end
		end

	replace_all (a_replacement: STRING): STRING is
			-- Substring of `subject' between `subject_start' and `subject_end'
			-- where the whole matched string has been repeatedly replaced by
			-- `a_replacement'; All occurrences of \n\ in `a_replacement' will
			-- have been replaced by the corresponding n-th captured substrings
			-- if any
		require
			is_matching: is_matching
			a_replacement_not_void: a_replacement /= Void
			same_type: a_replacement.same_type (subject)
		do
			Result := STRING_.new_empty_string (subject, subject_end - subject_start)
			append_replace_all_to_string (Result, a_replacement)
		ensure
			all_matched: not has_matched
			replace_not_void: Result /= Void
			same_type: Result.same_type (subject)
		end

	append_replace_all_to_string (a_string, a_replacement: STRING) is
			-- Append to `a_string' a substring of `subject' between `subject_start'
			-- and `subject_end' where the whole matched string has been repeatedly
			-- replaced by `a_replacement'. All occurrences of \n\ in `a_replacement'
			-- will have been replaced by the corresponding n-th captured substrings
			-- if any.
		require
			is_matching: is_matching
			a_string_not_void: a_string /= Void
			a_replacement_not_void: a_replacement /= Void
			a_replacement_same_type: a_replacement.same_type (subject)
			a_string_same_type: a_string.same_type (a_replacement)
		local
			old_subject_start: INTEGER
		do
			old_subject_start := subject_start
			from until not has_matched loop
				STRING_.append_substring_to_string (a_string, subject, subject_start, captured_start_position (0) - 1)
				append_replacement_to_string (a_string, a_replacement)
				match_substring (subject, captured_end_position (0) + 1, subject_end)
			end
			STRING_.append_substring_to_string (a_string, subject, subject_start, subject_end)
			subject_start := old_subject_start
		ensure
			all_matched: not has_matched
		end

feature -- Splitting

	split: ARRAY [STRING] is
			-- Parts of `subject' between `subject_start' and `subject_end'
			-- which do not match the pattern.
		require
			is_matching: is_matching
		do
			create Result.make (1, 0)
			append_split_to_array (Result)
		ensure
			all_matched: not has_matched
			split_not_void: Result /= Void
		end

	append_split_to_array (an_array: ARRAY [STRING]) is
			-- Append to `an_array' the parts of `subject' between `subject_start'
			-- and `subject_end' which do not match the pattern.
		require
			is_matching: is_matching
			an_array_not_void: an_array /= Void
		local
			i, j, nb: INTEGER
			old_subject_start: INTEGER
		do
			i := subject_start
			old_subject_start := i
			nb := an_array.upper
			from until not has_matched loop
				j := captured_start_position (0) - 1
				if i <= j + 1 then
					nb := nb + 1
					an_array.force (STRING_.substring (subject, i, j), nb)
				end
				i := captured_end_position (0) + 1
				match_substring (subject, i, subject_end)
			end
			if i <= subject_end + 1 then
				nb := nb + 1
				an_array.force (STRING_.substring (subject, i, subject_end), nb)
			end
			subject_start := old_subject_start
		ensure
			all_matched: not has_matched
		end

end
