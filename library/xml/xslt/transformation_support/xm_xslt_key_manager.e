indexing

	description:

		"XSLT key managers"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_KEY_MANAGER

inherit

	UC_SHARED_STRING_EQUALITY_TESTER

	KL_IMPORTED_STRING_ROUTINES

	XM_XPATH_STANDARD_NAMESPACES

	XM_XPATH_SHARED_TYPE_FACTORY

	XM_XPATH_SHARED_ATOMIC_VALUE_TESTER

	XM_XPATH_SHARED_64BIT_TESTER

	XM_XPATH_SHARED_NAME_POOL

	XM_XPATH_TYPE

	XM_XPATH_ERROR_TYPES

	XM_XPATH_AXIS

		-- Separate this class into a pure interface, plus an implementation class.
		--  (hm. perhaps template design pattern would be better)
		-- Then add a COMPONENTS_FACTORY class which will provide instances of KEY_MANAGERs
		--  (and NAME_POOLs), so that non-portable classes can be written to make use of
		--  compiler-specific weak references (e.g. IDENTIFIED in ISE).
		-- That way, we can avoid locking multiple documents in memory.

creation

	make

feature {NONE} -- Initialization

	make is
			-- Establish invariant.
		do
			create key_map.make_map_default
			create collation_map.make_with_equality_testers (5, string_equality_tester, Void)
			create document_map.make_map_default
			-- TODO - register idref() support 
		end

feature -- Access

	last_key_sequence: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
		-- Result from `generate_keyed_sequence'
	
	generate_keyed_sequence (a_key_fingerprint: INTEGER; a_document: XM_XPATH_DOCUMENT; a_key_value: XM_XPATH_ATOMIC_VALUE;
						  a_context: XM_XSLT_EVALUATION_CONTEXT) is
			-- Generate a sequence of nodes for a particular key value
		require
			strictly_positive_key_fingerprint: a_key_fingerprint > 0
			document_not_void: a_document /= Void
			key_value_not_void: a_key_value /= Void
			context_not_void: a_context /= Void
		local
			an_item_type: INTEGER
			a_value: XM_XPATH_ATOMIC_VALUE
			an_index: XM_XSLT_KEY_INDEX
			a_key_definition: XM_XSLT_KEY_DEFINITION
			a_list: DS_ARRAYED_LIST [XM_XPATH_NODE]
			--a_collator: ST_COLLATOR
			an_error: XM_XPATH_ERROR_VALUE
		do
			last_key_sequence := Void 
			an_item_type := a_key_value.item_type.primitive_type
			if an_item_type = Integer_type_code or else
				an_item_type = Decimal_type_code or else
				an_item_type = Float_type_code then
				an_item_type := Double_type_code
				a_value := a_key_value.convert_to_type (type_factory.schema_type (an_item_type))
			else
				a_value := a_key_value
			end
			if does_index_exist (a_document, a_key_fingerprint, an_item_type) then
				an_index := index (a_document, a_key_fingerprint, an_item_type)
				if an_index.is_under_construction then
					create an_error.make_from_string ("Key definition is circular", "", "XT0640", Dynamic_error)
					a_context.transformer.report_fatal_error (an_error, Void)
				end
			else
				create an_index.make_under_construction
				put_index (a_document, a_key_fingerprint, an_item_type, an_index)
				build_index (a_key_fingerprint, an_item_type, a_document, a_context)
				if not a_context.transformer.is_error then
					an_index := last_built_index
					put_index (a_document, a_key_fingerprint, an_item_type, an_index)
				end
			end
			if not a_context.transformer.is_error then
				a_key_definition := key_definitions (a_key_fingerprint).item (1)
				-- a_collator := a_key_definition.collator TODO - collation keys
				if an_index.has (a_key_value) then
					a_list := an_index.map.item (a_key_value)
					create {XM_XPATH_ARRAY_LIST_ITERATOR [XM_XPATH_NODE]} last_key_sequence.make (a_list)
				else
					create {XM_XPATH_EMPTY_ITERATOR [XM_XPATH_NODE]} last_key_sequence.make
				end
			end
		ensure
			possible_error: a_context.transformer.is_error implies last_key_sequence = Void 
			iterator_not_void: not a_context.transformer.is_error implies last_key_sequence /= Void -- of course, the iteration may well yield zero nodes
		end

	collation_uri (a_key_fingerprint: INTEGER): STRING is
			-- Collation URI for the key defined by a_key_fingerprint'
		require
			key_defined: has_key (a_key_fingerprint)
		do
			Result := collation_map.item (a_key_fingerprint)
		ensure
			collation_uri_not_void: Result /= Void
		end

	key_definitions (a_key_fingerprint: INTEGER): DS_ARRAYED_LIST [XM_XSLT_KEY_DEFINITION] is
			-- List of key definitions mataching `a_key_fingerprint:'
		require
			key_defined: has_key (a_key_fingerprint)
		do
			Result := key_map.item (a_key_fingerprint)
		ensure
			key_definitions_list_not_void: Result /= Void
		end
	
