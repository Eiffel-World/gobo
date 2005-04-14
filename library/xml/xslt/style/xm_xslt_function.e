indexing

	description:

		"xsl:function element nodes"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date  $"
	revision: "$Revision$"

class XM_XSLT_FUNCTION

inherit

	XM_XSLT_STYLE_ELEMENT
		redefine
			make_style_element, validate, may_contain_sequence_constructor,
			fixup_references, is_permitted_child
		end

	XM_XSLT_PROCEDURE

	XM_XPATH_ROLE

		-- A gexslt-specific extension attribute is implemented - gexslt:memo-function=yes|no

creation

	make_style_element

feature {NONE} -- Initialization
	
	make_style_element (an_error_listener: XM_XSLT_ERROR_LISTENER; a_document: XM_XPATH_TREE_DOCUMENT;  a_parent: XM_XPATH_TREE_COMPOSITE_NODE;
		an_attribute_collection: XM_XPATH_ATTRIBUTE_COLLECTION; a_namespace_list:  DS_ARRAYED_LIST [INTEGER];
		a_name_code: INTEGER; a_sequence_number: INTEGER) is
			-- Establish invariant.
		do
			number_of_arguments := -1
			internal_function_fingerprint := -1
			is_overriding := True
			create references.make_default
			create slot_manager.make
			Precursor (an_error_listener, a_document, a_parent, an_attribute_collection, a_namespace_list, a_name_code, a_sequence_number)
		end

feature -- Access

	references: DS_ARRAYED_LIST [XM_XSLT_USER_FUNCTION_CALL]
			-- References to `Current'

	compiled_function: XM_XSLT_COMPILED_USER_FUNCTION
			-- Compiled version of `Current'

	arity: INTEGER is
			-- Arity of function;
			-- CAUTION: not pure - memo function
		require
			attributes_prepared: attributes_prepared
		local
			an_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
			finished: BOOLEAN
			a_param: XM_XSLT_PARAM
		do
			if number_of_arguments = -1 then
				number_of_arguments := 0
				from
					an_iterator := new_axis_iterator (Child_axis); an_iterator.start
				until
					finished or else an_iterator.after
				loop
					a_param ?= an_iterator.item
					if a_param /= Void then
						number_of_arguments := number_of_arguments + 1
						an_iterator.forth
					else
						finished := True
					end
				end
			end
			Result := number_of_arguments
		ensure
			positive_arity: Result >= 0
		end

	argument_types: DS_ARRAYED_LIST [XM_XPATH_SEQUENCE_TYPE] is
			-- Types for arguments
		require
			validated: validated
		local
			an_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
			a_param: XM_XSLT_PARAM
		do
			create Result.make (arity)
			from
				an_iterator := new_axis_iterator (Child_axis); an_iterator.start
			until
				an_iterator.after
			loop
				a_param ?= an_iterator.item
				if a_param /= Void then
					Result.put_last (a_param.required_type)
				end
				an_iterator.forth
			end
		end

	function_fingerprint: INTEGER is
			-- Fingerprint of function's QName;
			-- CAUTION: not pure - memo function
		do
			if internal_function_fingerprint = -1 then

				-- This is a forwards reference to the function.

				if static_context = Void then create static_context.make (Current) end
				prepare_attributes
				if any_compile_errors then
					internal_function_fingerprint := -1
				end
			end
			Result := internal_function_fingerprint
		ensure
			nearly_positive_fingerprint: Result >= -1
		end

