indexing

	description:

		"XPath types"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_TYPE

inherit
	
	ANY -- required by SE 2.1b1

	XM_XPATH_SHARED_TYPE_FACTORY

	XM_XPATH_SHARED_ANY_ITEM_TYPE

	XM_XPATH_SHARED_NO_NODE_TEST

	XM_XPATH_SHARED_ANY_NODE_TEST

	XM_XPATH_STANDARD_NAMESPACES

	KL_IMPORTED_INTEGER_ROUTINES

	XM_XPATH_DEBUGGING_ROUTINES

feature -- Access

	-- The following are the DOM node type definitions for those nodes
	-- actually used by XPath;
	-- All should be INTEGER_16 when this is available

	Element_node: INTEGER is 1
	Attribute_node: INTEGER is 2
	Text_node: INTEGER is 3
	Processing_instruction_node: INTEGER is 7
	Comment_node: INTEGER is 8
	Document_node: INTEGER is 9
	Namespace_node: INTEGER is 13

	Any_node: INTEGER is 0

	Any_item_fingerprint: INTEGER is 88

	Same_item_type: INTEGER is 1
	Subsuming_type: INTEGER is 2
	Subsumed_type: INTEGER is 3
	Overlapping_types: INTEGER is 4
	Disjoint_types: INTEGER is 5
			-- Type realtionships

	common_super_type (t1, t2: XM_XPATH_ITEM_TYPE): XM_XPATH_ITEM_TYPE is
			-- Common supertype of two given types
		require
			types_not_void: t1 /= Void and then t2 /= void
		local
			a_no_node_test: XM_XPATH_NO_NODE_TEST
		do
			a_no_node_test ?= t1
			if a_no_node_test /= Void then
				Result := t2
			else
				a_no_node_test ?= t2
				if a_no_node_test /= Void then
					Result := t1
				elseif t1 = t2 then
					Result := t1
				elseif is_sub_type (t1, t2) then
					Result := t2
				elseif is_sub_type (t2, t1) then
					Result := t1
				else
					Result := common_super_type (t2.super_type, t1)
					
					-- eventually we will hit a type that is a supertype of t2. We reverse
					-- the arguments so we go up each branch of the tree alternately.
					-- If we hit the root of the tree, one of the earlier conditions will be satisfied,
					-- so the recursion will stop.
				end
			end
		ensure
			result_not_void: Result /= void
		end

	node_type_name (a_node_type: INTEGER): STRING is
			-- name of `a_node_type'
		require
			valid_node_type: is_node_type (a_node_type)
		do
			inspect
				a_node_type
			when Element_node then
				Result := "element"
			when Document_node then
				Result := "document"
			when Text_node then
				Result := "text"
			when Comment_node then
				Result := "comment"
			when Attribute_node then
				Result := "attribute"
			when Namespace_node then
				Result := "namespace"
			when Processing_instruction_node then
				Result := "processing-instruction"
			when Any_node then
				Result := "node()"
			end
		ensure
			node_type_name_not_void: Result /= Void
		end

	built_in_item_type (a_uri, a_local_name: STRING): XM_XPATH_ITEM_TYPE is
			-- Built-in type named by `a_uri', `a_local_name'
		require
			uri_not_void: a_uri /= Void
			local_name_not_void: a_local_name /= Void
		local
			a_fingerprint: INTEGER
		do
			if is_reserved_namespace (a_uri) then
				a_fingerprint := type_factory.standard_fingerprint (a_uri, a_local_name)
				if a_fingerprint /= -1 then
					Result := type_factory.schema_type (a_fingerprint)
				end
			end
		end

