indexing

	description:

		"Eiffel dynamic type set builders where types are pushed to supersets"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_DYNAMIC_PUSH_TYPE_SET_BUILDER

inherit

	ET_DYNAMIC_TYPE_BUILDER
		redefine
			new_dynamic_type_set,
			build_dynamic_type_sets,
			build_tuple_item,
			build_tuple_put,
			build_agent_call,
			report_catcall_error,
			report_assignment,
			report_assignment_attempt,
			report_convert_function,
			report_creation_expression,
			report_creation_instruction,
			report_manifest_array,
			report_manifest_tuple,
			report_precursor_expression,
			report_precursor_instruction,
			report_qualified_call_agent,
			report_qualified_call_expression,
			report_qualified_call_instruction,
			report_static_call_expression,
			report_static_call_instruction,
			report_string_constant,
			report_unqualified_call_agent,
			report_unqualified_call_expression,
			report_unqualified_call_instruction,
			report_builtin_any_twin
		end

creation

	make

creation {ET_FEATURE_CHECKER}

	make_from_checker

feature -- Factory

	new_dynamic_type_set (a_type: ET_DYNAMIC_TYPE): ET_DYNAMIC_TYPE_SET is
			-- New dynamic type set
		do
			if a_type.is_expanded then
				Result := a_type
			else
				create {ET_DYNAMIC_PUSH_TYPE_SET} Result.make (a_type)
			end
		end

feature -- Generation

	build_dynamic_type_sets is
			-- Build dynamic type sets for `current_system'.
			-- Set `has_fatal_error' if a fatal error occurred.
		local
			i, nb: INTEGER
			l_type: ET_DYNAMIC_TYPE
			j, nb2: INTEGER
			l_features: ET_DYNAMIC_FEATURE_LIST
			l_feature: ET_DYNAMIC_FEATURE
			l_precursor: ET_DYNAMIC_PRECURSOR
			l_other_precursors: ET_DYNAMIC_PRECURSOR_LIST
			k, nb3: INTEGER
			l_dynamic_types: DS_ARRAYED_LIST [ET_DYNAMIC_TYPE]
		do
			has_fatal_error := False
			l_dynamic_types := current_system.dynamic_types
			is_built := False
			from until is_built loop
				is_built := True
				nb := l_dynamic_types.count
				from i := 1 until i > nb loop
					l_type := l_dynamic_types.item (i)
					l_features := l_type.features
					nb2 := l_features.count
					from j := 1 until j > nb2 loop
						l_feature := l_features.item (j)
						if not l_feature.is_built then
							is_built := False
							build_feature_dynamic_type_sets (l_feature, l_type)
								-- `build_feature_dynamic_type_sets' may have
								-- added other features to the list.
							nb2 := l_features.count
							l_precursor := l_feature.first_precursor
							if l_precursor /= Void then
								if not l_precursor.is_built then
									is_built := False
									build_feature_dynamic_type_sets (l_precursor, l_type)
										-- `build_feature_dynamic_type_sets' may have
										-- added other features to the list.
									nb2 := l_features.count
								end
								l_other_precursors := l_feature.other_precursors
								if l_other_precursors /= Void then
									nb3 := l_other_precursors.count
									from k := 1 until k > nb3 loop
										l_precursor := l_other_precursors.item (k)
										if not l_precursor.is_built then
											is_built := False
											build_feature_dynamic_type_sets (l_precursor, l_type)
												-- `build_feature_dynamic_type_sets' may have
												-- added other precursors to the list.
											nb3 := l_other_precursors.count
												-- `build_feature_dynamic_type_sets' may have
												-- added other features to the list.
											nb2 := l_features.count
										end
										k := k + 1
									end
								end
							end
						end
						j := j + 1
					end
					i := i + 1
				end
			end
			check_catcall_validity
			dynamic_qualified_calls.wipe_out
			dynamic_qualified_agents.wipe_out
			dynamic_unqualified_agents.wipe_out
		end

feature {ET_DYNAMIC_TUPLE_TYPE} -- Generation

	build_tuple_item (a_tuple_type: ET_DYNAMIC_TUPLE_TYPE; an_item_feature: ET_DYNAMIC_FEATURE) is
			-- Build type set of result type of `an_item_feature' from `a_tuple_type'.
		local
			i, nb: INTEGER
			l_result_type_set: ET_DYNAMIC_TYPE_SET
			l_item_type_sets: ET_DYNAMIC_TYPE_SET_LIST
		do
			l_result_type_set := an_item_feature.result_type_set
			if l_result_type_set /= Void then
				l_item_type_sets := a_tuple_type.item_type_sets
				nb := l_item_type_sets.count
				from i := 1 until i > nb loop
					l_item_type_sets.item (i).put_target (l_result_type_set, current_system)
					i := i + 1
				end
			end
		end

	build_tuple_put (a_tuple_type: ET_DYNAMIC_TUPLE_TYPE; a_put_feature: ET_DYNAMIC_FEATURE) is
			-- Build type set of argument type of `a_put_feature' from `a_tuple_type'.
		local
			i, nb: INTEGER
			l_argument_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_argument_type_set: ET_DYNAMIC_TYPE_SET
			l_item_type_sets: ET_DYNAMIC_TYPE_SET_LIST
		do
			l_argument_type_sets := a_put_feature.dynamic_type_sets
			if l_argument_type_sets.count > 1 then
				l_argument_type_set := l_argument_type_sets.item (1)
				l_item_type_sets := a_tuple_type.item_type_sets
				nb := l_item_type_sets.count
				from i := 1 until i > nb loop
					l_argument_type_set.put_target (l_item_type_sets.item (i), current_system)
					i := i + 1
				end
			end
		end

feature {ET_DYNAMIC_ROUTINE_TYPE} -- Generation

	build_agent_call (an_agent_type: ET_DYNAMIC_ROUTINE_TYPE; a_call_feature: ET_DYNAMIC_FEATURE) is
			-- Build type set of argument type of `a_call_feature' from `an_agent_type'.
		local
			l_dynamic_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_agent_type_set: ET_DYNAMIC_AGENT_OPERAND_PUSH_TYPE_SET
		do
			l_dynamic_type_sets := a_call_feature.dynamic_type_sets
			if not l_dynamic_type_sets.is_empty then
				create l_agent_type_set.make (l_dynamic_type_sets.item (1).static_type, an_agent_type)
				l_dynamic_type_sets.put (l_agent_type_set, 1)
			end
		end