feature -- Status report

	may_contain_sequence_constructor: BOOLEAN is
			-- Is `Current' allowed to contain a sequence constructor?
		do
			Result := True
		end
	
	is_permitted_child (a_style_element: XM_XSLT_STYLE_ELEMENT): BOOLEAN is
			-- Is `a_style_element' a permitted child of `Current'?
		local
			a_param: XM_XSLT_PARAM
		do
			a_param ?= a_style_element
			Result := a_param /= Void
		end

	is_overriding: BOOLEAN
			-- Was `override="yes"' specified (or defaulted)?

feature -- Element change

	register_reference (a_reference: XM_XSLT_USER_FUNCTION_CALL) is
			-- Register a function call reference for future fix-up.
		require
			reference_not_void: a_reference /= Void
		do
			references.force_last (a_reference)
		end

	fixup_references is
			-- Fix up references from XPath expressions.
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XSLT_USER_FUNCTION_CALL]
			a_function_call: XM_XSLT_USER_FUNCTION_CALL
		do
			from
				a_cursor := references.new_cursor; a_cursor.start
			until
				a_cursor.after
			loop
				a_function_call := a_cursor.item
				a_function_call.set_static_type (result_type)
				a_cursor.forth
			end
			Precursor
		end

	prepare_attributes is
			-- Set the attribute list for the element.
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [INTEGER]
			a_name_code: INTEGER
			an_expanded_name, an_as_attribute, an_override_attribute, a_memo_function_attribute: STRING
			an_error: XM_XPATH_ERROR_VALUE
		do
			from
				a_cursor := attribute_collection.name_code_cursor
				a_cursor.start
			variant
				attribute_collection.number_of_attributes + 1 - a_cursor.index				
			until
				a_cursor.after
			loop
				a_name_code := a_cursor.item
				an_expanded_name := shared_name_pool.expanded_name_from_name_code (a_name_code)
				if STRING_.same_string (an_expanded_name, Name_attribute) then
					function_name := attribute_value_by_index (a_cursor.index)
					if function_name.index_of (':', 2) = 0 then
						create an_error.make_from_string ("Xsl:function name must have a namespace prefix", "", "XTSE0740", Static_error)
						report_compile_error (an_error)
					else
						STRING_.left_adjust (function_name)
						STRING_.right_adjust (function_name)
						generate_name_code (function_name)
						internal_function_fingerprint := fingerprint_from_name_code (last_generated_name_code)
						-- TODO: do we need name code also?
					end
				elseif STRING_.same_string (an_expanded_name, As_attribute) then
					an_as_attribute := attribute_value_by_index (a_cursor.index)
				elseif STRING_.same_string (an_expanded_name, Override_attribute) then
					an_override_attribute := attribute_value_by_index (a_cursor.index)
					STRING_.left_adjust (an_override_attribute)
					STRING_.right_adjust (an_override_attribute)
					if STRING_.same_string (an_override_attribute, "yes") then
						is_overriding := True
					elseif STRING_.same_string (an_override_attribute, "no") then
						is_overriding := False
					else
						create an_error.make_from_string ("Xsl:function override attribute must be 'yes' or 'no'", "", "XTSE0020", Static_error)
						report_compile_error (an_error)
					end
				elseif STRING_.same_string (an_expanded_name, Gexslt_memo_function_attribute) then
					debug ("XSLT memo function")
						std.error.put_string ("gexslt:memo-function found%N")
					end
					a_memo_function_attribute := attribute_value_by_index (a_cursor.index)
					STRING_.left_adjust (a_memo_function_attribute)
					STRING_.right_adjust (a_memo_function_attribute)
					if STRING_.same_string (a_memo_function_attribute, "yes") then
						is_memo_function := True
					elseif STRING_.same_string (a_memo_function_attribute, "no") then
						is_memo_function := False
					else
						create an_error.make_from_string ("Xsl:function memo-function extension attribute must be 'yes' or 'no'", "", "XTSE0020", Static_error)
						report_compile_error (an_error)
					end
				else
					check_unknown_attribute (a_name_code)
				end
				a_cursor.forth
			end

			if function_name = Void then
				report_absence ("name")
			end
			if an_as_attribute /= Void then
				generate_sequence_type (an_as_attribute)
				result_type := last_generated_sequence_type
			else
				create result_type.make_any_sequence
			end
			attributes_prepared := True
		end

	validate is
			-- Check that the stylesheet element is valid.
			-- This is called once for each element, after the entire tree has been built.
			-- As well as validation, it can perform first-time initialisation.
		local
			an_arity: INTEGER
			a_root: XM_XSLT_STYLESHEET
			a_cursor: DS_BILINKED_LIST_CURSOR [XM_XSLT_STYLE_ELEMENT]
			a_function: XM_XSLT_FUNCTION
			an_error: XM_XPATH_ERROR_VALUE
		do
			check_top_level (Void)
			an_arity := arity

			-- Check that this function is not a duplicate of another.

			from
				a_root := principal_stylesheet
				a_cursor := a_root.top_level_elements.new_cursor; a_cursor.finish
			variant
				a_cursor.index
			until
				a_cursor.before
			loop
				a_function ?= a_cursor.item
				if a_function /= Void and then a_function /= Current
					and then a_function.arity = an_arity
					and then a_function.function_fingerprint = function_fingerprint
					and then a_function.precedence = precedence then
					create an_error.make_from_string (STRING_.concat ("Duplicate function declaration for ", function_name), "", "XTSE0770", Static_error)
					report_compile_error (an_error)
					a_cursor.go_before
				else
					a_cursor.back
				end
			end
			debug ("XSLT memo function")
				if is_memo_function then
					std.error.put_string ("Memo function:")
					std.error.put_string (function_name)
					std.error.put_new_line
				end
			end
			validated := True
		end

	compile (an_executable: XM_XSLT_EXECUTABLE) is
			-- Compile `Current' to an excutable instruction.
		local
			a_body: XM_XPATH_EXPRESSION
			a_role: XM_XPATH_ROLE_LOCATOR
			a_type_checker: XM_XPATH_TYPE_CHECKER
		do
			compile_sequence_constructor (an_executable, new_axis_iterator (Child_axis), False)
			a_body := last_generated_expression
			if a_body = Void then create {XM_XPATH_EMPTY_SEQUENCE} a_body.make end
			a_body.simplify
			if a_body.was_expression_replaced then a_body := a_body.replacement_expression end
			a_body.analyze (static_context)
			if a_body.was_expression_replaced then a_body := a_body.replacement_expression end
			if result_type /= Void then
				create a_role.make (Function_result_role, function_name, 1, Xpath_errors_uri, "XPTY0004")
				create a_type_checker
				a_type_checker.static_type_check (static_context, a_body, result_type, False, a_role)
				if a_type_checker.is_static_type_check_error then
					report_compile_error (a_type_checker.static_type_check_error)
				else
					a_body := a_type_checker.checked_expression
				end
			end
			create compiled_function.make (an_executable, a_body, function_name, system_id, line_number, slot_manager, result_type, is_memo_function)
			set_parameter_definitions (compiled_function)
			fixup_instruction (compiled_function)
		end

