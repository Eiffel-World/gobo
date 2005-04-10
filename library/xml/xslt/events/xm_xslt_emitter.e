indexing

	description:

		"Objects that send receiver events to an output destination."

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_XSLT_EMITTER

inherit
	
	XM_XPATH_RECEIVER

	XM_XPATH_STANDARD_NAMESPACES

	XM_XPATH_ERROR_TYPES

	UC_UNICODE_ROUTINES

feature -- Access

	outputter: XM_XSLT_OUTPUT_ENCODER
			-- Outputter which writes to the destination stream

	output_properties: XM_XSLT_OUTPUT_PROPERTIES
			-- Output properties

	character_map_expander: XM_XSLT_CHARACTER_MAP_EXPANDER
			-- Optional character-map expander 

	normalized_string (a_value: STRING) : STRING is
			-- Unicode-normalized version of `a_value'
		require
			value_not_void: a_value /= Void
			-- and then URI escaping and character mapping has not been performed
		do

			-- TODO

			Result := a_value
		end

feature -- Status report

	is_error: BOOLEAN
			-- has an error occured?

feature -- Events

	on_error (a_message: STRING) is
			-- Event producer detected an error.
		local
			an_error: XM_XPATH_ERROR_VALUE
			a_uri, a_code, a_text: STRING
			an_index: INTEGER
		do
			an_index := a_message.index_of (':', 1)
			if a_message.count > an_index + 1 and then STRING_.same_string (a_message.substring (1, 1), "X") and then an_index > 0 then
				if STRING_.same_string (a_message.substring (1, 2), "XT") then
					a_uri := ""
				else
					a_uri := Xpath_errors_uri
				end
				a_code := a_message.substring (1, an_index - 1)
				a_text := a_message.substring (an_index + 2, a_message.count)
			else
				a_text := a_message
				a_uri := Gexslt_eiffel_type_uri
				a_code := "SERIALIZATION_ERROR"
			end
			create an_error.make_from_string (a_text, a_uri, a_code, Dynamic_error)
			transformer.report_fatal_error (an_error, Void)
			is_error := True
		end

	set_unparsed_entity (a_name: STRING; a_system_id: STRING; a_public_id: STRING) is
			-- Notify an unparsed entity URI.
		do
			-- Not used by emitters
		end

feature -- Element change

	set_system_id (a_system_id: STRING) is
			-- Set the system-id of the destination tree.
		do
			system_id := a_system_id
		end

	set_document_locator (a_locator: XM_XPATH_LOCATOR) is
			-- Set the locator.
		do
			-- Not used by emitters
		end

	set_output_properties (some_output_properties: XM_XSLT_OUTPUT_PROPERTIES) is
			-- Set `output_properties'.
		require
			output_properties_not_void: some_output_properties /= Void
		do
			-- TODO: character set
			output_properties := some_output_properties
		ensure
			output_properties_set: output_properties = some_output_properties
		end

feature {NONE} -- Implementation

	transformer: XM_XSLT_TRANSFORMER
			-- Transformer

invariant

	system_id_not_void: system_id /= Void
	output_properties_not_void: output_properties /= Void
	transformer_not_void: transformer /= Void

end

