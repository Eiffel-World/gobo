indexing

	description:

		"Eiffel precursor validity checkers"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2003, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_PRECURSOR_CHECKER

inherit

	ET_AST_NULL_PROCESSOR
		redefine
			make,
			process_actual_argument_list,
			process_agent_actual_argument_list,
			process_assignment,
			process_assignment_attempt,
			process_attribute,
			process_bang_instruction,
			process_call_agent,
			process_call_expression,
			process_call_instruction,
			process_check_instruction,
			process_compound,
			process_constant_attribute,
			process_convert_expression,
			process_create_expression,
			process_create_instruction,
			process_debug_instruction,
			process_deferred_function,
			process_deferred_procedure,
			process_do_function,
			process_do_procedure,
			process_elseif_part,
			process_elseif_part_list,
			process_equality_expression,
			process_expression_address,
			process_external_function,
			process_external_procedure,
			process_if_instruction,
			process_infix_expression,
			process_inspect_instruction,
			process_invariants,
			process_loop_instruction,
			process_manifest_array,
			process_manifest_tuple,
			process_old_expression,
			process_once_function,
			process_once_procedure,
			process_parenthesized_expression,
			process_precursor_expression,
			process_precursor_instruction,
			process_prefix_expression,
			process_static_call_expression,
			process_static_call_instruction,
			process_tagged_assertion,
			process_unique_attribute,
			process_when_part,
			process_when_part_list
		end

	ET_SHARED_TOKEN_CONSTANTS
		export {NONE} all end

creation

	make

feature {NONE} -- Initialization

	make (a_universe: like universe) is
			-- Create a new precursor validity checker.
		do
			universe := a_universe
			current_class := a_universe.unknown_class
			current_feature := dummy_feature
		end

feature -- Status report

	has_fatal_error: BOOLEAN
			-- Has a fatal error occurred when checking
			-- validity of last feature?

feature -- Validity checking

	check_feature_validity (a_feature: ET_REDECLARED_FEATURE; a_class: ET_CLASS) is
			-- Check validity of Precursor constructs in `a_feature' in `a_class'.
		require
			a_feature_not_void: a_feature /= Void
			a_class_not_void: a_class /= Void
		local
			old_feature: ET_REDECLARED_FEATURE
			old_class: ET_CLASS
		do
			has_fatal_error := False
			old_feature := current_feature
			current_feature := a_feature
			old_class := current_class
			current_class := a_class
			internal_call := True
			a_feature.flattened_feature.process (Current)
			if internal_call then
					-- Internal error.
				internal_call := False
				set_fatal_error
				error_handler.report_giabv_error
			end
			current_class := old_class
			current_feature := old_feature
		end

