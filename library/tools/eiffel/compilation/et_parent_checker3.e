indexing

	description:

		"Eiffel parent validity third pass checkers"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2003, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_PARENT_CHECKER3

inherit

	ET_AST_NULL_PROCESSOR
		redefine
			make,
			process_class,
			process_class_type,
			process_generic_class_type
		end

creation

	make

feature {NONE} -- Initialization

	make (a_universe: like universe) is
			-- Create a new parent third pass checker.
		do
			precursor (a_universe)
			current_class := a_universe.unknown_class
			create classes_to_be_processed.make (10)
		end

feature -- Status report

	has_fatal_error: BOOLEAN
			-- Has a fatal error occurred?

feature -- Validity checking

	check_parents_validity (a_class: ET_CLASS) is
			-- Third pass of the validity check of parents of `a_class'.
			-- Check the creation procedures of formal parameters.
			-- Set `has_fatal_error' if an error occurred.
		require
			a_class_not_void: a_class /= Void
		local
			a_parents: ET_PARENT_LIST
			i, nb: INTEGER
			other_class: ET_CLASS
			old_class: ET_CLASS
		do
			has_fatal_error := False
			old_class := current_class
			current_class := a_class
			a_parents := current_class.parents
			if a_parents /= Void then
				nb := a_parents.count
				from i := 1 until i > nb loop
					internal_call := True
					a_parents.parent (i).type.process (Current)
					internal_call := False
					i := i + 1
				end
				from
				until
					classes_to_be_processed.is_empty
				loop
					other_class := classes_to_be_processed.last
					classes_to_be_processed.remove_last
					other_class.process (universe.interface_checker)
					if other_class.has_interface_error then
						set_fatal_error
					end
				end
			end
			current_class := a_class
		end

feature {NONE} -- Parent validity

	check_class_type_validity (a_type: ET_CLASS_TYPE) is
			-- Check validity of `a_type' when it appears in the parent
			-- clause `a_parent' in `current_class'. Check whether the
			-- actual generic parameters of `a_type' are equipped with
			-- the creation procedures listed in the corresponding formal
			-- parameters' constraints. Set `has_fatal_error' if an error
			-- occurred.
		require
			a_type_not_void: a_type /= Void
		local
			i, nb: INTEGER
			a_formals: ET_FORMAL_PARAMETER_LIST
			an_actuals: ET_ACTUAL_PARAMETER_LIST
			an_actual: ET_TYPE
			a_formal: ET_FORMAL_PARAMETER
			a_creator: ET_CONSTRAINT_CREATOR
			a_class: ET_CLASS
			an_actual_class: ET_CLASS
			a_formal_type: ET_FORMAL_PARAMETER_TYPE
			an_index: INTEGER
			a_formal_parameters: ET_FORMAL_PARAMETER_LIST
			a_formal_parameter: ET_FORMAL_PARAMETER
			a_formal_creator: ET_CONSTRAINT_CREATOR
			has_formal_type_error: BOOLEAN
			j, nb2: INTEGER
			a_class_type: ET_CLASS_TYPE
			a_name: ET_FEATURE_NAME
			a_seed: INTEGER
			a_creation_feature: ET_FEATURE
		do
			a_class := a_type.direct_base_class (universe)
			if not a_class.interface_checked then
				classes_to_be_processed.force_last (a_class)
			end
			if a_class.is_generic then
				a_formals := a_class.formal_parameters
				check a_class_generic: a_formals /= Void end
				an_actuals := a_type.actual_parameters
				if an_actuals = Void or else an_actuals.count /= a_formals.count then
						-- Error already reported during first pass of
						-- parent validity checking.
					set_fatal_error
				else
					a_formal_parameters := current_class.formal_parameters
					nb := an_actuals.count
					from i := 1 until i > nb loop
						an_actual := an_actuals.type (i)
						a_formal := a_formals.formal_parameter (i)
						a_creator := a_formal.creation_procedures
						if a_creator /= Void and then not a_creator.is_empty then
							an_actual_class := an_actual.base_class (current_class, universe)
							a_formal_type ?= an_actual
							if a_formal_type /= Void then
								an_index := a_formal_type.index
								if a_formal_parameters = Void or else an_index > a_formal_parameters.count then
										-- Internal error: `a_formal_parameter' is supposed
										-- to be a formal parameter of `current_class'.
									has_formal_type_error := True
									set_fatal_error
									error_handler.report_giabt_error
								else
									has_formal_type_error := False
									a_formal_parameter := a_formal_parameters.formal_parameter (an_index)
									a_formal_creator := a_formal_parameter.creation_procedures
								end
							end
							nb2 := a_creator.count
							if nb2 > 0 then
								an_actual_class.process (universe.feature_flattener)
								if an_actual_class.has_flattening_error then
									set_fatal_error
								else
									from j := 1 until j > nb2 loop
										a_name := a_creator.feature_name (j)
										a_seed := a_name.seed
										a_creation_feature := an_actual_class.seeded_feature (a_seed)
										if a_creation_feature = Void then
												-- Internal error: the conformance of the actual
												-- parameter to its generic constraint has been
												-- checked during the second pass.
											set_fatal_error
											error_handler.report_giabu_error
										elseif a_formal_type /= Void then
											if not has_formal_type_error then
												if a_formal_creator = Void or else not a_formal_creator.has_feature (a_creation_feature) then
													set_fatal_error
													error_handler.report_vtcg4c_error (current_class, a_type.position, i, a_name, a_formal_parameter, a_class)
												end
											end
										elseif
											not a_creation_feature.is_creation_exported_to (a_class, an_actual_class, universe.ancestor_builder) and then
											(an_actual_class.creators /= Void or else not a_creation_feature.has_seed (universe.default_create_seed))
										then
											set_fatal_error
											error_handler.report_vtcg4a_error (current_class, a_type.position, i, a_name, an_actual_class, a_class)
										end
										j := j + 1
									end
								end
							end
								-- Since the corresponding formal generic parameter
								-- has creation procedures associated with it, it
								-- is possible to create instances of `an_actual'
								-- through that means. So we need to check recursively
								-- its validity as a creation type.
							internal_call := True
							an_actual.process (Current)
							internal_call := False
						else
								-- We need to check whether `an_actual' is expanded.
								-- In that case the creation of an instance of that
								-- type will be implicit, so we need to check recursively
								-- its validity as a creation type.
							a_class_type ?= an_actual
							if a_class_type /= Void and then a_class_type.is_expanded then
								internal_call := True
								an_actual.process (Current)
								internal_call := False
							end
						end
						i := i + 1
					end
				end
			end
		end

feature {ET_AST_NODE} -- Type dispatcher

	process_class (a_class: ET_CLASS) is
			-- Process `a_class'.
		do
			process_class_type (a_class)
		end

	process_class_type (a_type: ET_CLASS_TYPE) is
			-- Process `a_type'.
		do
			if internal_call then
				internal_call := False
				check_class_type_validity (a_type)
			end
		end

	process_generic_class_type (a_type: ET_GENERIC_CLASS_TYPE) is
			-- Process `a_type'.
		do
			process_class_type (a_type)
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

	current_class: ET_CLASS
			-- Class being processed

	classes_to_be_processed: DS_ARRAYED_LIST [ET_CLASS]
			-- Classes that need to be processed

feature {NONE} -- Implementation

	internal_call: BOOLEAN
			-- Have the process routines been called from here?

invariant

	current_class_not_void: current_class /= Void
	classes_to_be_processed_not_void: classes_to_be_processed /= Void
	no_void_class_to_be_processed: not classes_to_be_processed.has (Void)

end
