indexing

	description:

		"Eiffel feature calls at run-time"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_DYNAMIC_CALL

inherit

	ANY

	ET_SHARED_TOKEN_CONSTANTS
		export {NONE} all end

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

creation

	make, make_default

feature {NONE} -- Initialization

	make (a_target: like target; a_target_type: like target_type; a_name: like feature_name;
		a_feature: like static_feature; a_current_feature: like current_feature;
		a_current_type: like current_type; a_system: ET_SYSTEM) is
			-- Create a new dynamic call.
		require
			a_target_not_void: a_target /= Void
			a_target_type_not_void: a_target_type /= Void
			a_name_not_void: a_name /= Void
			a_feature_not_void: a_feature /= Void
			a_current_feature_not_void: a_current_feature /= Void
			a_current_type_not_void: a_current_type /= Void
			a_system_not_void: a_system /= Void
		do
			reset (a_target, a_target_type, a_name, a_feature, a_current_feature, a_current_type, a_system)
		ensure
			target_set: target = a_target
			target_type_set: target_type = a_target_type
			feature_name_set: feature_name = a_name
			static_feature_set: static_feature = a_feature
			current_feature_set: current_feature = a_current_feature
			current_type_set: current_type = a_current_type
		end

	make_default (a_name: like feature_name; a_current_feature: like current_feature;
		a_current_type: like current_type; a_system: ET_SYSTEM) is
			-- Create a default dynamic call.
		require
			a_name_not_void: a_name /= Void
			a_current_feature_not_void: a_current_feature /= Void
			a_current_type_not_void: a_current_type /= Void
			a_system_not_void: a_system /= Void
		do
			target := tokens.current_keyword
			target_type := a_system.none_type
			feature_name := a_name
			static_feature := a_current_feature
			argument_sources := Void
			result_type := Void
			current_feature := a_current_feature
			current_type := a_current_type
		ensure
			feature_name_set: feature_name = a_name
			current_feature_set: current_feature = a_current_feature
			current_type_set: current_type = a_current_type
		end

feature -- Initialization

	reset (a_target: like target; a_target_type: like target_type; a_name: like feature_name;
		a_feature: like static_feature; a_current_feature: like current_feature;
		a_current_type: like current_type; a_system: ET_SYSTEM) is
			-- Reset current dynamic call.
		require
			a_target_not_void: a_target /= Void
			a_target_type_not_void: a_target_type /= Void
			a_name_not_void: a_name /= Void
			a_feature_not_void: a_feature /= Void
			a_current_feature_not_void: a_current_feature /= Void
			a_current_type_not_void: a_current_type /= Void
			a_system_not_void: a_system /= Void
		local
			l_type: ET_TYPE
			l_dynamic_type: ET_DYNAMIC_TYPE
			l_dynamic_type_set: ET_NESTED_DYNAMIC_TYPE_SET
		do
			target := a_target
			target_type := a_target_type
			feature_name := a_name
			static_feature := a_feature
			argument_sources := Void
			l_type := a_feature.type
			if l_type /= Void then
				l_dynamic_type := a_system.dynamic_type (l_type, a_target_type.static_type.base_type)
				create l_dynamic_type_set.make (l_dynamic_type)
				result_type := l_dynamic_type_set
			else
				result_type := Void
			end
			current_feature := a_current_feature
			current_type := a_current_type
		ensure
			target_set: target = a_target
			target_type_set: target_type = a_target_type
			feature_name_set: feature_name = a_name
			static_feature_set: static_feature = a_feature
			current_feature_set: current_feature = a_current_feature
			current_type_set: current_type = a_current_type
		end

