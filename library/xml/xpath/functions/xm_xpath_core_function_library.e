indexing

	description:

		"Objects that provide access to core XPath functions"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_CORE_FUNCTION_LIBRARY

inherit

	XM_XPATH_FUNCTION_LIBRARY

	XM_XPATH_STANDARD_NAMESPACES

creation

	make

feature {NONE} -- Initialization

	make is
			-- Nothing to do.
		do
		end

feature -- Access

	is_function_available (a_fingerprint, an_arity: INTEGER; is_restricted: BOOLEAN): BOOLEAN is
			-- Does `a_fingerprint' represent an available function with `an_arity'?
		do
			if a_fingerprint = Abs_function_type_code then
				Result := an_arity = -1 or else an_arity = 1
			elseif a_fingerprint = Boolean_function_type_code then
				Result := an_arity = -1 or else an_arity = 1
			elseif a_fingerprint = Ceiling_function_type_code then
				Result := an_arity = -1 or else an_arity = 1
			elseif a_fingerprint = Compare_function_type_code then
				Result := an_arity = -1 or else an_arity = 2  or else an_arity = 3
			elseif a_fingerprint = Concat_function_type_code then
				Result := an_arity = -1 or else an_arity > 1
			elseif a_fingerprint = Contains_function_type_code then
				Result := an_arity = -1 or else an_arity = 2  or else an_arity = 3
			elseif a_fingerprint = Count_function_type_code then
				Result := an_arity = -1 or else an_arity = 1
			elseif a_fingerprint = Current_date_function_type_code then
				Result := an_arity = -1 or else an_arity = 0
			elseif a_fingerprint = Current_datetime_function_type_code then
				Result := an_arity = -1 or else an_arity = 0
			elseif a_fingerprint = Current_time_function_type_code then
				Result := an_arity = -1 or else an_arity = 0
			elseif a_fingerprint = Doc_function_type_code then
				Result := an_arity = -1 or else an_arity = 1
			elseif a_fingerprint = Empty_function_type_code then
				Result := an_arity = -1 or else an_arity = 1
			elseif a_fingerprint = Ends_with_function_type_code then
				Result := an_arity = -1 or else an_arity = 2 or else an_arity = 3
			elseif a_fingerprint = Error_function_type_code then
				Result := an_arity < 4
			elseif a_fingerprint = Escape_uri_function_type_code then
				Result := an_arity = -1 or else an_arity = 1 or else an_arity = 2
			elseif a_fingerprint = Exists_function_type_code then
				Result := an_arity = -1 or else an_arity = 1
			elseif a_fingerprint = False_function_type_code then
				Result := an_arity = -1 or else an_arity = 0
			elseif a_fingerprint = Floor_function_type_code then
				Result := an_arity = -1 or else an_arity = 1
			elseif a_fingerprint = Id_function_type_code then
				Result := an_arity = -1 or else an_arity = 1  or else an_arity = 2
			elseif a_fingerprint = In_scope_prefixes_function_type_code then
				Result := an_arity = -1 or else an_arity = 1
			elseif a_fingerprint = Index_of_function_type_code then
				Result := an_arity = -1 or else an_arity = 2 or else an_arity = 3
			elseif a_fingerprint = Insert_before_function_type_code then
				Result := an_arity = -1 or else an_arity = 3				
			elseif a_fingerprint = Lang_function_type_code then
				Result := an_arity = -1 or else an_arity = 1 or else an_arity = 2
			elseif a_fingerprint = Last_function_type_code then
				Result := an_arity = -1 or else an_arity = 0
			elseif a_fingerprint = Local_name_function_type_code then
				Result := an_arity = -1 or else an_arity = 0 or else an_arity = 1
			elseif a_fingerprint = Lower_case_function_type_code then
				Result := an_arity = -1 or else an_arity = 1
			elseif a_fingerprint = Matches_function_type_code then
				Result := an_arity = -1 or else an_arity = 3	or else an_arity = 2
			elseif a_fingerprint = Max_function_type_code then
				Result := an_arity = -1 or else an_arity = 1	or else an_arity = 2
			elseif a_fingerprint = Min_function_type_code then
				Result := an_arity = -1 or else an_arity = 1	or else an_arity = 2
			elseif a_fingerprint = Name_function_type_code then
				Result := an_arity = -1 or else an_arity = 0 or else an_arity = 1
			elseif a_fingerprint = Namespace_uri_function_type_code then
				Result := an_arity = -1 or else an_arity = 0 or else an_arity = 1
			elseif a_fingerprint = Namespace_uri_for_prefix_function_type_code then
				Result := an_arity = -1 or else an_arity = 2
			elseif a_fingerprint = Normalize_space_function_type_code then
				Result := an_arity = -1 or else an_arity = 0 or else an_arity = 1
			elseif a_fingerprint = Not_function_type_code then
				Result := an_arity = -1 or else an_arity = 1
			elseif a_fingerprint = Number_function_type_code then
				Result := an_arity = -1 or else an_arity = 0 or else an_arity = 1
			elseif a_fingerprint = Position_function_type_code then
				Result := an_arity = -1 or else an_arity = 0
			elseif a_fingerprint = Replace_function_type_code then
				Result := an_arity = -1 or else an_arity = 3 or else an_arity = 4
			elseif a_fingerprint = Root_function_type_code then
				Result := an_arity = -1 or else an_arity = 0  or else an_arity = 1
			elseif a_fingerprint = Round_function_type_code then
				Result := an_arity = -1 or else an_arity = 1
			elseif a_fingerprint = Round_half_to_even_function_type_code then
				Result := an_arity = -1 or else an_arity = 1  or else an_arity = 2
			elseif a_fingerprint = Starts_with_function_type_code then
				Result := an_arity = -1 or else an_arity = 2  or else an_arity = 3
			elseif a_fingerprint = String_length_function_type_code then
				Result := an_arity = -1 or else an_arity = 0 or else an_arity = 1
			elseif a_fingerprint = String_function_type_code then
				Result := an_arity = -1 or else an_arity = 0 or else an_arity = 1
			elseif a_fingerprint = String_join_function_type_code then
				Result := an_arity = -1 or else an_arity = 2
			elseif a_fingerprint = Subsequence_function_type_code then
				Result := an_arity = -1 or else an_arity = 2  or else an_arity = 3
			elseif a_fingerprint = Substring_function_type_code then
				Result := an_arity = -1 or else an_arity = 2  or else an_arity = 3
			elseif a_fingerprint = Substring_before_function_type_code then
				Result := an_arity = -1 or else an_arity = 2  or else an_arity = 3
			elseif a_fingerprint = Substring_after_function_type_code then
				Result := an_arity = -1 or else an_arity = 2  or else an_arity = 3
			elseif a_fingerprint = Sum_function_type_code then
				Result := an_arity = -1 or else an_arity = 1  or else an_arity = 2
			elseif a_fingerprint = Tokenize_function_type_code then
				Result := an_arity = -1 or else an_arity = 2  or else an_arity = 3				
			elseif a_fingerprint = Translate_function_type_code then
				Result := an_arity = -1 or else an_arity = 3
			elseif a_fingerprint = True_function_type_code then
				Result := an_arity = -1 or else an_arity = 0
			elseif a_fingerprint = Upper_case_function_type_code then
				Result := an_arity = -1 or else an_arity = 1
			end
		end

