indexing

	description:

		"XPath sequences of atomic values and nodes"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_XPATH_SEQUENCE_VALUE

inherit

	XM_XPATH_VALUE
		redefine
			is_sequence_value, as_sequence_value
		end

feature -- Access

	is_sequence_value: BOOLEAN is
			-- Is `Current' a sequence value?
		do
			Result := True
		end

	as_sequence_value: XM_XPATH_SEQUENCE_VALUE is
			-- `Current' seen as a sequence value
		do
			Result := Current
		end

	item_type: XM_XPATH_ITEM_TYPE is
			-- Data type
		do
			Result := any_item
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

	item (p: INTEGER): XM_XPATH_ITEM is
			-- Item at `p'
		require
			position_strictly_positive: p > 0
		local
			an_item: XM_XPATH_ITEM
			a_counter: INTEGER
		do
			from
				create_iterator (Void)
				a_counter := 1
			until
				a_counter > p or else last_iterator.after
			loop
				last_iterator.forth
				an_item := last_iterator.item
				if a_counter = p then
					Result := an_item
				else
					a_counter := a_counter + 1
				end
			end
		ensure
			item_may_not_be_present: True -- As we do not know the lengths of sequences
		end

feature -- Status report

	is_convertible_to_item (a_context: XM_XPATH_CONTEXT): BOOLEAN is
			-- Can `Current' be converted to an `XM_XPATH_ITEM'?
		do
			create_iterator (a_context)
			last_iterator.start
			if last_iterator.after then
				Result := False
			else
				last_iterator.forth
				if last_iterator.after then
					Result := False
				else
					Result := True
				end
			end
		end

	display (a_level: INTEGER) is
			-- Diagnostic print of expression structure to `std.error'
		local
			a_string: STRING
		do
			a_string := STRING_.appended_string (indentation (a_level), "sequence of ")
			a_string := STRING_.appended_string (a_string, item_type.conventional_name)
			if is_error then
				std.error.put_string (" in error%N")
			else
				a_string := STRING_.appended_string (a_string, " (")
				from
					create_iterator (Void)
						check
							before: last_iterator.before
						end
					last_iterator.forth
				until
					last_iterator.after
				loop
					std.error.put_string (indentation (a_level + 1))
					std.error.put_string (last_iterator.item.string_value)
					std.error.put_new_line
					last_iterator.forth				
				end
				a_string := STRING_.appended_string (a_string, ")")
				std.error.put_string (a_string)
				std.error.put_new_line
			end
		end

feature -- Evaluation

	calculate_effective_boolean_value (a_context: XM_XPATH_CONTEXT) is
			-- Effective boolean value
		local
			an_item: XM_XPATH_ITEM
			a_numeric_value: XM_XPATH_NUMERIC_VALUE
		do
			create_iterator (a_context)
			last_iterator.start
			if last_iterator.after then
				create last_boolean_value.make (False)
			else
				an_item := last_iterator.item
				if an_item.is_node then
					create last_boolean_value.make (True)
				elseif an_item.is_boolean_value then
					if an_item.as_boolean_value.value then
						last_boolean_value := an_item.as_boolean_value
					else
						last_iterator.forth
						create last_boolean_value.make (not last_iterator.after)
					end
				elseif an_item.is_string_value  then
					if an_item.as_string_value.string_value.count > 0 then
						create last_boolean_value.make (True)
					else
						last_iterator.forth
						create last_boolean_value.make (not last_iterator.after)
					end
				else
					if an_item.is_numeric_value then
						last_iterator.forth
						if not last_iterator.after then
							create last_boolean_value.make (True)
						else
							a_numeric_value := an_item.as_numeric_value 
							create last_boolean_value.make ((not a_numeric_value.is_zero ) and then (not a_numeric_value.is_nan))
						end
					else
						create last_boolean_value.make (True)
					end
				end
			end
		end

	evaluate_item (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate an expression as a single item
		do
			create_iterator (a_context)
			if last_iterator.is_error then
				create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make (last_iterator.error_value)
			else
				last_iterator.start
				if not last_iterator.after then
					last_evaluated_item := last_iterator.item
				end
			end
		end

	evaluate_as_string (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate as a String
		do
			evaluate_item (a_context)
			if not last_evaluated_item.is_string_value then
				create last_evaluated_string.make ("")
			else
				last_evaluated_string := last_evaluated_item.as_string_value 
			end
		end

feature  -- Conversion

	as_item (a_context: XM_XPATH_CONTEXT): XM_XPATH_ITEM is
			-- Convert to an item
		do
			create_iterator (a_context)
			if not last_iterator.is_error then
				last_iterator.start
				if last_iterator.is_error then
					create {XM_XPATH_INVALID_ITEM} Result.make (last_iterator.error_value)
				else
					Result := last_iterator.item
				end
			else
				create {XM_XPATH_INVALID_ITEM} Result.make (last_iterator.error_value)
			end		
		end

end