feature {NONE} -- CAT-calls

	report_catcall_error (a_target_type: ET_DYNAMIC_TYPE; a_dynamic_feature: ET_DYNAMIC_FEATURE;
		arg: INTEGER; a_formal_type: ET_DYNAMIC_TYPE; an_actual_type: ET_DYNAMIC_TYPE; a_call: ET_DYNAMIC_QUALIFIED_CALL) is
			-- Report a CAT-call error in `a_call'. When the target is of type `a_target_type', we
			-- try to pass to the corresponding feature `a_dynamic_feature' an actual
			-- argument of type `an_actual_type' which does not conform to the type of
			-- the `arg'-th corresponding formal argument `a_formal_type'.
		local
			l_message: STRING
			l_class_impl: ET_CLASS
			l_position: ET_POSITION
		do
-- TODO: better error message reporting.
			l_message := shared_error_message
			STRING_.wipe_out (l_message)
			l_message.append_string ("[CATCALL] class ")
			l_message.append_string (a_call.current_type.base_type.to_text)
			l_message.append_string (" (")
			l_class_impl := a_call.current_feature.static_feature.implementation_class
			if a_call.current_type.base_type.direct_base_class (universe) /= l_class_impl then
				l_message.append_string (l_class_impl.name.name)
				l_message.append_character (',')
			end
			l_position := a_call.position
			l_message.append_string (l_position.line.out)
			l_message.append_character (',')
			l_message.append_string (l_position.column.out)
			l_message.append_string ("): type '")
			l_message.append_string (an_actual_type.base_type.to_text)
			l_message.append_string ("' of actual argument #")
			l_message.append_string (arg.out)
			l_message.append_string (" does not conform to type '")
			l_message.append_string (a_formal_type.base_type.to_text)
			l_message.append_string ("' of formal argument in feature `")
			l_message.append_string (a_dynamic_feature.static_feature.name.name)
			l_message.append_string ("' in class '")
			l_message.append_string (a_target_type.base_type.to_text)
			l_message.append_string ("%'")
			set_fatal_error
			error_handler.report_error_message (l_message)
			STRING_.wipe_out (l_message)
		end