feature -- Status report

	is_node_type (a_type: INTEGER): BOOLEAN is
			-- `True' if `a_type' type is node() or a subtype of node()
		do
			Result := a_type = Element_node
				or else a_type = Attribute_node
				or else a_type = Text_node
				or else a_type = Processing_instruction_node
				or else a_type = Comment_node
				or else a_type = Document_node
				or else a_type = Namespace_node
				or else a_type = Any_node
		end

	is_node_item_type (a_type: XM_XPATH_ITEM_TYPE): BOOLEAN is
			-- `True' if `a_type' is node() or a subtype of node()
		require
			type_not_void: a_type /= Void
		do
			Result := is_sub_type (a_type, any_node_test)
		end

	is_atomic_item_type (a_type: XM_XPATH_ITEM_TYPE): BOOLEAN is
			-- `True' if `a_type' is an atomic value
		require
			type_not_void: a_type /= Void
		do
			Result := is_sub_type (a_type, type_factory.any_atomic_type)
		end
	
	is_sub_type (a_sub_type, a_super_type: XM_XPATH_ITEM_TYPE): BOOLEAN is
			-- Is `a_sub_type' a (non-proper) descendant of `a_super_type'?
		require
			super_type_not_void: a_super_type /= Void
		local
			a_relationship: INTEGER
		do
			if a_sub_type /= Void then
				a_relationship := type_relationship (a_sub_type, a_super_type)
				Result := a_relationship = Same_item_type or else a_relationship = Subsumed_type
			end
		end

	type_relationship (a_first_type, a_second_type: XM_XPATH_ITEM_TYPE): INTEGER is
			-- Relation of `a_first_type' to `a_second_type'
		require
			types_not_void: a_first_type /= Void and then a_second_type /= Void
		local
			an_atomic_type, another_atomic_type, a_third_atomic_type: XM_XPATH_ATOMIC_TYPE
			a_node_test, another_node_test: XM_XPATH_NODE_TEST
			an_item_type: XM_XPATH_ITEM_TYPE
			finished: BOOLEAN
			a_fingerprint: INTEGER
		do
			if a_first_type = any_item then
				if a_second_type = any_item then
					Result := Same_item_type
				else
					Result := Subsuming_type
				end
			elseif a_second_type = any_item then
				Result := Subsumed_type
			else
				an_atomic_type ?= a_first_type
				if an_atomic_type /= Void then
					a_node_test ?= a_second_type
					if a_node_test /= Void then
						Result := Disjoint_types
					else
						another_atomic_type ?= a_second_type
						a_fingerprint := an_atomic_type.fingerprint
						if another_atomic_type /= Void and then
							a_fingerprint = another_atomic_type.fingerprint then
							Result := Same_item_type
						else
							Result := -1
							from
								an_item_type := a_second_type
							until
								finished
							loop
								a_third_atomic_type ?= an_item_type
								if a_third_atomic_type = Void then
									finished := True
								else
									if a_fingerprint = a_third_atomic_type.fingerprint then
										Result := Subsuming_type
										finished := True
									else
										an_item_type := an_item_type.super_type
									end
								end
							end
							if Result = -1 then
								from
									finished := False
									a_fingerprint := another_atomic_type.fingerprint
									an_item_type := a_first_type
								until
									finished
								loop
									a_third_atomic_type ?= an_item_type
									if a_third_atomic_type = Void then
										Result := Disjoint_types
										finished := True
									else
										if a_fingerprint = a_third_atomic_type.fingerprint then
											Result := Subsumed_type
											finished := True
										else
											an_item_type := an_item_type.super_type
										end
									end
								end
							end
						end
					end
				else

					-- `a_first_type' must be a node test

					an_atomic_type ?= a_second_type
					if an_atomic_type /= Void then
						Result := Disjoint_types
					else
						a_node_test ?= a_first_type
						another_node_test ?= a_second_type
						check
							both_node_tests: a_node_test /= Void and then another_node_test /= Void
						end
						Result := node_test_relationship (a_node_test, another_node_test)
					end
				end
			end
		ensure
			valid_relationship: Result >= Same_item_type and then Disjoint_types >= Result
		end
			
	is_promotable (a_source_type, a_target_type: XM_XPATH_ITEM_TYPE): BOOLEAN is
			-- Can `a_source_type' be numerically promoted to `a_target_type?
			--  (e.g. xs:integer is promotable to xs:double)
		require
			target_type_not_void: a_target_type /= Void
		do
			if is_sub_type (a_source_type, type_factory.decimal_type) then
				Result := a_target_type = type_factory.double_type
			end
		end

	are_types_comparable (a_type, another_type: INTEGER): BOOLEAN is
			-- Is `a_type' comparable with `another_type'?
		local
			t1, t2: INTEGER
		do
			if a_type = Any_atomic_type_code or else
				another_type = Any_atomic_type_code then
				Result := True -- as far as we know
			else
				t1 := a_type
				t2 := another_type
				if t1 = Untyped_atomic_type_code then
					t1 := String_type_code
				end
				if t2 = Untyped_atomic_type_code then
					t2 := String_type_code
				end
				if t1 = Double_type_code or else
					t1 = Decimal_type_code or else
					t1 = Float_type_code or else
					t1 = Integer_type_code then
					t1 := Numeric_type_code
				end
				if t2 = Integer_type_code or else
					t2 = Decimal_type_code or else
					t2 = Float_type_code or else
					t2 = Double_type_code then
					t2 := Numeric_type_code
				end
				Result := t1 = t2
			end
		end