feature -- Access

	target: ET_TARGET
			-- Target of call

	target_type: ET_DYNAMIC_TYPE_SET
			-- Type of target

	feature_name: ET_FEATURE_NAME
			-- Name of feature being called

	static_feature: ET_FEATURE
			-- Feature being called

	argument_sources: ET_DYNAMIC_ATTACHMENT
			-- Sources of arguments, if any

	result_type: ET_DYNAMIC_TYPE_SET
			-- Type of Result, if any

	current_feature: ET_FEATURE
			-- Feature where the call appears

	current_type: ET_BASE_TYPE
			-- Type to which `current_feature' belongs

	position: ET_POSITION is
			-- Position of attachment
		do
			Result := target.position
		ensure
			position_not_void: Result /= Void
		end

feature -- Measurement

	count: INTEGER
			-- Number of types in `target_type' when
			-- `propagate_types' was last called

feature -- Element change

	put_argument_source (a_source: ET_DYNAMIC_ATTACHMENT) is
			-- Add `a_source' to beginning of `argument_sources'.
		do
			if argument_sources = Void then
				argument_sources := a_source
			else
				a_source.set_next_attachment (argument_sources)
				argument_sources := a_source
			end
		end

	propagate_types (a_system: ET_SYSTEM) is
			-- Propagate types from target type set.
		require
			a_system_not_void: a_system /= Void
		local
			l_count: INTEGER
			l_type: ET_DYNAMIC_TYPE
			l_other_type: DS_LINKABLE [ET_DYNAMIC_TYPE]
			i, nb: INTEGER
		do
			l_count := target_type.count
			if l_count /= count then
				nb := l_count - count
				count := l_count
				from
					l_other_type := target_type.other_types
				until
					l_other_type = Void
				loop
					propagate_type (l_other_type.item, a_system)
					i := i + 1
					if i < nb then
						l_other_type := l_other_type.right
					else
							-- Jump out of the loop.
						l_other_type := Void
					end
				end
				if i < nb then
					l_type := target_type.first_type
					if l_type /= Void then
						propagate_type (l_type, a_system)
					end
				end
			end
		end

feature {NONE} -- Element change

	propagate_type (a_type: ET_DYNAMIC_TYPE; a_system: ET_SYSTEM) is
			-- Propagate `a_type' from target type set.
		require
			a_type_not_void: a_type /= Void
			a_system_not_void: a_system /= Void
		local
			l_seed: INTEGER
			l_feature: ET_FEATURE
			l_dynamic_feature: ET_DYNAMIC_FEATURE
			l_argument_types: ET_DYNAMIC_TYPE_SET_LIST
			l_result_type: ET_DYNAMIC_TYPE_SET
			i, nb: INTEGER
			l_source: ET_DYNAMIC_ATTACHMENT
			l_attachment: ET_NULL_DYNAMIC_ATTACHMENT
		do
			if a_type /= a_system.none_type then
				l_seed := static_feature.first_seed
				l_feature := a_type.base_class.seeded_feature (l_seed)
				if l_feature = Void then
					if a_type.conforms_to_type (target_type.static_type, a_system) then
							-- Internal error: there should be a feature with seed
							-- `l_seed' in all descendants of `target_type.static_type'.
						a_system.set_fatal_error
						a_system.error_handler.report_gibbt_error
					else
						-- The error has already been reported somewhere else.
					end
				else
					l_dynamic_feature := a_type.dynamic_feature (l_feature, a_system)
					l_dynamic_feature.set_regular (True)
					l_argument_types := l_dynamic_feature.argument_types
					if l_argument_types = Void then
						if argument_sources /= Void then
								-- Internal error: it has already been checked somewhere else
								-- that there was the same number of formal arguments in
								-- feature redeclaration.
							a_system.set_fatal_error
							a_system.error_handler.report_gibbu_error
						end
					else
						from
							i := 1
							nb := l_argument_types.count
							l_source := argument_sources
						until
							l_source = Void
						loop
							if i > nb then
									-- Internal error: it has already been checked somewhere else
									-- that there was the same number of formal arguments in
									-- feature redeclaration.
								a_system.set_fatal_error
								a_system.error_handler.report_gibbv_error
									-- Jump out of the loop.
								l_source := Void
							else
								l_argument_types.item (i).put_source (l_source.cloned_attachment, a_system)
								l_source := l_source.next_attachment
								i := i + 1
							end
						end
					end
					l_result_type := l_dynamic_feature.result_type
					if result_type /= Void then
						if l_result_type = Void then
								-- Internal error: it has already been checked somewhere else
								-- that the redeclaration of a query should be a query.
							a_system.set_fatal_error
							a_system.error_handler.report_gibbw_error
						else
							create l_attachment.make (l_result_type, current_feature, current_type)
							result_type.put_source (l_attachment, a_system)
						end
					elseif l_result_type /= Void then
							-- Internal error: it has already been checked somewhere else
							-- that the redeclaration of a procedure should be a procedure.
						a_system.set_fatal_error
						a_system.error_handler.report_gibbx_error
					end
				end
			end
		end

