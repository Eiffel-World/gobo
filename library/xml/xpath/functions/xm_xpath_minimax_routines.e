indexing

	description:

		"Objects that support the XPath min() and max() functions"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_MINIMAX_ROUTINES

inherit

	XM_XPATH_COLLATING_FUNCTION

	XM_XPATH_SYSTEM_FUNCTION
		undefine
			pre_evaluate, analyze
		redefine
			evaluate_item
		end

feature -- Access

	item_type: XM_XPATH_ITEM_TYPE is
			-- Data type of the expression, where known
		do
			Result := type_factory.any_atomic_type
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

feature -- Status report

	required_type (argument_number: INTEGER): XM_XPATH_SEQUENCE_TYPE is
			-- Type of argument number `argument_number'
		do
			if argument_number = 2 then
				create Result.make_single_string
			else
				create Result.make_atomic_sequence
			end
		end

feature -- Evaluation

	evaluate_item (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate as a single item
		local
			an_atomic_value, another_atomic_value: XM_XPATH_ATOMIC_VALUE
			a_comparer: KL_COMPARATOR [XM_XPATH_ITEM]
			an_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]
			a_numeric_value: XM_XPATH_NUMERIC_VALUE
			a_primitive_type, another_primitive_type: INTEGER
			already_finished: BOOLEAN
		do
			last_evaluated_item := Void
			a_comparer := atomic_comparer (2, a_context)
			if a_comparer = Void then
				create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string ("Unsupported collation", Xpath_errors_uri, "FOCH0002", Dynamic_error)
			else
				if is_max then create {XM_XPATH_DESCENDING_COMPARER} a_comparer.make (a_comparer) end
				arguments.item (1).create_iterator (a_context)
				an_iterator := arguments.item (1).last_iterator
				an_iterator.start
				if not an_iterator.after then
					check
						atomic_item: an_iterator.item.is_atomic_value
						-- static typing
					end
					an_atomic_value := an_iterator.item.as_atomic_value
					a_primitive_type := an_atomic_value.item_type.primitive_type
					if a_primitive_type = Untyped_atomic_type_code then
						a_primitive_type := Numeric_type_code
						if an_atomic_value.is_convertible (type_factory.double_type) then
							an_atomic_value := an_atomic_value.convert_to_type (type_factory.double_type)
						else
							create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string ("Cannot convert xdt:untypedAtomic value to xs:double", Xpath_errors_uri, "FORG0007", Dynamic_error)
							already_finished := True
						end
					else
						inspect
							a_primitive_type
						when Integer_type_code, Double_type_code, Decimal_type_code then
							a_primitive_type := Numeric_type_code
						else
						end
					end
					if not already_finished then
						inspect
							a_primitive_type
						when Numeric_type_code then
							a_numeric_value := an_atomic_value.as_numeric_value
							if a_numeric_value.is_nan then
								already_finished := True
								last_evaluated_item := a_numeric_value
							end
						when Boolean_type_code, String_type_code, Year_month_duration_type_code, Day_time_duration_type_code then
							-- No problems
						when Date_time_type_code, Time_type_code, Date_type_code then
							-- TODO: add implicit time-zone if needed
						else
							create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string (STRING_.concat ("Invalid base type for fn:min/max(): ", an_atomic_value.item_type.conventional_name), Xpath_errors_uri, "FORG0007", Dynamic_error)
							already_finished := True
						end
					end
					from
					until
						already_finished or else an_iterator.after
					loop
						an_iterator.forth
						if an_iterator.after then
							last_evaluated_item := an_atomic_value
						else
							check
								atomic_item: an_iterator.item.is_atomic_value
								-- static typing
							end
							another_atomic_value := an_iterator.item.as_atomic_value
							another_primitive_type := another_atomic_value.item_type.primitive_type
							if another_primitive_type = Untyped_atomic_type_code then
								another_primitive_type := Numeric_type_code
								if another_atomic_value.is_convertible (type_factory.double_type) then
									another_atomic_value := another_atomic_value.convert_to_type (type_factory.double_type)
								else
									create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string ("Cannot convert xdt:untypedAtomic value to xs:double", Xpath_errors_uri, "FORG0007", Dynamic_error)
									already_finished := True
								end
							else
								inspect
									another_primitive_type
								when Integer_type_code, Double_type_code, Decimal_type_code then
									another_primitive_type := Numeric_type_code
								else
								end
							end
							if not already_finished then
								if another_primitive_type /= a_primitive_type then
									create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string ("Not all items have same base type for fn:min/max()", Xpath_errors_uri, "FORG0007", Dynamic_error)
									already_finished := True
								else
									if a_primitive_type = Numeric_type_code then
										a_numeric_value := another_atomic_value.as_numeric_value
										if a_numeric_value.is_nan then
											already_finished := True
											last_evaluated_item := a_numeric_value
										end
									end
									if not already_finished then
										if a_comparer.less_equal (another_atomic_value, an_atomic_value) then
											an_atomic_value := another_atomic_value
										end
									end
								end
							end
						end
					end
					if not already_finished then
						last_evaluated_item := an_atomic_value
					end
				end
			end
		end

feature {XM_XPATH_EXPRESSION} -- Restricted

	compute_cardinality is
			-- Compute cardinality.
		do
			set_cardinality_optional
		end

	is_max: BOOLEAN
			-- max() or min()?

end
	
