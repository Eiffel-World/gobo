indexing

	description:

		"C code generators"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_C_GENERATOR

inherit

	ET_AST_NULL_PROCESSOR
		rename
			make as make_processor
		redefine
			process_assignment,
			process_assignment_attempt,
			process_attribute,
			process_bang_instruction,
			process_bit_constant,
			process_c1_character_constant,
			process_c2_character_constant,
			process_c3_character_constant,
			process_call_agent,
			process_call_expression,
			process_call_instruction,
			process_check_instruction,
			process_constant_attribute,
			process_convert_expression,
			process_convert_to_expression,
			process_create_expression,
			process_create_instruction,
			process_current,
			process_current_address,
			process_debug_instruction,
			process_deferred_function,
			process_deferred_procedure,
			process_do_function,
			process_do_procedure,
			process_equality_expression,
			process_expression_address,
			process_external_function,
			process_external_procedure,
			process_false_constant,
			process_feature_address,
			process_hexadecimal_integer_constant,
			process_identifier,
			process_if_instruction,
			process_infix_cast_expression,
			process_infix_expression,
			process_inspect_instruction,
			process_loop_instruction,
			process_manifest_array,
			process_manifest_tuple,
			process_old_expression,
			process_once_function,
			process_once_manifest_string,
			process_once_procedure,
			process_parenthesized_expression,
			process_precursor_expression,
			process_precursor_instruction,
			process_prefix_expression,
			process_regular_integer_constant,
			process_regular_manifest_string,
			process_regular_real_constant,
			process_result,
			process_result_address,
			process_retry_instruction,
			process_semicolon_symbol,
			process_special_manifest_string,
			process_static_call_expression,
			process_static_call_instruction,
			process_strip_expression,
			process_true_constant,
			process_underscored_integer_constant,
			process_underscored_real_constant,
			process_unique_attribute,
			process_verbatim_string,
			process_void
		end

	ET_SHARED_TOKEN_CONSTANTS
		export {NONE} all end

	KL_SHARED_STREAMS
		export {NONE} all end

	KL_IMPORTED_CHARACTER_ROUTINES
		export {NONE} all end

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

	UT_IMPORTED_FORMATTERS
		export {NONE} all end

creation

	make

feature {NONE} -- Initialization

	make (a_system: like current_system) is
			-- Create a new C code generator.
		do
			make_processor (a_system.universe)
			create type_checker.make (universe)
			current_system := a_system
			current_file := null_output_stream
			current_type := a_system.none_type
			current_feature := dummy_feature
			create instruction_buffer_stack.make (10)
			create local_buffer_stack.make (10)
			create current_local_buffer.make ("")
			create accepted_types.make_with_capacity (15)
			create denied_types.make_with_capacity (15)
		end