feature -- Validity checking

	check_catcall_validity (a_system: ET_SYSTEM) is
			-- Check CAT-call validity.
		require
			a_system_not_void: a_system /= Void
		local
			l_type: ET_DYNAMIC_TYPE
			l_other_type: DS_LINKABLE [ET_DYNAMIC_TYPE]
		do
			l_type := target_type.first_type
			if l_type /= Void then
				check_target_type_validity (l_type, a_system)
				from
					l_other_type := target_type.other_types
				until
					l_other_type = Void
				loop
					check_target_type_validity (l_other_type.item, a_system)
					l_other_type := l_other_type.right
				end
			end
		end

feature {NONE} -- Validity checking

	check_target_type_validity (a_type: ET_DYNAMIC_TYPE; a_system: ET_SYSTEM) is
			-- Check whether target type `a_type' introduces CAT-calls.
		require
			a_type_not_void: a_type /= Void
			a_system_not_void: a_system /= Void
		local
			l_seed: INTEGER
			l_feature: ET_FEATURE
			l_formal_arguments: ET_FORMAL_ARGUMENT_LIST
			l_dynamic_feature: ET_DYNAMIC_FEATURE
			l_argument_types: ET_DYNAMIC_TYPE_SET_LIST
			i, nb: INTEGER
			l_source: ET_DYNAMIC_ATTACHMENT
			l_source_type_set: ET_DYNAMIC_TYPE_SET
			l_other_type: DS_LINKABLE [ET_DYNAMIC_TYPE]
			l_source_type: ET_DYNAMIC_TYPE
			l_target_type: ET_DYNAMIC_TYPE
		do
			if a_type /= a_system.none_type and then a_type.conforms_to_type (target_type.static_type, a_system) then
				l_seed := static_feature.first_seed
				l_feature := a_type.base_class.seeded_feature (l_seed)
				if l_feature = Void then
						-- Internal error: there should be a feature with seed
						-- `l_seed' in all descendants of `target_type.static_type'.
					a_system.set_fatal_error
					a_system.error_handler.report_gibby_error
				else
					l_formal_arguments := static_feature.arguments
					l_dynamic_feature := a_type.dynamic_feature (l_feature, a_system)
					l_argument_types := l_dynamic_feature.argument_types
					if l_argument_types = Void then
						if argument_sources /= Void then
							-- Internal error: it has already been checked somewhere else
							-- that there was the same number of formal arguments in
							-- feature redeclaration.
						a_system.set_fatal_error
						a_system.error_handler.report_gibbz_error
						end
					elseif l_formal_arguments = Void then
							-- Internal error: it has already been checked somewhere else
							-- that there was the same number of formal arguments in
							-- feature redeclaration.
						a_system.set_fatal_error
						a_system.error_handler.report_gibca_error
					elseif l_argument_types.count /= l_formal_arguments.count then
							-- Internal error: it has already been checked somewhere else
							-- that there was the same number of formal arguments in
							-- feature redeclaration.
						a_system.set_fatal_error
						a_system.error_handler.report_gibcb_error
					else
						from
							i := 1
							nb := l_argument_types.count
							l_source := argument_sources
						until
							l_source = Void
						loop
							if i > nb then
								-- Internal error: it has already been checked somewhere else
								-- that there was the same number of formal arguments in
								-- feature redeclaration.
							a_system.set_fatal_error
							a_system.error_handler.report_gibcc_error
									-- Jump out of the loop.
								l_source := Void
							else
								l_target_type := l_argument_types.item (i).static_type
								l_source_type_set := l_source.source_type
								l_source_type := l_source_type_set.first_type
								if l_source_type /= Void then
									if l_source_type.base_type.conforms_to_type (l_formal_arguments.formal_argument (i).type, target_type.static_type.base_type, a_system.universe.any_class, a_system.universe) then
										if not l_source_type.conforms_to_type (l_target_type, a_system) then
											report_catcall_error (a_type, l_dynamic_feature, i, l_target_type, l_source_type, l_source, a_system)
										end
										from
											l_other_type := l_source_type_set.other_types
										until
											l_other_type = Void
										loop
											l_source_type := l_other_type.item
											if l_source_type.base_type.conforms_to_type (l_formal_arguments.formal_argument (i).type, target_type.static_type.base_type, a_system.universe.any_class, a_system.universe) then
												if not l_source_type.conforms_to_type (l_target_type, a_system) then
													report_catcall_error (a_type, l_dynamic_feature, i, l_target_type, l_source_type, l_source, a_system)
												end
											end
											l_other_type := l_other_type.right
										end
									end
								end
								l_source := l_source.next_attachment
								i := i + 1
							end
						end
					end
				end
			end
		end

	report_catcall_error (a_target_type: ET_DYNAMIC_TYPE; a_dynamic_feature: ET_DYNAMIC_FEATURE;
		arg: INTEGER; a_formal_type: ET_DYNAMIC_TYPE; an_actual_type: ET_DYNAMIC_TYPE;
		an_actual_source: ET_DYNAMIC_ATTACHMENT; a_system: ET_SYSTEM) is
			-- Report a CAT-call error. When the target is of type `a_target_type', we
			-- try to pass to the corresponding feature `a_dynamic_feature' an actual
			-- argument of type `an_actual_type' (coming from `an_actual_source')
			-- which does not conform to the type of the `arg'-th corresponding formal
			-- argument `a_formal_type'.
		local
			l_error_handler: ET_ERROR_HANDLER
			l_message: STRING
			l_class_impl: ET_CLASS
			l_source: ET_DYNAMIC_ATTACHMENT
			l_type_set: ET_DYNAMIC_TYPE_SET
			l_visited_sources: DS_ARRAYED_LIST [ET_DYNAMIC_ATTACHMENT]
			l_source_stack: DS_ARRAYED_STACK [ET_DYNAMIC_ATTACHMENT]
			i, nb: INTEGER
		do
			l_error_handler := a_system.universe.error_handler
