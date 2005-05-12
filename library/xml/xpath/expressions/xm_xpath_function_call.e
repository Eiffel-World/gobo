indexing

	description:

		"Objects that call XPath system-defined and user-defined functions"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_XPATH_FUNCTION_CALL

inherit

	XM_XPATH_COMPUTED_EXPRESSION
		redefine
			simplify, promote, sub_expressions
		end

feature -- Access

	arguments: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION]
			-- Actual parameters

	supplied_argument_count: INTEGER is
			-- Number of actual arguments supplied in the function call
		do
			Result := arguments.count
		ensure
			positive_result: Result >= 0
		end

	sub_expressions: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION] is
			-- Immediate sub-expressions of `Current'
		do
			Result := arguments
		end

	name: STRING is
			-- Function name
		deferred
		ensure
			Name_not_void: Result /= Void and then Result.count > 0
		end

	namespace_uri: STRING is
			-- Namespace uri for `name'
		deferred
		ensure
			Namespace_uri_not_void: Result /= Void
		end

feature -- Status report

	display (a_level: INTEGER) is
			-- Diagnostic print of expression structure to `std.error'
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
		do
			std.error.put_string (indentation (a_level))
			std.error.put_string ("function ")
			if namespace_uri.count > 0 then
				std.error.put_string ("{")
				std.error.put_string (namespace_uri)
				std.error.put_string ("}")
			end
			std.error.put_string (name)
			std.error.put_new_line
			a_cursor := arguments.new_cursor
			from
				a_cursor.start
			variant
				arguments.count + 1 - a_cursor.index				
			until
				a_cursor.after
			loop
				a_cursor.item.display (a_level + 1)
				a_cursor.forth
			end
		end

feature -- Status setting

	set_arguments (args: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION]) is
			-- Set all arguments.
		require
			arguments_not_void: args /= Void
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
		do
			arguments := args
			arguments.set_equality_tester (expression_tester)											
			from
				a_cursor := arguments.new_cursor; a_cursor.start
			variant
				arguments.count + 1 - a_cursor.index
			until
				a_cursor.after
			loop
				adopt_child_expression (a_cursor.item)
				a_cursor.forth
			end
			compute_static_properties
		ensure
			arguments_set: arguments = args
			static_properties_computed: are_static_properties_computed
		end
	
feature -- Optimization

	simplify is
			-- Perform context-independent static optimizations.
		do
			simplify_arguments
		end

	simplify_arguments is
			-- Simplify `arguments'
		require
			no_previous_error: not is_error
		local
			an_argument: XM_XPATH_EXPRESSION
			arguments_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
		do
			from
				arguments_cursor := arguments.new_cursor
				arguments_cursor.start
			variant
				arguments.count + 1 - arguments_cursor.index
			until
				is_error or else arguments_cursor.after
			loop
				an_argument := arguments_cursor.item
				if an_argument.was_expression_replaced then
					an_argument := an_argument.replacement_expression
					adopt_child_expression (an_argument)
					arguments_cursor.replace (an_argument)
				end
				an_argument.simplify
				if an_argument.is_error then
					set_last_error (an_argument.error_value)
				elseif an_argument.was_expression_replaced then
					arguments_cursor.replace (an_argument.replacement_expression)
					adopt_child_expression (an_argument.replacement_expression)
				end
				arguments_cursor.forth
			end
		end

	analyze (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Perform static analysis of `Current' and its subexpressions.
			-- This also calls pre_evaluate to evaluate the function
			--  if all the arguments are constant;
			-- Functions that do not require this behavior
			--  can override the pre_evaluate routine.
		local
			fixed_values: BOOLEAN
			arguments_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
		do
			mark_unreplaced
			from
				fixed_values := True -- until we find otherwise
				arguments_cursor := arguments.new_cursor
				arguments_cursor.start
			variant
				arguments.count + 1 - arguments_cursor.index
			until
				is_error or else arguments_cursor.after
			loop
				arguments_cursor.item.analyze (a_context)
				if arguments_cursor.item.is_error then
					set_last_error (arguments_cursor.item.error_value)
				else
					if arguments_cursor.item.was_expression_replaced then
						arguments_cursor.replace (arguments_cursor.item.replacement_expression)
						arguments_cursor.item.mark_unreplaced
						adopt_child_expression (arguments_cursor.item)
					end
					if not arguments_cursor.item.is_value then fixed_values := False end
				end
				arguments_cursor.forth
			end
			
			if not is_error then check_arguments (a_context) end
			
			-- Now, if any of the arguments has a static type error,
			--  then `Current' as a whole has too.
			
			if not is_error and then fixed_values then
				pre_evaluate (a_context) -- May or may not be in error
			end
		end

	promote (an_offer: XM_XPATH_PROMOTION_OFFER) is
			-- Promote this subexpression.
		local
			a_promotion: XM_XPATH_EXPRESSION
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
		do
			an_offer.accept (Current)
			a_promotion := an_offer.accepted_expression
			if a_promotion /= Void then
				set_replacement (a_promotion)
			elseif an_offer.action /= Unordered then
				a_cursor := arguments.new_cursor
				from
					a_cursor.start
				variant
					arguments.count + 1 - a_cursor.index
				until
						a_cursor.after
				loop
					a_cursor.item.promote (an_offer)
					if a_cursor.item.was_expression_replaced then
						a_cursor.replace (a_cursor.item.replacement_expression)
						a_cursor.item.mark_unreplaced
					end
					a_cursor.forth
				end
			end
		end	

feature -- Evaluation

	pre_evaluate (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Pre-evaluate `Current' at compile time.
			-- Functions that do not allow pre-evaluation,
			--  or that need access to context information,
			--  can redefine this routine.
		require
			no_error: not is_error
			context_not_void: a_context /= Void
		do
			eagerly_evaluate (Void)
			set_replacement (last_evaluation)
		end

feature {XM_XPATH_FUNCTION_CALL} -- Local

	check_arguments (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Check arguments during parsing, when all the argument expressions have been read.
		require
			no_error: not is_error
			context_not_void: a_context /= Void
		deferred
		ensure
			maybe_type_error: True
		end

feature {NONE} -- Implementation

	augmented_argument_count: INTEGER
			-- Number of secretly added arguments

	check_argument_count (a_minimum_count, a_maximum_count: INTEGER) is
			-- Check number of arguments
		require
			positive_minimum_count: a_minimum_count >= 0
			nearly_positive_maximum_count: a_maximum_count >= -1
			no_previous_error: not is_error
		local
			a_message: STRING
			is_type_error: BOOLEAN
		do
			-- TODO - need to add location information in messages
			if a_minimum_count = a_maximum_count and then a_minimum_count /= supplied_argument_count then
				is_type_error := True
			a_message := STRING_.appended_string ("Function ", name)
			a_message := STRING_.appended_string (a_message, " must have ")
			a_message := STRING_.appended_string (a_message, (a_minimum_count - augmented_argument_count).out)
			a_message := STRING_.appended_string (a_message, plural_arguments_text ((a_minimum_count - augmented_argument_count)))
			elseif supplied_argument_count < a_minimum_count then
			is_type_error := True
				a_message := STRING_.appended_string ("Function ", name)
				a_message := STRING_.appended_string (a_message, " must have at least")
				a_message := STRING_.appended_string (a_message, (a_minimum_count - augmented_argument_count).out)
				a_message := STRING_.appended_string (a_message, plural_arguments_text ((a_minimum_count - augmented_argument_count)))
			elseif a_maximum_count > -1 and supplied_argument_count > a_maximum_count then
			is_type_error := True
				a_message := STRING_.appended_string ("Function ", name)
				a_message := STRING_.appended_string (a_message, " must have at most")
				a_message := STRING_.appended_string (a_message, (a_maximum_count - augmented_argument_count).out)
				a_message := STRING_.appended_string (a_message, plural_arguments_text ((a_maximum_count - augmented_argument_count)))
			end
			if is_type_error then
				set_last_error_from_string (a_message, Xpath_errors_uri, "XPST0017", Static_error)
			end
		ensure
			Correct_number_or_error: True
		end

	plural_arguments_text (a_count: INTEGER): STRING is
			-- Singular of plural arguments text
		require
			positive_count: a_count >= 0
		do
			if a_count = 1 then
				Result := " argument"
			else
				Result := " arguments"
			end
		ensure
			plural_arguments_text_not_void: Result /= Void
		end

invariant

	arguments: arguments /= Void and then arguments.equality_tester.is_equal (expression_tester)
	augmented_argument_count: augmented_argument_count = 0 or else augmented_argument_count = 1

end
