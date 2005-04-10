indexing

	description:

		"Objects that implement the XPath id() function"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_ID

inherit

	XM_XPATH_SYSTEM_FUNCTION
		redefine
			simplify, pre_evaluate, check_arguments,
			compute_special_properties, create_iterator
		end

	XM_XPATH_SHARED_NODE_KIND_TESTS

creation

	make

feature {NONE} -- Initialization

	make is
			-- Establish invariant
		do
			name := "id"
			minimum_argument_count := 1
			maximum_argument_count := 2
			create arguments.make (2)
			arguments.set_equality_tester (expression_tester)
			compute_static_properties
		end

feature -- Access

	item_type: XM_XPATH_ITEM_TYPE is
			-- Data type of the expression, where known
		do
			Result := element_node_kind_test
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

feature -- Status report

	required_type (argument_number: INTEGER): XM_XPATH_SEQUENCE_TYPE is
			-- Type of argument number `argument_number'
		do
			inspect
				argument_number
			when 1 then
					create Result.make_string_sequence
			when 2 then
				create Result.make_single_node
			end	
		end

feature -- Optimization

	simplify is
			-- Perform context-independent static optimizations
		do
			if supplied_argument_count = 1 or else arguments.item (1).context_document_nodeset then
				set_context_document_nodeset
			end
			Precursor
			add_context_document_argument (1, "id+")
			merge_dependencies (arguments.item (2).dependencies)
		end

feature -- Evaluation


	create_iterator (a_context: XM_XPATH_CONTEXT) is
			-- An iterator over the values of a sequence
		local
			a_node: XM_XPATH_NODE
			a_document: XM_XPATH_DOCUMENT
			idrefs: STRING
			a_splitter: ST_SPLITTER
			an_idref_list: DS_LIST [STRING]
			an_atomic_value: XM_XPATH_ATOMIC_VALUE
			a_mapping_iterator: XM_XPATH_NODE_MAPPING_ITERATOR
			a_local_order_comparer: XM_XPATH_LOCAL_ORDER_COMPARER
			an_id_mapping_function: XM_XPATH_ID_MAPPING_FUNCTION
		do
			arguments.item (2).evaluate_item (a_context)
			a_node ?= arguments.item (2).last_evaluated_item
			check
				node: a_node /= Void
				-- `required_type' will have ensured this
			end
			a_document ?= a_node.root
			if a_document /= Void then
				if is_singleton_id then
					arguments.item (1).evaluate_item (a_context)
					an_atomic_value ?= arguments.item (1).last_evaluated_item
					if an_atomic_value /= Void then
						idrefs := an_atomic_value.string_value
						create a_splitter.make
						an_idref_list := a_splitter.split (idrefs)
						if an_idref_list.count > 1 then
							todo ("iterator (multiple IDREFS/string)", True)
						else
							create {XM_XPATH_SINGLETON_ITERATOR [XM_XPATH_NODE]} last_iterator.make (a_document.selected_id (idrefs))
						end
					else
						create {XM_XPATH_EMPTY_ITERATOR [XM_XPATH_ITEM]} last_iterator.make
					end
				else
					create a_local_order_comparer
					arguments.item (1).create_iterator (a_context)
					create an_id_mapping_function.make (a_document)
					create a_mapping_iterator.make (arguments.item (1).last_iterator, an_id_mapping_function, Void)
					create {XM_XPATH_DOCUMENT_ORDER_ITERATOR} last_iterator.make (a_mapping_iterator, a_local_order_comparer) 
				end
			else
				create {XM_XPATH_INVALID_ITERATOR} last_iterator.make_from_string ("In the id() function," +
													 " the tree being searched must be one whose root is a document node", Xpath_errors_uri, "FODC0001", Dynamic_error)
			end
		end

	pre_evaluate (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Pre-evaluate `Current' at compile time.
		do
		end

feature {XM_XPATH_FUNCTION_CALL} -- Local

	check_arguments (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Check arguments during parsing, when all the argument expressions have been read.
		local

		do
			Precursor (a_context)
			arguments.item (1).set_unsorted (False)
			is_singleton_id := not arguments.item (1).cardinality_allows_many
		end

feature {XM_XPATH_EXPRESSION} -- Restricted

	compute_cardinality is
			-- Compute cardinality.
		do
			set_cardinality_zero_or_more
		end

	compute_special_properties is
			-- Compute special properties.
		do
			initialize_special_properties
			set_single_document_nodeset
			set_ordered_nodeset
			set_non_creating
		end

feature {NONE} -- Implementation

	is_singleton_id: BOOLEAN
			-- Is only one IDREFS value supplied?

end
	