feature -- Element change

	bind_function (a_fingerprint: INTEGER; some_arguments: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION]; is_restricted: BOOLEAN) is
			-- Bind `a_fingerprint' to it's definition as `last_bound_function'.
		local
			a_function_call: XM_XPATH_FUNCTION_CALL
		do
			if a_fingerprint = Abs_function_type_code then
				create {XM_XPATH_ABS} a_function_call.make
			elseif a_fingerprint = Boolean_function_type_code then
				create {XM_XPATH_BOOLEAN} a_function_call.make
			elseif a_fingerprint = Ceiling_function_type_code then
				create {XM_XPATH_CEILING} a_function_call.make
			elseif a_fingerprint = Compare_function_type_code then
				create {XM_XPATH_COMPARE} a_function_call.make
			elseif a_fingerprint = Concat_function_type_code then
				create {XM_XPATH_CONCAT} a_function_call.make
			elseif a_fingerprint = Contains_function_type_code then
				create {XM_XPATH_CONTAINS} a_function_call.make
			elseif a_fingerprint = Count_function_type_code then
				create {XM_XPATH_COUNT} a_function_call.make
			elseif a_fingerprint = Current_date_function_type_code then
				create {XM_XPATH_CURRENT_DATE} a_function_call.make
			elseif a_fingerprint = Current_datetime_function_type_code then
				create {XM_XPATH_CURRENT_DATETIME} a_function_call.make
			elseif a_fingerprint = Current_time_function_type_code then
				create {XM_XPATH_CURRENT_TIME} a_function_call.make
			elseif a_fingerprint = Doc_function_type_code then
				create {XM_XPATH_DOC} a_function_call.make
			elseif a_fingerprint = Empty_function_type_code then
				create {XM_XPATH_EMPTY} a_function_call.make
			elseif a_fingerprint = Ends_with_function_type_code then
				create {XM_XPATH_ENDS_WITH} a_function_call.make				
			elseif a_fingerprint = Error_function_type_code then
				create {XM_XPATH_ERROR} a_function_call.make				
			elseif a_fingerprint = Escape_uri_function_type_code then
				create {XM_XPATH_ESCAPE_URI} a_function_call.make
			elseif a_fingerprint = Exists_function_type_code then
				create {XM_XPATH_EXISTS} a_function_call.make
			elseif a_fingerprint = False_function_type_code then
				create {XM_XPATH_FALSE} a_function_call.make
			elseif a_fingerprint = Floor_function_type_code then
				create {XM_XPATH_FLOOR} a_function_call.make
			elseif a_fingerprint = Id_function_type_code then
				create {XM_XPATH_ID} a_function_call.make
			elseif a_fingerprint = In_scope_prefixes_function_type_code then
				create {XM_XPATH_IN_SCOPE_PREFIXES} a_function_call.make
			elseif a_fingerprint = Index_of_function_type_code then
				create {XM_XPATH_INDEX_OF} a_function_call.make
			elseif a_fingerprint = Insert_before_function_type_code then
				create {XM_XPATH_INSERT_BEFORE} a_function_call.make
			elseif a_fingerprint = Last_function_type_code then
				create {XM_XPATH_LAST} a_function_call.make
			elseif a_fingerprint = Lang_function_type_code then
				create {XM_XPATH_LANG} a_function_call.make
			elseif a_fingerprint = Local_name_function_type_code then
				create {XM_XPATH_LOCAL_NAME} a_function_call.make
			elseif a_fingerprint = Lower_case_function_type_code then
				create {XM_XPATH_LOWER_CASE} a_function_call.make
			elseif a_fingerprint = Matches_function_type_code then
				create {XM_XPATH_MATCHES} a_function_call.make												
			elseif a_fingerprint = Max_function_type_code then
				create {XM_XPATH_MAX} a_function_call.make												
			elseif a_fingerprint = Min_function_type_code then
				create {XM_XPATH_MIN} a_function_call.make												
			elseif a_fingerprint = Name_function_type_code then
				create {XM_XPATH_NAME} a_function_call.make
			elseif a_fingerprint = Namespace_uri_function_type_code then
				create {XM_XPATH_NAMESPACE_URI} a_function_call.make
			elseif a_fingerprint = Namespace_uri_for_prefix_function_type_code then
				create {XM_XPATH_NAMESPACE_URI_FOR_PREFIX} a_function_call.make
			elseif a_fingerprint = Normalize_space_function_type_code then
				create {XM_XPATH_NORMALIZE_SPACE} a_function_call.make
			elseif a_fingerprint = Not_function_type_code then
				create {XM_XPATH_NOT} a_function_call.make
			elseif a_fingerprint = Number_function_type_code then
				create {XM_XPATH_NUMBER} a_function_call.make
			elseif a_fingerprint = Position_function_type_code then
				create {XM_XPATH_POSITION} a_function_call.make								
			elseif a_fingerprint = Replace_function_type_code then
				create {XM_XPATH_REPLACE} a_function_call.make
			elseif a_fingerprint = Root_function_type_code then
				create {XM_XPATH_ROOT} a_function_call.make
			elseif a_fingerprint = Round_function_type_code then
				create {XM_XPATH_ROUND} a_function_call.make
			elseif a_fingerprint = Round_half_to_even_function_type_code then
				create {XM_XPATH_ROUND_HALF_EVEN} a_function_call.make
			elseif a_fingerprint = Starts_with_function_type_code then
				create {XM_XPATH_STARTS_WITH} a_function_call.make								
			elseif a_fingerprint = String_length_function_type_code then
				create {XM_XPATH_STRING_LENGTH} a_function_call.make								
			elseif a_fingerprint = String_function_type_code then
				create {XM_XPATH_STRING} a_function_call.make								
			elseif a_fingerprint = String_join_function_type_code then
				create {XM_XPATH_STRING_JOIN} a_function_call.make								
			elseif a_fingerprint = Subsequence_function_type_code then
				create {XM_XPATH_SUBSEQUENCE} a_function_call.make
			elseif a_fingerprint = Substring_function_type_code then
				create {XM_XPATH_SUBSTRING} a_function_call.make												
			elseif a_fingerprint = Substring_before_function_type_code then
				create {XM_XPATH_SUBSTRING_BEFORE} a_function_call.make								
			elseif a_fingerprint = Substring_after_function_type_code then
				create {XM_XPATH_SUBSTRING_AFTER} a_function_call.make								
			elseif a_fingerprint = Sum_function_type_code then
				create {XM_XPATH_SUM} a_function_call.make								
			elseif a_fingerprint = Tokenize_function_type_code then
				create {XM_XPATH_TOKENIZE} a_function_call.make								
			elseif a_fingerprint = Translate_function_type_code then
				create {XM_XPATH_TRANSLATE} a_function_call.make								
			elseif a_fingerprint = True_function_type_code then
				create {XM_XPATH_TRUE} a_function_call.make								
			elseif a_fingerprint = Upper_case_function_type_code then
				create {XM_XPATH_UPPER_CASE} a_function_call.make								
			end
			check
				function_bound: a_function_call /= Void
				-- From pre-condition
			end
			a_function_call.set_arguments (some_arguments)
			last_bound_function := a_function_call
		end

end