feature -- Status report

	has_key (a_key_fingerprint: INTEGER): BOOLEAN is
			-- Is there a key definition for `a_key_fingerprint'?
		do
			Result := key_map.has (a_key_fingerprint)
		end

	is_same_collation (a_key_definition: XM_XSLT_KEY_DEFINITION; a_key_fingerprint: INTEGER): BOOLEAN is
			-- Does `a_key_definition' use the same collation as all keys defined to map to `a_key_fingerprint'?
		require
			key_definition_not_void: a_key_definition /= Void
		do
			if not key_map.has (a_key_fingerprint) then
				Result := True
			else
				Result := collation_map.has (a_key_fingerprint) and then STRING_.same_string (collation_uri (a_key_fingerprint), a_key_definition.collation_uri)
			end
		end

feature -- Element change

	add_key_definition (a_key_definition: XM_XSLT_KEY_DEFINITION; a_key_fingerprint: INTEGER) is
			-- Add a key definition.
		require
			key_definition_not_void: a_key_definition /= Void
			same_collation: is_same_collation (a_key_definition, a_key_fingerprint)
		local
			a_key_list: DS_ARRAYED_LIST [XM_XSLT_KEY_DEFINITION]
		do
			if key_map.has (a_key_fingerprint) then
				a_key_list := key_map.item (a_key_fingerprint)
				check
					collation_map_entry: collation_map.has (a_key_fingerprint)
					-- as this routine ensures it
				end
			else
				create a_key_list.make (3)
				key_map.put (a_key_list, a_key_fingerprint)
				collation_map.put (a_key_definition.collation_uri, a_key_fingerprint)
			end
			if not a_key_list.extendible (1) then
				a_key_list.resize (2 * a_key_list.count)
			end
			a_key_list.put_last (a_key_definition)
		ensure
			has_key: has_key (a_key_fingerprint)
			key_definition_added: True -- TODO
		end