feature {NONE} -- Implementation

	internal_function_fingerprint: INTEGER
			-- Fingerprint of function's QName (-1 = forward reference)

	number_of_arguments: INTEGER
			-- Number of arguments (-1 = not yet known)

	function_name: STRING
			-- QName of function

	result_type: XM_XPATH_SEQUENCE_TYPE
			-- Type of result

	is_memo_function: BOOLEAN
			-- Is this function a memo function? (From: gexslt extension attribute)

	fixup_instruction (a_user_function: XM_XSLT_COMPILED_USER_FUNCTION) is
			-- Fix-up all references.
		require
			user_function_not_void: a_user_function /= Void
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XSLT_USER_FUNCTION_CALL]
		do
			from
				a_cursor := references.new_cursor; a_cursor.start
			variant
				references.count + 1 - a_cursor.index
			until
				any_compile_errors or else a_cursor.after
			loop
				a_cursor.item.set_function (Current, a_user_function)
				if a_cursor.item.is_type_error then
					report_compile_error (a_cursor.item.error_value)
				end
				a_cursor.forth
			end
		end

	set_parameter_definitions (a_user_function: XM_XSLT_COMPILED_USER_FUNCTION) is
			-- Compile and save the xsl:param definitions.
		require
			user_function_not_void: a_user_function /= Void
		local
			some_parameters: DS_ARRAYED_LIST [XM_XSLT_USER_FUNCTION_PARAMETER]
			an_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
			a_param: XM_XSLT_PARAM
			a_function_param: XM_XSLT_USER_FUNCTION_PARAMETER
		do
			create some_parameters.make (number_of_arguments)
			a_user_function.set_parameter_definitions (some_parameters)
			from
				an_iterator := new_axis_iterator (Child_axis); an_iterator.start
			until
				an_iterator.after
			loop
				a_param ?= an_iterator.item
				if a_param /= Void then
					create a_function_param.make (a_param.required_type, a_param.slot_number, a_param.variable_name)
					a_param.fixup_binding (a_function_param)
					a_function_param.set_reference_count (a_param.references)
					some_parameters.put_last (a_function_param)
				end
				an_iterator.forth
			end
		end
			
invariant

	references_not_void: references /= Void

end	

