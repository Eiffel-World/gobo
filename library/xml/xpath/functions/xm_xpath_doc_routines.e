indexing

	description:

		"Routines to implement the XPath doc() function"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_DOC_ROUTINES

inherit

	XM_XPATH_ERROR_TYPES

	KL_IMPORTED_STRING_ROUTINES

feature -- Access

	last_evaluated_document: XM_XPATH_ITEM
			-- Result from `parse_document'

feature -- Evaluation
	
	parse_document (a_uri_reference: STRING; a_base_uri: UT_URI; a_context: XM_XPATH_CONTEXT) is
			-- Parse `a_uri_reference' as a document'.
		require
			uri_reference_not_void: a_uri_reference /= Void
			base_uri_not_void: a_base_uri /= Void and then a_base_uri.is_absolute
			context_not_void: a_context /= Void
		local
			a_uri: UT_URI
			a_document: XM_XPATH_DOCUMENT
			a_message: STRING
		do
			if uri_encoding.has_excluded_characters (a_uri_reference) then
				create {XM_XPATH_INVALID_ITEM} last_evaluated_document.make_from_string ("Argument to fn:doc is not a valid URI", "FODC0005", Dynamic_error)
			else
				create a_uri.make_resolve (a_base_uri, a_uri_reference)
				if a_context.available_documents.is_mapped (a_uri.full_reference) then
					last_evaluated_document := a_context.available_documents.document (a_uri.full_reference)
				else
					a_context.build_document (a_uri.full_reference)
					if a_context.is_build_document_error then
						a_message := STRING_.concat ("Failed to parse ", a_uri.full_reference)
						a_message := STRING_.appended_string (a_message, ". ")
						a_message := STRING_.appended_string (a_message, a_context.last_build_error)
						create {XM_XPATH_INVALID_ITEM} last_evaluated_document.make_from_string (a_message, "FODC0002", Dynamic_error)
					else
						a_document := a_context.last_parsed_document
						last_evaluated_document := a_document
						a_context.available_documents.add (a_document, a_uri.full_reference)
					end
				end
			end
		end
	
	uri_encoding: UT_URL_ENCODING is
			-- Encoding/decoding routines and tests
		once
			create Result
		ensure
			uri_encoding_not_void: Result /= Void
		end

end
	
