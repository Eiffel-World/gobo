indexing

	description:

		"Eiffel class invariants"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002-2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_INVARIANTS

inherit

	ET_ASSERTIONS
		rename
			make as make_assertions,
			make_with_capacity as make_assertions_with_capacity
		end

	ET_FEATURE
		undefine
			position
		end

creation

	make, make_with_capacity

feature {NONE} -- Initialization

	make (a_class: like implementation_class) is
			-- Create a new invariant clause.
		require
			a_class_not_void: a_class /= Void
		do
			name_item := tokens.invariant_feature_name
			clients := tokens.any_clients
			implementation_class := a_class
			implementation_feature := Current
			invariant_keyword := tokens.invariant_keyword
			make_assertions
		ensure
			is_empty: is_empty
			capacity_set: capacity = 0
			implementation_class_set: implementation_class = a_class
			implementation_feature_set: implementation_feature = Current
		end

	make_with_capacity (a_class: like implementation_class; nb: INTEGER) is
			-- Create a new invariant clause with capacity `nb'.
		require
			a_class_not_void: a_class /= Void
		do
			name_item := tokens.invariant_feature_name
			clients := tokens.any_clients
			implementation_class := a_class
			implementation_feature := Current
			invariant_keyword := tokens.invariant_keyword
			make_assertions_with_capacity (nb)
		ensure
			is_empty: is_empty
			capacity_set: capacity = nb
			implementation_class_set: implementation_class = a_class
			implementation_feature_set: implementation_feature = Current
		end

feature -- Access

	invariant_keyword: ET_KEYWORD
			-- 'invariant' keyword

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			Result := invariant_keyword.position
			if Result.is_null and not is_empty then
				Result := item (1).position
			end
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			if not is_empty then
				Result := item (count).break
			else
				Result := invariant_keyword.break
			end
		end

feature -- Setting

	set_invariant_keyword (an_invariant: like invariant_keyword) is
			-- Set `invariant_keyword' to `an_invariant'.
		require
			an_invariant_not_void: an_invariant /= Void
		do
			invariant_keyword := an_invariant
		ensure
			invariant_keyword_not_void: invariant_keyword = an_invariant
		end

feature {ET_INVARIANTS} -- Setting

	set_name (a_name: like name_item) is
			-- Set `name' to `a_name'.
		require
			a_name_not_void: a_name /= Void
		do
			name_item := a_name
		ensure
			name_set: name = a_name
			name_item_set: name_item = a_name
		end

feature -- Duplication

	new_synonym (a_name: like name_item): like Current is
			-- Synonym feature
		do
			create Result.make (implementation_class)
			Result.set_name (a_name)
			Result.set_implementation_feature (implementation_feature)
		end

feature -- Conversion

	renamed_feature (a_name: like name): like Current is
			-- Renamed version of current feature
		do
			create Result.make (implementation_class)
			Result.set_name (a_name)
			Result.set_implementation_feature (implementation_feature)
		end

	undefined_feature (a_name: like name): ET_DEFERRED_ROUTINE is
			-- Undefined version of current feature
		do
			create {ET_DEFERRED_PROCEDURE} Result.make (a_name, Void, Void, Void, Void, clients, implementation_class)
		end

feature -- Type processing

	resolve_inherited_signature (a_parent: ET_PARENT) is
			-- Resolve arguments and type inherited from `a_parent'.
			-- Resolve any formal generic parameters of declared types
			-- with the corresponding actual parameters in `a_parent',
			-- and duplicate identifier anchored types (and clear their
			-- base types).
		do
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_invariants (Current)
		end

invariant

	invariant_keyword_not_void: invariant_keyword /= Void

end
