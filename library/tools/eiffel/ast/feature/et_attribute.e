indexing

	description:

		"Eiffel variable attributes"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_ATTRIBUTE

inherit

	ET_QUERY
		redefine
			is_attribute,
			is_prefixable
		end

creation

	make

feature {NONE} -- Initialization

	make (a_name: like name_item; a_type: like declared_type; a_clients: like clients;
		a_class: like implementation_class) is
			-- Create a new attribute.
		require
			a_name_not_void: a_name /= Void
			a_type_not_void: a_type /= Void
			a_clients_not_void: a_clients /= Void
			a_class_not_void: a_class /= Void
		do
			name_item := a_name
			hash_code := name.hash_code
			declared_type := a_type
			clients := a_clients
			implementation_class := a_class
			implementation_feature := Current
		ensure
			name_item_set: name_item = a_name
			declared_type_set: declared_type = a_type
			clients_set: clients = a_clients
			implementation_class_set: implementation_class = a_class
			implementation_feature_set: implementation_feature = Current
		end

feature -- Status report

	is_attribute: BOOLEAN is True
			-- Is feature an attribute?

	is_prefixable: BOOLEAN is True
			-- Can current feature have a name of
			-- the form 'prefix ...'?

feature -- Access

	last_leaf: ET_AST_LEAF is
			-- Last leaf node in current node
		do
			Result := declared_type.last_leaf
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			Result := declared_type.break
		end

feature -- Duplication

	new_synonym (a_name: like name_item): like Current is
			-- Synonym feature
		do
			create Result.make (a_name, declared_type, clients, implementation_class)
			Result.set_semicolon (semicolon)
			Result.set_feature_clause (feature_clause)
			Result.set_first_indexing (first_indexing)
			Result.set_synonym (Current)
		end

feature -- Conversion

	renamed_feature (a_name: like name): like Current is
			-- Renamed version of current feature
		do
			create Result.make (a_name, declared_type, clients, implementation_class)
			Result.set_implementation_feature (implementation_feature)
			Result.set_first_precursor (first_precursor)
			Result.set_other_precursors (other_precursors)
			Result.set_version (version)
			Result.set_frozen_keyword (frozen_keyword)
			Result.set_semicolon (semicolon)
			Result.set_feature_clause (feature_clause)
			Result.set_first_indexing (first_indexing)
			Result.set_first_seed (first_seed)
			Result.set_other_seeds (other_seeds)
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_attribute (Current)
		end

invariant

	is_attribute: arguments = Void

end
