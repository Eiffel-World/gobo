indexing

	description:

		"Eiffel features"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_FEATURE

inherit

	ET_AST_NODE

	ET_FLATTENED_FEATURE
		redefine
			is_immediate,
			immediate_feature
		end

	HASHABLE

	DEBUG_OUTPUT

feature -- Initialization

	reset is
			-- Reset feature as it was when it was first parsed.
		local
			l_type: like type
			l_arguments: like arguments
			l_preconditions: like preconditions
			l_postconditions: like postconditions
		do
			name.reset
			first_seed := id
			other_seeds := Void
			version := id
			first_precursor := Void
			other_precursors := Void
			l_type := type
			if l_type /= Void then
				l_type.reset
			end
			l_arguments := arguments
			if l_arguments /= Void then
				l_arguments.reset
			end
			l_preconditions := preconditions
			if l_preconditions /= Void then
				l_preconditions.reset
			end
			l_postconditions := postconditions
			if l_postconditions /= Void then
				l_postconditions.reset
			end
			implementation_checked := False
			has_implementation_error := False
			assertions_checked := False
			has_assertions_error := False
		end

feature -- Access

	name: ET_FEATURE_NAME is
			-- Feature name
		do
			Result := name_item.feature_name
		end

	type: ET_TYPE is
			-- Return type;
			-- Void for procedures
		do
		end

	arguments: ET_FORMAL_ARGUMENT_LIST is
			-- Formal arguments;
			-- Void if not a routine or a routine with no arguments
		do
		end

	preconditions: ET_PRECONDITIONS is
			-- Preconditions;
			-- Void if not a routine or a routine with no preconditions
		do
		end

	postconditions: ET_POSTCONDITIONS is
			-- Postconditions;
			-- Void if not a routine or a routine with no postconditions
		do
		end

	obsolete_message: ET_OBSOLETE is
			-- Obsolete message
		do
		end

	locals: ET_LOCAL_VARIABLE_LIST is
			-- Local variables;
			-- Void if not an internal routine or a routine with no local variables
		do
		end

	first_indexing: ET_INDEXING_LIST
			-- Indexing clause at the beginning of the feature

	id: INTEGER
			-- Feature ID

	version: INTEGER
			-- Version (feature ID of last declaration
			-- of current feature)

	first_precursor: ET_FEATURE
			-- First precursor;
			-- Void if the feature has no precursor.
			-- Useful to build the flat preconditions and
			-- postconditions of the feature.

	other_precursors: ET_FEATURE_LIST
			-- Other precursors (Features from which the current
			-- feature gets parts of its preconditions and
			-- postconditions from its parents. Note that because
			-- of replication all the seeds of the precursors are not
			-- necessarily a subset of the seeds of current feature.);
			-- May be Void if there is only one precursor (which is
			-- then accessible through `first_precursor') or no
			-- precursor. There can be several precursors if the
			-- current feature is the result of a merge or join of
			-- several features in the inheritance clause.

	implementation_class: ET_CLASS
			-- Class where implementation of current feature
			-- has been provided;
			-- Useful for interpreting feature calls and type
			-- anchors (that might be renamed in descendant classes)
			-- when feature is inherited as-is.
			-- Note that the signature has already been resolved
			-- in the context of the current class.

	implementation_feature: ET_FEATURE
			-- Current feature in `implementation_class',
			-- Useful for interpreting feature calls and type
			-- anchors (that might be renamed in descendant classes)
			-- when feature is inherited as-is.
			-- Note that the signature has already been resolved
			-- in the context of the current class.

	name_item: ET_FEATURE_NAME_ITEM
			-- Feature name (possibly followed by comma for synomyms)

	frozen_keyword: ET_KEYWORD
			-- 'frozen' keyword

	feature_clause: ET_FEATURE_CLAUSE
			-- Feature clause containing current feature

	semicolon: ET_SEMICOLON_SYMBOL
			-- Optional semicolon in semicolon-separated list of features

	synonym: ET_FEATURE
			-- Next synonym if any

	hash_code: INTEGER
			-- Hash code value

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			if not is_frozen then
				Result := name_item.position
			else
				Result := frozen_keyword.position
				if Result.is_null then
					Result := name_item.position
				end
			end
		end

	first_leaf: ET_AST_LEAF is
			-- First leaf node in current node
		do
			if not is_frozen then
				Result := name_item.first_leaf
			else
				Result := frozen_keyword
			end
		end

feature -- Status report

	is_registered: BOOLEAN is
			-- Has feature been registered to the surrounding universe?
		do
			Result := (id > 0)
		ensure
			definition: Result = (id > 0)
		end

	is_frozen: BOOLEAN is
			-- Has feature been declared as frozen?
		do
			Result := (frozen_keyword /= Void)
		end

	is_deferred: BOOLEAN is
			-- Is feature deferred?
		do
			-- Result := False
		end

	is_function: BOOLEAN is
			-- Is feature a function?
		do
			-- Result := False
		ensure
			query: Result implies type /= Void
		end

	is_attribute: BOOLEAN is
			-- Is feature an attribute?
		do
			-- Result := False
		ensure
			query: Result implies type /= Void
		end

	is_constant_attribute: BOOLEAN is
			-- Is feature a constant attribute?
		do
			-- Result := False
		ensure
			query: Result implies type /= Void
		end

	is_unique_attribute: BOOLEAN is
			-- Is feature a unique attribute?
		do
			-- Result := False
		ensure
			query: Result implies type /= Void
		end

	is_procedure: BOOLEAN is
			-- Is current feature a procedure?
		do
			Result := (type = Void)
		ensure
			definition: Result = (type = Void)
		end

	is_once: BOOLEAN is
			-- Is current feature a once feature?
		do
			-- Result := False
		end
		
	is_infixable: BOOLEAN is
			-- Can current feature have a name of
			-- the form 'infix ...'?
		do
			-- Result := False
		ensure
			definition: type /= Void and (arguments /= Void and then arguments.count = 1)
		end

	is_prefixable: BOOLEAN is
			-- Can current feature have a name of
			-- the form 'prefix ...'?
		do
			-- Result := False
		ensure
			definition: type /= Void and (arguments = Void or else arguments.count = 0)
		end

	is_immediate: BOOLEAN is True
			-- Is current feature immediate?

feature -- Implementation checking status

	implementation_checked: BOOLEAN
			-- Has the implementation of current feature been checked?
			-- (Check everything except assertions.)

	has_implementation_error: BOOLEAN
			-- Has a fatal error occurred during implementation checking?
			-- (Check everything except assertions.)

	assertions_checked: BOOLEAN
			-- Has the implementation of assertions of current feature been checked?

	has_assertions_error: BOOLEAN
			-- Has a fatal error occurred during assertions implementation checking?

	set_implementation_checked is
			-- Set `implementation_checked' to True.
		do
			implementation_checked := True
		ensure
			implementation_checked: implementation_checked
		end

	set_implementation_error is
			-- Set `has_implementation_error' to True.
		do
			has_implementation_error := True
		ensure
			has_implementation_error: has_implementation_error
		end

	set_assertions_checked is
			-- Set `assertions_checked' to True.
		do
			assertions_checked := True
		ensure
			assertions_checked: assertions_checked
		end

	set_assertions_error is
			-- Set `has_assertions_error' to True.
		do
			has_assertions_error := True
		ensure
			has_assertions_error: has_assertions_error
		end

feature -- Export status

	is_exported_to (a_client: ET_CLASS; a_universe: ET_UNIVERSE): BOOLEAN is
			-- Is current feature exported to `a_client'?
			-- (Note: Use `a_universe.ancestor_builder' on the classes whose ancestors
			-- need to be built in order to check for descendants.)
		require
			a_client_not_void: a_client /= Void
			a_universe_not_void: a_universe /= Void
		do
			Result := clients.has_descendant (a_client, a_universe)
		end

	is_directly_exported_to (a_client: ET_CLASS): BOOLEAN is
			-- Does `a_client' appear in the list of clients of current feature?
			-- (This is different from `is_exported_to' where `a_client' can
			-- be a descendant of a class appearing in the list of clients.
			-- Note: The use of 'direct' in the name of this feature has not
			-- the same meaning as 'direct and indirect client' in ETL2 p.91.)
		require
			a_client_not_void: a_client /= Void
		do
			Result := clients.has_class (a_client)
		end

	is_creation_exported_to (a_client, a_class: ET_CLASS; a_universe: ET_UNIVERSE): BOOLEAN is
			-- Is current feature listed in the creation clauses
			-- of `a_class' and exported to `a_client'?
			-- (Note: Use `a_universe.ancestor_builder' on the classes whose ancestors
			-- need to be built in order to check for descendants.)
		require
			a_client_not_void: a_client /= Void
			a_class_not_void: a_class /= Void
			a_universe_not_void: a_universe /= Void
		do
			Result := a_class.is_creation_exported_to (name, a_client, a_universe)
		end

	is_creation_directly_exported_to (a_client, a_class: ET_CLASS): BOOLEAN is
			-- Is current feature listed in the creation clauses
			-- of `a_class' and directly exported to `a_client'?
			-- (This is different from `is_creation_exported_to' where `a_client'
			-- can be a descendant of a class appearing in the list of clients.
			-- Note: The use of 'direct' in the name of this feature has not
			-- the same meaning as 'direct and indirect client' in ETL2 p.91.)
		require
			a_client_not_void: a_client /= Void
			a_class_not_void: a_class /= Void
		do
			Result := a_class.is_creation_directly_exported_to (name, a_client)
		end

	clients: ET_CLASS_NAME_LIST
			-- Clients to which feature is exported

	set_clients (a_clients: like clients) is
			-- Set `clients' to `a_clients'.
		require
			a_clients_not_void: a_clients /= Void
		do
			clients := a_clients
		ensure
			clients_set: clients = a_clients
		end

feature -- Comparison

	same_version (other: ET_FEATURE): BOOLEAN is
			-- Do current feature and `other' have the same version?
		require
			other_not_void: other /= Void
		do
			Result := version = other.version
		ensure
			definition: Result = (version = other.version)
		end

feature -- Setting

	set_id (an_id: INTEGER) is
			-- Set `id' to `an_id'.
		require
			an_id_positive: an_id > 0
		do
			id := an_id
			if first_seed = 0 then
				set_first_seed (an_id)
			end
			if version = 0 then
				set_version (an_id)
			end
		ensure
			id_set: id = an_id
		end

	set_feature_clause (a_feature_clause: like feature_clause) is
			-- Set `feature_clause' to `a_feature_clause'.
		do
			feature_clause := a_feature_clause
		ensure
			feature_clause_set: feature_clause = a_feature_clause
		end

	set_first_indexing (an_indexing: like first_indexing) is
			-- Set `first_indexing' to `an_indexing'
		do
			first_indexing := an_indexing
		ensure
			first_indexing_set: first_indexing = an_indexing
		end

	set_version (a_version: INTEGER) is
			-- Set `version' to `a_version'.
		require
			a_version_not_void: a_version > 0
		do
			version := a_version
		ensure
			version_set: version = a_version
		end

	set_implementation_class (a_class: like implementation_class) is
			-- Set `implementation_class' to `a_class'.
		require
			a_class_not_void: a_class /= Void
		do
			implementation_class := a_class
		ensure
			implementation_class_set: implementation_class = a_class
		end

	set_implementation_feature (a_feature: like implementation_feature) is
			-- Set `implementation_feature' to `a_feature'.
		require
			a_feature_not_void: a_feature /= Void
		do
			implementation_feature := a_feature
		ensure
			implementation_feature_set: implementation_feature = a_feature
		end

	set_first_seed (a_seed: INTEGER) is
			-- Set `first_seed' to `a_seed'.
		require
			a_seed_positive: a_seed > 0
		do
			first_seed := a_seed
		ensure
			first_seed_set: first_seed = a_seed
		end

	set_other_seeds (a_seeds: like other_seeds) is
			-- Set `other_seeds' to `a_seeds'.
		do
			other_seeds := a_seeds
		ensure
			other_seeds_set: other_seeds = a_seeds
		end

	set_first_precursor (a_precursor: like first_precursor) is
			-- Set `first_precursor' to `a_precursor'.
		do
			first_precursor := a_precursor
		ensure
			first_precursor_set: first_precursor = a_precursor
		end

	set_other_precursors (a_precursors: like other_precursors) is
			-- Set `other_precursors' to `a_precursors'.
		do
			other_precursors := a_precursors
		ensure
			other_precursors_set: other_precursors = a_precursors
		end

	set_frozen_keyword (a_frozen: like frozen_keyword) is
			-- Set `frozen_keyword' to `a_frozen'.
		do
			frozen_keyword := a_frozen
		ensure
			frozen_keyword_set: frozen_keyword = a_frozen
		end

	set_synonym (a_synonym: like synonym) is
			-- Set `synonym' to `a_synonym'.
		do
			synonym := a_synonym
		ensure
			synonym_set: a_synonym = a_synonym
		end

	set_semicolon (a_semicolon: like semicolon) is
			-- Set `semicolon' to `a_semicolon'.
		do
			semicolon := a_semicolon
		ensure
			semicolon_set: semicolon = a_semicolon
		end

	reset_preconditions is
			-- Set `preconditions' to Void.
		do
		ensure
			preconditions_reset: preconditions = Void
		end

	reset_postconditions is
			-- Set `postconditions' to Void.
		do
		ensure
			postconditions_reset: postconditions = Void
		end
		
feature -- Duplication

	new_synonym (a_name: like name_item): like Current is
			-- Synonym feature
		require
			a_name_not_void: a_name /= Void
		deferred
		ensure
			new_synonym_not_void: Result /= Void
			name_item_set: Result.name_item = a_name
		end

feature -- Conversion

	renamed_feature (a_name: like name): like Current is
			-- Renamed version of current feature
		require
			a_name_not_void: a_name /= Void
		deferred
		ensure
			renamed_feature_not_void: Result /= Void
			name_set: Result.name = a_name
			first_precursor_set: Result.first_precursor = first_precursor
			other_precursors_set: Result.other_precursors = other_precursors
		end

	undefined_feature (a_name: like name): ET_DEFERRED_ROUTINE is
			-- Undefined version of current feature
		require
			a_name_not_void: a_name /= Void
		deferred
		ensure
			undefined_feature_not_void: Result /= Void
			name_set: Result.name = a_name
			version_set: Result.version = Result.id
			first_precursor_set: Result.first_precursor = Current
			other_precursors_set: Result.other_precursors = Void
		end

feature -- Type processing

	resolve_inherited_signature (a_parent: ET_PARENT) is
			-- Resolve arguments and type inherited from `a_parent'.
			-- Resolve any formal generic parameters of declared types
			-- with the corresponding actual parameters in `a_parent',
			-- and duplicate identifier anchored types (and clear their
			-- base types).
		require
			a_parent_not_void: a_parent /= Void
		deferred
		end

feature -- Inheritance

	flattened_feature: ET_FEATURE is
			-- Feature resulting after feature flattening
		do
			Result := Current
		ensure then
			definition: Result = Current
		end

	immediate_feature: ET_FEATURE is
			-- Current feature viewed as an immediate feature
		do
			Result := Current
		end

feature -- Output

	debug_output: STRING is
			-- String that should be displayed in debugger to represent `Current'
		do
			Result := name.name
		end

invariant

	name_item_not_void: name_item /= Void
	clients_not_void: clients /= Void
	hash_code_definition: hash_code = name.hash_code
	first_seed_positive: is_registered implies first_seed > 0
	implementation_class_not_void: implementation_class /= Void
	implementation_feature_not_void: implementation_feature /= Void
	is_immediate: is_immediate

end