-- TODO: better error message reporting.
			l_message := shared_error_message
			STRING_.wipe_out (l_message)
			l_message.append_string ("[CATCALL] class ")
			l_message.append_string (current_type.to_text)
			l_message.append_string (" (")
			l_class_impl := current_feature.implementation_class
			if current_type.direct_base_class (a_system.universe) /= l_class_impl then
				l_message.append_string (l_class_impl.name.name)
				l_message.append_character (',')
			end
			l_message.append_string (position.line.out)
			l_message.append_character (',')
			l_message.append_string (position.column.out)
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
			l_message.append_string ("':%N")
			l_visited_sources := shared_visited_sources
			l_visited_sources.wipe_out
			l_source_stack := shared_source_stack
			l_source_stack.wipe_out
			l_message.append_string ("%TTarget type: '")
			l_message.append_string (a_target_type.base_type.to_text)
			l_message.append_string ("'%N")
			from
				l_type_set := target_type
			until
				l_type_set = Void
			loop
				from
					l_source := l_type_set.sources
					l_type_set := Void
				until
					l_source = Void
				loop
					if l_source.has_type (a_target_type) then
						if not l_source.is_null_attachment then
							l_message.append_string ("%T%T")
							from i := 1 until i > nb loop
								l_message.append_character ('.')
								i := i + 1
							end
							l_message.append_string ("class ")
							l_message.append_string (l_source.current_type.to_text)
							l_message.append_string (" (")
							l_class_impl := l_source.current_feature.implementation_class
							if l_source.current_type.direct_base_class (a_system.universe) /= l_class_impl then
								l_message.append_string (l_class_impl.name.name)
								l_message.append_character (',')
							end
							l_message.append_string (l_source.position.line.out)
							l_message.append_character (',')
							l_message.append_string (l_source.position.column.out)
							l_message.append_character (')')
						end
						if not l_visited_sources.has (l_source) then
							if not l_source.is_null_attachment then
								l_message.append_character ('%N')
								nb := nb + 1
							end
							l_source_stack.force (l_source)
							l_visited_sources.force_last (l_source)
							l_type_set := l_source.source_type
								-- Jump out of the loop.
							l_source := Void
						else
							if not l_source.is_null_attachment then
								l_message.append_string (" -- already visited%N")
							end
							from
								l_source := Void
							until
								l_source_stack.is_empty or l_source /= Void
							loop
								l_source := l_source_stack.item
								l_source_stack.remove
								if not l_source.is_null_attachment then
									nb := nb - 1
								end
								l_source := l_source.next_attachment
							end
						end
					else
						from
							l_source := l_source.next_attachment
						until
							l_source_stack.is_empty or l_source /= Void
						loop
							l_source := l_source_stack.item
							l_source_stack.remove
							if not l_source.is_null_attachment then
								nb := nb - 1
							end
							l_source := l_source.next_attachment
						end
					end
				end
			end
			l_visited_sources.wipe_out
			l_source_stack.wipe_out
			nb := 0
			l_message.append_string ("%TArgument type: '")
			l_message.append_string (an_actual_type.base_type.to_text)
			l_message.append_string ("'%N")
			from
				l_source := an_actual_source
				l_visited_sources.force_last (l_source)
				l_source_stack.force (l_source)
				if not l_source.is_null_attachment then
					l_message.append_string ("%T%Tclass ")
					l_message.append_string (l_source.current_type.to_text)
					l_message.append_string (" (")
					l_class_impl := l_source.current_feature.implementation_class
					if l_source.current_type.direct_base_class (a_system.universe) /= l_class_impl then
						l_message.append_string (l_class_impl.name.name)
						l_message.append_character (',')
					end
					l_message.append_string (l_source.position.line.out)
					l_message.append_character (',')
					l_message.append_string (l_source.position.column.out)
					l_message.append_string (")%N")
					nb := nb + 1
				end
				l_type_set := l_source.source_type
			until
				l_type_set = Void
			loop
				from
					l_source := l_type_set.sources
					l_type_set := Void
				until
					l_source = Void
				loop
					if l_source.has_type (an_actual_type) then
						if not l_source.is_null_attachment then
							l_message.append_string ("%T%T")
							from i := 1 until i > nb loop
								l_message.append_character ('.')
								i := i + 1
							end
							l_message.append_string ("class ")
							l_message.append_string (l_source.current_type.to_text)
							l_message.append_string (" (")
							l_class_impl := l_source.current_feature.implementation_class
							if l_source.current_type.direct_base_class (a_system.universe) /= l_class_impl then
								l_message.append_string (l_class_impl.name.name)
								l_message.append_character (',')
							end
							l_message.append_string (l_source.position.line.out)
							l_message.append_character (',')
							l_message.append_string (l_source.position.column.out)
							l_message.append_character (')')
						end
						if not l_visited_sources.has (l_source) then
							if not l_source.is_null_attachment then
								l_message.append_character ('%N')
								nb := nb + 1
							end
							l_source_stack.force (l_source)
							l_visited_sources.force_last (l_source)
							l_type_set := l_source.source_type
								-- Jump out of the loop.
							l_source := Void
						else
							if not l_source.is_null_attachment then
								l_message.append_string (" -- already visited%N")
							end
							from
								l_source := Void
							until
								l_source_stack.is_empty or l_source /= Void
							loop
								l_source := l_source_stack.item
								l_source_stack.remove
								if not l_source.is_null_attachment then
									nb := nb - 1
								end
								l_source := l_source.next_attachment
							end
						end
					else
						from
							l_source := l_source.next_attachment
						until
							l_source_stack.is_empty or l_source /= Void
						loop
							l_source := l_source_stack.item
							l_source_stack.remove
							if not l_source.is_null_attachment then
								nb := nb - 1
							end
							l_source := l_source.next_attachment
						end
					end
				end
			end
			l_visited_sources.wipe_out
			l_source_stack.wipe_out
			l_error_handler.report_error_message (l_message)
			STRING_.wipe_out (l_message)
		end