feature -- Access

	current_system: ET_SYSTEM
			-- Surrounding system
			-- (Note: there is a frozen feature called `system' in
			-- class GENERAL of SmartEiffel 1.0)

feature -- Status report

	has_fatal_error: BOOLEAN
			-- Has a fatal error occurred when generating `current_system'?

feature -- Generation

	generate (a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Generate C code for `current_system' in to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			old_file: KI_TEXT_OUTPUT_STREAM
			l_dynamic_types: DS_ARRAYED_LIST [ET_DYNAMIC_TYPE]
			l_type: ET_DYNAMIC_TYPE
			i, nb: INTEGER
			j, nb2: INTEGER
			l_features: ET_DYNAMIC_FEATURE_LIST
			l_root_type: ET_DYNAMIC_TYPE
			l_root_creation: ET_DYNAMIC_FEATURE
		do
			has_fatal_error := False
			old_file := current_file
			current_file := a_file
			a_file.put_line ("#include <stdlib.h>")
			a_file.put_line ("#if defined(_MSC_VER) && (_MSC_VER < 1400) /* MSVC older than v8 */")
			a_file.put_line ("typedef signed char int8_t;")
			a_file.put_line ("typedef signed short int16_t;")
			a_file.put_line ("typedef signed int int32_t;")
			a_file.put_line ("typedef signed __int64 int64_t;")
			a_file.put_line ("#else")
			a_file.put_line ("#include <inttypes.h>")
			a_file.put_line ("#endif")
			a_file.put_new_line
			print_types
			a_file.put_new_line
			a_file.put_line ("#define EIF_VOID ((T0*)0)")
			a_file.put_string ("#define EIF_TRUE (")
			print_type_cast (current_system.boolean_type)
			a_file.put_line ("1)")
			a_file.put_string ("#define EIF_FALSE (")
			print_type_cast (current_system.boolean_type)
			a_file.put_line ("0)")
			a_file.put_new_line
			l_dynamic_types := current_system.dynamic_types
			nb := l_dynamic_types.count
			from i := 1 until i > nb loop
				l_type := l_dynamic_types.item (i)
				if l_type.is_alive or l_type.has_static then
					l_features := l_type.features
					if l_features /= Void then
						nb2 := l_features.count
						from j := 1 until j > nb2 loop
							print_feature_declaration (l_features.item (j), l_type)
							j := j + 1
						end
					end
				end
				i := i + 1
			end
			a_file.put_new_line
			from i := 1 until i > nb loop
				l_type := l_dynamic_types.item (i)
				if l_type.is_alive or l_type.has_static then
					print_features (l_type)
				end
				i := i + 1
			end
			l_root_type := current_system.root_type
			l_root_creation := current_system.root_creation_procedure
			if l_root_type = Void or l_root_creation = Void then
				a_file.put_line ("main(char** argv, int argc)")
				a_file.put_character ('{')
				a_file.put_new_line
				a_file.put_character ('}')
				a_file.put_new_line
			else
				a_file.put_line ("main (char** argv, int argc)")
				a_file.put_character ('{')
				a_file.put_new_line
				indent
				print_indentation
				print_type_declaration (l_root_type)
				a_file.put_string (" l1;")
				a_file.put_new_line
				print_indentation
				a_file.put_string ("l1 = ")
				print_creation_expression (l_root_type, l_root_creation, Void)
				a_file.put_character (';')
				a_file.put_new_line
				dedent
				a_file.put_character ('}')
				a_file.put_new_line
			end
			current_file := old_file
		end

feature {NONE} -- Feature generation

	print_feature_declaration (a_feature: ET_DYNAMIC_FEATURE; a_type: ET_DYNAMIC_TYPE) is
			-- Print feature declaration.
		require
			a_feature_not_void: a_feature /= Void
			a_type_not_void: a_type /= Void
		local
			i, nb: INTEGER
			l_arguments: ET_FORMAL_ARGUMENT_LIST
			l_dynamic_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_precursor: ET_DYNAMIC_PRECURSOR
			l_other_precursors: ET_DYNAMIC_PRECURSOR_LIST
		do
			if a_feature.is_function then
				if a_feature.is_regular then
					current_file.put_string (c_extern)
					current_file.put_character (' ')
					print_type_declaration (a_feature.result_type_set.static_type)
					current_file.put_character (' ')
					print_routine_name (a_feature, a_type)
					current_file.put_character ('(')
					print_type_declaration (a_type)
					current_file.put_character (' ')
					current_file.put_character ('C')
					l_arguments := a_feature.static_feature.arguments
					if l_arguments /= Void then
						nb := l_arguments.count
						if nb > 0 then
								-- Dynamic type sets for arguments are stored first
								-- in `dynamic_type_sets'.
							l_dynamic_type_sets := a_feature.dynamic_type_sets
							if l_dynamic_type_sets.count < nb then
									-- Internal error: it has already been checked somewhere else
									-- that there was the same number of actual and formal arguments.
								set_fatal_error
								error_handler.report_gibar_error
							else
								from i := 1 until i > nb loop
									current_file.put_character (',')
									current_file.put_character (' ')
									print_type_declaration (l_dynamic_type_sets.item (i).static_type)
									current_file.put_character (' ')
									current_file.put_character ('a')
									current_file.put_integer (i)
									i := i + 1
								end
							end
						end
					end
					current_file.put_character (')')
					current_file.put_character (';')
				 	current_file.put_new_line
				end
				if a_feature.is_static then
					current_file.put_string (c_extern)
					current_file.put_character (' ')
					print_type_declaration (a_feature.result_type_set.static_type)
					current_file.put_character (' ')
					print_static_routine_name (a_feature, a_type)
					current_file.put_character ('(')
					l_arguments := a_feature.static_feature.arguments
					if l_arguments /= Void then
						nb := l_arguments.count
						if nb > 0 then
								-- Dynamic type sets for arguments are stored first
								-- in `dynamic_type_sets'.
							l_dynamic_type_sets := a_feature.dynamic_type_sets
							if l_dynamic_type_sets.count < nb then
									-- Internal error: it has already been checked somewhere else
									-- that there was the same number of actual and formal arguments.
								set_fatal_error
								error_handler.report_giaed_error
							else
								from i := 1 until i > nb loop
									if i /= 1 then
										current_file.put_character (',')
										current_file.put_character (' ')
									end
									print_type_declaration (l_dynamic_type_sets.item (i).static_type)
									current_file.put_character (' ')
									current_file.put_character ('a')
									current_file.put_integer (i)
									i := i + 1
								end
							end
						end
					end
					current_file.put_character (')')
					current_file.put_character (';')
					current_file.put_new_line
				end
			elseif a_feature.is_procedure then
				if a_feature.is_regular then
					current_file.put_string (c_extern)
					current_file.put_character (' ')
					current_file.put_string (c_void)
					current_file.put_character (' ')
					print_routine_name (a_feature, a_type)
					current_file.put_character ('(')
					print_type_declaration (a_type)
					current_file.put_character (' ')
					current_file.put_character ('C')
					l_arguments := a_feature.static_feature.arguments
					if l_arguments /= Void then
						nb := l_arguments.count
						if nb > 0 then
								-- Dynamic type sets for arguments are stored first
								-- in `dynamic_type_sets'.
							l_dynamic_type_sets := a_feature.dynamic_type_sets
							if l_dynamic_type_sets.count < nb then
									-- Internal error: it has already been checked somewhere else
									-- that there was the same number of actual and formal arguments.
								set_fatal_error
								error_handler.report_giaec_error
							else
								from i := 1 until i > nb loop
									current_file.put_character (',')
									current_file.put_character (' ')
									print_type_declaration (l_dynamic_type_sets.item (i).static_type)
									current_file.put_character (' ')
									current_file.put_character ('a')
									current_file.put_integer (i)
									i := i + 1
								end
							end
						end
					end
					current_file.put_character (')')
					current_file.put_character (';')
					current_file.put_new_line
				end
				if a_feature.is_creation then
					current_file.put_string (c_extern)
					current_file.put_character (' ')
					print_type_declaration (a_type)
					current_file.put_character (' ')
					print_creation_procedure_name (a_feature, a_type)
					current_file.put_character ('(')
					l_arguments := a_feature.static_feature.arguments
					if l_arguments /= Void then
						nb := l_arguments.count
						if nb > 0 then
								-- Dynamic type sets for arguments are stored first
								-- in `dynamic_type_sets'.
							l_dynamic_type_sets := a_feature.dynamic_type_sets
							if l_dynamic_type_sets.count < nb then
									-- Internal error: it has already been checked somewhere else
									-- that there was the same number of actual and formal arguments.
								set_fatal_error
								error_handler.report_gibcb_error
							else
								from i := 1 until i > nb loop
									if i /= 1 then
										current_file.put_character (',')
										current_file.put_character (' ')
									end
									print_type_declaration (l_dynamic_type_sets.item (i).static_type)
									current_file.put_character (' ')
									current_file.put_character ('a')
									current_file.put_integer (i)
									i := i + 1
								end
							end
						end
					end
					current_file.put_character (')')
					current_file.put_character (';')
					current_file.put_new_line
				end
				if a_feature.is_static then
					current_file.put_string (c_extern)
					current_file.put_character (' ')
					current_file.put_string (c_void)
					current_file.put_character (' ')
					print_static_routine_name (a_feature, a_type)
					current_file.put_character ('(')
					l_arguments := a_feature.static_feature.arguments
					if l_arguments /= Void then
						nb := l_arguments.count
						if nb > 0 then
								-- Dynamic type sets for arguments are stored first
								-- in `dynamic_type_sets'.
							l_dynamic_type_sets := a_feature.dynamic_type_sets
							if l_dynamic_type_sets.count < nb then
									-- Internal error: it has already been checked somewhere else
									-- that there was the same number of actual and formal arguments.
								set_fatal_error
								error_handler.report_gibca_error
							else
								from i := 1 until i > nb loop
									if i /= 1 then
										current_file.put_character (',')
										current_file.put_character (' ')
									end
									print_type_declaration (l_dynamic_type_sets.item (i).static_type)
									current_file.put_character (' ')
									current_file.put_character ('a')
									current_file.put_integer (i)
									i := i + 1
								end
							end
						end
					end
					current_file.put_character (')')
					current_file.put_character (';')
					current_file.put_new_line
				end
			end
			l_precursor := a_feature.first_precursor
			if l_precursor /= Void then
				print_feature_declaration (l_precursor, a_type)
				l_other_precursors := a_feature.other_precursors
				if l_other_precursors /= Void then
					nb := l_other_precursors.count
					from i := 1 until i > nb loop
						print_feature_declaration (l_other_precursors.item (i), a_type)
						i := i + 1
					end
				end
			end
		end

	print_features (a_type: ET_DYNAMIC_TYPE) is
			-- Print features of `a_type'.
		require
			a_type_not_void: a_type /= Void
		local
			old_type: ET_DYNAMIC_TYPE
			l_features: ET_DYNAMIC_FEATURE_LIST
			i, nb: INTEGER
		do
			old_type := current_type
			current_type := a_type
			l_features := a_type.features
			if l_features /= Void then
				nb := l_features.count
				from i := 1 until i > nb loop
					print_feature (l_features.item (i))
					i := i + 1
				end
			end
			current_type := old_type
		end

	print_feature (a_feature: ET_DYNAMIC_FEATURE) is
			-- Print `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		local
			old_feature: ET_DYNAMIC_FEATURE
			l_precursor: ET_DYNAMIC_PRECURSOR
			l_other_precursors: ET_DYNAMIC_PRECURSOR_LIST
			i, nb: INTEGER
		do
			old_feature := current_feature
			current_feature := a_feature
			local_count := 0
			a_feature.static_feature.process (Current)
			current_feature := old_feature
			l_precursor := a_feature.first_precursor
			if l_precursor /= Void then
				print_feature (l_precursor)
				l_other_precursors := a_feature.other_precursors
				if l_other_precursors /= Void then
					nb := l_other_precursors.count
					from i := 1 until i > nb loop
						print_feature (l_other_precursors.item (i))
						i := i + 1
					end
				end
			end
		end

	print_deferred_function (a_feature: ET_DEFERRED_FUNCTION) is
			-- Print `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
				-- Internal error: deferred features cannot be executed at run-time.
			set_fatal_error
			error_handler.report_gibdm_error
		end

	print_deferred_procedure (a_feature: ET_DEFERRED_PROCEDURE) is
			-- Print `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
				-- Internal error: deferred features cannot be executed at run-time.
			set_fatal_error
			error_handler.report_gibdn_error
		end

	print_do_function (a_feature: ET_DO_FUNCTION) is
			-- Print `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
			print_internal_function (a_feature)
		end

	print_do_procedure (a_feature: ET_DO_PROCEDURE) is
			-- Print `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
			print_internal_procedure (a_feature)
		end

	print_external_function (a_feature: ET_EXTERNAL_FUNCTION) is
			-- Print `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
			if current_feature.static_feature /= a_feature then
					-- Internal error: inconsistent `current_feature'.
				set_fatal_error
				error_handler.report_giadl_error
			else
				if current_feature.is_regular then
					print_external_routine (a_feature, False)
				end
				if current_feature.is_static then
					print_external_routine (a_feature, True)
				end
			end
		end

	print_external_procedure (a_feature: ET_EXTERNAL_PROCEDURE) is
			-- Print `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
			if current_feature.static_feature /= a_feature then
					-- Internal error: inconsistent `current_feature'.
				set_fatal_error
				error_handler.report_giadu_error
			else
				if current_feature.is_regular then
					print_external_routine (a_feature, False)
				end
				if current_feature.is_static then
					print_external_routine (a_feature, True)
				end
			end
		end

	print_external_routine (a_feature: ET_EXTERNAL_ROUTINE; a_static: BOOLEAN) is
			-- Print `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
			valid_feature: current_feature.static_feature = a_feature
			is_static: a_static implies current_feature.is_static
		local
			l_result_type_set: ET_DYNAMIC_TYPE_SET
			l_dynamic_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_arguments: ET_FORMAL_ARGUMENT_LIST
			i, j, nb: INTEGER
			i2, nb2: INTEGER
			i3, nb3: INTEGER
			l_max: INTEGER
			l_max_index: INTEGER
			c, c3: CHARACTER
			l_language: ET_EXTERNAL_LANGUAGE
			l_language_value: ET_MANIFEST_STRING
			l_alias: ET_EXTERNAL_ALIAS
			l_alias_value: ET_MANIFEST_STRING
			l_c_code: STRING
			l_formal_arguments: ET_FORMAL_ARGUMENT_LIST
			l_name: STRING
			l_comma: BOOLEAN
		do
			print_feature_name_comment (a_feature, current_type)
			l_result_type_set := current_feature.result_type_set
			if l_result_type_set /= Void then
				print_type_declaration (l_result_type_set.static_type)
			else
				current_file.put_string (c_void)
			end
			current_file.put_character (' ')
			if a_static then
				print_static_routine_name (current_feature, current_type)
				current_file.put_character ('(')
			else
				print_routine_name (current_feature, current_type)
				current_file.put_character ('(')
				print_type_declaration (current_type)
				current_file.put_character (' ')
				current_file.put_character ('C')
				l_comma := True
			end
			l_arguments := a_feature.arguments
			if l_arguments /= Void then
				nb := l_arguments.count
				if nb > 0 then
						-- Dynamic type sets for arguments are stored first
						-- in `dynamic_type_sets'.
					l_dynamic_type_sets := current_feature.dynamic_type_sets
					if l_dynamic_type_sets.count < nb then
							-- Internal error: it has already been checked somewhere else
							-- that there was the same number of actual and formal arguments.
						set_fatal_error
						error_handler.report_gibdz_error
					else
						from i := 1 until i > nb loop
							if l_comma then
								current_file.put_character (',')
								current_file.put_character (' ')
							else
								l_comma := True
							end
							print_type_declaration (l_dynamic_type_sets.item (i).static_type)
							current_file.put_character (' ')
							current_file.put_character ('a')
							current_file.put_integer (i)
							i := i + 1
						end
					end
				end
			end
			current_file.put_character (')')
			current_file.put_new_line
			current_file.put_character ('{')
			current_file.put_new_line
			indent
			if l_result_type_set /= Void then
				print_indentation
				print_type_declaration (l_result_type_set.static_type)
				current_file.put_character (' ')
				current_file.put_character ('R')
				current_file.put_character (' ')
				current_file.put_character ('=')
				current_file.put_character (' ')
				current_file.put_character ('0')
				current_file.put_character (';')
				current_file.put_new_line
			end
			l_language := a_feature.language
			l_language_value := l_language.manifest_string
			if not l_language_value.computed then
				l_language_value.compute (error_handler)
			end
			if STRING_.same_case_insensitive (l_language_value.value, e_inline) then
				l_alias := a_feature.alias_clause
				if l_alias /= Void then
					l_alias_value := l_alias.manifest_string
					if not l_alias_value.computed then
						l_alias_value.compute (error_handler)
					end
					l_c_code := l_alias_value.value
					l_formal_arguments := a_feature.arguments
					if l_formal_arguments /= Void then
						nb := l_c_code.count
						from i := 1 until i > nb loop
							c := l_c_code.item (i)
							if c = '$' then
								i := i + 1
								if i <= nb then
									c := l_c_code.item (i)
									inspect c
									when '$' then
										current_file.put_character ('$')
										i := i + 1
									when 'a'..'z', 'A'..'Z' then
										l_max := 0
										l_max_index := 0
										nb2 := l_formal_arguments.count
										from i2 := 1 until i2 > nb2 loop
											l_name := l_formal_arguments.formal_argument (i2).name.name
											nb3 := l_name.count
											if nb3 > l_max then
												from
													i3 := 1
													j := i
												until
													j > nb or
													i3 > nb3
												loop
													c := l_c_code.item (j)
													c3 := l_name.item (i3)
													if CHARACTER_.as_lower (c3) = CHARACTER_.as_lower (c) then
														i3 := i3 + 1
														j := j + 1
													else
														j := nb + 1
													end
												end
												if i3 > nb3 then
													l_max_index := i2
													l_max := nb3
												end
											end
											i2 := i2 + 1
										end
										if l_max_index /= 0 then
											current_file.put_character ('a')
											current_file.put_integer (l_max_index)
											i := i + l_max
										else
											current_file.put_character ('$')
											current_file.put_character (l_c_code.item (i))
											i := i + 1
										end
									else
										current_file.put_character ('$')
										current_file.put_character (c)
										i := i + 1
									end
								else
									current_file.put_character ('$')
								end
							else
								current_file.put_character (c)
								i := i + 1
							end
						end
						current_file.put_new_line
					else
						current_file.put_line (l_c_code)
					end
				end
			elseif l_result_type_set /= Void then
				print_indentation
				current_file.put_string (c_return)
				current_file.put_character (' ')
				current_file.put_character ('R')
				current_file.put_character (';')
				current_file.put_new_line
			end
			dedent
			current_file.put_character ('}')
			current_file.put_new_line
			current_file.put_new_line
		end

	print_internal_function (a_feature: ET_INTERNAL_FUNCTION) is
			-- Print `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
			if current_feature.static_feature /= a_feature then
					-- Internal error: inconsistent `current_feature'.
				set_fatal_error
				error_handler.report_gibcg_error
			else
				if current_feature.is_regular then
					print_internal_routine (a_feature, False, False)
				end
				if current_feature.is_static then
					print_internal_routine (a_feature, True, False)
				end
			end
		end

	print_internal_procedure (a_feature: ET_INTERNAL_PROCEDURE) is
			-- Print `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
			if current_feature.static_feature /= a_feature then
					-- Internal error: inconsistent `current_feature'.
				set_fatal_error
				error_handler.report_gibci_error
			else
				if current_feature.is_regular then
					print_internal_routine (a_feature, False, False)
				end
				if current_feature.is_creation then
					print_internal_routine (a_feature, False, True)
				end
				if current_feature.is_static then
					print_internal_routine (a_feature, True, False)
				end
			end
		end

	print_internal_routine (a_feature: ET_INTERNAL_ROUTINE; a_static: BOOLEAN; a_creation: BOOLEAN) is
			-- Print `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
			valid_feature: current_feature.static_feature = a_feature
			is_static: a_static implies current_feature.is_static
			is_creation: a_creation implies current_feature.is_creation
		local
			l_result_type_set: ET_DYNAMIC_TYPE_SET
			l_dynamic_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_arguments: ET_FORMAL_ARGUMENT_LIST
			l_locals: ET_LOCAL_VARIABLE_LIST
			l_local_type_set: ET_DYNAMIC_TYPE_SET
			i, nb: INTEGER
			l_compound: ET_COMPOUND
			l_comma: BOOLEAN
		do
			print_feature_name_comment (a_feature, current_type)
			l_result_type_set := current_feature.result_type_set
			if l_result_type_set /= Void then
				print_type_declaration (l_result_type_set.static_type)
			elseif a_creation then
				print_type_declaration (current_type)
			else
				current_file.put_string (c_void)
			end
			current_file.put_character (' ')
			if a_static then
				print_static_routine_name (current_feature, current_type)
				current_file.put_character ('(')
			elseif a_creation then
				print_creation_procedure_name (current_feature, current_type)
				current_file.put_character ('(')
			else
				print_routine_name (current_feature, current_type)
				current_file.put_character ('(')
				print_type_declaration (current_type)
				current_file.put_character (' ')
				current_file.put_character ('C')
				l_comma := True
			end
			l_arguments := a_feature.arguments
			if l_arguments /= Void then
				nb := l_arguments.count
				if nb > 0 then
						-- Dynamic type sets for arguments are stored first
						-- in `dynamic_type_sets'.
					l_dynamic_type_sets := current_feature.dynamic_type_sets
					if l_dynamic_type_sets.count < nb then
							-- Internal error: it has already been checked somewhere else
							-- that there was the same number of actual and formal arguments.
						set_fatal_error
						error_handler.report_gibdy_error
					else
						from i := 1 until i > nb loop
							if l_comma then
								current_file.put_character (',')
								current_file.put_character (' ')
							else
								l_comma := True
							end
							print_type_declaration (l_dynamic_type_sets.item (i).static_type)
							current_file.put_character (' ')
							current_file.put_character ('a')
							current_file.put_integer (i)
							i := i + 1
						end
					end
				end
			end
			current_file.put_character (')')
			current_file.put_new_line
			current_file.put_character ('{')
			current_file.put_new_line
			indent
			if l_result_type_set /= Void then
				print_indentation
				print_type_declaration (l_result_type_set.static_type)
				current_file.put_character (' ')
				current_file.put_character ('R')
				current_file.put_character (' ')
				current_file.put_character ('=')
				current_file.put_character (' ')
				current_file.put_character ('0')
				current_file.put_character (';')
				current_file.put_new_line
			end
			l_locals := a_feature.locals
			if l_locals /= Void then
				nb := l_locals.count
				from i := 1 until i > nb loop
					l_local_type_set := current_feature.dynamic_type_set (l_locals.local_variable (i).name)
					if l_local_type_set = Void then
							-- Internal error: the dynamic type of local variable
							-- should be known at this stage.
						set_fatal_error
						error_handler.report_gibdx_error
					else
						print_indentation
						print_type_declaration (l_local_type_set.static_type)
						current_file.put_character (' ')
						current_file.put_character ('l')
						current_file.put_integer (i)
						current_file.put_character (' ')
						current_file.put_character ('=')
						current_file.put_character (' ')
						current_file.put_character ('0')
						current_file.put_character (';')
						current_file.put_new_line
					end
					i := i + 1
				end
			end
			if a_creation then
				print_indentation
				print_type_declaration (current_type)
				current_file.put_character (' ')
				current_file.put_character ('C')
				current_file.put_character (';')
				current_file.put_new_line
				print_indentation
				current_file.put_character ('C')
				current_file.put_character (' ')
				current_file.put_character ('=')
				current_file.put_character (' ')
				current_file.put_character ('(')
				print_type_declaration (current_type)
				current_file.put_character (')')
				current_file.put_string (c_malloc)
				current_file.put_character ('(')
				current_file.put_string (c_sizeof)
				current_file.put_character ('(')
				print_type_name (current_type)
				current_file.put_character (')')
				current_file.put_character (')')
				current_file.put_character (';')
				current_file.put_new_line
			end
-- TODO
			if current_type = current_system.character_type then
			elseif current_type = current_system.boolean_type then
			elseif current_type = current_system.integer_8_type then
			elseif current_type = current_system.integer_16_type then
			elseif current_type = current_system.integer_type then
			elseif current_type = current_system.integer_64_type then
			elseif current_type = current_system.real_type then
			elseif current_type = current_system.double_type then
			elseif current_type = current_system.pointer_type then
			else
				l_compound := a_feature.compound
				if l_compound /= Void then
					print_compound (l_compound)
				end
			end
			if l_result_type_set /= Void then
				print_indentation
				current_file.put_string (c_return)
				current_file.put_character (' ')
				current_file.put_character ('R')
				current_file.put_character (';')
				current_file.put_new_line
			elseif a_creation then
				print_indentation
				current_file.put_string (c_return)
				current_file.put_character (' ')
				current_file.put_character ('C')
				current_file.put_character (';')
				current_file.put_new_line
			end
			dedent
			current_file.put_character ('}')
			current_file.put_new_line
			current_file.put_new_line
		end

	print_once_function (a_feature: ET_ONCE_FUNCTION) is
			-- Print `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
			print_internal_function (a_feature)
		end

	print_once_procedure (a_feature: ET_ONCE_PROCEDURE) is
			-- Print `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
			print_internal_procedure (a_feature)
		end

feature {NONE} -- Instruction generation

	print_assignment (an_instruction: ET_ASSIGNMENT) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		do
			print_writable (an_instruction.target)
			current_file.put_character (' ')
			current_file.put_character ('=')
			current_file.put_character (' ')
			current_file.put_character ('(')
			print_expression (an_instruction.source)
			current_file.put_character (')')
			current_file.put_character (';')
		end

	print_assignment_attempt (an_instruction: ET_ASSIGNMENT_ATTEMPT) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		local
			l_other_types: ET_DYNAMIC_TYPE_LIST
			i, nb: INTEGER
			l_local_index: INTEGER
			l_source_type_set: ET_DYNAMIC_TYPE_SET
			l_source_type: ET_DYNAMIC_TYPE
			l_target_type_set: ET_DYNAMIC_TYPE_SET
			l_target_type: ET_DYNAMIC_TYPE
			l_accepted_types: ET_DYNAMIC_TYPE_LIST
			l_denied_types: ET_DYNAMIC_TYPE_LIST
		do
			l_source_type_set := current_feature.dynamic_type_set (an_instruction.source)
			l_target_type_set := current_feature.dynamic_type_set (an_instruction.target)
			if l_source_type_set = Void or l_target_type_set = Void then
					-- Internal error: the dynamic type sets of the source
					-- and the target should be known at this stage.
				set_fatal_error
				error_handler.report_gibcj_error
			else
				nb := l_source_type_set.count
				l_accepted_types := accepted_types
				l_accepted_types.resize (nb)
				l_denied_types := denied_types
				l_denied_types.resize (nb)
				l_target_type := l_target_type_set.static_type
				l_source_type := l_source_type_set.first_type
				if l_source_type /= Void then
					if l_source_type.conforms_to_type (l_target_type, current_system) then
						l_accepted_types.put_last (l_source_type)
					else
						l_denied_types.put_last (l_source_type)
					end
					l_other_types := l_source_type_set.other_types
					if l_other_types /= Void then
						nb := l_other_types.count
						from i := 1 until i > nb loop
							l_source_type := l_other_types.item (i)
							if l_source_type.conforms_to_type (l_target_type, current_system) then
								l_accepted_types.put_last (l_source_type)
							else
								l_denied_types.put_last (l_source_type)
							end
							i := i + 1
						end
					end
				end
				if l_denied_types.is_empty then
						-- Direct assignment.
					print_writable (an_instruction.target)
					current_file.put_character (' ')
					current_file.put_character ('=')
					current_file.put_character (' ')
					current_file.put_character ('(')
					print_expression (an_instruction.source)
					current_file.put_character (')')
					current_file.put_character (';')
				elseif l_accepted_types.is_empty then
						-- We need to compute the source (in case there is
						-- a side-effect) before assigning Void to the target.
					local_count := local_count + 1
					l_local_index := local_count
					print_reference_local_declaration (l_local_index)
					current_file.put_character ('z')
					current_file.put_integer (l_local_index)
					current_file.put_character (' ')
					current_file.put_character ('=')
					current_file.put_character (' ')
					current_file.put_character ('(')
					print_expression (an_instruction.source)
					current_file.put_character (')')
					current_file.put_character (';')
					current_file.put_new_line
					print_indentation
					print_writable (an_instruction.target)
					current_file.put_character (' ')
					current_file.put_character ('=')
					current_file.put_character (' ')
					current_file.put_string (c_eif_void)
					current_file.put_character (';')
				elseif l_denied_types.count < l_accepted_types.count then
					local_count := local_count + 1
					l_local_index := local_count
					print_reference_local_declaration (l_local_index)
					current_file.put_character ('z')
					current_file.put_integer (l_local_index)
					current_file.put_character (' ')
					current_file.put_character ('=')
					current_file.put_character (' ')
					current_file.put_character ('(')
					print_expression (an_instruction.source)
					current_file.put_character (')')
					current_file.put_character (';')
					current_file.put_new_line
					print_indentation
					current_file.put_string (c_switch)
					current_file.put_character (' ')
					current_file.put_character ('(')
					current_file.put_character ('z')
					current_file.put_integer (l_local_index)
					current_file.put_string (c_arrow)
					current_file.put_string (c_id)
					current_file.put_character (')')
					current_file.put_character (' ')
					current_file.put_character ('{')
					current_file.put_new_line
					nb := l_denied_types.count
					from i := 1 until i > nb loop
						l_source_type := l_denied_types.item (i)
						print_indentation
						current_file.put_string (c_case)
						current_file.put_character (' ')
						current_file.put_integer (l_source_type.id)
						current_file.put_character (':')
						current_file.put_new_line
						i := i + 1
					end
					indent
					print_indentation
					print_writable (an_instruction.target)
					current_file.put_character (' ')
					current_file.put_character ('=')
					current_file.put_character (' ')
					current_file.put_string (c_eif_void)
					current_file.put_character (';')
					current_file.put_new_line
					print_indentation
					current_file.put_string (c_break)
					current_file.put_character (';')
					current_file.put_new_line
					dedent
					print_indentation
					current_file.put_string (c_default)
					current_file.put_character (':')
					current_file.put_new_line
					indent
					print_indentation
					print_writable (an_instruction.target)
					current_file.put_character (' ')
					current_file.put_character ('=')
					current_file.put_character (' ')
					current_file.put_character ('z')
					current_file.put_integer (l_local_index)
					current_file.put_character (';')
					current_file.put_new_line
					dedent
					print_indentation
					current_file.put_character ('}')
				else
					local_count := local_count + 1
					l_local_index := local_count
					print_reference_local_declaration (l_local_index)
					current_file.put_character ('z')
					current_file.put_integer (l_local_index)
					current_file.put_character (' ')
					current_file.put_character ('=')
					current_file.put_character (' ')
					current_file.put_character ('(')
					print_expression (an_instruction.source)
					current_file.put_character (')')
					current_file.put_character (';')
					current_file.put_new_line
					print_indentation
					current_file.put_string (c_switch)
					current_file.put_character (' ')
					current_file.put_character ('(')
					current_file.put_character ('z')
					current_file.put_integer (l_local_index)
					current_file.put_string (c_arrow)
					current_file.put_string (c_id)
					current_file.put_character (')')
					current_file.put_character (' ')
					current_file.put_character ('{')
					current_file.put_new_line
					nb := l_accepted_types.count
					from i := 1 until i > nb loop
						l_source_type := l_accepted_types.item (i)
						print_indentation
						current_file.put_string (c_case)
						current_file.put_character (' ')
						current_file.put_integer (l_source_type.id)
						current_file.put_character (':')
						current_file.put_new_line
						i := i + 1
					end
					indent
					print_indentation
					print_writable (an_instruction.target)
					current_file.put_character (' ')
					current_file.put_character ('=')
					current_file.put_character (' ')
					current_file.put_character ('z')
					current_file.put_integer (l_local_index)
					current_file.put_character (';')
					current_file.put_new_line
					print_indentation
					current_file.put_string (c_break)
					current_file.put_character (';')
					current_file.put_new_line
					dedent
					print_indentation
					current_file.put_string (c_default)
					current_file.put_character (':')
					current_file.put_new_line
					indent
					print_indentation
					print_writable (an_instruction.target)
					current_file.put_character (' ')
					current_file.put_character ('=')
					current_file.put_character (' ')
					current_file.put_string (c_eif_void)
					current_file.put_character (';')
					current_file.put_new_line
					dedent
					print_indentation
					current_file.put_character ('}')
					current_file.put_character (';')
				end
				l_accepted_types.wipe_out
				l_denied_types.wipe_out
			end
		end

	print_bang_instruction (an_instruction: ET_BANG_INSTRUCTION) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		do
			print_creation_instruction (an_instruction)
		end

	print_call_instruction (an_instruction: ET_CALL_INSTRUCTION) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		do
			if an_instruction.is_qualified_call then
				print_qualified_call (an_instruction)
			else
				print_unqualified_call (an_instruction)
			end
		end

	print_check_instruction (an_instruction: ET_CHECK_INSTRUCTION) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		do
			-- Do nothing.
		end

	print_compound (a_compound: ET_COMPOUND) is
			-- Print `a_compound'.
		require
			a_compound_not_void: a_compound /= Void
		local
			i, nb: INTEGER
		do
			nb := a_compound.count
			from i := 1 until i > nb loop
				print_indentation
				print_instruction (a_compound.item (i))
				current_file.put_new_line
				i := i + 1
			end
		end

	print_create_instruction (an_instruction: ET_CREATE_INSTRUCTION) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		do
			print_creation_instruction (an_instruction)
		end

	print_creation_instruction (an_instruction: ET_CREATION_INSTRUCTION) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		local
			l_target: ET_WRITABLE
			l_type: ET_TYPE
			l_resolved_type: ET_TYPE
			l_dynamic_type: ET_DYNAMIC_TYPE
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			l_call: ET_QUALIFIED_CALL
			l_seed: INTEGER
			l_actuals: ET_ACTUAL_ARGUMENT_LIST
			l_feature: ET_FEATURE
			l_dynamic_feature: ET_DYNAMIC_FEATURE
		do
				-- Look for the dynamic type of the creation type.
			l_target := an_instruction.target
			l_type := an_instruction.type
			if l_type /= Void then
				l_resolved_type := resolved_formal_parameters (l_type)
				if not has_fatal_error then
					l_dynamic_type := current_system.dynamic_type (l_resolved_type, current_type.base_type)
				end
			else
					-- Look for the dynamic type of the target.
				l_dynamic_type_set := current_feature.dynamic_type_set (l_target)
				if l_dynamic_type_set = Void then
						-- Internal error: the dynamic type sets of the
						-- target should be known at this stage.
					set_fatal_error
					error_handler.report_gibck_error
				else
					l_dynamic_type := l_dynamic_type_set.static_type
				end
			end
			if l_dynamic_type /= Void then
				l_call := an_instruction.creation_call
				if l_call /= Void then
					l_seed := l_call.name.seed
					l_actuals := l_call.arguments
				else
					l_seed := universe.default_create_seed
					l_actuals := Void
				end
				l_feature := l_dynamic_type.base_class.seeded_feature (l_seed)
				if l_feature = Void then
						-- Internal error: there should be a feature with `l_seed'.
						-- It has been computed in ET_FEATURE_CHECKER or else an
						-- error should have already been reported.
					set_fatal_error
					error_handler.report_gibcr_error
				elseif not l_feature.is_procedure then
						-- Internal error: the creation routine should be a procedure.
					set_fatal_error
					error_handler.report_gibcs_error
				else
					print_writable (l_target)
					current_file.put_character (' ')
					current_file.put_character ('=')
					current_file.put_character (' ')
					current_file.put_character ('(')
					l_dynamic_feature := l_dynamic_type.dynamic_feature (l_feature, current_system)
					print_creation_expression (l_dynamic_type, l_dynamic_feature, l_actuals)
					current_file.put_character (')')
					current_file.put_character (';')
				end
			end
		end

	print_debug_instruction (an_instruction: ET_DEBUG_INSTRUCTION) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		do
			-- Do nothing.
		end

	print_if_instruction (an_instruction: ET_IF_INSTRUCTION) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		local
			a_compound: ET_COMPOUND
			an_elseif_parts: ET_ELSEIF_PART_LIST
			an_elseif: ET_ELSEIF_PART
			i, nb: INTEGER
		do
			current_file.put_string (c_if)
			current_file.put_character (' ')
			current_file.put_character ('(')
			print_expression (an_instruction.expression)
			current_file.put_character (')')
			current_file.put_character (' ')
			current_file.put_character ('{')
			current_file.put_new_line
			a_compound := an_instruction.then_compound
			if a_compound /= Void then
				indent
				print_compound (a_compound)
				dedent
			end
			print_indentation
			current_file.put_character ('}')
			an_elseif_parts := an_instruction.elseif_parts
			if an_elseif_parts /= Void then
				nb := an_elseif_parts.count
				from i := 1 until i > nb loop
					an_elseif := an_elseif_parts.item (i)
					current_file.put_character (' ')
					current_file.put_string (c_else)
					current_file.put_character (' ')
					current_file.put_string (c_if)
					current_file.put_character (' ')
					current_file.put_character ('(')
					print_expression (an_elseif.expression)
					current_file.put_character (')')
					current_file.put_character (' ')
					current_file.put_character ('{')
					current_file.put_new_line
					a_compound := an_elseif.then_compound
					if a_compound /= Void then
						indent
						print_compound (a_compound)
						dedent
					end
					print_indentation
					current_file.put_character ('}')
					i := i + 1
				end
			end
			a_compound := an_instruction.else_compound
			if a_compound /= Void then
				current_file.put_character (' ')
				current_file.put_string (c_else)
				current_file.put_character (' ')
				current_file.put_character ('{')
				current_file.put_new_line
				indent
				print_compound (a_compound)
				dedent
				print_indentation
				current_file.put_character ('}')
			end
			current_file.put_character (';')
		end

	print_inspect_instruction (an_instruction: ET_INSPECT_INSTRUCTION) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		local
			an_expression: ET_EXPRESSION
			a_when_parts: ET_WHEN_PART_LIST
			a_when_part: ET_WHEN_PART
			a_choices: ET_CHOICE_LIST
			a_choice: ET_CHOICE
			a_compound: ET_COMPOUND
			i, nb: INTEGER
			j, nb2: INTEGER
			l_has_case: BOOLEAN
		do
-- TODO.
			current_file.put_string (c_switch)
			current_file.put_character (' ')
			current_file.put_character ('(')
			an_expression := an_instruction.conditional.expression
			print_expression (an_expression)
			current_file.put_character (')')
			current_file.put_character (' ')
			current_file.put_character ('{')
			current_file.put_new_line
			a_when_parts := an_instruction.when_parts
			if a_when_parts /= Void then
				nb := a_when_parts.count
				from i := 1 until i > nb loop
					a_when_part := a_when_parts.item (i)
					a_choices := a_when_part.choices
					nb2 := a_choices.count
					if nb2 = 0 then
						-- Do nothing.
					else
						l_has_case := False
						from j := 1 until j > nb2 loop
							a_choice := a_choices.choice (j)
							if a_choice.is_range then
-- TODO
							else
								l_has_case := True
								print_indentation
								current_file.put_string (c_case)
								current_file.put_character (' ')
								print_expression (a_choice.lower.expression)
								current_file.put_character (':')
								current_file.put_new_line
							end
							j := j + 1
						end
						if l_has_case then
							indent
							a_compound := a_when_part.then_compound
							if a_compound /= Void then
								print_compound (a_compound)
							end
							print_indentation
							current_file.put_string (c_break)
							current_file.put_character (';')
							current_file.put_new_line
							dedent
						end
					end
					i := i + 1
				end
			end
			print_indentation
			current_file.put_string (c_default)
			current_file.put_character (':')
			current_file.put_new_line
			a_compound := an_instruction.else_compound
			if a_compound /= Void then
				indent
				print_compound (a_compound)
				dedent
			else
-- TODO.
				indent
				print_indentation
				current_file.put_character (';')
				current_file.put_new_line
				dedent
			end
			print_indentation
			current_file.put_character ('}')
			current_file.put_character (';')
		end

	print_instruction (an_instruction: ET_INSTRUCTION) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		local
			l_instruction_buffer_string: STRING
			l_instruction_buffer: KL_STRING_OUTPUT_STREAM
			l_local_buffer_string: STRING
			l_local_buffer: KL_STRING_OUTPUT_STREAM
			old_file: like current_file
			old_local_buffer: like current_local_buffer
		do
			if not instruction_buffer_stack.is_empty then
				l_instruction_buffer := instruction_buffer_stack.item
				instruction_buffer_stack.remove
				l_instruction_buffer_string := l_instruction_buffer.string
				STRING_.wipe_out (l_instruction_buffer_string)
			else
				l_instruction_buffer_string := STRING_.make (256)
				create l_instruction_buffer.make (l_instruction_buffer_string)
			end
			old_file := current_file
			current_file := l_instruction_buffer
			if not local_buffer_stack.is_empty then
				l_local_buffer := local_buffer_stack.item
				local_buffer_stack.remove
				l_local_buffer_string := l_local_buffer.string
				STRING_.wipe_out (l_local_buffer_string)
			else
				l_local_buffer_string := STRING_.make (256)
				create l_local_buffer.make (l_local_buffer_string)
			end
			old_local_buffer := current_local_buffer
			current_local_buffer := l_local_buffer
			an_instruction.process (Current)
			current_file := old_file
			instruction_buffer_stack.force (l_instruction_buffer)
			current_local_buffer := old_local_buffer
			local_buffer_stack.force (l_local_buffer)
			if l_local_buffer_string.count > 0 then
				current_file.put_character ('{')
				current_file.put_new_line
				current_file.put_string (l_local_buffer_string)
				print_indentation
				current_file.put_string (l_instruction_buffer_string)
				current_file.put_new_line
				print_indentation
				current_file.put_character ('}')
				current_file.put_character (';')
			else
				current_file.put_string (l_instruction_buffer_string)
			end
		end

	print_loop_instruction (an_instruction: ET_LOOP_INSTRUCTION) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		local
			a_compound: ET_COMPOUND
		do
			a_compound := an_instruction.from_compound
			if a_compound /= Void then
				print_compound (a_compound)
				print_indentation
			end
			current_file.put_string (c_while)
			current_file.put_character (' ')
			current_file.put_character ('(')
			print_expression (an_instruction.until_expression)
			current_file.put_character (')')
			current_file.put_character (' ')
			current_file.put_character ('{')
			current_file.put_new_line
			a_compound := an_instruction.loop_compound
			if a_compound /= Void then
				indent
				print_compound (a_compound)
				dedent
			end
			print_indentation
			current_file.put_character ('}')
			current_file.put_character (';')
		end

	print_precursor_instruction (an_instruction: ET_PRECURSOR_INSTRUCTION) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		do
			print_precursor_call (an_instruction)
			current_file.put_character (';')
		end

	print_retry_instruction (an_instruction: ET_RETRY_INSTRUCTION) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		do
-- TODO.
		end

	print_static_call_instruction (an_instruction: ET_STATIC_CALL_INSTRUCTION) is
			-- Print `an_instruction'.
		require
			an_instruction_not_void: an_instruction /= Void
		do
			print_static_call (an_instruction)
		end

feature {NONE} -- Expression generation

	print_bit_constant (a_constant: ET_BIT_CONSTANT) is
			-- Print `a_constant'.
		require
			a_constant_not_void: a_constant /= Void
		do
-- TODO.
		end

	print_c1_character_constant (a_constant: ET_C1_CHARACTER_CONSTANT) is
			-- Print `a_constant'.
		require
			a_constant_not_void: a_constant /= Void
		local
			c: CHARACTER
		do
			print_type_cast (current_system.character_type)
			current_file.put_character ('(')
			current_file.put_character ('%'')
			c := a_constant.value
			inspect c
			when ' ', '!', '#', '$', '&', '('..'[', ']'..'~' then
				current_file.put_character (c)
			when '%N' then
				current_file.put_character ('\')
				current_file.put_character ('n')
			when '%R' then
				current_file.put_character ('\')
				current_file.put_character ('r')
			when '%T' then
				current_file.put_character ('\')
				current_file.put_character ('t')
			when '\' then
				current_file.put_character ('\')
				current_file.put_character ('\')
			when '%'' then
				current_file.put_character ('\')
				current_file.put_character ('%'')
			when '%"' then
				current_file.put_character ('\')
				current_file.put_character ('%"')
			else
				current_file.put_character ('\')
				INTEGER_FORMATTER_.put_octal_integer (current_file, c.code)
			end
			current_file.put_character ('%'')
			current_file.put_character (')')
		end

	print_c2_character_constant (a_constant: ET_C2_CHARACTER_CONSTANT) is
			-- Print `a_constant'.
		require
			a_constant_not_void: a_constant /= Void
		local
			c: CHARACTER
		do
			print_type_cast (current_system.character_type)
			current_file.put_character ('(')
			current_file.put_character ('%'')
			c := a_constant.value
			inspect c
			when ' ', '!', '#', '$', '&', '('..'[', ']'..'~' then
				current_file.put_character (c)
			when '%N' then
				current_file.put_character ('\')
				current_file.put_character ('n')
			when '%R' then
				current_file.put_character ('\')
				current_file.put_character ('r')
			when '%T' then
				current_file.put_character ('\')
				current_file.put_character ('t')
			when '\' then
				current_file.put_character ('\')
				current_file.put_character ('\')
			when '%'' then
				current_file.put_character ('\')
				current_file.put_character ('%'')
			when '%"' then
				current_file.put_character ('\')
				current_file.put_character ('%"')
			else
				current_file.put_character ('\')
				INTEGER_FORMATTER_.put_octal_integer (current_file, c.code)
			end
			current_file.put_character ('%'')
			current_file.put_character (')')
		end

	print_c3_character_constant (a_constant: ET_C3_CHARACTER_CONSTANT) is
			-- Print `a_constant'.
		require
			a_constant_not_void: a_constant /= Void
		do
			print_type_cast (current_system.character_type)
			current_file.put_character ('(')
			current_file.put_character ('%'')
			current_file.put_character ('\')
-- TODO
			INTEGER_FORMATTER_.put_octal_integer (current_file, a_constant.literal.to_integer)
			current_file.put_character ('%'')
			current_file.put_character (')')
		end

	print_call_expression (an_expression: ET_CALL_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
			if an_expression.is_qualified_call then
				print_qualified_call (an_expression)
			else
				print_unqualified_call (an_expression)
			end
		end

	print_convert_expression (an_expression: ET_CONVERT_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		local
			a_convert_feature: ET_CONVERT_FEATURE
			an_actuals: ET_ACTUAL_ARGUMENTS
		do
			a_convert_feature := an_expression.convert_feature
			if a_convert_feature.is_convert_from then
				an_actuals := an_expression.expression
-- TODO.
--				check_creation_expression_validity (current_target_type.named_type (universe),
--					a_convert_feature.name, an_actuals)
				print_expression (an_expression.expression)
			else
				print_expression (an_expression.expression)
			end
		end

	print_convert_to_expression (an_expression: ET_CONVERT_TO_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
			print_qualified_call (an_expression)
		end

	print_create_expression (an_expression: ET_CREATE_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		local
			l_type: ET_TYPE
			l_resolved_type: ET_TYPE
			l_dynamic_type: ET_DYNAMIC_TYPE
			l_call: ET_QUALIFIED_CALL
			l_seed: INTEGER
			l_actuals: ET_ACTUAL_ARGUMENT_LIST
			l_feature: ET_FEATURE
			l_dynamic_feature: ET_DYNAMIC_FEATURE
		do
			l_type := an_expression.type
			l_resolved_type := resolved_formal_parameters (l_type)
			if not has_fatal_error then
				l_dynamic_type := current_system.dynamic_type (l_resolved_type, current_type.base_type)
				l_call := an_expression.creation_call
				if l_call /= Void then
					l_seed := l_call.name.seed
					l_actuals := l_call.arguments
				else
					l_seed := universe.default_create_seed
					l_actuals := Void
				end
				l_feature := l_dynamic_type.base_class.seeded_feature (l_seed)
				if l_feature = Void then
						-- Internal error: there should be a feature with `l_seed'.
						-- It has been computed in ET_FEATURE_CHECKER or else an
						-- error should have already been reported.
					set_fatal_error
					error_handler.report_gibct_error
				elseif not l_feature.is_procedure then
						-- Internal error: the creation routine should be a procedure.
					set_fatal_error
					error_handler.report_gibcu_error
				else
					l_dynamic_feature := l_dynamic_type.dynamic_feature (l_feature, current_system)
					print_creation_expression (l_dynamic_type, l_dynamic_feature, l_actuals)
				end
			end
		end

	print_creation_expression (a_type: ET_DYNAMIC_TYPE; a_procedure: ET_DYNAMIC_FEATURE; an_actuals: ET_ACTUAL_ARGUMENT_LIST) is
			-- Print a creation expression.
		require
			a_type_not_void: a_type /= Void
			a_procedure_not_void: a_procedure /= Void
			is_procedure: a_procedure.is_procedure
		local
			i, nb: INTEGER
		do
			print_creation_procedure_name (a_procedure, a_type)
			current_file.put_character ('(')
			if an_actuals /= Void then
				nb := an_actuals.count
				from i := 1 until i > nb loop
					if i /= 1 then
						current_file.put_character (',')
						current_file.put_character (' ')
					end
					print_expression (an_actuals.actual_argument (i))
					i := i + 1
				end
			end
			current_file.put_character (')')
		end

	print_current (an_expression: ET_CURRENT) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
			current_file.put_character ('C')
		end

	print_current_address (an_expression: ET_CURRENT_ADDRESS) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		local
			l_local_index: INTEGER
			a_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			a_dynamic_type: ET_DYNAMIC_TYPE
		do
-- TODO.
			a_dynamic_type_set := current_feature.dynamic_type_set (an_expression)
			if a_dynamic_type_set = Void then
					-- Internal error: the dynamic type set of `an_expression'
					-- should be known atthis stage.
				set_fatal_error
				error_handler.report_gibdg_error
			else
				a_dynamic_type := a_dynamic_type_set.static_type
				local_count := local_count + 1
				l_local_index := local_count
				print_typed_pointer_local_declaration (l_local_index, a_dynamic_type)
				if current_type.is_expanded then
--					current_file.put_character ('&')
--					current_file.put_character ('C')
					current_file.put_character ('z')
					current_file.put_integer (l_local_index)
				else
--					current_file.put_character ('C')
					current_file.put_character ('z')
					current_file.put_integer (l_local_index)
				end
			end
		end

	print_equality_expression (an_expression: ET_EQUALITY_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
-- TODO: expandedness
			current_file.put_character ('(')
			print_expression (an_expression.left)
			current_file.put_character (')')
			if an_expression.operator.is_not_equal then
				current_file.put_character ('!')
			else
				current_file.put_character ('=')
			end
			current_file.put_character ('=')
			current_file.put_character ('(')
			print_expression (an_expression.right)
			current_file.put_character (')')
		end

	print_expression (an_expression: ET_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
			an_expression.process (Current)
		end

	print_expression_address (an_expression: ET_EXPRESSION_ADDRESS) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
-- TODO.
			current_file.put_character ('0')
		end

	print_false_constant (a_constant: ET_FALSE_CONSTANT) is
			-- Print `a_constant'.
		require
			a_constant_not_void: a_constant /= Void
		do
			current_file.put_string (c_eif_false)
		end

	print_feature_address (an_expression: ET_FEATURE_ADDRESS) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		local
			a_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			a_dynamic_type: ET_DYNAMIC_TYPE
			l_local_index: INTEGER
		do
-- TODO.
			a_dynamic_type_set := current_feature.dynamic_type_set (an_expression)
			if a_dynamic_type_set = Void then
					-- Internal error: the dynamic type set of `an_expression'
					-- should be known atthis stage.
				set_fatal_error
				error_handler.report_gibch_error
			else
				a_dynamic_type := a_dynamic_type_set.static_type
				if a_dynamic_type = current_system.pointer_type then
						-- $feature_name is of type POINTER, even
						-- in ISE and its TYPED_POINTER support.
					current_file.put_character ('0')
				else
					local_count := local_count + 1
					l_local_index := local_count
					print_typed_pointer_local_declaration (l_local_index, a_dynamic_type)
					current_file.put_character ('z')
					current_file.put_integer (l_local_index)
				end
			end
		end

	print_formal_argument (a_name: ET_IDENTIFIER) is
			-- Print formal argument `a_name'.
		require
			a_name_not_void: a_name /= Void
			a_name_argument: a_name.is_argument
		do
			current_file.put_character ('a')
			current_file.put_integer (a_name.seed)
		end

	print_hexadecimal_integer_constant (a_constant: ET_HEXADECIMAL_INTEGER_CONSTANT) is
			-- Print `a_constant'.
		require
			a_constant_not_void: a_constant /= Void
		local
			a_literal: STRING
		do
			a_literal := a_constant.literal
			inspect a_literal.count
			when 4 then
					-- 0[xX][a-fA-F0-9]{2}
				print_type_cast (current_system.integer_8_type)
				current_file.put_character ('(')
				current_file.put_string (a_literal)
				current_file.put_character (')')
			when 6 then
					-- 0[xX][a-fA-F0-9]{4}
				print_type_cast (current_system.integer_16_type)
				current_file.put_character ('(')
				current_file.put_string (a_literal)
				current_file.put_character (')')
			when 10 then
					-- 0[xX][a-fA-F0-9]{8}
				print_type_cast (current_system.integer_type)
				current_file.put_character ('(')
				current_file.put_string (a_literal)
				current_file.put_character (')')
			when 18 then
					-- 0[xX][a-fA-F0-9]{16}
				print_type_cast (current_system.integer_64_type)
				current_file.put_character ('(')
				current_file.put_string (a_literal)
				current_file.put_character (')')
			else
				print_type_cast (current_system.integer_type)
				current_file.put_character ('(')
				current_file.put_string (a_literal)
				current_file.put_character (')')
			end
		end

	print_infix_cast_expression (an_expression: ET_INFIX_CAST_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
-- TODO.
			print_expression (an_expression.expression)
		end

	print_infix_expression (an_expression: ET_INFIX_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
			print_qualified_call (an_expression)
		end

	print_local_variable (a_name: ET_IDENTIFIER) is
			-- Print local variable `a_name'.
		require
			a_name_not_void: a_name /= Void
			a_name_local: a_name.is_local
		do
			current_file.put_character ('l')
			current_file.put_integer (a_name.seed)
		end

	print_manifest_array (an_expression: ET_MANIFEST_ARRAY) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		local
			l_local_index: INTEGER
			i, nb: INTEGER
		do
-- TODO.
			local_count := local_count + 1
			l_local_index := local_count
			print_reference_local_declaration (l_local_index)
			nb := an_expression.count
			current_file.put_character ('(')
			from i := 1 until i > nb loop
				current_file.put_character ('(')
				print_expression (an_expression.expression (i))
				current_file.put_character (')')
				current_file.put_character (',')
				i := i + 1
			end
			current_file.put_string (c_eif_void)
			current_file.put_character (')')
		end

	print_manifest_tuple (an_expression: ET_MANIFEST_TUPLE) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		local
			l_local_index: INTEGER
			i, nb: INTEGER
		do
-- TODO.
			local_count := local_count + 1
			l_local_index := local_count
			print_reference_local_declaration (l_local_index)
			nb := an_expression.count
			current_file.put_character ('(')
			from i := 1 until i > nb loop
				current_file.put_character ('(')
				print_expression (an_expression.expression (i))
				current_file.put_character (')')
				current_file.put_character (',')
				i := i + 1
			end
			current_file.put_string (c_eif_void)
			current_file.put_character (')')
		end

	print_old_expression (an_expression: ET_OLD_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
-- TODO.
			print_expression (an_expression.expression)
		end

	print_once_manifest_string (an_expression: ET_ONCE_MANIFEST_STRING) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
-- TODO.
			current_file.put_string (c_eif_void)
		end

	print_parenthesized_expression (an_expression: ET_PARENTHESIZED_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
			current_file.put_character ('(')
			print_expression (an_expression.expression)
			current_file.put_character (')')
		end

	print_precursor_call (a_precursor: ET_PRECURSOR) is
			-- Print `a_precursor'.
		require
			a_precursor_not_void: a_precursor /= Void
		local
			a_precursor_keyword: ET_PRECURSOR_KEYWORD
			a_feature: ET_FEATURE
			a_parent_type, an_ancestor: ET_BASE_TYPE
			a_class: ET_CLASS
			an_actuals: ET_ACTUAL_ARGUMENT_LIST
			l_current_class: ET_CLASS
			l_class_impl: ET_CLASS
			l_dynamic_feature: ET_DYNAMIC_FEATURE
			l_dynamic_type: ET_DYNAMIC_TYPE
			i, nb: INTEGER
			l_comma: BOOLEAN
		do
			a_parent_type := a_precursor.parent_type
			if a_parent_type = Void then
					-- Internal error: the Precursor construct should already
					-- have been resolved when flattening the features of the
					-- implementation class of current feature.
				set_fatal_error
				error_handler.report_gibcv_error
			else
				a_precursor_keyword := a_precursor.precursor_keyword
				a_class := a_parent_type.direct_base_class (universe)
				a_feature := a_class.seeded_feature (a_precursor_keyword.seed)
				if a_feature = Void then
						-- Internal error: the Precursor construct should
						-- already have been resolved when flattening the
						-- features of `a_class_impl'.
					set_fatal_error
					error_handler.report_gibcw_error
				else
					if a_parent_type.is_generic then
						l_current_class := current_type.base_class
						l_class_impl := current_feature.static_feature.implementation_class
						if l_current_class /= l_class_impl then
								-- Resolve generic parameters in the
								-- context of `current_type'.
							l_current_class.process (universe.ancestor_builder)
							if l_current_class.has_ancestors_error then
								set_fatal_error
							else
								an_ancestor := l_current_class.ancestor (a_parent_type, universe)
								if an_ancestor = Void then
										-- Internal error: `a_parent_type' is an ancestor
										-- of `l_class_impl', and hence of `l_current_class'.
									set_fatal_error
									error_handler.report_gibcx_error
								else
									a_parent_type := an_ancestor
								end
							end
						end
					end
					if not has_fatal_error then
						l_dynamic_type := current_system.dynamic_type (a_parent_type, current_type.base_type)
						l_dynamic_feature := current_feature.dynamic_precursor (a_feature, l_dynamic_type, current_system)
						if l_dynamic_feature.is_static then
							print_static_routine_name (l_dynamic_feature, current_type)
							current_file.put_character ('(')
						else
							print_routine_name (l_dynamic_feature, current_type)
							current_file.put_character ('(')
							current_file.put_character ('C')
							l_comma := True
						end
						an_actuals := a_precursor.arguments
						if an_actuals /= Void then
							nb := an_actuals.count
							from i := 1 until i > nb loop
								if l_comma then
									current_file.put_character (',')
									current_file.put_character (' ')
								else
									l_comma := True
								end
								print_expression (an_actuals.actual_argument (i))
								i := i + 1
							end
						end
						current_file.put_character (')')
					end
				end
			end
		end

	print_precursor_expression (an_expression: ET_PRECURSOR_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
			print_precursor_call (an_expression)
		end

	print_prefix_expression (an_expression: ET_PREFIX_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
			print_qualified_call (an_expression)
		end

	print_qualified_call (a_call: ET_FEATURE_CALL) is
			-- Print qualified call.
		require
			a_call_not_void: a_call /= Void
			qualified_call: a_call.is_qualified_call
		local
			a_name: ET_FEATURE_NAME
			a_target: ET_EXPRESSION
			a_target_type_set: ET_DYNAMIC_TYPE_SET
			an_actuals: ET_ACTUAL_ARGUMENTS
			a_feature: ET_FEATURE
			a_constant_attribute: ET_CONSTANT_ATTRIBUTE
			a_seed: INTEGER
			i, nb: INTEGER
			l_dynamic_type: ET_DYNAMIC_TYPE
			l_other_dynamic_types: ET_DYNAMIC_TYPE_LIST
			j, nb2: INTEGER
			l_local_index: INTEGER
		do
			a_target := a_call.target
			a_name := a_call.name
			an_actuals := a_call.arguments
			a_target_type_set := current_feature.dynamic_type_set (a_target)
			if a_target_type_set = Void then
					-- Internal error: the dynamic type set of the target
					-- should be known at this stage.
				set_fatal_error
				error_handler.report_gibcy_error
			else
				a_seed := a_call.name.seed
				l_dynamic_type := a_target_type_set.first_type
				l_other_dynamic_types := a_target_type_set.other_types
				if l_dynamic_type = Void then
						-- Call on Void target.
					a_feature := a_target_type_set.static_type.base_class.seeded_feature (a_seed)
					if a_feature = Void then
							-- Internal error: there should be a feature with `a_seed'.
							-- It has been computed in ET_FEATURE_FLATTENER.
						set_fatal_error
						error_handler.report_gibco_error
-- TODO error.
					elseif a_feature.is_procedure then
-- TODO
						local_count := local_count + 1
						l_local_index := local_count
						print_reference_local_declaration (l_local_index)
						current_file.put_character ('z')
						current_file.put_integer (l_local_index)
						current_file.put_character (' ')
						current_file.put_character ('=')
						current_file.put_character (' ')
						current_file.put_character ('(')
						current_file.put_character ('(')
						print_expression (a_target)
						current_file.put_character (')')
						current_file.put_character (',')
						if an_actuals /= Void then
							nb := an_actuals.count
							from i := 1 until i > nb loop
								current_file.put_character ('(')
								print_expression (an_actuals.actual_argument (i))
								current_file.put_character (')')
								current_file.put_character (',')
								i := i + 1
							end
						end
						current_file.put_string (c_eif_void)
						current_file.put_character (')')
						current_file.put_character (';')
					else
-- TODO
						current_file.put_character ('(')
						current_file.put_character ('(')
						print_expression (a_target)
						current_file.put_character (')')
						current_file.put_character (',')
						if an_actuals /= Void then
							nb := an_actuals.count
							from i := 1 until i > nb loop
								current_file.put_character ('(')
								print_expression (an_actuals.actual_argument (i))
								current_file.put_character (')')
								current_file.put_character (',')
								i := i + 1
							end
						end
						current_file.put_character ('0')
						current_file.put_character (')')
					end
				elseif l_other_dynamic_types = Void then
						-- Static binding.
					a_feature := l_dynamic_type.base_class.seeded_feature (a_seed)
					if a_feature = Void then
							-- Internal error: there should be a feature with `a_seed'.
							-- It has been computed in ET_FEATURE_FLATTENER.
						set_fatal_error
						error_handler.report_gibdb_error
					elseif a_feature.is_procedure then
						print_routine_name (l_dynamic_type.dynamic_feature (a_feature, current_system), l_dynamic_type)
						current_file.put_character ('(')
						print_expression (a_target)
						if an_actuals /= Void then
							nb := an_actuals.count
							from i := 1 until i > nb loop
								current_file.put_character (',')
								current_file.put_character (' ')
								print_expression (an_actuals.actual_argument (i))
								i := i + 1
							end
						end
						current_file.put_character (')')
						current_file.put_character (';')
					elseif a_feature.is_attribute then
						print_attribute_name (l_dynamic_type.dynamic_feature (a_feature, current_system), a_target, l_dynamic_type)
					elseif a_feature.is_constant_attribute then
						a_constant_attribute ?= a_feature
						if a_constant_attribute = Void then
								-- Internal error.
							set_fatal_error
							error_handler.report_gibdc_error
						else
							current_file.put_character ('(')
							print_expression (a_target)
							current_file.put_character (',')
							a_constant_attribute.constant.process (Current)
							current_file.put_character (')')
						end
					elseif a_feature.is_unique_attribute then
-- TODO.
						current_file.put_character ('(')
						print_expression (a_target)
						current_file.put_character (',')
						print_type_cast (current_system.integer_type)
						current_file.put_character ('(')
						unique_count := unique_count + 1
						current_file.put_integer (unique_count)
						current_file.put_character (')')
						current_file.put_character (')')
					else
						print_routine_name (l_dynamic_type.dynamic_feature (a_feature, current_system), l_dynamic_type)
						current_file.put_character ('(')
						print_expression (a_target)
						if an_actuals /= Void then
							nb := an_actuals.count
							from i := 1 until i > nb loop
								current_file.put_character (',')
								current_file.put_character (' ')
								print_expression (an_actuals.actual_argument (i))
								i := i + 1
							end
						end
						current_file.put_character (')')
					end
				else
						-- Dynamic binding.
					a_feature := l_dynamic_type.base_class.seeded_feature (a_seed)
					if a_feature = Void then
							-- Internal error: there should be a feature with `a_seed'.
							-- It has been computed in ET_FEATURE_FLATTENER.
						set_fatal_error
						error_handler.report_gibcp_error
					elseif a_feature.is_procedure then
						from
							j := 1
							nb2 := l_other_dynamic_types.count
							local_count := local_count + 1
							l_local_index := local_count
							print_reference_local_declaration (l_local_index)
							current_file.put_character ('z')
							current_file.put_integer (l_local_index)
							current_file.put_character (' ')
							current_file.put_character ('=')
							current_file.put_character (' ')
							current_file.put_character ('(')
							print_expression (a_target)
							current_file.put_character (')')
							current_file.put_character (';')
							current_file.put_new_line
							print_indentation
							current_file.put_string (c_switch)
							current_file.put_character (' ')
							current_file.put_character ('(')
							current_file.put_character ('z')
							current_file.put_integer (l_local_index)
							current_file.put_string (c_arrow)
							current_file.put_string (c_id)
							current_file.put_character (')')
							current_file.put_character (' ')
							current_file.put_character ('{')
							current_file.put_new_line
						until
							l_dynamic_type = Void
						loop
							print_indentation
							current_file.put_string (c_case)
							current_file.put_character (' ')
							current_file.put_integer (l_dynamic_type.id)
							current_file.put_character (':')
							current_file.put_new_line
							indent
							if a_feature = Void then
									-- Internal error: there should be a feature with `a_seed'.
									-- It has been computed in ET_FEATURE_FLATTENER.
								set_fatal_error
								error_handler.report_gibdf_error
							else
								print_indentation
								print_routine_name (l_dynamic_type.dynamic_feature (a_feature, current_system), l_dynamic_type)
								current_file.put_character ('(')
								current_file.put_character ('z')
								current_file.put_integer (l_local_index)
								if an_actuals /= Void then
									nb := an_actuals.count
									from i := 1 until i > nb loop
										current_file.put_character (',')
										current_file.put_character (' ')
										print_expression (an_actuals.actual_argument (i))
										i := i + 1
									end
								end
								current_file.put_character (')')
								current_file.put_character (';')
								current_file.put_new_line
							end
							print_indentation
							current_file.put_string (c_break)
							current_file.put_character (';')
							current_file.put_new_line
							dedent
							if j > nb2 then
								l_dynamic_type := Void
							else
								l_dynamic_type := l_other_dynamic_types.item (j)
								a_feature := l_dynamic_type.base_class.seeded_feature (a_seed)
								j := j + 1
							end
						end
						print_indentation
						current_file.put_character ('}')
						current_file.put_character (';')
					else
							-- Query.
						from
							j := 1
							nb2 := l_other_dynamic_types.count
							local_count := local_count + 1
							l_local_index := local_count
							print_reference_local_declaration (l_local_index)
							current_file.put_character ('(')
							current_file.put_character ('(')
							current_file.put_character ('z')
							current_file.put_integer (l_local_index)
							current_file.put_character (' ')
							current_file.put_character ('=')
							current_file.put_character (' ')
							current_file.put_character ('(')
							print_expression (a_target)
							current_file.put_character (')')
							current_file.put_character (')')
							current_file.put_character (',')
						until
							l_dynamic_type = Void
						loop
							if j <= nb2 then
								current_file.put_character ('(')
								current_file.put_character ('z')
								current_file.put_integer (l_local_index)
								current_file.put_string (c_arrow)
								current_file.put_string (c_id)
								current_file.put_character ('=')
								current_file.put_character ('=')
								current_file.put_integer (l_dynamic_type.id)
								current_file.put_character (')')
								current_file.put_character ('?')
							end
							if a_feature = Void then
									-- Internal error: there should be a feature with `a_seed'.
									-- It has been computed in ET_FEATURE_FLATTENER.
								set_fatal_error
								error_handler.report_gibdh_error
							elseif a_feature.is_attribute then
								print_local_attribute_name (l_dynamic_type.dynamic_feature (a_feature, current_system), l_local_index, l_dynamic_type)
							elseif a_feature.is_constant_attribute then
								a_constant_attribute ?= a_feature
								if a_constant_attribute = Void then
										-- Internal error.
									set_fatal_error
									error_handler.report_gibdi_error
								else
									a_constant_attribute.constant.process (Current)
								end
							elseif a_feature.is_unique_attribute then
-- TODO.
								print_type_cast (current_system.integer_type)
								current_file.put_character ('(')
								unique_count := unique_count + 1
								current_file.put_integer (unique_count)
								current_file.put_character (')')
							else
								print_routine_name (l_dynamic_type.dynamic_feature (a_feature, current_system), l_dynamic_type)
								current_file.put_character ('(')
								current_file.put_character ('z')
								current_file.put_integer (l_local_index)
								if an_actuals /= Void then
									nb := an_actuals.count
									from i := 1 until i > nb loop
										current_file.put_character (',')
										current_file.put_character (' ')
										print_expression (an_actuals.actual_argument (i))
										i := i + 1
									end
								end
								current_file.put_character (')')
							end
							if j > nb2 then
								l_dynamic_type := Void
							else
								current_file.put_character (':')
								l_dynamic_type := l_other_dynamic_types.item (j)
								a_feature := l_dynamic_type.base_class.seeded_feature (a_seed)
								j := j + 1
							end
						end
						current_file.put_character (')')
					end
				end
			end
		end

	print_regular_integer_constant (a_constant: ET_REGULAR_INTEGER_CONSTANT) is
			-- Check validity of `a_constant'.
		require
			a_constant_not_void: a_constant /= Void
		local
			i, nb: INTEGER
			l_literal: STRING
		do
			if a_constant.is_integer_8 then
				print_type_cast (current_system.integer_8_type)
			elseif a_constant.is_integer_16 then
				print_type_cast (current_system.integer_16_type)
			elseif a_constant.is_integer_64 then
				print_type_cast (current_system.integer_64_type)
			else
				print_type_cast (current_system.integer_type)
			end
			current_file.put_character ('(')
			if a_constant.is_negative then
				current_file.put_character ('-')
			end
			l_literal := a_constant.literal
			nb := l_literal.count
				-- Remove leading zeros.
			from
				i := 1
			until
				i > nb or else l_literal.item (i) /= '0'
			loop
				i := i + 1
			end
			if i > nb then
				current_file.put_character ('0')
			else
				from until i > nb loop
					current_file.put_character (l_literal.item (i))
					i := i + 1
				end
			end
			current_file.put_character (')')
		end

	print_regular_manifest_string (a_string: ET_REGULAR_MANIFEST_STRING) is
			-- Print `a_string'.
		require
			a_string_not_void: a_string /= Void
		do
-- TODO.
			current_file.put_string (c_eif_void)
		end

	print_regular_real_constant (a_constant: ET_REGULAR_REAL_CONSTANT) is
			-- Print `a_constant'.
		require
			a_constant_not_void: a_constant /= Void
		do
			if a_constant.is_real_32 then
				print_type_cast (current_system.real_type)
			else
				print_type_cast (current_system.double_type)
			end
			current_file.put_character ('(')
			if a_constant.is_negative then
				current_file.put_character ('-')
			end
			current_file.put_string (a_constant.literal)
			current_file.put_character (')')
		end

	print_result (an_expression: ET_RESULT) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
			current_file.put_character ('R')
		end

	print_result_address (an_expression: ET_RESULT_ADDRESS) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		local
			l_local_index: INTEGER
			l_result_type_set: ET_DYNAMIC_TYPE_SET
			a_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			a_dynamic_type: ET_DYNAMIC_TYPE
		do
-- TODO.
			a_dynamic_type_set := current_feature.dynamic_type_set (an_expression)
			if a_dynamic_type_set = Void then
					-- Internal error: the dynamic type set of `an_expression'
					-- should be known atthis stage.
				set_fatal_error
				error_handler.report_gibdj_error
			else
				a_dynamic_type := a_dynamic_type_set.static_type
				local_count := local_count + 1
				l_local_index := local_count
				print_typed_pointer_local_declaration (l_local_index, a_dynamic_type)
				l_result_type_set := current_feature.result_type_set
				if l_result_type_set = Void then
						-- Internal error: it should have been checked elsewhere that
						-- the current feature is a function.
					set_fatal_error
					error_handler.report_gibdk_error
				elseif l_result_type_set.static_type.is_expanded then
--					current_file.put_character ('&')
--					current_file.put_character ('R')
					current_file.put_character ('z')
					current_file.put_integer (l_local_index)
				else
--					current_file.put_character ('R')
					current_file.put_character ('z')
					current_file.put_integer (l_local_index)
				end
			end
		end

	print_special_manifest_string (a_string: ET_SPECIAL_MANIFEST_STRING) is
			-- Print `a_string'.
		require
			a_string_not_void: a_string /= Void
		do
-- TODO.
			current_file.put_string (c_eif_void)
		end

	print_static_call (a_call: ET_STATIC_FEATURE_CALL) is
			-- Check validity of `a_call'.
		require
			a_call_not_void: a_call /= Void
		local
			a_type: ET_TYPE
			a_resolved_type: ET_TYPE
			a_target_type: ET_DYNAMIC_TYPE
			a_feature: ET_FEATURE
			an_actuals: ET_ACTUAL_ARGUMENT_LIST
			a_constant_attribute: ET_CONSTANT_ATTRIBUTE
			a_seed: INTEGER
			i, nb: INTEGER
		do
			a_type := a_call.type
			a_resolved_type := resolved_formal_parameters (a_type)
			if not has_fatal_error then
				a_target_type := current_system.dynamic_type (a_resolved_type, current_type.base_type)
				a_seed := a_call.name.seed
				a_feature := a_target_type.base_class.seeded_feature (a_seed)
				if a_feature = Void then
						-- Internal error: there should be a feature with `a_seed'.
						-- It has been computed in ET_FEATURE_CHECKER or else an
						-- error should have already been reported.
					set_fatal_error
					error_handler.report_gibdd_error
				elseif a_feature.is_procedure then
					print_static_routine_name (a_target_type.dynamic_feature (a_feature, current_system), a_target_type)
					current_file.put_character ('(')
					an_actuals := a_call.arguments
					if an_actuals /= Void then
						nb := an_actuals.count
						from i := 1 until i > nb loop
							if i > 1 then
								current_file.put_character (',')
								current_file.put_character (' ')
							end
							print_expression (an_actuals.actual_argument (i))
							i := i + 1
						end
					end
					current_file.put_character (')')
					current_file.put_character (';')
				elseif a_feature.is_attribute then
						-- Internal error: no object available.
					set_fatal_error
					error_handler.report_gibdl_error
				elseif a_feature.is_constant_attribute then
					a_constant_attribute ?= a_feature
					if a_constant_attribute = Void then
							-- Internal error.
						set_fatal_error
						error_handler.report_gibde_error
					else
						a_constant_attribute.constant.process (Current)
					end
				elseif a_feature.is_unique_attribute then
-- TODO.
					print_type_cast (current_system.integer_type)
					current_file.put_character ('(')
					unique_count := unique_count + 1
					current_file.put_integer (unique_count)
					current_file.put_character (')')
				else
					print_static_routine_name (a_target_type.dynamic_feature (a_feature, current_system), a_target_type)
					current_file.put_character ('(')
					an_actuals := a_call.arguments
					if an_actuals /= Void then
						nb := an_actuals.count
						from i := 1 until i > nb loop
							if i > 1 then
								current_file.put_character (',')
								current_file.put_character (' ')
							end
							print_expression (an_actuals.actual_argument (i))
							i := i + 1
						end
					end
					current_file.put_character (')')
				end
			end
		end

	print_static_call_expression (an_expression: ET_STATIC_CALL_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
			print_static_call (an_expression)
		end

	print_strip_expression (an_expression: ET_STRIP_EXPRESSION) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
-- TODO.
			current_file.put_string (c_eif_void)
		end

	print_true_constant (a_constant: ET_TRUE_CONSTANT) is
			-- Print `a_constant'.
		require
			a_constant_not_void: a_constant /= Void
		do
			current_file.put_string (c_eif_true)
		end

	print_underscored_integer_constant (a_constant: ET_UNDERSCORED_INTEGER_CONSTANT) is
			-- Print `a_constant'.
		require
			a_constant_not_void: a_constant /= Void
		local
			i, nb: INTEGER
			l_literal: STRING
		do
			if a_constant.is_integer_8 then
				print_type_cast (current_system.integer_8_type)
			elseif a_constant.is_integer_16 then
				print_type_cast (current_system.integer_16_type)
			elseif a_constant.is_integer_64 then
				print_type_cast (current_system.integer_64_type)
			else
				print_type_cast (current_system.integer_type)
			end
			current_file.put_character ('(')
			if a_constant.is_negative then
				current_file.put_character ('-')
			end
			l_literal := a_constant.literal
			nb := l_literal.count
				-- Remove leading zeros.
			from
				i := 1
			until
				i > nb or else (l_literal.item (i) /= '0' and l_literal.item (i) /= '_')
			loop
				i := i + 1
			end
			if i > nb then
				current_file.put_character ('0')
			else
				from until i > nb loop
					if l_literal.item (i) /= '_' then
						current_file.put_character (l_literal.item (i))
					end
					i := i + 1
				end
			end
			current_file.put_character (')')
		end

	print_underscored_real_constant (a_constant: ET_UNDERSCORED_REAL_CONSTANT) is
			-- Print `a_constant'.
		require
			a_constant_not_void: a_constant /= Void
		local
			i, nb: INTEGER
			l_literal: STRING
		do
			if a_constant.is_real_32 then
				print_type_cast (current_system.real_type)
			else
				print_type_cast (current_system.double_type)
			end
			current_file.put_character ('(')
			if a_constant.is_negative then
				current_file.put_character ('-')
			end
			l_literal := a_constant.literal
			nb := l_literal.count
			from i := 1 until i > nb loop
				if l_literal.item (i) /= '_' then
					current_file.put_character (l_literal.item (i))
				end
				i := i + 1
			end
			current_file.put_character (')')
		end

	print_unqualified_call (a_call: ET_FEATURE_CALL) is
			-- Print unqualified call.
		require
			a_call_not_void: a_call /= Void
			unqualified_call: not a_call.is_qualified_call
		local
			a_name: ET_FEATURE_NAME
			an_actuals: ET_ACTUAL_ARGUMENTS
			a_feature: ET_FEATURE
			a_constant_attribute: ET_CONSTANT_ATTRIBUTE
			a_seed: INTEGER
			i, nb: INTEGER
		do
			a_name := a_call.name
			a_seed := a_name.seed
			a_feature := current_type.base_class.seeded_feature (a_seed)
			if a_feature = Void then
					-- Internal error: there should be a feature with `a_seed'.
					-- It has been computed in ET_FEATURE_CHECKER or else an
					-- error should have already been reported.
				set_fatal_error
				error_handler.report_gibcz_error
			elseif a_feature.is_procedure then
				print_routine_name (current_type.dynamic_feature (a_feature, current_system), current_type)
				current_file.put_character ('(')
				current_file.put_character ('C')
				an_actuals := a_call.arguments
				if an_actuals /= Void then
					nb := an_actuals.count
					from i := 1 until i > nb loop
						current_file.put_character (',')
						current_file.put_character (' ')
						print_expression (an_actuals.actual_argument (i))
						i := i + 1
					end
				end
				current_file.put_character (')')
				current_file.put_character (';')
			elseif a_feature.is_attribute then
				print_current_attribute_name (current_type.dynamic_feature (a_feature, current_system))
			elseif a_feature.is_constant_attribute then
				a_constant_attribute ?= a_feature
				if a_constant_attribute = Void then
						-- Internal error.
					set_fatal_error
					error_handler.report_gibda_error
				else
					a_constant_attribute.constant.process (Current)
				end
			elseif a_feature.is_unique_attribute then
-- TODO.
				print_type_cast (current_system.integer_type)
				current_file.put_character ('(')
				unique_count := unique_count + 1
				current_file.put_integer (unique_count)
				current_file.put_character (')')
			else
				print_routine_name (current_type.dynamic_feature (a_feature, current_system), current_type)
				current_file.put_character ('(')
				current_file.put_character ('C')
				an_actuals := a_call.arguments
				if an_actuals /= Void then
					nb := an_actuals.count
					from i := 1 until i > nb loop
						current_file.put_character (',')
						current_file.put_character (' ')
						print_expression (an_actuals.actual_argument (i))
						i := i + 1
					end
				end
				current_file.put_character (')')
			end
		end

	print_verbatim_string (a_string: ET_VERBATIM_STRING) is
			-- Print `a_string'.
		require
			a_string_not_void: a_string /= Void
		do
-- TODO.
			current_file.put_string (c_eif_void)
		end

	print_void (an_expression: ET_VOID) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		do
			current_file.put_string (c_eif_void)
		end

	print_writable (a_writable: ET_WRITABLE) is
			-- Print `a_writable'.
		require
			a_writable_not_void: a_writable /= Void
		do
			a_writable.process (Current)
		end

feature {NONE} -- Agent generation

	print_call_agent (an_expression: ET_CALL_AGENT) is
			-- Print `an_expression'.
		require
			an_expression_not_void: an_expression /= Void
		local
			a_name: ET_FEATURE_NAME
			an_arguments: ET_AGENT_ACTUAL_ARGUMENT_LIST
			a_target: ET_AGENT_TARGET
			an_expression_target: ET_EXPRESSION
			a_type_target: ET_TARGET_TYPE
			an_any: ANY
		do
			a_name := an_expression.name
			an_arguments := an_expression.arguments
			a_target := an_expression.target
			if a_target = Void then
				print_unqualified_call_agent (a_name, an_arguments)
			else
				-- SmartEiffel 1.1 does not allow the assignment attempt
				-- because ET_EXPRESSION does not conform to ET_AGENT_TARGET.
				-- an_expression_target ?= a_target
				an_any := a_target
				an_expression_target ?= an_any
				if an_expression_target /= Void then
					print_qualified_call_agent (an_expression_target, a_name, an_arguments)
				else
					a_type_target ?= a_target
					if a_type_target /= Void then
						print_typed_call_agent (a_type_target.type, a_name, an_arguments)
					else
							-- Internal error: no other kind of targets.
						set_fatal_error
-- TODO
--						error_handler.report_giaca_error
					end
				end
			end
		end

	print_unqualified_call_agent (a_name: ET_FEATURE_NAME; an_actuals: ET_AGENT_ACTUAL_ARGUMENT_LIST) is
			-- Print unqualified call agent.
		require
			a_name_not_void: a_name /= Void
		do
-- TODO.
		end

	print_qualified_call_agent (a_target: ET_EXPRESSION; a_name: ET_FEATURE_NAME;
		an_actuals: ET_AGENT_ACTUAL_ARGUMENT_LIST) is
			-- Print qualified call agent.
		require
			a_target_not_void: a_target /= Void
			a_name_not_void: a_name /= Void
		do
-- TODO.
		end

	print_typed_call_agent (a_type: ET_TYPE; a_name: ET_FEATURE_NAME;
		an_actuals: ET_AGENT_ACTUAL_ARGUMENT_LIST) is
			-- Print typed call agent.
		require
			a_type_not_void: a_type /= Void
			a_name_not_void: a_name /= Void
		do
-- TODO.
		end

feature {NONE} -- Locals

	print_reference_local_declaration (i: INTEGER) is
			-- Print declaration of reference local z`i'.
		local
			old_file: like current_file
		do
			old_file := current_file
			current_file := current_local_buffer
			print_indentation
			current_file.put_character ('T')
			current_file.put_character ('0')
			current_file.put_character ('*')
			current_file.put_character (' ')
			current_file.put_character ('z')
			current_file.put_integer (i)
			current_file.put_character (';')
			current_file.put_new_line
			current_file := old_file
		end

	print_typed_pointer_local_declaration (i: INTEGER; a_type: ET_DYNAMIC_TYPE) is
			-- Print declaration of typed pointer local z`i'.
		require
			a_type_not_void: a_type /= Void
		local
			old_file: like current_file
		do
			old_file := current_file
			current_file := current_local_buffer
			print_indentation
			current_file.put_character ('T')
			current_file.put_integer (a_type.id)
			current_file.put_character (' ')
			current_file.put_character ('z')
			current_file.put_integer (i)
			current_file.put_character (' ')
			current_file.put_character ('=')
			current_file.put_character (' ')
			current_file.put_character ('{')
			current_file.put_character ('0')
			current_file.put_character ('}')
			current_file.put_character (';')
			current_file.put_new_line
			current_file := old_file
		end

feature {NONE} -- Type generation

	print_types is
			-- Print declarations of types of `current_system'.
		local
			l_dynamic_types: DS_ARRAYED_LIST [ET_DYNAMIC_TYPE]
			l_type: ET_DYNAMIC_TYPE
			i, nb: INTEGER
			l_features: ET_DYNAMIC_FEATURE_LIST
			l_feature: ET_DYNAMIC_FEATURE
			j, nb2: INTEGER
		do
			current_file.put_string (c_typedef)
			current_file.put_character (' ')
			current_file.put_string (c_struct)
			current_file.put_character (' ')
			current_file.put_character ('{')
			current_file.put_string (c_int)
			current_file.put_character (' ')
			current_file.put_string (c_id)
			current_file.put_character (';')
			current_file.put_character ('}')
			current_file.put_character (' ')
			current_file.put_character ('T')
			current_file.put_character ('0')
			current_file.put_character (';')
			current_file.put_new_line
			l_dynamic_types := current_system.dynamic_types
			nb := l_dynamic_types.count
			from i := 1 until i > nb loop
				l_type := l_dynamic_types.item (i)
				if l_type.is_alive then
					if l_type = current_system.character_type then
						current_file.put_string (c_typedef)
						current_file.put_character (' ')
						current_file.put_string (c_unsigned)
						current_file.put_character (' ')
						current_file.put_string (c_char)
						current_file.put_character (' ')
						print_type_name (l_type)
						current_file.put_character (';')
						current_file.put_new_line
					elseif l_type = current_system.boolean_type then
						current_file.put_string (c_typedef)
						current_file.put_character (' ')
						current_file.put_string (c_int)
						current_file.put_character (' ')
						print_type_name (l_type)
						current_file.put_character (';')
						current_file.put_new_line
					elseif l_type = current_system.integer_8_type then
						current_file.put_string (c_typedef)
						current_file.put_character (' ')
						current_file.put_string (c_int8_t)
						current_file.put_character (' ')
						print_type_name (l_type)
						current_file.put_character (';')
						current_file.put_new_line
					elseif l_type = current_system.integer_16_type then
						current_file.put_string (c_typedef)
						current_file.put_character (' ')
						current_file.put_string (c_int16_t)
						current_file.put_character (' ')
						print_type_name (l_type)
						current_file.put_character (';')
						current_file.put_new_line
					elseif l_type = current_system.integer_type then
						current_file.put_string (c_typedef)
						current_file.put_character (' ')
						current_file.put_string (c_int32_t)
						current_file.put_character (' ')
						print_type_name (l_type)
						current_file.put_character (';')
						current_file.put_new_line
					elseif l_type = current_system.integer_64_type then
						current_file.put_string (c_typedef)
						current_file.put_character (' ')
						current_file.put_string (c_int64_t)
						current_file.put_character (' ')
						print_type_name (l_type)
						current_file.put_character (';')
						current_file.put_new_line
					elseif l_type = current_system.real_type then
						current_file.put_string (c_typedef)
						current_file.put_character (' ')
						current_file.put_string (c_float)
						current_file.put_character (' ')
						print_type_name (l_type)
						current_file.put_character (';')
						current_file.put_new_line
					elseif l_type = current_system.double_type then
						current_file.put_string (c_typedef)
						current_file.put_character (' ')
						current_file.put_string (c_double)
						current_file.put_character (' ')
						print_type_name (l_type)
						current_file.put_character (';')
						current_file.put_new_line
					elseif l_type = current_system.pointer_type then
						current_file.put_string (c_typedef)
						current_file.put_character (' ')
						current_file.put_string (c_void)
						current_file.put_character ('*')
						current_file.put_character (' ')
						print_type_name (l_type)
						current_file.put_character (';')
						current_file.put_new_line
					else
						current_file.put_string (c_typedef)
						current_file.put_character (' ')
						current_file.put_string (c_struct)
						current_file.put_character (' ')
						current_file.put_character ('{')
						current_file.put_string (c_int)
						current_file.put_character (' ')
						current_file.put_string (c_id)
						current_file.put_character (';')
						l_features := l_type.features
						if l_features /= Void then
							nb2 := l_features.count
							from j := 1 until j > nb2 loop
								l_feature := l_features.item (j)
								if l_feature.is_attribute then
									current_file.put_character (' ')
									print_type_declaration (l_feature.result_type_set.static_type)
									current_file.put_character (' ')
									current_file.put_character ('a')
									current_file.put_integer (l_feature.id)
									current_file.put_character (';')
								end
								j := j + 1
							end
						end
						current_file.put_character ('}')
						current_file.put_character (' ')
						print_type_name (l_type)
						current_file.put_character (';')
						current_file.put_new_line
					end
				end
				i := i + 1
			end
		end

	print_type_name (a_type: ET_DYNAMIC_TYPE) is
			-- Print name of `a_type'.
		require
			a_type_not_void: a_type /= Void
		do
			if a_type.is_expanded then
				current_file.put_character ('T')
				current_file.put_integer (a_type.id)
			else
				current_file.put_character ('T')
				current_file.put_integer (a_type.id)
			end
		end

	print_type_declaration (a_type: ET_DYNAMIC_TYPE) is
			-- Print declaration of `a_type'.
		require
			a_type_not_void: a_type /= Void
		do
			if a_type.is_expanded then
				current_file.put_character ('T')
				current_file.put_integer (a_type.id)
			else
				current_file.put_character ('T')
				current_file.put_character ('0')
				current_file.put_character ('*')
			end
		end

	print_type_cast (a_type: ET_DYNAMIC_TYPE) is
			-- Print type cast of `a_type'.
		require
			a_type_not_void: a_type /= Void
		do
			current_file.put_character ('(')
			print_type_name (a_type)
			if not a_type.is_expanded then
				current_file.put_character ('*')
			end
			current_file.put_character (')')
		end

feature {NONE} -- Feature name generation

	print_routine_name (a_routine: ET_DYNAMIC_FEATURE; a_type: ET_DYNAMIC_TYPE) is
			-- Print name of `a_routine'.
		require
			a_routine_not_void: a_routine /= Void
			a_type_not_void: a_type /= Void
		local
			l_precursor: ET_DYNAMIC_PRECURSOR
		do
			print_type_name (a_type)
			current_file.put_character ('f')
			l_precursor ?= a_routine
			if l_precursor /= Void then
				current_file.put_integer (l_precursor.current_feature.id)
				current_file.put_character ('p')
			end
			current_file.put_integer (a_routine.id)
		end

	print_static_routine_name (a_routine: ET_DYNAMIC_FEATURE; a_type: ET_DYNAMIC_TYPE) is
			-- Print name of static feature `a_feature'.
		require
			a_routine_not_void: a_routine /= Void
			a_routine_static: a_routine.is_static
			a_type_not_void: a_type /= Void
		local
			l_precursor: ET_DYNAMIC_PRECURSOR
		do
			print_type_name (a_type)
			current_file.put_character ('s')
			l_precursor ?= a_routine
			if l_precursor /= Void then
				current_file.put_integer (l_precursor.current_feature.id)
				current_file.put_character ('p')
			end
			current_file.put_integer (a_routine.id)
		end

	print_attribute_name (an_attribute: ET_DYNAMIC_FEATURE; a_target: ET_EXPRESSION; a_type: ET_DYNAMIC_TYPE) is
			-- Print name of `an_attribute' applied on `a_target' of type `a_type'.
		require
			an_attribute_not_void: an_attribute /= Void
			a_target_not_void: a_target /= Void
			a_type_not_void: a_type /= Void
		do
			current_file.put_character ('(')
			print_type_cast (a_type)
			current_file.put_character ('(')
			print_expression (a_target)
			current_file.put_character (')')
			current_file.put_character (')')
			current_file.put_character ('-')
			current_file.put_character ('>')
			current_file.put_character ('a')
			current_file.put_integer (an_attribute.id)
		end

	print_current_attribute_name (an_attribute: ET_DYNAMIC_FEATURE) is
			-- Print name of `an_attribute' with current object as target.
		require
			an_attribute_not_void: an_attribute /= Void
		do
			current_file.put_character ('(')
			print_type_cast (current_type)
			current_file.put_character ('(')
			current_file.put_character ('C')
			current_file.put_character (')')
			current_file.put_character (')')
			current_file.put_character ('-')
			current_file.put_character ('>')
			current_file.put_character ('a')
			current_file.put_integer (an_attribute.id)
		end

	print_local_attribute_name (an_attribute: ET_DYNAMIC_FEATURE; i: INTEGER; a_type: ET_DYNAMIC_TYPE) is
			-- Print name of `an_attribute' applied on `i'-th internal C local variabe of type `a_type'.
		require
			an_attribute_not_void: an_attribute /= Void
			a_type_not_void: a_type /= Void
		do
			current_file.put_character ('(')
			print_type_cast (a_type)
			current_file.put_character ('(')
			current_file.put_character ('z')
			current_file.put_integer (i)
			current_file.put_character (')')
			current_file.put_character (')')
			current_file.put_character ('-')
			current_file.put_character ('>')
			current_file.put_character ('a')
			current_file.put_integer (an_attribute.id)
		end

	print_creation_procedure_name (a_procedure: ET_DYNAMIC_FEATURE; a_type: ET_DYNAMIC_TYPE) is
			-- Print name of creation procedure `a_procedure'.
		require
			a_procedure_not_void: a_procedure /= Void
			a_procedure_creation: a_procedure.is_creation
			a_type_not_void: a_type /= Void
		do
			print_type_name (a_type)
			current_file.put_character ('c')
			current_file.put_integer (a_procedure.id)
		end

	print_feature_name_comment (a_feature: ET_FEATURE; a_type: ET_DYNAMIC_TYPE) is
			-- Print name of `a_feature' from `a_type' as a C comment.
		require
			a_feature_not_void: a_feature /= Void
			a_type_not_void: a_type /= Void
		do
			current_file.put_character ('/')
			current_file.put_character ('*')
			current_file.put_character (' ')
			current_file.put_string (a_type.base_type.to_text)
			current_file.put_character ('.')
			current_file.put_string (a_feature.name.name)
			current_file.put_character (' ')
			current_file.put_character ('*')
			current_file.put_character ('/')
			current_file.put_new_line
		end

feature {NONE} -- Indentation

	indentation: INTEGER
			-- Indentation

	indent is
			-- Increment indentation.
		do
			indentation := indentation + 1
		end

	dedent is
			-- Decrement indentation.
		do
			indentation := indentation - 1
		end

	print_indentation is
			-- Print indentation.
		local
			i, nb: INTEGER
		do
			nb := indentation
			from i := 1 until i > nb loop
				current_file.put_character ('%T')
				i := i + 1
			end
		end

feature {ET_AST_NODE} -- Processing

	process_assignment (an_instruction: ET_ASSIGNMENT) is
			-- Process `an_instruction'.
		do
			print_assignment (an_instruction)
		end

	process_assignment_attempt (an_instruction: ET_ASSIGNMENT_ATTEMPT) is
			-- Process `an_instruction'.
		do
			print_assignment_attempt (an_instruction)
		end

	process_attribute (a_feature: ET_ATTRIBUTE) is
			-- Process `a_feature'.
		do
			-- Do nothing.
		end

	process_bang_instruction (an_instruction: ET_BANG_INSTRUCTION) is
			-- Process `an_instruction'.
		do
			print_bang_instruction (an_instruction)
		end

	process_bit_constant (a_constant: ET_BIT_CONSTANT) is
			-- Process `a_constant'.
		do
			print_bit_constant (a_constant)
		end

	process_c1_character_constant (a_constant: ET_C1_CHARACTER_CONSTANT) is
			-- Process `a_constant'.
		do
			print_c1_character_constant (a_constant)
		end

	process_c2_character_constant (a_constant: ET_C2_CHARACTER_CONSTANT) is
			-- Process `a_constant'.
		do
			print_c2_character_constant (a_constant)
		end

	process_c3_character_constant (a_constant: ET_C3_CHARACTER_CONSTANT) is
			-- Process `a_constant'.
		do
			print_c3_character_constant (a_constant)
		end

	process_call_agent (an_expression: ET_CALL_AGENT) is
			-- Process `an_expression'.
		do
			print_call_agent (an_expression)
		end

	process_call_expression (an_expression: ET_CALL_EXPRESSION) is
			-- Process `an_expression'.
		do
			print_call_expression (an_expression)
		end

	process_call_instruction (an_instruction: ET_CALL_INSTRUCTION) is
			-- Process `an_instruction'.
		do
			print_call_instruction (an_instruction)
		end

	process_check_instruction (an_instruction: ET_CHECK_INSTRUCTION) is
			-- Process `an_instruction'.
		do
			print_check_instruction (an_instruction)
		end

	process_constant_attribute (a_feature: ET_CONSTANT_ATTRIBUTE) is
			-- Process `a_feature'.
		do
			-- Do nothing.
		end

	process_convert_expression (an_expression: ET_CONVERT_EXPRESSION) is
			-- Process `an_expression'.
		do
			print_convert_expression (an_expression)
		end

	process_convert_to_expression (an_expression: ET_CONVERT_TO_EXPRESSION) is
			-- Process `an_expression'.
		do
			print_convert_to_expression (an_expression)
		end

	process_create_expression (an_expression: ET_CREATE_EXPRESSION) is
			-- Process `an_expression'.
		do
			print_create_expression (an_expression)
		end

	process_create_instruction (an_instruction: ET_CREATE_INSTRUCTION) is
			-- Process `an_instruction'.
		do
			print_create_instruction (an_instruction)
		end

	process_current (an_expression: ET_CURRENT) is
			-- Process `an_expression'.
		do
			print_current (an_expression)
		end

	process_current_address (an_expression: ET_CURRENT_ADDRESS) is
			-- Process `an_expression'.
		do
			print_current_address (an_expression)
		end

	process_debug_instruction (an_instruction: ET_DEBUG_INSTRUCTION) is
			-- Process `an_instruction'.
		do
			print_debug_instruction (an_instruction)
		end

	process_deferred_function (a_feature: ET_DEFERRED_FUNCTION) is
			-- Process `a_feature'.
		do
			print_deferred_function (a_feature)
		end

	process_deferred_procedure (a_feature: ET_DEFERRED_PROCEDURE) is
			-- Process `a_feature'.
		do
			print_deferred_procedure (a_feature)
		end

	process_do_function (a_feature: ET_DO_FUNCTION) is
			-- Process `a_feature'.
		do
			print_do_function (a_feature)
		end

	process_do_procedure (a_feature: ET_DO_PROCEDURE) is
			-- Process `a_feature'.
		do
			print_do_procedure (a_feature)
		end

	process_equality_expression (an_expression: ET_EQUALITY_EXPRESSION) is
			-- Process `an_expression'.
		do
			print_equality_expression (an_expression)
		end

	process_expression_address (an_expression: ET_EXPRESSION_ADDRESS) is
			-- Process `an_expression'.
		do
			print_expression_address (an_expression)
		end

	process_external_function (a_feature: ET_EXTERNAL_FUNCTION) is
			-- Process `a_feature'.
		do
			print_external_function (a_feature)
		end

	process_external_procedure (a_feature: ET_EXTERNAL_PROCEDURE) is
			-- Process `a_feature'.
		do
			print_external_procedure (a_feature)
		end

	process_false_constant (a_constant: ET_FALSE_CONSTANT) is
			-- Process `a_constant'.
		do
			print_false_constant (a_constant)
		end

	process_feature_address (an_expression: ET_FEATURE_ADDRESS) is
			-- Process `an_expression'.
		do
			print_feature_address (an_expression)
		end

	process_hexadecimal_integer_constant (a_constant: ET_HEXADECIMAL_INTEGER_CONSTANT) is
			-- Process `a_constant'.
		do
			print_hexadecimal_integer_constant (a_constant)
		end

	process_identifier (an_identifier: ET_IDENTIFIER) is
			-- Process `an_identifier'.
		do
			if an_identifier.is_argument then
				print_formal_argument (an_identifier)
			elseif an_identifier.is_local then
				print_local_variable (an_identifier)
			else
				print_unqualified_call (an_identifier)
			end
		end

	process_if_instruction (an_instruction: ET_IF_INSTRUCTION) is
			-- Process `an_instruction'.
		do
			print_if_instruction (an_instruction)
		end

	process_infix_cast_expression (an_expression: ET_INFIX_CAST_EXPRESSION) is
			-- Process `an_expression'.
		do
			print_infix_cast_expression (an_expression)
		end

	process_infix_expression (an_expression: ET_INFIX_EXPRESSION) is
			-- Process `an_expression'.
		do
			print_infix_expression (an_expression)
		end

	process_inspect_instruction (an_instruction: ET_INSPECT_INSTRUCTION) is
			-- Process `an_instruction'.
		do
			print_inspect_instruction (an_instruction)
		end

	process_loop_instruction (an_instruction: ET_LOOP_INSTRUCTION) is
			-- Process `an_instruction'.
		do
			print_loop_instruction (an_instruction)
		end

	process_manifest_array (an_expression: ET_MANIFEST_ARRAY) is
			-- Process `an_expression'.
		do
			print_manifest_array (an_expression)
		end

	process_manifest_tuple (an_expression: ET_MANIFEST_TUPLE) is
			-- Process `an_expression'.
		do
			print_manifest_tuple (an_expression)
		end

	process_old_expression (an_expression: ET_OLD_EXPRESSION) is
			-- Process `an_expression'.
		do
			print_old_expression (an_expression)
		end

	process_once_function (a_feature: ET_ONCE_FUNCTION) is
			-- Process `a_feature'.
		do
			print_once_function (a_feature)
		end

	process_once_manifest_string (an_expression: ET_ONCE_MANIFEST_STRING) is
			-- Process `an_expression'.
		do
			print_once_manifest_string (an_expression)
		end

	process_once_procedure (a_feature: ET_ONCE_PROCEDURE) is
			-- Process `a_feature'.
		do
			print_once_procedure (a_feature)
		end

	process_parenthesized_expression (an_expression: ET_PARENTHESIZED_EXPRESSION) is
			-- Process `an_expression'.
		do
			print_parenthesized_expression (an_expression)
		end

	process_precursor_expression (an_expression: ET_PRECURSOR_EXPRESSION) is
			-- Process `an_expression'.
		do
			print_precursor_expression (an_expression)
		end

	process_precursor_instruction (an_instruction: ET_PRECURSOR_INSTRUCTION) is
			-- Process `an_instruction'.
		do
			print_precursor_instruction (an_instruction)
		end

	process_prefix_expression (an_expression: ET_PREFIX_EXPRESSION) is
			-- Process `an_expression'.
		do
			print_prefix_expression (an_expression)
		end

	process_regular_integer_constant (a_constant: ET_REGULAR_INTEGER_CONSTANT) is
			-- Process `a_constant'.
		do
			print_regular_integer_constant (a_constant)
		end

	process_regular_manifest_string (a_string: ET_REGULAR_MANIFEST_STRING) is
			-- Process `a_string'.
		do
			print_regular_manifest_string (a_string)
		end

	process_regular_real_constant (a_constant: ET_REGULAR_REAL_CONSTANT) is
			-- Process `a_constant'.
		do
			print_regular_real_constant (a_constant)
		end

	process_result (an_expression: ET_RESULT) is
			-- Process `an_expression'.
		do
			print_result (an_expression)
		end

	process_result_address (an_expression: ET_RESULT_ADDRESS) is
			-- Process `an_expression'.
		do
			print_result_address (an_expression)
		end

	process_retry_instruction (an_instruction: ET_RETRY_INSTRUCTION) is
			-- Process `an_instruction'.
		do
			print_retry_instruction (an_instruction)
		end

	process_semicolon_symbol (a_symbol: ET_SEMICOLON_SYMBOL) is
			-- Process `a_symbol'.
		do
			-- Do nothing.
		end

	process_special_manifest_string (a_string: ET_SPECIAL_MANIFEST_STRING) is
			-- Process `a_string'.
		do
			print_special_manifest_string (a_string)
		end

	process_static_call_expression (an_expression: ET_STATIC_CALL_EXPRESSION) is
			-- Process `an_expression'.
		do
			print_static_call_expression (an_expression)
		end

	process_static_call_instruction (an_instruction: ET_STATIC_CALL_INSTRUCTION) is
			-- Process `an_instruction'.
		do
			print_static_call_instruction (an_instruction)
		end

	process_strip_expression (an_expression: ET_STRIP_EXPRESSION) is
			-- Process `an_expression'.
		do
			print_strip_expression (an_expression)
		end

	process_true_constant (a_constant: ET_TRUE_CONSTANT) is
			-- Process `a_constant'.
		do
			print_true_constant (a_constant)
		end

	process_underscored_integer_constant (a_constant: ET_UNDERSCORED_INTEGER_CONSTANT) is
			-- Process `a_constant'.
		do
			print_underscored_integer_constant (a_constant)
		end

	process_underscored_real_constant (a_constant: ET_UNDERSCORED_REAL_CONSTANT) is
			-- Process `a_constant'.
		do
			print_underscored_real_constant (a_constant)
		end

	process_unique_attribute (a_feature: ET_UNIQUE_ATTRIBUTE) is
			-- Process `a_feature'.
		do
			-- Do nothing.
		end

	process_verbatim_string (a_string: ET_VERBATIM_STRING) is
			-- Process `a_string'.
		do
			print_verbatim_string (a_string)
		end

	process_void (an_expression: ET_VOID) is
			-- Process `an_expression'.
		do
			print_void (an_expression)
		end

feature {NONE} -- Error handling

	set_fatal_error is
			-- Report a fatal error.
		do
			has_fatal_error := True
		ensure
			has_fatal_error: has_fatal_error
		end

feature {NONE} -- Type resolving

	resolved_formal_parameters (a_type: ET_TYPE): ET_TYPE is
			-- Replace formal generic parameters in `a_type' by their
			-- corresponding actual parameters if the class where
			-- `a_type' appears is generic and is not `current_type.base_type'.
			-- Set `has_fatal_error' if a fatal error occurred.
		require
			a_type_not_void: a_type /= Void
		do
-- TODO.
--			has_fatal_error := False
			Result := type_checker.resolved_formal_parameters (a_type, current_feature.static_feature, current_type.base_type)
			if type_checker.has_fatal_error then
				set_fatal_error
			end
		ensure
			resolved_type_not_void: not has_fatal_error implies Result /= Void
		end

	type_checker: ET_TYPE_CHECKER
			-- Type checker

feature {NONE} -- Access

	current_feature: ET_DYNAMIC_FEATURE
			-- Feature being processed

	current_type: ET_DYNAMIC_TYPE
			-- Type where `current_feature' belongs

	current_file: KI_TEXT_OUTPUT_STREAM
			-- Output file

	current_local_buffer: KL_STRING_OUTPUT_STREAM
			-- Current buffer for internal C local declarations

	unique_count: INTEGER
			-- Number of unique attributes found so far

	local_count: INTEGER
			-- Number of internal C local variables declared

	instruction_buffer_stack: DS_ARRAYED_STACK [KL_STRING_OUTPUT_STREAM]
			-- Output buffers for instructions

	local_buffer_stack: DS_ARRAYED_STACK [KL_STRING_OUTPUT_STREAM]
			-- Output buffers for internal C local declarations

feature {NONE} -- Implementation

	accepted_types: ET_DYNAMIC_TYPE_LIST
			-- Types accepted by the current assignment attempt

	denied_types: ET_DYNAMIC_TYPE_LIST
			-- Types deined by the current assignment attempt

	dummy_feature: ET_DYNAMIC_FEATURE is
			-- Dummy feature
		local
			l_name: ET_FEATURE_NAME
			l_feature: ET_FEATURE
		once
			create {ET_IDENTIFIER} l_name.make ("**dummy**")
			create {ET_DO_PROCEDURE} l_feature.make (l_name, Void, Void, Void, Void, Void, Void, Void, tokens.any_clients, current_type.base_class)
			create Result.make (l_feature, current_type, current_system)
		ensure
			dummy_feature_not_void: Result /= Void
		end

feature {NONE} -- Constants

	e_inline: STRING is "C inline"
	c_arrow: STRING is "->"
	c_break: STRING is "break"
	c_case: STRING is "case"
	c_char: STRING is "char"
	c_default: STRING is "default"
	c_double: STRING is "double"
	c_eif_false: STRING is "EIF_FALSE"
	c_eif_true: STRING is "EIF_TRUE"
	c_eif_void: STRING is "EIF_VOID"
	c_else: STRING is "else"
	c_extern: STRING is "extern"
	c_float: STRING is "float"
	c_id: STRING is "id"
	c_if: STRING is "if"
	c_int: STRING is "int"
	c_int8_t: STRING is "int8_t"
	c_int16_t: STRING is "int16_t"
	c_int32_t: STRING is "int32_t"
	c_int64_t: STRING is "int64_t"
	c_malloc: STRING is "malloc"
	c_return: STRING is "return"
	c_sizeof: STRING is "sizeof"
	c_struct: STRING is "struct"
	c_switch: STRING is "switch"
	c_typedef: STRING is "typedef"
	c_unsigned: STRING is "unsigned"
	c_void: STRING is "void"
	c_while: STRING is "while"
			-- String constants

invariant

	current_system_not_void: current_system /= Void
	current_file_not_void: current_file /= Void
	current_file_open_write: current_file.is_open_write
	current_feature_not_void: current_feature /= Void
	current_type_not_void: current_type /= Void
	type_checker_not_void: type_checker /= Void
	instruction_buffer_stack_not_void: instruction_buffer_stack /= Void
	no_void_instruction_buffer: not instruction_buffer_stack.has (Void)
	local_buffer_stack_not_void: local_buffer_stack /= Void
	no_void_local_buffer: not local_buffer_stack.has (Void)
	current_local_buffer_not_void: current_local_buffer /= Void
	accepted_types_not_void: accepted_types /= Void
	denied_types_not_void: denied_types /= Void

end