feature {NONE} -- Implementation

	node_test_relationship (a_node_test, another_node_test: XM_XPATH_NODE_TEST): INTEGER is
			-- Relation of `a_node_test' to `another_node_test'
		require
			tests_not_void: a_node_test /= Void and then another_node_test /= Void
		local
			a_mask, another_mask, a_node_kind_relationship, a_node_name_relationship: INTEGER
			a_set, another_set: DS_SET [INTEGER]
		do
			Result := -1
			if a_node_test = any_node_test then
				if another_node_test = any_node_test then
					Result := Same_item_type
				else
					Result := Subsuming_type
				end
			elseif another_node_test = any_node_test then
				Result := Subsumed_type
			elseif a_node_test = empty_item then
				Result := Disjoint_types
			elseif another_node_test = empty_item then
				Result := Disjoint_types
			else

				-- Firstly, find the relationship between the node kinds allowed.

				a_mask := a_node_test.node_kind_mask; another_mask := another_node_test.node_kind_mask
				if INTEGER_.bit_and (a_mask, another_mask) = 0 then
					Result := Disjoint_types
				elseif a_mask = another_mask then
					a_node_kind_relationship := Same_item_type
				elseif INTEGER_.bit_and (a_mask, another_mask) = a_mask then
					a_node_kind_relationship := Subsumed_type
				elseif INTEGER_.bit_and (a_mask, another_mask) = another_mask then
					a_node_kind_relationship := Subsuming_type
				else
					a_node_kind_relationship := Overlapping_types
				end

				-- Next, find the relationship between the node names allowed.
				-- N.B. Namespace tests and local name tests do not occur
				--  in sequence types, so we don't need to consider them.

				if a_node_test.is_at_most_one_name_constraint then
					a_set := a_node_test.constraining_node_names
				end
				if another_node_test.is_at_most_one_name_constraint then
					another_set := another_node_test.constraining_node_names
				end
				if a_set = Void then
					if another_set = Void then
						a_node_name_relationship := Same_item_type
					else
						a_node_name_relationship := Subsuming_type
					end
				elseif another_set = Void then
					a_node_name_relationship := Subsumed_type
				elseif a_set.is_superset (another_set) then
					if a_set.is_equal (another_set) then
						a_node_name_relationship := Same_item_type
					else
						a_node_name_relationship := Subsuming_type
					end
				elseif another_set.is_superset (a_set) then
					a_node_name_relationship := Subsumed_type
				else
					a_node_name_relationship := Overlapping_types
				end

				-- TODO - need to test content-type relationship, but only
				--  for schema-aware processor(?)
				
				if a_node_kind_relationship = Same_item_type
					and then a_node_name_relationship = Same_item_type then
					Result := Same_item_type
				elseif
					(a_node_name_relationship = Same_item_type or else a_node_name_relationship = Subsuming_type)and then
					(a_node_kind_relationship = Same_item_type or else a_node_kind_relationship = Subsuming_type) then
					Result := Subsuming_type
				elseif
					(a_node_name_relationship = Same_item_type or else a_node_name_relationship = Subsumed_type)and then
					(a_node_kind_relationship = Same_item_type or else a_node_kind_relationship = Subsumed_type) then
					Result := Subsumed_type
				elseif a_node_name_relationship = Disjoint_types or else a_node_kind_relationship = Disjoint_types then
					Result := Disjoint_types
				else
					Result := Overlapping_types
				end
			end
		ensure
			valid_realtionship: Result >= Same_item_type and then Disjoint_types >= Result
		end

end
