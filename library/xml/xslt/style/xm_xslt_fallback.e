indexing

	description:

		"xsl:fallback element nodes"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_FALLBACK

inherit

	XM_XSLT_STYLE_ELEMENT
		redefine
			make_style_element, validate, may_contain_sequence_constructor
		end

creation {XM_XSLT_NODE_FACTORY}

	make_style_element

feature {NONE} -- Initialization
	
	make_style_element (an_error_listener: XM_XSLT_ERROR_LISTENER; a_document: XM_XPATH_TREE_DOCUMENT;  a_parent: XM_XPATH_TREE_COMPOSITE_NODE;
		an_attribute_collection: XM_XPATH_ATTRIBUTE_COLLECTION; a_namespace_list:  DS_ARRAYED_LIST [INTEGER];
		a_name_code: INTEGER; a_sequence_number: INTEGER) is
			-- Establish invariant.
		do
			is_instruction := True
			Precursor (an_error_listener, a_document, a_parent, an_attribute_collection, a_namespace_list, a_name_code, a_sequence_number)
		end


feature -- Status_report

	may_contain_sequence_constructor: BOOLEAN is
			-- Is `Current' allowed to contain a sequence constructor?
		do
			Result := True
		end

feature -- Element change

	prepare_attributes is
			-- Set the attribute list for the element.
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [INTEGER]
			a_name_code: INTEGER
			an_expanded_name: STRING
		do
			from
				a_cursor := attribute_collection.name_code_cursor
				a_cursor.start
			variant
				attribute_collection.number_of_attributes + 1 - a_cursor.index				
			until
				a_cursor.after
			loop
				a_name_code := a_cursor.item
				an_expanded_name := shared_name_pool.expanded_name_from_name_code (a_name_code)
				check_unknown_attribute (a_name_code)
				a_cursor.forth
			end
			attributes_prepared := True
		end

	validate is
			-- Check that the stylesheet element is valid.
		local
			a_parent: XM_XSLT_STYLE_ELEMENT
			an_error: XM_XPATH_ERROR_VALUE
		do
			a_parent ?= parent
			if not a_parent.may_contain_fallback then
				create an_error.make_from_string (STRING_.concat ("xsl:fallback is not allowed as a child of ", a_parent.node_name), "", "XT0010", Static_error)
				report_compile_error (an_error)
			end
			validated := True
		end

	compile (an_executable: XM_XSLT_EXECUTABLE) is
			-- Compile `Current' to an excutable instruction. 
		do

			-- If we get here, then the parent instruction is OK, so the fallback is not activated
			
			last_generated_expression := Void
		end
	
end
	