feature {NONE} -- Implementation

	key_map: DS_HASH_TABLE [DS_ARRAYED_LIST [XM_XSLT_KEY_DEFINITION], INTEGER]
			-- Map of fingerprints to keys

	collation_map: DS_HASH_TABLE [STRING, INTEGER]
			-- Map of fingerprints to collation_names

	document_map: DS_HASH_TABLE [DS_HASH_TABLE [XM_XSLT_KEY_INDEX, XM_XPATH_64BIT_NUMERIC_CODE], XM_XPATH_DOCUMENT]
			-- Map of documents in memory to a map of key-fingerprint/item-types to indices of key/value pairs

	last_built_index: XM_XSLT_KEY_INDEX
			-- Result from `build_index'

	build_index (a_key_fingerprint, an_item_type: INTEGER; a_document: XM_XPATH_DOCUMENT; a_context: XM_XSLT_EVALUATION_CONTEXT) is 
			-- Build index for `a_document' for a named key.
		require
			document_not_void: a_document /= Void
			context_not_void: a_context /= Void
			transformer_not_in_error: a_context.transformer /= Void and then not a_context.transformer.is_error
		local
			some_key_definitions: DS_ARRAYED_LIST [XM_XSLT_KEY_DEFINITION]
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XSLT_KEY_DEFINITION]
			a_message: STRING
			a_map: DS_HASH_TABLE [DS_ARRAYED_LIST [XM_XPATH_NODE], XM_XPATH_ATOMIC_VALUE]
			an_error: XM_XPATH_ERROR_VALUE
		do
			debug ("XSLT key manager")
				std.error.put_string ("Ready to build an index%N")
			end
			last_built_index := Void
			some_key_definitions := key_definitions (a_key_fingerprint)
			if some_key_definitions /= Void then
				create a_map.make_with_equality_testers (10, Void, atomic_value_tester)
				from
					a_cursor := some_key_definitions.new_cursor; a_cursor.start
				variant
					some_key_definitions.count + 1 - a_cursor.index
				until
					a_cursor.after
				loop
					construct_index (a_document, a_map, a_cursor.item, an_item_type, a_context, a_cursor.index = 1)
					a_cursor.forth
				end
				if not a_context.transformer.is_error then create last_built_index.make (a_map) end
			else
				a_message := STRING_.concat ("Key ", shared_name_pool.display_name_from_name_code (a_key_fingerprint))
				a_message := STRING_.appended_string (a_message, " has not been defined")
				create an_error.make_from_string (a_message, "", "XT1260", Dynamic_error)
				a_context.transformer.report_fatal_error (an_error, Void)
			end
		ensure
			error_or_index_built: not a_context.transformer.is_error implies last_built_index /= Void
		end
	
	construct_index (a_document: XM_XPATH_DOCUMENT; a_map: DS_HASH_TABLE [DS_ARRAYED_LIST [XM_XPATH_NODE], XM_XPATH_ATOMIC_VALUE];
		a_key: XM_XSLT_KEY_DEFINITION; a_sought_item_type: INTEGER; a_context: XM_XSLT_EVALUATION_CONTEXT; is_first: BOOLEAN) is
			-- Fill in `a_map' for `a_key'.
		require
			document_not_void: a_document /= Void
			context_not_void: a_context /= Void
			transformer_not_in_error: a_context.transformer /= Void and then not a_context.transformer.is_error
			empty_map: a_map /= Void and then a_map.count = 0
			key_not_void: a_key /= Void
		local
			use: XM_XPATH_EXPRESSION
			match: XM_XSLT_PATTERN
			a_node_type: INTEGER
			all_nodes_iterator, an_attribute_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
			a_node, another_node: XM_XPATH_NODE
			a_collator: ST_COLLATOR
			a_node_test: XM_XSLT_NODE_TEST
			a_new_context: XM_XSLT_EVALUATION_CONTEXT
			a_slot_manager: XM_XPATH_SLOT_MANAGER
		do
			use := a_key.body
			match := a_key.match
			a_collator := a_key.collator
			a_new_context := a_context.new_context
			a_slot_manager := a_key.slot_manager
			if a_slot_manager.number_of_variables > 0 then
				a_new_context.open_stack_frame (a_slot_manager)
			end
			a_node_type := match.node_kind
			if a_node_type = Attribute_node or else a_node_type = Any_node or else a_node_type = Document_node then
				-- If the match pattern allows attributes to appear, we must visit them.
				-- We also take this path in the ridiculous event that the pattern can match document nodes.
				from
					all_nodes_iterator := a_document.new_axis_iterator (Descendant_or_self_axis); all_nodes_iterator.start
				until
					all_nodes_iterator.after
				loop
					a_node := all_nodes_iterator.item
					if a_node.node_type = Element_node then
						from
							an_attribute_iterator := a_node.new_axis_iterator (Attribute_axis); an_attribute_iterator.start
						until
							an_attribute_iterator.after
						loop
							another_node := an_attribute_iterator.item
							if match.matches (another_node, a_new_context) then
								process_key_node (another_node, use, a_sought_item_type, a_collator, a_map, a_new_context, is_first)
							end
							an_attribute_iterator.forth
						end
						if a_node_type = Any_node then
							-- Index the element as well as it's attributes							
							if match.matches (a_node, a_new_context) then
								
								process_key_node (a_node, use, a_sought_item_type, a_collator, a_map, a_new_context, is_first)
							end
						end
					else
						if match.matches (a_node, a_new_context) then
							process_key_node (a_node, use, a_sought_item_type, a_collator, a_map, a_new_context, is_first)
						end
					end
					all_nodes_iterator.forth
				end
			else
				from
					all_nodes_iterator := a_document.new_axis_iterator (Descendant_axis); all_nodes_iterator.start
				until
					all_nodes_iterator.after
				loop
					a_node := all_nodes_iterator.item
					a_node_test ?= match
					if a_node_test /= Void or else match.matches (a_node, a_new_context) then
						process_key_node (a_node, use, a_sought_item_type, a_collator, a_map, a_new_context, is_first)
					end
					all_nodes_iterator.forth
				end
			end
		end

	process_key_node (a_node: XM_XPATH_NODE; use: XM_XPATH_EXPRESSION; a_sought_item_type: INTEGER;
		a_collator: ST_COLLATOR; a_map: DS_HASH_TABLE [DS_ARRAYED_LIST [XM_XPATH_NODE], XM_XPATH_ATOMIC_VALUE];
		a_context: XM_XSLT_EVALUATION_CONTEXT; is_first: BOOLEAN) is
			-- Process one matching node, adding entries to the index if appropriate.
		require
			node_not_void: a_node /= Void
			use_not_void: use /= Void
			map_not_void: a_map /= Void
			collator: a_collator /= Void
			context_not_void: a_context /= Void
		local
			a_singleton_iterator: XM_XPATH_SINGLETON_ITERATOR [XM_XPATH_NODE]
			an_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]
			an_atomic_value, a_value: XM_XPATH_ATOMIC_VALUE
			a_numeric_value: XM_XPATH_NUMERIC_VALUE
			an_actual_item_type: INTEGER
		do

			-- Make the node we are testing the context node and the current node,
			--  with context position and context size set to 1

			create a_singleton_iterator.make (a_node)
			a_singleton_iterator.start
			a_context.set_current_iterator (a_singleton_iterator)

			-- Evaluate the "use" expression against this context node

			from
				use.create_iterator (a_context)
				an_iterator := use.last_iterator; an_iterator.start
			until
				an_iterator.after
			loop
				an_atomic_value ?= an_iterator.item
				check
					atomic_values: an_atomic_value /= Void
					-- Use attribute is statically type-checked - sequence constructor is not yet supported
				end
				an_actual_item_type := an_atomic_value.item_type.primitive_type
				if are_types_comparable (an_actual_item_type, a_sought_item_type) then
					if a_sought_item_type = Untyped_atomic_type_code then

						-- If the supplied key value is untyped atomic, we build an index using the
						--  actual type returned by the use expression.
						-- TODO: collation keys

						create {XM_XPATH_STRING_VALUE} a_value.make (an_atomic_value.string_value)
					elseif a_sought_item_type = String_type_code then

						-- If the supplied key value is a string, there is no match unless the use expression
						--  returns a string or an untyped atomic value.
						-- TODO: collation keys

						create {XM_XPATH_STRING_VALUE} a_value.make (an_atomic_value.string_value)
					else
						a_numeric_value ?= an_atomic_value
						if a_numeric_value /= Void and then a_numeric_value.is_nan then
							-- ignore NaN
						else
							if an_atomic_value.is_convertible (type_factory.schema_type (a_sought_item_type)) then
								a_value := an_atomic_value.convert_to_type(type_factory.schema_type (a_sought_item_type))
							end
						end
					end
					add_node_to_index (a_node, a_map, a_value, is_first)
				end
				an_iterator.forth
			end
		end

	add_node_to_index (a_node: XM_XPATH_NODE; a_map: DS_HASH_TABLE [DS_ARRAYED_LIST [XM_XPATH_NODE], XM_XPATH_ATOMIC_VALUE];
							 a_value: XM_XPATH_ATOMIC_VALUE; is_first: BOOLEAN) is
			-- Add `a_node' to `a_map'.
		require
			node_not_void: a_node /= Void
			map_not_void: a_map /= Void
			value_not_void: a_value /= Void
		local
			a_node_list: DS_ARRAYED_LIST [XM_XPATH_NODE]
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_NODE]
			a_local_order_comparer: XM_XPATH_LOCAL_ORDER_COMPARER
			a_comparison: INTEGER
			added: BOOLEAN
		do
			if a_map.has (a_value) then
				a_node_list := a_map.item (a_value)

				-- This is not the first node with this key value.
            -- Add the node to the list of nodes for this key,
				--  unless it's already there

				if is_first then

					-- If this is the first index definition that we're processing,
					--  then this node must be after all existing nodes in document
					--  order, or the same node as the last existing node

					if a_node_list.is_empty or else a_node_list.last /= a_node then
						a_node_list.force_last (a_node)
					end
				else

					-- Otherwise, we need to insert the node at the correct
					--  position in document order.

					create a_local_order_comparer
					from
						a_cursor := a_node_list.new_cursor; a_cursor.start
					variant
						a_node_list.count + 1 - a_cursor.index
					until
						a_cursor.after
					loop
						a_comparison := a_local_order_comparer.three_way_comparison (a_node, a_cursor.item)
						if a_comparison <= 0 then
							if a_comparison = 0 then

								-- Node already in list; do nothing.

							else

								-- Add the node at this position.

								a_cursor.force_left (a_node)
							end
							added := True
							a_cursor.go_after
						else
							a_cursor.forth
						end
					end

					-- Otherwise add the new node at the end.

					if not added then a_node_list.force_last (a_node) end
				end
			else
				create a_node_list.make_default
				a_map.put (a_node_list, a_value)
				a_node_list.force_last (a_node)
			end
		end

	put_index (a_document: XM_XPATH_DOCUMENT; a_key_fingerprint, an_item_type: INTEGER; an_index: XM_XSLT_KEY_INDEX) is
			-- Save the index associated with `a_key_fingerprint', `an_item_type', and `a_document'.
		require
			document_not_void: a_document /= Void
			index_not_void: an_index /= Void
		local
			an_index_map: DS_HASH_TABLE [XM_XSLT_KEY_INDEX, XM_XPATH_64BIT_NUMERIC_CODE]
			a_long: XM_XPATH_64BIT_NUMERIC_CODE
		do
			if document_map.has (a_document) then
				an_index_map := document_map.item (a_document)
			else
				create an_index_map.make_with_equality_testers (10, Void, long_equality_tester)
				document_map.put (an_index_map, a_document)
			end
			create a_long.make (a_key_fingerprint, an_item_type)
			if an_index_map.has (a_long) then
				check
					an_index_map.item (a_long).is_under_construction
					-- Logic of `sequence_by_key'
				end
				an_index_map.replace (an_index, a_long)
			else
				an_index_map.put (an_index, a_long)
			end
		ensure
			index_exists: does_index_exist (a_document, a_key_fingerprint, an_item_type)
		end

	does_index_exist (a_document: XM_XPATH_DOCUMENT; a_key_fingerprint, an_item_type: INTEGER): BOOLEAN is
			-- Is there an index for `a_key_fingerprint', `an_item_type', and `a_document'?
		require
			document_not_void: a_document /= Void
		local
			an_index_map: DS_HASH_TABLE [XM_XSLT_KEY_INDEX, XM_XPATH_64BIT_NUMERIC_CODE]
			a_long: XM_XPATH_64BIT_NUMERIC_CODE
		do
			if document_map.has (a_document) then
				an_index_map := document_map.item (a_document)
				create a_long.make (a_key_fingerprint, an_item_type)
				Result := an_index_map.has (a_long)
			end
		end

	index (a_document: XM_XPATH_DOCUMENT; a_key_fingerprint, an_item_type: INTEGER): XM_XSLT_KEY_INDEX is
			-- Index associated with `a_key_fingerprint', `an_item_type', and `a_document'
		require
			document_not_void: a_document /= Void
			index_exists: does_index_exist (a_document, a_key_fingerprint, an_item_type)
		local
			an_index_map: DS_HASH_TABLE [XM_XSLT_KEY_INDEX, XM_XPATH_64BIT_NUMERIC_CODE]
			a_long: XM_XPATH_64BIT_NUMERIC_CODE
		do
			check
				index_map_exists: document_map.has (a_document)
				-- From pre-condition
			end
			an_index_map := document_map.item (a_document)
			create a_long.make (a_key_fingerprint, an_item_type)
			Result := an_index_map.item (a_long)
		ensure
			index_not_void: Result /= Void
		end

invariant

	document_map_not_void: document_map /= Void
	key_map: key_map /= Void
	collation_map: collation_map /= Void
		-- coordinated_maps: forall.a_key_fingerprint key_map.has (a_key_fingerprint) implies collation_map.has (a_key_fingerprint)
	
end
	
