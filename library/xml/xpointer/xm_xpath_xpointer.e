indexing

	description:

		"Objects that process XPointers"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2005, Colin Adams and others"
	derivation: "See notice at bottom of file"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_XPOINTER

inherit

	XM_UNICODE_CHARACTERS_1_0

	XM_XPATH_ERROR_TYPES

	XM_XPATH_STANDARD_NAMESPACES

	UC_SHARED_STRING_EQUALITY_TESTER

	KL_IMPORTED_STRING_ROUTINES

creation

	make

feature {NONE} -- Initialization

	make (report_scheme_errors: BOOLEAN) is
			-- Establish invariant.
		do
			create registered_schemes.make_with_equality_testers (3, Void, string_equality_tester)
			create namespace_bindings.make
			is_reporting_scheme_errors := report_scheme_errors
		end

feature -- Access

	is_reporting_scheme_errors: BOOLEAN
			-- Are scheme errors to be reported to the application?

	is_valid_name (a_name: STRING): BOOLEAN is
			-- Is `a_name' a valid in-scope QName?
		require
			qname: a_name /= Void and then is_qname (a_name)
		local
			a_splitter: ST_SPLITTER
			some_qname_parts: DS_LIST [STRING]
		do
			create a_splitter.make
			a_splitter.set_separators (":")
			some_qname_parts := a_splitter.split (a_name)
			Result := some_qname_parts.count = 1 or else some_qname_parts.count = 2 and then namespace_bindings.is_prefix_declared (some_qname_parts.item (1))
		end

	expanded_name (a_name: STRING): STRING is
			-- Expanded version of `a_name'
		require
			qname: a_name /= Void and then is_qname (a_name)
			valid_name: is_valid_name (a_name)
		local
			a_splitter: ST_SPLITTER
			some_qname_parts: DS_LIST [STRING]			
		do
			create a_splitter.make
			a_splitter.set_separators (":")
			some_qname_parts := a_splitter.split (a_name)
			if some_qname_parts.count = 2 then
				Result := STRING_.concat ("{", namespace_bindings.namespace_uri (some_qname_parts.item (1)))
				Result := STRING_.appended_string (Result, "}")
				Result := STRING_.appended_string (Result,some_qname_parts.item (2))
			else
				Result := a_name
			end
		end

	value: XM_XPATH_VALUE
			-- Evaluation result;
			-- Usually a node sequence, but can be more general
			-- (For instance, the xpointer scheme includes points and ranges).
			-- Even if this is not in error, it may not be a valid result for
			--  the application - for instance, XSLT requires a node sequence.

	is_registered (a_scheme_name: STRING): BOOLEAN is
			-- Is `a_scheme_name' the expanded name of a registered scheme processor?
		require
			scheme_name_not_void: a_scheme_name /= Void
		do
			Result := registered_schemes.has (a_scheme_name)
		end


feature -- Evaluation

	evaluate (an_xpointer: STRING; a_resource: XM_XPATH_DOCUMENT) is
			-- Evaluate `an_xpointer' against `a_resource'.
		require
			xpointer_not_empty: an_xpointer /= Void and then an_xpointer.count > 0
			xml_resource_not_void: a_resource /= Void -- N.B. this may be an external parsed entity, or a well-formed document
		local
			a_parser: XM_XPATH_XPOINTER_PARSER
			an_element: XM_XPATH_ELEMENT
			a_cursor:  DS_ARRAYED_LIST_CURSOR [STRING]
			a_scheme_name: STRING
			a_processor: XM_XPATH_XPOINTER_SCHEME
		do
			value := Void
			create a_parser.make
			a_parser.parse (an_xpointer)
			if a_parser.is_error then
				create {XM_XPATH_INVALID_VALUE} value.make (a_parser.error_value)
			elseif a_parser.is_shorthand then
				an_element := a_resource.selected_id (a_parser.shorthand)
				if an_element = Void then
					create {XM_XPATH_EMPTY_SEQUENCE} value.make
					value.set_last_error_from_string ("Could not find shorthand element", Gexslt_eiffel_type_uri, "XPOINTER_EVALUATION", Dynamic_error)
				else
					create {XM_XPATH_SINGLETON_NODE} value.make (an_element)
				end
			else
				from
					a_cursor := a_parser.scheme_sequence.new_cursor; a_cursor.start
				variant
					a_parser.scheme_sequence.count + 1 - a_cursor.index
				until
					a_cursor.after
				loop
					if is_valid_name (a_cursor.item) then
						a_scheme_name := expanded_name (a_cursor.item)
					else
						a_scheme_name := ""
					end
					if is_registered (a_scheme_name) then
						a_processor := registered_schemes.item (a_scheme_name)
						a_processor.evaluate (a_resource, namespace_bindings, a_parser.scheme_data.item (a_cursor.index))
						if a_processor.were_resources_found then
							value := a_processor.value
							a_cursor.go_after
						else
							if a_processor.is_error and then is_reporting_scheme_errors then
								value := a_processor.value
							end
							a_cursor.forth
						end
					else
						a_cursor.forth
					end
				end
				if value = Void then
					create {XM_XPATH_EMPTY_SEQUENCE} value.make
				end
			end
		ensure
			value_may_be_in_error: value /= Void
		end

feature -- Element change

	register_scheme (a_scheme: XM_XPATH_XPOINTER_SCHEME) is
			-- Register `a_scheme' as an XPointer scheme.
		require
			scheme_not_empty: a_scheme /= Void
			scheme_not_already_registered: not is_registered (a_scheme.expanded_name)
		do
			registered_schemes.force_new (a_scheme, a_scheme.expanded_name)
		ensure
			scheme_registered: is_registered (a_scheme.expanded_name) and then registered_schemes.item (a_scheme.expanded_name) = a_scheme
		end
	
feature {NONE} -- Implementation

	registered_schemes: DS_HASH_TABLE [XM_XPATH_XPOINTER_SCHEME, STRING]
			-- Registered scheme processors, indexed by expanded-name

	namespace_bindings: XM_XPATH_XPOINTER_NAMESPACE_CONTEXT
	
invariant

	registered_schemes_not_void: registered_schemes /= Void
	namespace_bindings_not_void: namespace_bindings /= Void

end

