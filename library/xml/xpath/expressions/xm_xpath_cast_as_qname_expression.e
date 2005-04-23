indexing

	description:

		"XPath cast as xs:QName Expressions"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_CAST_AS_QNAME_EXPRESSION

inherit

	XM_XPATH_COMPUTED_EXPRESSION
		redefine
			sub_expressions, evaluate_item, compute_special_properties
		end

creation

	make

feature {NONE} -- Initialization
	
	make (an_expression: XM_XPATH_EXPRESSION) is
			-- Establish invariant.
		require
			source_expression_not_void: an_expression /= Void
		do
			source := an_expression
			compute_static_properties
			initialized := True
		ensure
			static_properties_computed: are_static_properties_computed
			source_set: source = an_expression
		end


feature -- Access
	
	item_type: XM_XPATH_ITEM_TYPE is
			--Determine the data type of the expression, if possible
		do
			Result := type_factory.qname_type
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

	sub_expressions: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION] is
			-- Immediate sub-expressions of `Current'
		do
			create Result.make (1)
			Result.put (source, 1)
			Result.set_equality_tester (expression_tester)
		end
	
feature -- Status report

	display (a_level: INTEGER) is
			-- Diagnostic print of expression structure to `std.error'
		local
			a_string: STRING
		do
			a_string := STRING_.appended_string (indentation (a_level), "cast as QName")
				std.error.put_string (a_string)
			if is_error then
				std.error.put_string (" in error%N")
			else
				std.error.put_new_line
				source.display (a_level + 1)
			end
		end

feature -- Optimization	

	analyze (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Perform static analysis of an expression and its subexpressions
		do
			mark_unreplaced
			namespace_context := a_context.namespace_resolver
		end

feature -- Evaluation

	evaluate_item (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate `Current' as a single item
		local
			a_string, an_xml_prefix, a_namespace_uri, a_local_name: STRING
			a_splitter: ST_SPLITTER
			qname_parts: DS_LIST [STRING]
			a_name_code: INTEGER
		do
			last_evaluated_item := Void
			source.evaluate_item (a_context)
			if not source.last_evaluated_item.is_atomic_value then
				last_evaluated_item := Void
			else
				a_string := source.last_evaluated_item.as_atomic_value.primitive_value.string_value
				create a_splitter.make
				a_splitter.set_separators (":")
				qname_parts := a_splitter.split (a_string)
				if qname_parts.count = 1 then
					an_xml_prefix := ""
					a_local_name := qname_parts.item (1)
				elseif qname_parts.count = 2 then
					an_xml_prefix := qname_parts.item (1)
					a_local_name := qname_parts.item (2)
				else
					create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string ("Argument to cast as xs:QName is not a lexical QName", Xpath_errors_uri, "FORG0001", Dynamic_error)
				end
				if last_evaluated_item = Void then
					a_namespace_uri := namespace_context.uri_for_defaulted_prefix (an_xml_prefix, True)
					if a_namespace_uri = Void then
						create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string ("Prefix of argument to cast as xs:QName is not in scope", Xpath_errors_uri, "FONS0003", Dynamic_error)
					else
						if not shared_name_pool.is_name_code_allocated (an_xml_prefix, a_namespace_uri, a_local_name) then
							shared_name_pool.allocate_name (an_xml_prefix, a_namespace_uri, a_local_name)
							a_name_code := shared_name_pool.last_name_code
						else
							a_name_code := shared_name_pool.name_code (an_xml_prefix, a_namespace_uri, a_local_name)
						end
						if a_name_code = -1 then
							create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string ("Resource failure trying to cast to xs:QName", Xpath_errors_uri, "FOER0000", Dynamic_error)
						else
							create {XM_XPATH_QNAME_VALUE} last_evaluated_item.make (a_name_code)
						end
					end
				end
			end
		end

feature {NONE} -- Implementation

	source: XM_XPATH_EXPRESSION
			-- Expression to be cast

	namespace_context: XM_XPATH_NAMESPACE_RESOLVER
	
	compute_cardinality is
			-- Compute cardinality.
		do
			set_cardinality_exactly_one
		end

	compute_special_properties is
			-- Compute special properties.
		do
			Precursor
			set_non_creating
		end

invariant

	source_expression_not_void: source /= Void

end
	
