indexing

	description:

	"Emitters that write plain text."

library: "Gobo Eiffel XSLT Library"
copyright: "Copyright (c) 2004, Colin Adams and others"
license: "Eiffel Forum License v2 (see forum.txt)"
date: "$Date$"
revision: "$Revision$"

class XM_XSLT_TEXT_EMITTER

inherit

	XM_XSLT_XML_EMITTER
		redefine
			start_document, notify_characters, start_element,
			notify_namespace, notify_attribute, end_element,
			notify_processing_instruction, notify_comment
		end

creation

	make

feature -- Events

	start_document is
			-- New document
		do
			is_document_started := True

			-- Prevent `open_document' from writing an XML declaration.

			is_declaration_written := True
			open_document

			-- Write a BOM if requested

			if output_properties.byte_order_mark_required then
				output_ignoring_error (byte_order_mark)
				is_empty := False
			end
		end

	notify_characters (chars: STRING; properties: INTEGER) is
			-- Notify character data.
			-- Special characters are not escaped
		local
			a_bad_character: INTEGER
			a_message: STRING
		do
			if not is_error then
				if not are_no_special_characters (properties) then
					a_bad_character := bad_character_code (chars)
					if a_bad_character = 0 then
						output (chars)
					else
						a_message := STRING_.concat ("Output character not available in this encoding (decimal ", a_bad_character.out)
						a_message := STRING_.appended_string (a_message, ")")
						transformer.report_fatal_error (a_message, Void)
						is_error := True
					end
				end
			end
		end

	-- Remaining events are no-ops

	start_element (a_name_code: INTEGER; a_type_code: INTEGER; properties: INTEGER) is
			-- Notify the start of an element
		do
		end

	end_element is
			-- Notify the end of an element.
		do
		end

	notify_namespace (a_namespace_code: INTEGER; properties: INTEGER) is
			-- Notify a namespace declaration.
		do
		end
	
	notify_attribute (a_name_code: INTEGER; a_type_code: INTEGER; a_value: STRING; properties: INTEGER) is
			-- Notify an attribute.
		do
		end

	notify_processing_instruction (a_name: STRING; a_data_string: STRING; properties: INTEGER) is
			-- Notify a processing instruction.
		do
		end

	notify_comment (a_content_string: STRING; properties: INTEGER) is
			-- Notify a comment.
		do
		end

end
	