feature {NONE} -- Precursor validity

	check_precursor_validity (a_precursor: ET_PRECURSOR) is
			-- Check validity of `a_precursor'.
		require
			a_precursor_not_void: a_precursor /= Void
		local
			a_parent_name: ET_PRECURSOR_CLASS_NAME
			a_class_name: ET_CLASS_NAME
			a_class: ET_CLASS
			a_parent_feature: ET_PARENT_FEATURE
			a_parent_type: ET_BASE_TYPE
			a_precursor_feature: ET_FEATURE
			an_effective: ET_PARENT_FEATURE
			a_deferred: ET_PARENT_FEATURE
			a_parents: ET_PARENT_LIST
			a_parent_found: BOOLEAN
			a_feature: ET_FEATURE
			i, nb: INTEGER
		do
			a_parent_name := a_precursor.parent_name
			if a_parent_name /= Void then
				a_class_name := a_parent_name.class_name
				if not universe.has_class (a_class_name) then
					set_fatal_error
					error_handler.report_vdpr2a_error (current_class, a_precursor)
				else
					a_class := universe.eiffel_class (a_class_name)
					from
						a_parent_feature := current_feature.parent_feature
					until
						a_parent_feature = Void
					loop
						a_parent_type := a_parent_feature.parent.type
						if a_parent_type.direct_base_class (universe) = a_class then
							a_precursor_feature := a_parent_feature.precursor_feature
							if an_effective /= Void then
								if not a_parent_feature.is_deferred then
									-- Note: use `same_version' to behave like ISE's implementation.
									-- if a_parent_feature.precursor_feature /= an_effective.precursor_feature then
									if not a_parent_feature.same_version (an_effective) then
										a_feature := current_feature.flattened_feature
										set_fatal_error
										error_handler.report_vdpr3a_error (current_class, a_precursor, a_feature, an_effective, a_parent_feature)
									end
								end
							elseif not a_parent_feature.is_deferred then
								an_effective := a_parent_feature
								a_precursor.precursor_keyword.set_seed (a_precursor_feature.first_seed)
								a_precursor.set_parent_type (a_parent_type)
							else
								a_deferred := a_parent_feature
							end
						end
						a_parent_feature := a_parent_feature.merged_feature
					end
					if an_effective = Void then
						if a_deferred /= Void then
							-- Note: follow ISE's behavior and do not take
							-- Undefine clauses into account.
							--a_feature := current_feature.flattened_feature
							--set_fatal_error
							--error_handler.report_vdpr3b_error (current_class, a_precursor, a_feature, a_deferred)
							from
								a_parent_feature := current_feature.parent_feature
							until
								a_parent_feature = Void
							loop
								a_parent_type := a_parent_feature.parent.type
								if a_parent_type.direct_base_class (universe) = a_class then
									a_precursor_feature := a_parent_feature.precursor_feature
									if an_effective /= Void then
										if not a_precursor_feature.is_deferred then
											-- Note: use `same_version' to behave like ISE's implementation.
											-- if a_parent_feature.precursor_feature /= an_effective.precursor_feature then
											if not a_parent_feature.same_version (an_effective) then
												a_feature := current_feature.flattened_feature
												set_fatal_error
												error_handler.report_vdpr3a_error (current_class, a_precursor, a_feature, an_effective, a_parent_feature)
											end
										end
									elseif not a_precursor_feature.is_deferred then
										an_effective := a_parent_feature
										a_precursor.precursor_keyword.set_seed (a_precursor_feature.first_seed)
										a_precursor.set_parent_type (a_parent_type)
									end
								end
								a_parent_feature := a_parent_feature.merged_feature
							end
							if an_effective = Void then
								a_feature := current_feature.flattened_feature
								set_fatal_error
								error_handler.report_vdpr3b_error (current_class, a_precursor, a_feature, a_deferred)
							end
						else
							a_parents := current_class.parents
							if a_parents = Void then
								if a_class /= universe.any_class then
									set_fatal_error
									error_handler.report_vdpr2a_error (current_class, a_precursor)
								else
									a_feature := current_feature.flattened_feature
									set_fatal_error
									error_handler.report_vdpr3c_error (current_class, a_precursor, a_feature)
								end
							else
								nb := a_parents.count
								from i := 1 until i > nb loop
									if a_parents.parent (i).type.direct_base_class (universe) = a_class then
										a_parent_found := True
										i := nb + 1 -- Jump out of the loop.
									else
										i := i + 1
									end
								end
								if a_parent_found then
									a_feature := current_feature.flattened_feature
									set_fatal_error
									error_handler.report_vdpr3c_error (current_class, a_precursor, a_feature)
								else
									set_fatal_error
									error_handler.report_vdpr2a_error (current_class, a_precursor)
								end
							end
						end
					end
				end
			else
				from
					a_parent_feature := current_feature.parent_feature
				until
					a_parent_feature = Void
				loop
					a_precursor_feature := a_parent_feature.precursor_feature
					if an_effective /= Void then
						if not a_parent_feature.is_deferred then
							-- Note: use `same_version' to behave like ISE's implementation.
							--a_parent_type := a_parent_feature.parent.type
							--a_class := a_parent_type.direct_base_class (universe)
							--if a_class /= an_effective.parent.type.direct_base_class (universe) then
							--	a_feature := current_feature.flattened_feature
							--	set_fatal_error
							--	error_handler.report_vdpr3a_error (current_class, a_precursor, a_feature, an_effective, a_parent_feature)
							--elseif a_precursor_feature /= an_effective.precursor_feature then
							if not a_parent_feature.same_version (an_effective) then
								a_feature := current_feature.flattened_feature
								set_fatal_error
								error_handler.report_vdpr3a_error (current_class, a_precursor, a_feature, an_effective, a_parent_feature)
							end
						end
					elseif not a_parent_feature.is_deferred then
						an_effective := a_parent_feature
						a_precursor.precursor_keyword.set_seed (a_precursor_feature.first_seed)
						a_precursor.set_parent_type (a_parent_feature.parent.type)
					else
						a_deferred := a_parent_feature
					end
					a_parent_feature := a_parent_feature.merged_feature
				end
				if an_effective = Void then
					if a_deferred /= Void then
						-- Note: follow ISE's behavior and do not take
						-- Undefine clauses into account.
						--a_feature := current_feature.flattened_feature
						--set_fatal_error
						--error_handler.report_vdpr3b_error (current_class, a_precursor, a_feature, a_deferred)
						from
							a_parent_feature := current_feature.parent_feature
						until
							a_parent_feature = Void
						loop
							a_precursor_feature := a_parent_feature.precursor_feature
							if an_effective /= Void then
								if not a_precursor_feature.is_deferred then
									-- Note: use `same_version' to behave like ISE's implementation.
									--a_parent_type := a_parent_feature.parent.type
									--a_class := a_parent.direct_base_class (universe)
									--if a_class /= an_effective.parent.type.direct_base_class (universe) then
									--	a_feature := current_feature.flattened_feature
									--	set_fatal_error
									--	error_handler.report_vdpr3a_error (current_class, a_precursor, a_feature, an_effective, a_parent_feature)
									--elseif a_precursor_feature /= an_effective.precursor_feature then
									if not a_parent_feature.same_version (an_effective) then
										a_feature := current_feature.flattened_feature
										set_fatal_error
										error_handler.report_vdpr3a_error (current_class, a_precursor, a_feature, an_effective, a_parent_feature)
									end
								end
							elseif not a_precursor_feature.is_deferred then
								an_effective := a_parent_feature
								a_precursor.precursor_keyword.set_seed (a_precursor_feature.first_seed)
								a_precursor.set_parent_type (a_parent_feature.parent.type)
							end
							a_parent_feature := a_parent_feature.merged_feature
						end
						if an_effective = Void then
							a_feature := current_feature.flattened_feature
							set_fatal_error
							error_handler.report_vdpr3b_error (current_class, a_precursor, a_feature, a_deferred)
						end
					else
							-- Internal error: either `an_effective' or `a_deferred'
							-- should be non-void because `current_feature' has at least
							-- one parent feature.
						set_fatal_error
						error_handler.report_giabw_error
					end
				end
			end
		end

feature {ET_AST_NODE} -- Processing

	process_actual_argument_list (a_list: ET_ACTUAL_ARGUMENT_LIST) is
			-- Process `a_list'.
		local
			i, nb: INTEGER
		do
			if internal_call then
				nb := a_list.count
				from i := 1 until i > nb loop
					a_list.expression (i).process (Current)
					i := i + 1
				end
			end
		end

	process_agent_actual_argument_list (a_list: ET_AGENT_ACTUAL_ARGUMENT_LIST) is
			-- Process `a_list'.
		local
			i, nb: INTEGER
		do
			if internal_call then
				nb := a_list.count
				from i := 1 until i > nb loop
					a_list.actual_argument (i).process (Current)
					i := i + 1
				end
			end
		end

	process_assignment (an_instruction: ET_ASSIGNMENT) is
			-- Process `an_instruction'.
		do
			if internal_call then
				an_instruction.source.process (Current)
			end
		end

	process_assignment_attempt (an_instruction: ET_ASSIGNMENT_ATTEMPT) is
			-- Process `an_instruction'.
		do
			if internal_call then
				an_instruction.source.process (Current)
			end
		end

	process_attribute (a_feature: ET_ATTRIBUTE) is
			-- Process `a_feature'.
		do
			internal_call := False
		end

	process_bang_instruction (an_instruction: ET_BANG_INSTRUCTION) is
			-- Process `an_instruction'.
		local
			a_call: ET_QUALIFIED_CALL
			an_arguments: ET_ACTUAL_ARGUMENT_LIST
		do
			if internal_call then
				a_call := an_instruction.creation_call
				if a_call /= Void then
					an_arguments := a_call.arguments
					if an_arguments /= Void then
						process_actual_argument_list (an_arguments)
					end
				end
			end
		end

	process_call_agent (an_expression: ET_CALL_AGENT) is
			-- Process `an_expression'.
		local
			a_target: ET_AGENT_TARGET
			an_arguments: ET_AGENT_ACTUAL_ARGUMENT_LIST
		do
			if internal_call then
				a_target := an_expression.target
				if a_target /= Void then
					a_target.process (Current)
				end
				an_arguments := an_expression.arguments
				if an_arguments /= Void then
					process_agent_actual_argument_list (an_arguments)
				end
			end
		end

	process_call_expression (an_expression: ET_CALL_EXPRESSION) is
			-- Process `an_expression'.
		local
			a_target: ET_EXPRESSION
			an_arguments: ET_ACTUAL_ARGUMENT_LIST
		do
			if internal_call then
				a_target := an_expression.target
				if a_target /= Void then
					a_target.process (Current)
				end
				an_arguments := an_expression.arguments
				if an_arguments /= Void then
					process_actual_argument_list (an_arguments)
				end
			end
		end

	process_call_instruction (an_instruction: ET_CALL_INSTRUCTION) is
			-- Process `an_instruction'.
		local
			a_target: ET_EXPRESSION
			an_arguments: ET_ACTUAL_ARGUMENT_LIST
		do
			if internal_call then
				a_target := an_instruction.target
				if a_target /= Void then
					a_target.process (Current)
				end
				an_arguments := an_instruction.arguments
				if an_arguments /= Void then
					process_actual_argument_list (an_arguments)
				end
			end
		end

	process_check_instruction (an_instruction: ET_CHECK_INSTRUCTION) is
			-- Process `an_instruction'.
		local
			i, nb: INTEGER
		do
			if internal_call then
				nb := an_instruction.count
				from i := 1 until i > nb loop
					an_instruction.assertion (i).process (Current)
					i := i + 1
				end
			end
		end

	process_compound (a_list: ET_COMPOUND) is
			-- Process `a_list'.
		local
			i, nb: INTEGER
		do
			if internal_call then
				nb := a_list.count
				from i := 1 until i > nb loop
					a_list.item (i).process (Current)
					i := i + 1
				end
			end
		end

	process_constant_attribute (a_feature: ET_CONSTANT_ATTRIBUTE) is
			-- Process `a_feature'.
		do
			internal_call := False
		end

	process_convert_expression (a_convert_expression: ET_CONVERT_EXPRESSION) is
			-- Process `a_convert_expression'.
		do
			if internal_call then
				a_convert_expression.expression.process (Current)
			end
		end

	process_create_expression (an_expression: ET_CREATE_EXPRESSION) is
			-- Process `an_expression'.
		local
			a_call: ET_QUALIFIED_CALL
			an_arguments: ET_ACTUAL_ARGUMENT_LIST
		do
			if internal_call then
				a_call := an_expression.creation_call
				if a_call /= Void then
					an_arguments := a_call.arguments
					if an_arguments /= Void then
						process_actual_argument_list (an_arguments)
					end
				end
			end
		end

	process_create_instruction (an_instruction: ET_CREATE_INSTRUCTION) is
			-- Process `an_instruction'.
		local
			a_call: ET_QUALIFIED_CALL
			an_arguments: ET_ACTUAL_ARGUMENT_LIST
		do
			if internal_call then
				a_call := an_instruction.creation_call
				if a_call /= Void then
					an_arguments := a_call.arguments
					if an_arguments /= Void then
						process_actual_argument_list (an_arguments)
					end
				end
			end
		end

	process_debug_instruction (an_instruction: ET_DEBUG_INSTRUCTION) is
			-- Process `an_instruction'.
		local
			a_compound: ET_COMPOUND
		do
			if internal_call then
				a_compound := an_instruction.compound
				if a_compound /= Void then
					process_compound (a_compound)
				end
			end
		end

	process_deferred_function (a_feature: ET_DEFERRED_FUNCTION) is
			-- Process `a_feature'.
		do
			internal_call := False
		end

	process_deferred_procedure (a_feature: ET_DEFERRED_PROCEDURE) is
			-- Process `a_feature'.
		do
			internal_call := False
		end

	process_do_function (a_feature: ET_DO_FUNCTION) is
			-- Process `a_feature'.
		local
			a_compound: ET_COMPOUND
		do
			if internal_call then
				a_compound := a_feature.compound
				if a_compound /= Void then
					process_compound (a_compound)
				end
				internal_call := False
			end
		end

	process_do_procedure (a_feature: ET_DO_PROCEDURE) is
			-- Process `a_feature'.
		local
			a_compound: ET_COMPOUND
		do
			if internal_call then
				a_compound := a_feature.compound
				if a_compound /= Void then
					process_compound (a_compound)
				end
				internal_call := False
			end
		end

	process_elseif_part (an_elseif_part: ET_ELSEIF_PART) is
			-- Process `an_elseif_part'.
		local
			a_compound: ET_COMPOUND
		do
			if internal_call then
				an_elseif_part.conditional.expression.process (Current)
				a_compound := an_elseif_part.then_compound
				if a_compound /= Void then
					process_compound (a_compound)
				end
			end
		end

	process_elseif_part_list (a_list: ET_ELSEIF_PART_LIST) is
			-- Process `a_list'.
		local
			i, nb: INTEGER
		do
			if internal_call then
				nb := a_list.count
				from i := 1 until i > nb loop
					a_list.item (i).process (Current)
					i := i + 1
				end
			end
		end

	process_equality_expression (an_expression: ET_EQUALITY_EXPRESSION) is
			-- Process `an_expression'.
		do
			if internal_call then
				an_expression.left.process (Current)
				an_expression.right.process (Current)
			end
		end

	process_expression_address (an_expression: ET_EXPRESSION_ADDRESS) is
			-- Process `an_expression'.
		do
			if internal_call then
				an_expression.expression.process (Current)
			end
		end

	process_external_function (a_feature: ET_EXTERNAL_FUNCTION) is
			-- Process `a_feature'.
		do
			internal_call := False
		end

	process_external_procedure (a_feature: ET_EXTERNAL_PROCEDURE) is
			-- Process `a_feature'.
		do
			internal_call := False
		end

	process_if_instruction (an_instruction: ET_IF_INSTRUCTION) is
			-- Process `an_instruction'.
		local
			an_elseif_parts: ET_ELSEIF_PART_LIST
			a_compound: ET_COMPOUND
		do
			if internal_call then
				an_instruction.conditional.expression.process (Current)
				a_compound := an_instruction.then_compound
				if a_compound /= Void then
					process_compound (a_compound)
				end
				an_elseif_parts := an_instruction.elseif_parts
				if an_elseif_parts /= Void then
					process_elseif_part_list (an_elseif_parts)
				end
				a_compound := an_instruction.else_compound
				if a_compound /= Void then
					process_compound (a_compound)
				end
			end
		end

	process_infix_expression (an_expression: ET_INFIX_EXPRESSION) is
			-- Process `an_expression'.
		do
			if internal_call then
				an_expression.left.process (Current)
				an_expression.right.process (Current)
			end
		end

	process_inspect_instruction (an_instruction: ET_INSPECT_INSTRUCTION) is
			-- Process `an_instruction'.
		local
			a_when_parts: ET_WHEN_PART_LIST
			an_else_compound: ET_COMPOUND
		do
			if internal_call then
				an_instruction.conditional.expression.process (Current)
				a_when_parts := an_instruction.when_parts
				if a_when_parts /= Void then
					process_when_part_list (a_when_parts)
				end
				an_else_compound := an_instruction.else_compound
				if an_else_compound /= Void then
					process_compound (an_else_compound)
				end
			end
		end

	process_invariants (a_list: ET_INVARIANTS) is
			-- Process `a_list'.
		local
			i, nb: INTEGER
		do
			if internal_call then
				nb := a_list.count
				from i := 1 until i > nb loop
					a_list.assertion (i).process (Current)
					i := i + 1
				end
			end
		end

	process_loop_instruction (an_instruction: ET_LOOP_INSTRUCTION) is
			-- Process `an_instruction'.
		local
			an_invariant_part: ET_INVARIANTS
			a_variant_part: ET_VARIANT
			a_compound: ET_COMPOUND
		do
			if internal_call then
				a_compound := an_instruction.from_compound
				if a_compound /= Void then
					process_compound (a_compound)
				end
				an_invariant_part := an_instruction.invariant_part
				if an_invariant_part /= Void then
					process_invariants (an_invariant_part)
				end
				a_variant_part := an_instruction.variant_part
				if a_variant_part /= Void then
					a_variant_part.expression.process (Current)
				end
				an_instruction.until_conditional.expression.process (Current)
				a_compound := an_instruction.loop_compound
				if a_compound /= Void then
					process_compound (a_compound)
				end
			end
		end

	process_manifest_array (an_expression: ET_MANIFEST_ARRAY) is
			-- Process `an_expression'.
		local
			i, nb: INTEGER
		do
			if internal_call then
				nb := an_expression.count
				from i := 1 until i > nb loop
					an_expression.expression (i).process (Current)
					i := i + 1
				end
			end
		end

	process_manifest_tuple (an_expression: ET_MANIFEST_TUPLE) is
			-- Process `an_expression'.
		local
			i, nb: INTEGER
		do
			if internal_call then
				nb := an_expression.count
				from i := 1 until i > nb loop
					an_expression.expression (i).process (Current)
					i := i + 1
				end
			end
		end

	process_old_expression (an_expression: ET_OLD_EXPRESSION) is
			-- Process `an_expression'.
		do
			if internal_call then
				an_expression.expression.process (Current)
			end
		end

	process_once_function (a_feature: ET_ONCE_FUNCTION) is
			-- Process `a_feature'.
		local
			a_compound: ET_COMPOUND
		do
			if internal_call then
				a_compound := a_feature.compound
				if a_compound /= Void then
					process_compound (a_compound)
				end
				internal_call := False
			end
		end

	process_once_procedure (a_feature: ET_ONCE_PROCEDURE) is
			-- Process `a_feature'.
		local
			a_compound: ET_COMPOUND
		do
			if internal_call then
				a_compound := a_feature.compound
				if a_compound /= Void then
					process_compound (a_compound)
				end
				internal_call := False
			end
		end

	process_parenthesized_expression (an_expression: ET_PARENTHESIZED_EXPRESSION) is
			-- Process `an_expression'.
		do
			if internal_call then
				an_expression.expression.process (Current)
			end
		end

	process_precursor_expression (an_expression: ET_PRECURSOR_EXPRESSION) is
			-- Process `an_expression'.
		local
			an_arguments: ET_ACTUAL_ARGUMENT_LIST
		do
			if internal_call then
				check_precursor_validity (an_expression)
				an_arguments := an_expression.arguments
				if an_arguments /= Void then
					process_actual_argument_list (an_arguments)
				end
			end
		end

	process_precursor_instruction (an_instruction: ET_PRECURSOR_INSTRUCTION) is
			-- Process `an_instruction'.
		local
			an_arguments: ET_ACTUAL_ARGUMENT_LIST
		do
			if internal_call then
				check_precursor_validity (an_instruction)
				an_arguments := an_instruction.arguments
				if an_arguments /= Void then
					process_actual_argument_list (an_arguments)
				end
			end
		end

	process_prefix_expression (an_expression: ET_PREFIX_EXPRESSION) is
			-- Process `an_expression'.
		do
			if internal_call then
				an_expression.expression.process (Current)
			end
		end

	process_static_call_expression (an_expression: ET_STATIC_CALL_EXPRESSION) is
			-- Process `an_expression'.
		local
			an_arguments: ET_ACTUAL_ARGUMENT_LIST
		do
			if internal_call then
				an_arguments := an_expression.arguments
				if an_arguments /= Void then
					process_actual_argument_list (an_arguments)
				end
			end
		end

	process_static_call_instruction (an_instruction: ET_STATIC_CALL_INSTRUCTION) is
			-- Process `an_instruction'.
		local
			an_arguments: ET_ACTUAL_ARGUMENT_LIST
		do
			if internal_call then
				an_arguments := an_instruction.arguments
				if an_arguments /= Void then
					process_actual_argument_list (an_arguments)
				end
			end
		end

	process_tagged_assertion (an_assertion: ET_TAGGED_ASSERTION) is
			-- Process `an_assertion'.
		local
			an_expression: ET_EXPRESSION
		do
			if internal_call then
				an_expression := an_assertion.expression
				if an_expression /= Void then
					an_expression.process (Current)
				end
			end
		end

	process_unique_attribute (a_feature: ET_UNIQUE_ATTRIBUTE) is
			-- Process `a_feature'.
		do
			internal_call := False
		end

	process_when_part (a_when_part: ET_WHEN_PART) is
			-- Process `a_when_part'.
		local
			a_compound: ET_COMPOUND
		do
			if internal_call then
				a_compound := a_when_part.then_compound
				if a_compound /= Void then
					process_compound (a_compound)
				end
			end
		end

	process_when_part_list (a_list: ET_WHEN_PART_LIST) is
			-- Process `a_list'.
		local
			i, nb: INTEGER
		do
			if internal_call then
				nb := a_list.count
				from i := 1 until i > nb loop
					process_when_part (a_list.item (i))
					i := i + 1
				end
			end
		end

feature {NONE} -- Error handling

	set_fatal_error is
			-- Report a fatal error.
		do
			has_fatal_error := True
		ensure
			has_fatal_error: has_fatal_error
		end

feature {NONE} -- Access

	current_feature: ET_REDECLARED_FEATURE
			-- Feature being processed

	current_class: ET_CLASS
			-- Class to with `current_feature' belongs

feature {NONE} -- Implementation

	internal_call: BOOLEAN
			-- Have the process routines been called from here?

	dummy_feature: ET_REDECLARED_FEATURE is
			-- Dummy feature
		local
			a_name: ET_FEATURE_NAME
			a_clients: ET_NONE_CLIENTS
			a_feature: ET_FEATURE
			a_parent_feature: ET_PARENT_FEATURE
		once
			create {ET_IDENTIFIER} a_name.make ("**dummy**")
			create a_clients.make (tokens.left_brace_symbol, tokens.right_brace_symbol)
			create {ET_DEFERRED_PROCEDURE} a_feature.make (a_name, Void, Void, Void, Void, a_clients, current_class)
			create a_parent_feature.make (a_feature, universe.any_parent)
			create Result.make (a_feature, a_parent_feature)
		ensure
			dummy_feature_not_void: Result /= Void
		end

invariant

	current_feature_not_void: current_feature /= Void
	current_class_not_void: current_class /= Void

end