feature -- Link

	next_call: ET_DYNAMIC_CALL
			-- Next linked feature call in list of feature calls

	set_next_call (a_next: ET_DYNAMIC_CALL) is
			-- Set `next_call' to `a_next'.
		do
			next_call := a_next
		ensure
			next_call_set: next_call = a_next
		end

feature {NONE} -- Implementation

	shared_visited_sources: DS_ARRAYED_LIST [ET_DYNAMIC_ATTACHMENT] is
			-- Shared visited sources (used in `report_catcall_error')
		once
			create Result.make (20)
		ensure
			shared_visited_sources_not_void: Result /= Void
		end

	shared_source_stack: DS_ARRAYED_STACK [ET_DYNAMIC_ATTACHMENT] is
			-- Shared stack of sources (used in `report_catcall_error')
		once
			create Result.make (20)
		ensure
			shared_source_stack_not_void: Result /= Void
		end

	shared_error_message: STRING is
			-- Shared error message (used in `report_catcall_error')
		once
			Result := STRING_.make (200)
		ensure
			shared_error_message_not_void: Result /= Void
		end

invariant

	target_not_void: target /= Void
	target_type_not_void: target_type /= Void
	feature_name_not_void: feature_name /= Void
	static_feature_not_void: static_feature /= Void
	current_feature_not_void: current_feature /= Void
	current_type_not_void: current_type /= Void

end