feature {NONE} -- Event handling

	report_assignment (an_instruction: ET_ASSIGNMENT) is
			-- Report that an assignment instruction has been processed.
		local
			l_source_type_set: ET_DYNAMIC_TYPE_SET
			l_target_type_set: ET_DYNAMIC_TYPE_SET
		do
			if current_type = current_dynamic_type.base_type then
				l_source_type_set := dynamic_type_set (an_instruction.source)
				l_target_type_set := dynamic_type_set (an_instruction.target)
				if l_source_type_set = Void or l_target_type_set = Void then
						-- Internal error: the dynamic type sets of the source
						-- and the target should be known at this stage.
					set_fatal_error
					error_handler.report_gibef_error
				else
					l_source_type_set.put_target (l_target_type_set, current_system)
				end
			end
		end

	report_assignment_attempt (an_instruction: ET_ASSIGNMENT_ATTEMPT) is
			-- Report that an assignment attempt instruction has been processed.
		local
			l_source_type_set: ET_DYNAMIC_TYPE_SET
			l_target_type_set: ET_DYNAMIC_TYPE_SET
		do
			if current_type = current_dynamic_type.base_type then
				l_source_type_set := dynamic_type_set (an_instruction.source)
				l_target_type_set := dynamic_type_set (an_instruction.target)
				if l_source_type_set = Void or l_target_type_set = Void then
						-- Internal error: the dynamic type sets of the source
						-- and the target should be known at this stage.
					set_fatal_error
					error_handler.report_gibeg_error
				else
					l_source_type_set.put_target (l_target_type_set, current_system)
				end
			end
		end

	report_convert_function (an_expression: ET_CONVERT_TO_EXPRESSION; a_target_type: ET_TYPE_CONTEXT; a_feature: ET_FEATURE) is
			-- Report that a convert function call expression has been processed.
		local
			l_target_type_set: ET_DYNAMIC_TYPE_SET
			l_result_type_set: ET_DYNAMIC_TYPE_SET
			l_dynamic_call: ET_DYNAMIC_QUALIFIED_CALL
			l_dynamic_type: ET_DYNAMIC_TYPE
			l_target: ET_EXPRESSION
			l_type: ET_TYPE
		do
			if current_type = current_dynamic_type.base_type then
				l_target := an_expression.expression
				l_target_type_set := dynamic_type_set (l_target)
				if l_target_type_set = Void then
						-- Internal error: the dynamic type set of the
						-- target should be known at this stage.
					set_fatal_error
					error_handler.report_gibeh_error
				else
					create l_dynamic_call.make (an_expression, l_target_type_set, current_dynamic_feature, current_dynamic_type)
					dynamic_qualified_calls.force_last (l_dynamic_call)
					l_type := a_feature.type
					if l_type = Void then
							-- Internal error: the result type set of a query cannot be void.
						set_fatal_error
						error_handler.report_gibei_error
					else
						l_dynamic_type := current_system.dynamic_type (l_type, l_target_type_set.static_type.base_type)
						l_result_type_set := new_dynamic_type_set (l_dynamic_type)
						l_dynamic_call.set_result_type_set (l_result_type_set)
						set_dynamic_type_set (l_result_type_set, an_expression)
						l_target_type_set.put_target (l_dynamic_call, current_system)
					end
				end
			end
		end

	report_creation_expression (an_expression: ET_EXPRESSION; a_creation_type: ET_NAMED_TYPE;
		a_procedure: ET_FEATURE; an_actuals: ET_ACTUAL_ARGUMENTS) is
			-- Report that a creation expression has been processed.
		local
			i, nb: INTEGER
			l_argument_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_procedure: ET_DYNAMIC_FEATURE
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			l_dynamic_creation_type: ET_DYNAMIC_TYPE
			l_actual: ET_EXPRESSION
		do
			if current_type = current_dynamic_type.base_type then
				l_dynamic_creation_type := current_system.dynamic_type (a_creation_type, current_type)
				l_procedure := l_dynamic_creation_type.dynamic_feature (a_procedure, current_system)
				l_procedure.set_creation (True)
				l_dynamic_creation_type.set_alive
				if an_actuals /= Void then
						-- Dynamic type sets for arguments are stored first
						-- in `dynamic_type_sets'.
					l_argument_type_sets := l_procedure.dynamic_type_sets
					nb := an_actuals.count
					if nb = 0 then
						-- Do nothing.
					elseif l_argument_type_sets.count < nb then
							-- Internal error: it has already been checked somewhere else
							-- that there was the same number of actual and formal arguments.
						set_fatal_error
						error_handler.report_gibej_error
					else
						from i := 1 until i > nb loop
							l_actual := an_actuals.actual_argument (i)
							l_dynamic_type_set := dynamic_type_set (l_actual)
							if l_dynamic_type_set = Void then
									-- Internal error: the dynamic type sets of the actual
									-- arguments should be known at this stage.
								set_fatal_error
								error_handler.report_gibek_error
							else
								l_dynamic_type_set.put_target (l_argument_type_sets.item (i), current_system)
							end
							i := i + 1
						end
					end
				end
				set_dynamic_type_set (l_dynamic_creation_type, an_expression)
			end
		end

	report_creation_instruction (an_instruction: ET_CREATION_INSTRUCTION; a_creation_type: ET_NAMED_TYPE; a_procedure: ET_FEATURE) is
			-- Report that a creation instruction has been processed.
		local
			i, nb: INTEGER
			l_actuals: ET_ACTUAL_ARGUMENT_LIST
			l_argument_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_procedure: ET_DYNAMIC_FEATURE
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			l_dynamic_creation_type: ET_DYNAMIC_TYPE
			l_target_type_set: ET_DYNAMIC_TYPE_SET
			l_actual: ET_EXPRESSION
		do
			if current_type = current_dynamic_type.base_type then
				l_dynamic_creation_type := current_system.dynamic_type (a_creation_type, current_type)
				l_procedure := l_dynamic_creation_type.dynamic_feature (a_procedure, current_system)
				l_procedure.set_creation (True)
				l_dynamic_creation_type.set_alive
				l_actuals := an_instruction.arguments
				if l_actuals /= Void then
						-- Dynamic type sets for arguments are stored first
						-- in `dynamic_type_sets'.
					l_argument_type_sets := l_procedure.dynamic_type_sets
					nb := l_actuals.count
					if nb = 0 then
						-- Do nothing.
					elseif l_argument_type_sets.count < nb then
							-- Internal error: it has already been checked somewhere else
							-- that there was the same number of actual and formal arguments.
						set_fatal_error
						error_handler.report_gibel_error
					else
						from i := 1 until i > nb loop
							l_actual := l_actuals.actual_argument (i)
							l_dynamic_type_set := dynamic_type_set (l_actual)
							if l_dynamic_type_set = Void then
									-- Internal error: the dynamic type sets of the actual
									-- arguments should be known at this stage.
								set_fatal_error
								error_handler.report_gibem_error
							else
								l_dynamic_type_set.put_target (l_argument_type_sets.item (i), current_system)
							end
							i := i + 1
						end
					end
				end
				l_target_type_set := dynamic_type_set (an_instruction.target)
				if l_target_type_set = Void then
						-- Internal error: the dynamic type sets of the
						-- target should be known at this stage.
					set_fatal_error
					error_handler.report_giben_error
				else
					l_dynamic_creation_type.put_target (l_target_type_set, current_system)
				end
			end
		end

	report_manifest_array (an_expression: ET_MANIFEST_ARRAY; a_type: ET_TYPE) is
			-- Report that a manifest array of type `a_type' in context
			-- of `current_type' has been processed.
		local
			l_type: ET_DYNAMIC_TYPE
			i, nb: INTEGER
			l_features: ET_DYNAMIC_FEATURE_LIST
			l_area_type_set: ET_DYNAMIC_TYPE_SET
			l_special_type: ET_DYNAMIC_SPECIAL_TYPE
			l_item_type_set: ET_DYNAMIC_TYPE_SET
			l_expression: ET_EXPRESSION
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
		do
			if current_type = current_dynamic_type.base_type then
				l_type := current_system.dynamic_type (a_type, current_type)
				l_type.set_alive
				set_dynamic_type_set (l_type, an_expression)
					-- Make sure that type SPECIAL[XXX] (used in feature 'area') is marked as alive.
					-- Feature 'area' should be the first in the list of features.
				l_features := l_type.features
				if l_features.is_empty then
						-- Error in feature 'area', already reported in ET_SYSTEM.compile_kernel.
					set_fatal_error
				else
					l_area_type_set := l_features.item (1).result_type_set
					if l_area_type_set = Void then
							-- Error in feature 'area', already reported in ET_SYSTEM.compile_kernel.
						set_fatal_error
					else
						l_special_type ?= l_area_type_set.static_type
						if l_special_type = Void then
								-- Error in feature 'area', already reported in ET_SYSTEM.compile_kernel.
							set_fatal_error
						else
							l_special_type.set_alive
							l_special_type.put_target (l_area_type_set, current_system)
							l_item_type_set := l_special_type.item_type_set
							nb := an_expression.count
							from i := 1 until i > nb loop
								l_expression := an_expression.expression (i)
								l_dynamic_type_set := dynamic_type_set (l_expression)
								if l_dynamic_type_set = Void then
										-- Internal error: the dynamic type set of the expressions
										-- in the manifest array should be known at this stage.
									set_fatal_error
									error_handler.report_gibeq_error
								else
									l_dynamic_type_set.put_target (l_item_type_set, current_system)
								end
								i := i + 1
							end
						end
					end
				end
					-- Make sure that type INTEGER (used in attributess 'lower' and 'upper') is marked as alive.
				current_system.integer_type.set_alive
			end
		end

	report_manifest_tuple (an_expression: ET_MANIFEST_TUPLE; a_type: ET_TYPE) is
			-- Report that a manifest tuple of type `a_type' in context of
			-- `current_type' has been processed.
		local
			l_type: ET_DYNAMIC_TYPE
			l_tuple_type: ET_DYNAMIC_TUPLE_TYPE
			i, nb: INTEGER
			l_item_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_expression: ET_EXPRESSION
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
		do
			if current_type = current_dynamic_type.base_type then
				l_type := current_system.dynamic_type (a_type, current_type)
				l_type.set_alive
				set_dynamic_type_set (l_type, an_expression)
				l_tuple_type ?= l_type
				if l_tuple_type = Void then
						-- Internal error: the type of a manifest tuple should be a tuple type.
					set_fatal_error
					error_handler.report_gibfw_error
				else
					l_item_type_sets := l_tuple_type.item_type_sets
					nb := an_expression.count
					if l_item_type_sets.count /= nb then
							-- Internal error: the tuple type of a manifest tuple should
							-- have the proper number of generic parameters.
						set_fatal_error
						error_handler.report_gibfx_error
					else
						from i := 1 until i > nb loop
							l_expression := an_expression.expression (i)
							l_dynamic_type_set := dynamic_type_set (l_expression)
							if l_dynamic_type_set = Void then
									-- Internal error: the dynamic type set of the expressions
									-- in the manifest tuple should be known at this stage.
								set_fatal_error
								error_handler.report_gibfy_error
							else
								l_dynamic_type_set.put_target (l_item_type_sets.item (i), current_system)
							end
							i := i + 1
						end
					end
				end
			end
		end

	report_precursor_expression (an_expression: ET_PRECURSOR_EXPRESSION; a_parent_type: ET_BASE_TYPE; a_feature: ET_FEATURE) is
			-- Report that a precursor expression has been processed.
			-- `a_parent_type' is viewed in the context of `current_type'
			-- and `a_feature' is the precursor feature.
		local
			i, nb: INTEGER
			l_actuals: ET_ACTUAL_ARGUMENT_LIST
			l_parent_type: ET_DYNAMIC_TYPE
			l_argument_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_query: ET_DYNAMIC_FEATURE
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			l_actual: ET_EXPRESSION
		do
			if current_type = current_dynamic_type.base_type then
				l_parent_type := current_system.dynamic_type (a_parent_type, current_type)
				l_query := current_dynamic_feature.dynamic_precursor (a_feature, l_parent_type, current_system)
				l_actuals := an_expression.arguments
				if l_actuals /= Void then
						-- Dynamic type sets for arguments are stored first
						-- in `dynamic_type_sets'.
					l_argument_type_sets := l_query.dynamic_type_sets
					nb := l_actuals.count
					if nb = 0 then
						-- Do nothing.
					elseif l_argument_type_sets.count < nb then
							-- Internal error: it has already been checked somewhere else
							-- that there was the same number of actual and formal arguments.
						set_fatal_error
						error_handler.report_giber_error
					else
						from i := 1 until i > nb loop
							l_actual := l_actuals.actual_argument (i)
							l_dynamic_type_set := dynamic_type_set (l_actual)
							if l_dynamic_type_set = Void then
									-- Internal error: the dynamic type sets of the actual
									-- arguments should be known at this stage.
								set_fatal_error
								error_handler.report_gibes_error
							else
								l_dynamic_type_set.put_target (l_argument_type_sets.item (i), current_system)
							end
							i := i + 1
						end
					end
				end
				l_dynamic_type_set := l_query.result_type_set
				if l_dynamic_type_set = Void then
						-- Internal error: the result type set of a query cannot be void.
					set_fatal_error
					error_handler.report_gibet_error
				else
					set_dynamic_type_set (l_dynamic_type_set, an_expression)
				end
			end
		end

	report_precursor_instruction (an_instruction: ET_PRECURSOR; a_parent_type: ET_BASE_TYPE; a_feature: ET_FEATURE) is
			-- Report that a precursor instruction has been processed.
			-- `a_parent_type' is viewed in the context of `current_type'
			-- and `a_feature' is the precursor feature.
		local
			i, nb: INTEGER
			l_actuals: ET_ACTUAL_ARGUMENT_LIST
			l_parent_type: ET_DYNAMIC_TYPE
			l_argument_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_procedure: ET_DYNAMIC_FEATURE
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			l_actual: ET_EXPRESSION
		do
			if current_type = current_dynamic_type.base_type then
				l_parent_type := current_system.dynamic_type (a_parent_type, current_type)
				l_procedure := current_dynamic_feature.dynamic_precursor (a_feature, l_parent_type, current_system)
				l_actuals := an_instruction.arguments
				if l_actuals /= Void then
						-- Dynamic type sets for arguments are stored first
						-- in `dynamic_type_sets'.
					l_argument_type_sets := l_procedure.dynamic_type_sets
					nb := l_actuals.count
					if nb = 0 then
						-- Do nothing.
					elseif l_argument_type_sets.count < nb then
							-- Internal error: it has already been checked somewhere else
							-- that there was the same number of actual and formal arguments.
						set_fatal_error
						error_handler.report_gibeu_error
					else
						from i := 1 until i > nb loop
							l_actual := l_actuals.actual_argument (i)
							l_dynamic_type_set := dynamic_type_set (l_actual)
							if l_dynamic_type_set = Void then
									-- Internal error: the dynamic type sets of the actual
									-- arguments should be known at this stage.
								set_fatal_error
								error_handler.report_gibev_error
							else
								l_dynamic_type_set.put_target (l_argument_type_sets.item (i), current_system)
							end
							i := i + 1
						end
					end
				end
			end
		end

	report_qualified_call_agent (an_expression: ET_CALL_AGENT; a_feature: ET_FEATURE; a_type: ET_TYPE; a_context: ET_TYPE_CONTEXT) is
			-- Report that a qualified call (to `a_feature') agent
			-- of type `a_type' in `a_context' has been processed.
		local
			l_dynamic_type: ET_DYNAMIC_TYPE
			l_agent_type: ET_DYNAMIC_ROUTINE_TYPE
			l_dynamic_feature: ET_DYNAMIC_FEATURE
			l_dynamic_call: ET_DYNAMIC_QUALIFIED_CALL
			l_dynamic_agent: ET_DYNAMIC_QUALIFIED_AGENT
			l_target_type_set: ET_DYNAMIC_TYPE_SET
			l_open_operand_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_target: ET_AGENT_TARGET
			l_target_expression: ET_EXPRESSION
			i, nb: INTEGER
			j, nb2: INTEGER
			l_actuals: ET_AGENT_ARGUMENT_OPERANDS
			l_actual: ET_AGENT_ARGUMENT_OPERAND
			l_actual_expression: ET_EXPRESSION
			l_argument_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
		do
			if current_type = current_dynamic_type.base_type then
				l_dynamic_type := current_system.dynamic_type (a_type, a_context)
				l_dynamic_type.set_alive
				set_dynamic_type_set (l_dynamic_type, an_expression)
				l_agent_type ?= l_dynamic_type
				if l_agent_type = Void then
						-- Internal error: the dynamic type of an agent should be an agent type.
					set_fatal_error
					error_handler.report_gibax_error
				else
					l_open_operand_type_sets := l_agent_type.open_operand_type_sets
					nb2 := l_open_operand_type_sets.count
					l_target := an_expression.target
					l_target_expression ?= l_target
					if l_target_expression /= Void then
						l_target_type_set := dynamic_type_set (l_target_expression)
					else
							-- The agent is of the form:   agent {TYPE}.f
							-- The dynamic type set of the target is the first of open operand dynamic type sets.
						j := 1
						if not l_open_operand_type_sets.is_empty then
							l_target_type_set := l_open_operand_type_sets.item (1)
							set_dynamic_type_set (l_target_type_set, l_target)
						end
					end
					if l_target_type_set = Void then
							-- Internal error: the dynamic type sets of the
							-- target should be known at this stage.
						set_fatal_error
						error_handler.report_gibga_error
					else
						l_dynamic_feature := l_target_type_set.static_type.dynamic_feature (a_feature, current_system)
						l_dynamic_feature.set_regular (True)
							-- Set dynamic type sets of open operands.
							-- Dynamic type sets for arguments are stored first in `dynamic_type_sets'.
						l_argument_type_sets := l_dynamic_feature.dynamic_type_sets
						l_actuals := an_expression.arguments
						if l_actuals /= Void then
							nb := l_actuals.count
							if nb = 0 then
								-- Do nothing.
							elseif l_argument_type_sets.count < nb then
									-- Internal error: it has already been checked somewhere else
									-- that there was the same number of actual and formal arguments.
								set_fatal_error
								error_handler.report_gibgb_error
							else
								from i := 1 until i > nb loop
									l_actual := l_actuals.actual_argument (i)
									l_actual_expression ?= l_actual
									if l_actual_expression /= Void then
										-- Do nothing.
									else
											-- Open operand.
										j := j + 1
										if j > nb2 then
												-- Internal error: missing open operands.
											set_fatal_error
											error_handler.report_gibfr_error
										else
											l_dynamic_type_set := l_open_operand_type_sets.item (j)
											set_dynamic_type_set (l_dynamic_type_set, l_actual)
										end
									end
									i := i + 1
								end
								if j < nb2 then
										-- Internal error: too many open operands.
									set_fatal_error
									error_handler.report_gibhk_error
								end
							end
						end
						create l_dynamic_call.make (an_expression, l_target_type_set, current_dynamic_feature, current_dynamic_type)
						l_dynamic_call.set_result_type_set (l_agent_type.result_type_set)
						create l_dynamic_agent.make (an_expression, l_agent_type, l_dynamic_call, current_dynamic_feature, current_dynamic_type)
						dynamic_qualified_agents.force_last (l_dynamic_agent)
						l_target_type_set.put_target (l_dynamic_call, current_system)
					end
				end
			end
		end

	report_qualified_call_expression (an_expression: ET_EXPRESSION; a_call: ET_FEATURE_CALL; a_target_type: ET_TYPE_CONTEXT; a_feature: ET_FEATURE) is
			-- Report that a qualified call expression has been processed.
		local
			l_target_type_set: ET_DYNAMIC_TYPE_SET
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			l_dynamic_call: ET_DYNAMIC_QUALIFIED_CALL
			l_target: ET_EXPRESSION
			l_type: ET_TYPE
			l_dynamic_type: ET_DYNAMIC_TYPE
		do
			if current_type = current_dynamic_type.base_type then
				l_target := a_call.target
				l_target_type_set := dynamic_type_set (l_target)
				if l_target_type_set = Void then
						-- Internal error: the dynamic type sets of the
						-- target should be known at this stage.
					set_fatal_error
					error_handler.report_gibew_error
				else
					create l_dynamic_call.make (a_call, l_target_type_set, current_dynamic_feature, current_dynamic_type)
					dynamic_qualified_calls.force_last (l_dynamic_call)
					l_type := a_feature.type
					if l_type = Void then
							-- Internal error: the result type set of a query cannot be void.
						set_fatal_error
						error_handler.report_gibey_error
					else
						l_dynamic_type := current_system.dynamic_type (l_type, l_target_type_set.static_type.base_type)
						l_dynamic_type_set := new_dynamic_type_set (l_dynamic_type)
						l_dynamic_call.set_result_type_set (l_dynamic_type_set)
						set_dynamic_type_set (l_dynamic_type_set, an_expression)
						l_target_type_set.put_target (l_dynamic_call, current_system)
					end
				end
			end
		end

	report_qualified_call_instruction (a_call: ET_FEATURE_CALL; a_target_type: ET_TYPE_CONTEXT; a_feature: ET_FEATURE) is
			-- Report that a qualified call instruction has been processed.
		local
			l_target_type_set: ET_DYNAMIC_TYPE_SET
			l_dynamic_call: ET_DYNAMIC_QUALIFIED_CALL
			l_target: ET_EXPRESSION
		do
			if current_type = current_dynamic_type.base_type then
				l_target := a_call.target
				l_target_type_set := dynamic_type_set (l_target)
				if l_target_type_set = Void then
						-- Internal error: the dynamic type sets of the
						-- target should be known at this stage.
					set_fatal_error
					error_handler.report_gibez_error
				else
					create l_dynamic_call.make (a_call, l_target_type_set, current_dynamic_feature, current_dynamic_type)
					dynamic_qualified_calls.force_last (l_dynamic_call)
					l_target_type_set.put_target (l_dynamic_call, current_system)
				end
			end
		end

	report_static_call_expression (an_expression: ET_STATIC_CALL_EXPRESSION; a_type: ET_TYPE; a_feature: ET_FEATURE) is
			-- Report that a static call expression has been processed.
		local
			i, nb: INTEGER
			l_actuals: ET_ACTUAL_ARGUMENT_LIST
			l_dynamic_type: ET_DYNAMIC_TYPE
			l_argument_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_query: ET_DYNAMIC_FEATURE
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			l_actual: ET_EXPRESSION
		do
			if current_type = current_dynamic_type.base_type then
				l_dynamic_type := current_system.dynamic_type (a_type, current_type)
				l_query := l_dynamic_type.dynamic_feature (a_feature, current_system)
				l_query.set_static (True)
				l_dynamic_type.set_static (True)
				l_actuals := an_expression.arguments
				if l_actuals /= Void then
						-- Dynamic type sets for arguments are stored first
						-- in `dynamic_type_sets'.
					l_argument_type_sets := l_query.dynamic_type_sets
					nb := l_actuals.count
					if nb = 0 then
						-- Do nothing.
					elseif l_argument_type_sets.count < nb then
							-- Internal error: it has already been checked somewhere else
							-- that there was the same number of actual and formal arguments.
						set_fatal_error
						error_handler.report_gibfb_error
					else
						from i := 1 until i > nb loop
							l_actual := l_actuals.actual_argument (i)
							l_dynamic_type_set := dynamic_type_set (l_actual)
							if l_dynamic_type_set = Void then
									-- Internal error: the dynamic type sets of the actual
									-- arguments should be known at this stage.
								set_fatal_error
								error_handler.report_gibfc_error
							else
								l_dynamic_type_set.put_target (l_argument_type_sets.item (i), current_system)
							end
							i := i + 1
						end
					end
				end
				l_dynamic_type_set := l_query.result_type_set
				if l_dynamic_type_set = Void then
						-- Internal error: the result type set of a query cannot be void.
					set_fatal_error
					error_handler.report_gibfd_error
				else
					set_dynamic_type_set (l_dynamic_type_set, an_expression)
				end
			end
		end

	report_static_call_instruction (an_instruction: ET_STATIC_FEATURE_CALL; a_type: ET_TYPE; a_feature: ET_FEATURE) is
			-- Report that a static call instruction has been processed.
		local
			i, nb: INTEGER
			l_actuals: ET_ACTUAL_ARGUMENT_LIST
			l_dynamic_type: ET_DYNAMIC_TYPE
			l_argument_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_procedure: ET_DYNAMIC_FEATURE
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			l_actual: ET_EXPRESSION
		do
			if current_type = current_dynamic_type.base_type then
				l_dynamic_type := current_system.dynamic_type (a_type, current_type)
				l_procedure := l_dynamic_type.dynamic_feature (a_feature, current_system)
				l_procedure.set_static (True)
				l_dynamic_type.set_static (True)
				l_actuals := an_instruction.arguments
				if l_actuals /= Void then
						-- Dynamic type sets for arguments are stored first
						-- in `dynamic_type_sets'.
					l_argument_type_sets := l_procedure.dynamic_type_sets
					nb := l_actuals.count
					if nb = 0 then
						-- Do nothing.
					elseif l_argument_type_sets.count < nb then
							-- Internal error: it has already been checked somewhere else
							-- that there was the same number of actual and formal arguments.
						set_fatal_error
						error_handler.report_gibfe_error
					else
						from i := 1 until i > nb loop
							l_actual := l_actuals.actual_argument (i)
							l_dynamic_type_set := dynamic_type_set (l_actual)
							if l_dynamic_type_set = Void then
									-- Internal error: the dynamic type sets of the actual
									-- arguments should be known at this stage.
								set_fatal_error
								error_handler.report_gibff_error
							else
								l_dynamic_type_set.put_target (l_argument_type_sets.item (i), current_system)
							end
							i := i + 1
						end
					end
				end
			end
		end

	report_string_constant (a_string: ET_MANIFEST_STRING) is
			-- Report that a string has been processed.
		local
			l_type: ET_DYNAMIC_TYPE
			l_features: ET_DYNAMIC_FEATURE_LIST
			l_area_type_set: ET_DYNAMIC_TYPE_SET
			l_special_type: ET_DYNAMIC_TYPE
		do
			if current_type = current_dynamic_type.base_type then
				l_type := current_system.string_type
				if a_string.index = 0 and string_index.item /= 0 then
					a_string.set_index (string_index.item)
				end
				l_type.set_alive
				set_dynamic_type_set (l_type, a_string)
				if string_index.item = 0 then
					string_index.put (a_string.index)
				end
					-- Make sure that type SPECIAL[CHARACTER] (used in
					-- feature 'area') is marked as alive.
					-- Feature 'area' should be the first in the list of features.
				l_special_type := current_system.special_character_type
				l_special_type.set_alive
				l_features := l_type.features
				if l_features.is_empty then
						-- Error in feature 'area', already reported in ET_SYSTEM.compile_kernel.
					set_fatal_error
				else
					l_area_type_set := l_features.item (1).result_type_set
					if l_area_type_set = Void then
							-- Error in feature 'area', already reported in ET_SYSTEM.compile_kernel.
						set_fatal_error
					else
						l_special_type.put_target (l_area_type_set, current_system)
					end
				end
					-- Make sure that type CHARACTER (used as actual generic type
					-- of 'SPECIAL[CHARACTER]' in feature 'area') is marked as alive.
				current_system.character_type.set_alive
					-- Make sure that type INTEGER (used in attribute 'count') is marked as alive.
				current_system.integer_type.set_alive
			end
		end

	report_unqualified_call_agent (an_expression: ET_CALL_AGENT; a_feature: ET_FEATURE; a_type: ET_TYPE; a_context: ET_TYPE_CONTEXT) is
			-- Report that an unqualified call (to `a_feature') agent
			-- of type `a_type' in `a_context' has been processed.
		local
			l_dynamic_type: ET_DYNAMIC_TYPE
			l_agent_type: ET_DYNAMIC_ROUTINE_TYPE
			l_dynamic_feature: ET_DYNAMIC_FEATURE
			l_dynamic_agent: ET_DYNAMIC_UNQUALIFIED_AGENT
			l_open_operand_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_result_type_set: ET_DYNAMIC_TYPE_SET
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			l_actuals: ET_AGENT_ARGUMENT_OPERANDS
			l_actual: ET_AGENT_ARGUMENT_OPERAND
			l_actual_expression: ET_EXPRESSION
			l_argument_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			i, nb: INTEGER
			j, nb2: INTEGER
			l_routine_type: ET_DYNAMIC_ROUTINE_TYPE
			l_routine_open_operand_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_manifest_tuple: ET_MANIFEST_TUPLE
			l_no_manifest_tuple: BOOLEAN
		do
			if current_type = current_dynamic_type.base_type then
				l_dynamic_feature := current_dynamic_type.dynamic_feature (a_feature, current_system)
				l_dynamic_feature.set_regular (True)
				l_dynamic_type := current_system.dynamic_type (a_type, a_context)
				l_dynamic_type.set_alive
				set_dynamic_type_set (l_dynamic_type, an_expression)
				l_agent_type ?= l_dynamic_type
				if l_agent_type = Void then
						-- Internal error: the dynamic type of an agent should be an agent type.
					set_fatal_error
					error_handler.report_gibfp_error
				else
					l_result_type_set := l_agent_type.result_type_set
					if l_result_type_set /= Void then
						l_dynamic_type_set := l_dynamic_feature.result_type_set
						if l_dynamic_type_set = Void then
								-- Internal error: a FUNCTION should be an agent on a query.
							set_fatal_error
							error_handler.report_gibfq_error
						else
							l_dynamic_type_set.put_target (l_result_type_set, current_system)
						end
					end
					create l_dynamic_agent.make (an_expression, l_agent_type, l_dynamic_feature, current_dynamic_feature, current_dynamic_type)
					dynamic_unqualified_agents.force_last (l_dynamic_agent)
						-- Dynamic type sets for arguments are stored first
						-- in `dynamic_type_sets'.
					l_argument_type_sets := l_dynamic_feature.dynamic_type_sets
					l_open_operand_type_sets := l_agent_type.open_operand_type_sets
					nb2 := l_open_operand_type_sets.count
					l_actuals := an_expression.arguments
					if l_actuals /= Void then
						nb := l_actuals.count
						if nb = 0 then
							-- Do nothing.
						elseif l_argument_type_sets.count < nb then
								-- Internal error: it has already been checked somewhere else
								-- that there was the same number of actual and formal arguments.
							set_fatal_error
							error_handler.report_gibfs_error
						else
							if (l_dynamic_feature.is_builtin_routine_call or l_dynamic_feature.is_builtin_function_item) and then current_dynamic_type.is_agent_type then
									-- This is something of the form:  'agent call ([...])' or 'agent item ([...])'
									-- Try to get the open operand type sets directly from the
									-- argument if it is a manifest tuple.
								l_routine_type ?= current_dynamic_type
								if l_routine_type = Void then
										-- Internal error: it has to be an agent type.
									set_fatal_error
									error_handler.report_gibhg_error
								else
									if nb /= 1 then
											-- Internal error: 'call' or 'item' should have exactly one argument.
										set_fatal_error
										error_handler.report_gibhh_error
									else
										l_actual := l_actuals.actual_argument (1)
										l_manifest_tuple ?= l_actual
										if l_manifest_tuple /= Void then
											l_routine_open_operand_type_sets := l_routine_type.open_operand_type_sets
											nb := l_routine_open_operand_type_sets.count
											if l_manifest_tuple.count < nb then
													-- Internal error: the actual argument conforms to the
													-- formal argument of 'call' or 'item', so there cannot
													-- be less items in the tuple.
												set_fatal_error
												error_handler.report_gibhi_error
											else
												from i := 1 until i > nb loop
													l_dynamic_type_set := dynamic_type_set (l_manifest_tuple.expression (i))
													if l_dynamic_type_set = Void then
															-- Internal error: the dynamic type sets of the actual
															-- arguments should be known at this stage.
														set_fatal_error
														error_handler.report_gibhj_error
													else
														l_dynamic_type_set.put_target (l_routine_open_operand_type_sets.item (i), current_system)
													end
													i := i + 1
												end
											end
										else
											l_no_manifest_tuple := True
										end
									end
								end
							else
								l_no_manifest_tuple := True
							end
							if l_no_manifest_tuple then
								from i := 1 until i > nb loop
									l_actual := l_actuals.actual_argument (i)
									l_actual_expression ?= l_actual
									if l_actual_expression /= Void then
										l_dynamic_type_set := dynamic_type_set (l_actual_expression)
										if l_dynamic_type_set = Void then
												-- Internal error: the dynamic type sets of the actual
												-- arguments should be known at this stage.
											set_fatal_error
											error_handler.report_gibft_error
										else
											l_dynamic_type_set.put_target (l_argument_type_sets.item (i), current_system)
										end
									else
											-- Open operand.
										j := j + 1
										if j > nb2 then
												-- Internal error: missing open operands.
											set_fatal_error
											error_handler.report_gibfu_error
										else
											l_dynamic_type_set := l_open_operand_type_sets.item (j)
											set_dynamic_type_set (l_dynamic_type_set, l_actual)
											l_dynamic_type_set.put_target (l_argument_type_sets.item (i), current_system)
										end
									end
									i := i + 1
								end
								if j < nb2 then
										-- Internal error: too many open operands.
									set_fatal_error
									error_handler.report_gibfv_error
								end
							end
						end
					end
				end
			end
		end

	report_unqualified_call_expression (an_expression: ET_EXPRESSION; a_call: ET_FEATURE_CALL; a_feature: ET_FEATURE) is
			-- Report that an unqualified call expression has been processed.
		local
			i, nb: INTEGER
			l_argument_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_query: ET_DYNAMIC_FEATURE
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			l_actuals: ET_ACTUAL_ARGUMENTS
			l_actual: ET_EXPRESSION
			l_agent_type: ET_DYNAMIC_ROUTINE_TYPE
			l_open_operand_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_manifest_tuple: ET_MANIFEST_TUPLE
		do
			if current_type = current_dynamic_type.base_type then
				l_query := current_dynamic_type.dynamic_feature (a_feature, current_system)
				l_query.set_regular (True)
				l_actuals := a_call.arguments
				if l_actuals /= Void then
						-- Dynamic type sets for arguments are stored first
						-- in `dynamic_type_sets'.
					l_argument_type_sets := l_query.dynamic_type_sets
					nb := l_actuals.count
					if nb = 0 then
						-- Do nothing.
					elseif l_argument_type_sets.count < nb then
							-- Internal error: it has already been checked somewhere else
							-- that there was the same number of actual and formal arguments.
						set_fatal_error
						error_handler.report_gibfg_error
					elseif l_query.is_builtin_function_item and then current_dynamic_type.is_agent_type then
							-- This is something of the form:  'item ([...])'
							-- Try to get the open operand type sets directly from the
							-- argument if it is a manifest tuple.
						l_agent_type ?= current_dynamic_type
						if l_agent_type = Void then
								-- Internal error: it has to be an agent type.
							set_fatal_error
							error_handler.report_gibhb_error
						else
							if nb /= 1 then
									-- Internal error: 'item' should have exactly one argument.
								set_fatal_error
								error_handler.report_gibhc_error
							else
								l_actual := l_actuals.actual_argument (1)
								l_manifest_tuple ?= l_actual
								if l_manifest_tuple /= Void then
									l_open_operand_type_sets := l_agent_type.open_operand_type_sets
									nb := l_open_operand_type_sets.count
									if l_manifest_tuple.count < nb then
											-- Internal error: the actual argument conforms to the
											-- formal argument of 'item', so there cannot be less
											-- items in the tuple.
										set_fatal_error
										error_handler.report_gibhd_error
									else
										from i := 1 until i > nb loop
											l_dynamic_type_set := dynamic_type_set (l_manifest_tuple.expression (i))
											if l_dynamic_type_set = Void then
													-- Internal error: the dynamic type sets of the actual
													-- arguments should be known at this stage.
												set_fatal_error
												error_handler.report_gibhe_error
											else
												l_dynamic_type_set.put_target (l_open_operand_type_sets.item (i), current_system)
											end
											i := i + 1
										end
									end
								else
									l_dynamic_type_set := dynamic_type_set (l_actual)
									if l_dynamic_type_set = Void then
											-- Internal error: the dynamic type sets of the actual
											-- arguments should be known at this stage.
										set_fatal_error
										error_handler.report_gibhf_error
									else
										l_dynamic_type_set.put_target (l_argument_type_sets.item (1), current_system)
									end
								end
							end
						end
					else
						from i := 1 until i > nb loop
							l_actual := l_actuals.actual_argument (i)
							l_dynamic_type_set := dynamic_type_set (l_actual)
							if l_dynamic_type_set = Void then
									-- Internal error: the dynamic type sets of the actual
									-- arguments should be known at this stage.
								set_fatal_error
								error_handler.report_gibfh_error
							else
								l_dynamic_type_set.put_target (l_argument_type_sets.item (i), current_system)
							end
							i := i + 1
						end
					end
				end
				l_dynamic_type_set := l_query.result_type_set
				if l_dynamic_type_set = Void then
						-- Internal error: the result type set of a query cannot be void.
					set_fatal_error
					error_handler.report_gibfi_error
				else
					set_dynamic_type_set (l_dynamic_type_set, an_expression)
				end
			end
		end

	report_unqualified_call_instruction (a_call: ET_FEATURE_CALL; a_feature: ET_FEATURE) is
			-- Report that an unqualified call instruction has been processed.
		local
			i, nb: INTEGER
			l_argument_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_procedure: ET_DYNAMIC_FEATURE
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
			l_actuals: ET_ACTUAL_ARGUMENTS
			l_actual: ET_EXPRESSION
			l_agent_type: ET_DYNAMIC_ROUTINE_TYPE
			l_open_operand_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_manifest_tuple: ET_MANIFEST_TUPLE
		do
			if current_type = current_dynamic_type.base_type then
				l_procedure := current_dynamic_type.dynamic_feature (a_feature, current_system)
				l_procedure.set_regular (True)
				l_actuals := a_call.arguments
				if l_actuals /= Void then
						-- Dynamic type sets for arguments are stored first
						-- in `dynamic_type_sets'.
					l_argument_type_sets := l_procedure.dynamic_type_sets
					nb := l_actuals.count
					if nb = 0 then
						-- Do nothing.
					elseif l_argument_type_sets.count < nb then
							-- Internal error: it has already been checked somewhere else
							-- that there was the same number of actual and formal arguments.
						set_fatal_error
						error_handler.report_gibfj_error
					elseif l_procedure.is_builtin_routine_call and then current_dynamic_type.is_agent_type then
							-- This is something of the form:  'call ([...])'
							-- Try to get the open operand type sets directly from the
							-- argument if it is a manifest tuple.
						l_agent_type ?= current_dynamic_type
						if l_agent_type = Void then
								-- Internal error: it has to be an agent type.
							set_fatal_error
							error_handler.report_gibgv_error
						else
							if nb /= 1 then
									-- Internal error: 'call' should have exactly one argument.
								set_fatal_error
								error_handler.report_gibgw_error
							else
								l_actual := l_actuals.actual_argument (1)
								l_manifest_tuple ?= l_actual
								if l_manifest_tuple /= Void then
									l_open_operand_type_sets := l_agent_type.open_operand_type_sets
									nb := l_open_operand_type_sets.count
									if l_manifest_tuple.count < nb then
											-- Internal error: the actual argument conforms to the
											-- formal argument of 'call', so there cannot be less
											-- items in the tuple.
										set_fatal_error
										error_handler.report_gibgx_error
									else
										from i := 1 until i > nb loop
											l_dynamic_type_set := dynamic_type_set (l_manifest_tuple.expression (i))
											if l_dynamic_type_set = Void then
													-- Internal error: the dynamic type sets of the actual
													-- arguments should be known at this stage.
												set_fatal_error
												error_handler.report_gibgy_error
											else
												l_dynamic_type_set.put_target (l_open_operand_type_sets.item (i), current_system)
											end
											i := i + 1
										end
									end
								else
									l_dynamic_type_set := dynamic_type_set (l_actual)
									if l_dynamic_type_set = Void then
											-- Internal error: the dynamic type sets of the actual
											-- arguments should be known at this stage.
										set_fatal_error
										error_handler.report_gibgz_error
									else
										l_dynamic_type_set.put_target (l_argument_type_sets.item (1), current_system)
									end
								end
							end
						end
					else
						from i := 1 until i > nb loop
							l_actual := l_actuals.actual_argument (i)
							l_dynamic_type_set := dynamic_type_set (l_actual)
							if l_dynamic_type_set = Void then
									-- Internal error: the dynamic type sets of the actual
									-- arguments should be known at this stage.
								set_fatal_error
								error_handler.report_gibfk_error
							else
								l_dynamic_type_set.put_target (l_argument_type_sets.item (i), current_system)
							end
							i := i + 1
						end
					end
				end
			end
		end

feature {NONE} -- Built-in features

	report_builtin_any_twin (a_feature: ET_EXTERNAL_FUNCTION) is
			-- Report that built-in feature ANY.twin is being analyzed.
		local
			l_result_type_set: ET_DYNAMIC_TYPE_SET
			l_copy_feature: ET_FEATURE
			l_dynamic_feature: ET_DYNAMIC_FEATURE
			l_dynamic_type_sets: ET_DYNAMIC_TYPE_SET_LIST
			l_dynamic_type_set: ET_DYNAMIC_TYPE_SET
		do
			if current_type = current_dynamic_type.base_type then
				current_dynamic_feature.set_builtin_code (builtin_any_twin)
				l_result_type_set := current_dynamic_feature.result_type_set
				if l_result_type_set = Void then
					set_fatal_error
					error_handler.report_giaac_error
				else
					current_dynamic_type.put_target (l_result_type_set, current_system)
						-- Feature `copy' is called internally.
					l_copy_feature := current_class.seeded_feature (universe.copy_seed)
					if l_copy_feature = Void then
						set_fatal_error
						if universe.copy_seed = 0 then
-- TODO: error
						else
							error_handler.report_gibgq_error
						end
					else
						l_dynamic_feature := current_dynamic_type.dynamic_feature (l_copy_feature, current_system)
						l_dynamic_feature.set_regular (True)
						l_dynamic_type_sets := l_dynamic_feature.dynamic_type_sets
						if l_dynamic_type_sets.count >= 1 then
							l_dynamic_type_set := l_dynamic_type_sets.item (1)
							current_dynamic_type.put_target (l_dynamic_type_set, current_system)
						end
					end
				end
			end
		end

end
