indexing

	description:

	"Emitters that write HTML."

library: "Gobo Eiffel XSLT Library"
copyright: "Copyright (c) 2004, Colin Adams and others"
license: "Eiffel Forum License v2 (see forum.txt)"
date: "$Date$"
revision: "$Revision$"

class XM_XSLT_HTML_EMITTER

inherit

	UC_SHARED_STRING_EQUALITY_TESTER

	XM_XSLT_XML_EMITTER
		rename
			make as make_xml
		redefine
			open_document, start_content, output_attribute,
			output_escape, end_element, notify_processing_instruction, start_element,
			notify_characters, maximal_ordinary_string
		end

	XM_XPATH_STANDARD_NAMESPACES

creation

	make

feature {NONE} -- Initialization

	make (a_transformer: XM_XSLT_TRANSFORMER; an_outputter: XM_OUTPUT; some_output_properties: XM_XSLT_OUTPUT_PROPERTIES) is
			-- Establish invariant.
		require
			transformer_not_void: a_transformer /= Void
			outputter_not_void: an_outputter /= Void
			output_properties_not_void: some_output_properties /= Void
		do
			make_xml (a_transformer, an_outputter, some_output_properties)
			make_empty_tags_set
			make_boolean_attributes_sets
			make_url_attributes
			make_entities
		ensure
			transformer_set: transformer = a_transformer
			outputter_set: raw_outputter = an_outputter
			output_properties_set: output_properties = some_output_properties
		end

feature -- Status report

	is_url_attribute (an_element, an_attribute: STRING): BOOLEAN is
			-- Is `an_attribute' url-valued when used with `an_element'.?
		require
			element_name_not_void: an_element /= Void
			attribute_name_not_void: an_attribute /= Void
		do
			if url_attributes_set.has (an_attribute) then
				Result := url_combinations_set.has (an_element + "+" + an_attribute)
			end
		end

feature -- Events

	start_element (a_name_code: INTEGER; a_type_code: INTEGER; properties: INTEGER) is
			-- Notify the start of an element
		do
			Precursor (a_name_code, a_type_code, properties)
			element_name := STRING_.to_lower (element_qname_stack.item)
			element_uri_code := shared_name_pool.uri_code_from_name_code (a_name_code)
			if element_uri_code = Default_uri_code and then
				(STRING_.same_string (element_name, "script") or else
				 STRING_.same_string (element_name, "style")) then
				in_script := 0
			end
			check
				huge_element_nesting_level: in_script /= -1
			end
			in_script := in_script + 1
		end

	start_content is
			-- Notify the start of the content, that is, the completion of all attributes and namespaces.
		do
			close_start_tag ("", False) -- prevent <xxx/> syntax

			-- add a META tag after the HEAD tag if there is one.

			if not is_error and then element_uri_code = Default_uri_code and then STRING_.same_string (element_name, "head") then
				if output_properties.include_content_type then
					output_ignoring_error ("%N      <meta http-equiv=%"Content-Type%" content=%"" +
												  media_type + "; charset=" + encoding + "%">%N   ") 
				end
			end
		end

	end_element is
			-- Notify the end of an element.
		do
			in_script := in_script - 1

			if is_empty_tag (element_name) and then element_uri_code = Default_uri_code then
				element_qname_stack.remove
				element_name := STRING_.to_lower (element_qname_stack.item)
			else
				Precursor
			end
		end

	notify_characters (chars: STRING; properties: INTEGER) is
			-- Notify character data.
		local
			options: INTEGER
		do
			options := properties
			if in_script > 0 and then not is_output_escaping_disabled (properties) then
				options := options + Disable_escaping -- <script> and <style> contents must not be escaped
			end
			Precursor (chars, options)
		end

	notify_processing_instruction (a_name: STRING; a_data_string: STRING; properties: INTEGER) is
			-- Notify a processing instruction.
		local
			a_string: STRING
		do
			if not is_error then
				if not is_open then
					open_document
				end
				a_string := STRING_.concat ("<?", a_name)
				a_string := STRING_.appended_string (a_string, " ")
				a_string := STRING_.appended_string (a_string, a_data_string)
				a_string := STRING_.appended_string (a_string, ">")
				output (a_string)
			end
		end
	
feature {NONE} -- Implementation

	empty_tags_set: DS_HASH_SET [STRING] is
			-- Names of tags that should not be closed
		once
			create Result.make (13)
			Result.set_equality_tester (string_equality_tester)
		end
		
	boolean_attributes_set: DS_HASH_SET [STRING] is
			-- Names of attributes that are sometimes boolean valued

		once
			create Result.make (17)
			Result.set_equality_tester (string_equality_tester)
		end

	boolean_combinations_set: DS_HASH_SET [STRING] is
		-- Names of elements-attribute pairs that are boolean valued
		once
			create Result.make (24)
			Result.set_equality_tester (string_equality_tester)
		end

	url_attributes_set: DS_HASH_SET [STRING] is
			-- Names of attributes that are sometimes URL valued
		once
			create Result.make (12)
			Result.set_equality_tester (string_equality_tester)
		end

	url_combinations_set: DS_HASH_SET [STRING] is
		-- Names of elements-attribute pairs that are URL valued
		once
			create Result.make (27)
			Result.set_equality_tester (string_equality_tester)
		end

	media_type: STRING
			-- Mime type

	escape_uri_attributes: BOOLEAN
			-- Should the html and xhtml methods escape non-ASCII charaters in URI attribute values?

	Native_representation, Entity_representation, Decimal_representation, Hexadecimal_representation: INTEGER is unique
			-- Character representation methods
	
	non_ascii_representation: INTEGER
			-- Method for representing non-ASCII characters
	
	excluded_representation: INTEGER
			-- Method for representing characters excluded from the encoding

	in_script: INTEGER
			-- nested depth of elements withn script or style elements

	element_name: STRING
			-- Name of current element

	element_uri_code: INTEGER -- _16
			-- Namespace URI of current element

	latin1_entities: ARRAY [STRING] is
			-- latin-1 entity names
		once
			create Result.make (161, 255)
		end

	make_empty_tags_set is
			-- Build `empty_tags_set'.
		once
			if empty_tags_set.count = 0 then
				empty_tags_set.put ("area")
				empty_tags_set.put ("base")
				empty_tags_set.put ("basefont")
				empty_tags_set.put ("br")
				empty_tags_set.put ("col")
				empty_tags_set.put ("frame")
				empty_tags_set.put ("hr")
				empty_tags_set.put ("img")
				empty_tags_set.put ("input")
				empty_tags_set.put ("isindex")
				empty_tags_set.put ("link")
				empty_tags_set.put ("meta")
				empty_tags_set.put ("param")
			end
		end

	is_empty_tag (a_tag: STRING): BOOLEAN is
			-- Is `a_tag' an empty tag?
		require
			tag_not_void: a_tag /= Void
		do			
			Result := empty_tags_set.has (STRING_.to_lower (a_tag))
		end

	make_boolean_attributes_sets is
			-- Build sets for determinging boolean-valued attributes
		once
			if boolean_attributes_set.count = 0 then
				set_boolean_attribute ("area", "nohref")
				set_boolean_attribute ("button", "disabled")
				set_boolean_attribute ("dir", "compact")
				set_boolean_attribute ("dl", "compact")
				set_boolean_attribute ("frame", "noresize")
				set_boolean_attribute ("hr", "noshade")
				set_boolean_attribute ("img", "ismap")
				set_boolean_attribute ("input", "checked")
				set_boolean_attribute ("input", "disabled")
				set_boolean_attribute ("input", "readonly")
				set_boolean_attribute ("menu", "compact")
				set_boolean_attribute ("object", "declare")
				set_boolean_attribute ("ol", "compact")
				set_boolean_attribute ("optgroup", "disabled")
				set_boolean_attribute ("option", "selected")
				set_boolean_attribute ("option", "disabled")
				set_boolean_attribute ("script", "defer")
				set_boolean_attribute ("select", "multiple")
				set_boolean_attribute ("select", "disabled")
				set_boolean_attribute ("td", "nowrap")
				set_boolean_attribute ("textarea", "disabled")
				set_boolean_attribute ("textarea", "readonly")
				set_boolean_attribute ("th", "nowrap")
				set_boolean_attribute ("ul", "compact")
				end
		end

	set_boolean_attribute (an_element, an_attribute: STRING) is
			-- Mark `an_attribute' as boolean when used with `an_element'.
		require
			element_name_not_void: an_element /= Void
			attribute_name_not_void: an_attribute /= Void
		do
			if not boolean_attributes_set.has (STRING_.to_lower (an_attribute)) then
				boolean_attributes_set.put (STRING_.to_lower (an_attribute))
			end
			boolean_combinations_set.put (STRING_.to_lower (an_element + "+" + an_attribute))
		end

	is_boolean_attribute (an_element, an_attribute, a_value: STRING): BOOLEAN is
			-- Is `an_attribute' boolean valued?
		require
			element_name_not_void: an_element /= Void
			attribute_name_not_void: an_attribute /= Void
			value_not_void: a_value /= Void
		do
			if STRING_.same_case_insensitive (an_attribute, a_value) then
				if boolean_attributes_set.has (STRING_.to_lower (an_attribute)) then
					Result := boolean_combinations_set.has (STRING_.to_lower (an_element + "+" + an_attribute))
				end
			end
		end

	make_url_attributes is
			-- Build sets for determinging URL-valued attributes
		once
			if url_attributes_set.count = 0 then
				set_url_attribute ("form", "action")
				set_url_attribute ("body", "background")
				set_url_attribute ("q", "cite")
				set_url_attribute ("blockquote", "cite")
				set_url_attribute ("del", "cite")
				set_url_attribute ("ins", "cite")
				set_url_attribute ("object", "classid")
				set_url_attribute ("object", "codebase")
				set_url_attribute ("applet", "codebase")
				set_url_attribute ("object", "data")
				set_url_attribute ("a", "href")
				set_url_attribute ("a", "name")       -- see second note in section B.2.1 of HTML 4 specification
				set_url_attribute ("area", "href")
				set_url_attribute ("link", "href")
				set_url_attribute ("base", "href")
				set_url_attribute ("img", "longdesc")
				set_url_attribute ("frame", "longdesc")
				set_url_attribute ("iframe", "longdesc")
				set_url_attribute ("head", "profile")
				set_url_attribute ("script", "src")
				set_url_attribute ("input", "src")
				set_url_attribute ("frame", "src")
				set_url_attribute ("iframe", "src")
				set_url_attribute ("img", "src")
				set_url_attribute ("img", "usemap")
				set_url_attribute ("input", "usemap")
				set_url_attribute ("object", "usemap")
			end
		end

	set_url_attribute (an_element, an_attribute: STRING) is
			-- Mark `an_attribute' as url-valued when used with `an_element'.
		require
			element_name_not_void: an_element /= Void
			attribute_name_not_void: an_attribute /= Void
		do
			if not url_attributes_set.has (STRING_.to_lower (an_attribute)) then
				url_attributes_set.put (STRING_.to_lower (an_attribute))
			end
			url_combinations_set.put (STRING_.to_lower (an_element + "+" + an_attribute))
		end

	open_document is
			-- Open output document.
		local
			a_system_id, a_public_id: STRING
			a_character_representation, a_non_ascii_representation, an_excluded_representation: STRING
			an_index: INTEGER
		do
			encoding := STRING_.to_upper (output_properties.encoding)
			if not encoding.is_equal ("UTF-8") then
				on_error ("Only UTF-8 is supported as an encoding for the moment")
				encoding := "UTF-8"
			end

			outputter := encoder_factory.outputter (encoding, raw_outputter)
			if outputter = Void then
				on_error ("Unable to open output stream for encoding " + encoding)
			else
				is_open := True

				create media_type.make_from_string (output_properties.media_type)

				if output_properties.byte_order_mark_required then
					output_ignoring_error (byte_order_mark)
				end

				escape_uri_attributes := output_properties.escape_uri_attributes

				a_system_id := output_properties.doctype_system
				a_public_id := output_properties.doctype_public
				if a_system_id /= Void or else a_public_id /= Void then
					write_doctype ("html", a_system_id, a_public_id)
				end
				is_empty := False
				in_script := -1000000 -- safe to assume we will not increment up to zero!
	
				a_character_representation := output_properties.character_representation
				an_index := a_character_representation.index_of (';', 1)
				if an_index = 0 or else an_index = a_character_representation.count then
					a_non_ascii_representation := a_character_representation
					an_excluded_representation := a_character_representation
				else
					a_non_ascii_representation := a_character_representation.substring (1, an_index - 1)
					a_non_ascii_representation.left_adjust
					a_non_ascii_representation.right_adjust
					an_excluded_representation := a_character_representation.substring (an_index + 1, a_character_representation.count)
					an_excluded_representation.left_adjust
					an_excluded_representation.right_adjust
				end
				non_ascii_representation := representation_code (a_non_ascii_representation, False)
				excluded_representation := representation_code (an_excluded_representation, True)
			end
		end

	representation_code (a_representation: STRING; for_excluded: BOOLEAN): INTEGER is
			-- Representation code for character representations
		require
			representation_string_not_void: a_representation /= Void
		do
			if STRING_.same_string (a_representation, "decimal") then
				Result := Decimal_representation
			elseif STRING_.same_string (a_representation, "hex") then
				Result := Hexadecimal_representation
			elseif STRING_.same_string (a_representation, "native") and then not for_excluded then
				Result := Native_representation
			elseif STRING_.same_string (a_representation, "entity") and then not for_excluded then
				Result := Entity_representation
			else
				on_error ("Illegal value for gexslt:character-representation: " + a_representation)
			end
		end

	output_attribute (an_element_name_code: INTEGER; an_attribute_qname: STRING; a_value: STRING; properties: INTEGER) is
			-- Output attribute.
			-- Overrides the XML behaviour if the name and value are the same
			--  (we assume this is a boolean attribute to be minimised), or if the value is a URL.
		do
			if element_uri_code = Default_uri_code then
				if is_boolean_attribute (element_name, an_attribute_qname, a_value) then
					output (an_attribute_qname)
				elseif escape_uri_attributes and then
					is_url_attribute (element_name, an_attribute_qname) and then
					not is_output_escaping_disabled (properties) then
					Precursor (an_element_name_code, an_attribute_qname, escaped_url (a_value), 0)
				else
					Precursor (an_element_name_code, an_attribute_qname, a_value, properties)
				end
			end
		end

	hex_characters: STRING is "0123456789ABCDEF"
			-- Hexadecimal characters

	escaped_url (a_url: STRING): STRING is
			-- Escaped version of `a_url'.
		require
			url_not_void: a_url /= Void
		local
			an_index, a_code: INTEGER
		do
			create Result.make (a_url.count)
			from
				an_index := 1
			variant
				a_url.count + 1 - an_index
			until
				an_index > a_url.count
			loop
				a_code := a_url.item_code (an_index)
				if a_code < 32 or else a_code > 126 then
					todo ("escaped_url", True)
				else
					Result.append_character (a_url.item (an_index))
				end
				an_index := an_index + 1
			end
		ensure
			escaped_url_not_void: Result /= Void
		end

	output_escape (a_character_string: STRING; in_attribute: BOOLEAN) is
			-- Output `a_character_string', escaping special characters.
		local
			disabled: BOOLEAN
			a_start_index, a_beyond_index, a_code, another_code: INTEGER
			special_characters: ARRAY [BOOLEAN]
		do
			if in_attribute then
				special_characters := specials_in_attributes
			else
				special_characters := specials_in_text
			end
			from
				a_start_index := 1;
			variant
				a_character_string.count + 2 - a_start_index
			until
				a_start_index > a_character_string.count
			loop
				a_beyond_index := maximal_ordinary_string (a_character_string, a_start_index, special_characters)

				if a_beyond_index > a_start_index then
					output (a_character_string.substring (a_start_index, a_beyond_index - 1))
				end
				if a_beyond_index <= a_character_string.count then
					a_code := a_character_string.item_code (a_beyond_index)
					if a_code = 0 then -- enable/disable escaping toggle
						disabled := not disabled
					elseif disabled then
						output (a_character_string.substring (a_beyond_index, a_beyond_index))
					elseif a_code <= 127 then -- special ASCII
						if a_beyond_index = a_character_string.count then
							another_code := 0
						else
							another_code := a_character_string.item_code (a_beyond_index + 1)
						end
						output_special_ascii (a_code, another_code, in_attribute)
					elseif a_code = 160 then
						output ("&nbsp;")
					else
						--elseif a_code >= 55296 and then a_code <= 56319 then
						todo ("output_escape (surroagtes)", True)
						if not outputter.is_bad_character_code (a_code) then
							output_non_ascii (a_code, in_attribute)
						else
							is_hex_preferred := excluded_representation = Hexadecimal_representation
							output_character_reference (a_code)
						end
					end
				end
				a_start_index := a_beyond_index + 1
			end
		end

	output_special_ascii (a_character_code, a_second_character_code: INTEGER; in_attribute: BOOLEAN) is
			-- Output `a_character_code'.
		do
			if in_attribute then
				if a_character_code = 60 then
					output ("<")                    -- not escaped
				elseif a_character_code = 62 then
					output ("&gt;")                 -- recommended for older browsers
				elseif a_character_code = 38 then
					if a_second_character_code = 40 then
						output ("&")                 -- not escaped if followed by '{'
					else
						output ("&amp;")
					end
				elseif a_character_code = 34 then
					output ("&#34;")                -- double quote
				elseif a_character_code = 10 then
					output ("&#xA;")                -- LF
				elseif a_character_code = 13 then
					output ("&#xD;")                -- CR
				elseif a_character_code = 9 then
					output ("&#9;")                 -- TAB					
				end
			else -- not in attribute
				if a_character_code = 60 then
					output ("&lt;")                
				elseif a_character_code = 62 then
					output ("&gt;")                 -- changed to allow for "]]>" ???
				elseif a_character_code = 38 then
					output ("&amp;")
				elseif a_character_code = 13 then
					output ("&#xD;")                -- CR
				end
			end
		end

	output_non_ascii (a_character_code: INTEGER; in_attribute: BOOLEAN) is
			-- Output non-ASCII character.
		require
			non_ascii_character: a_character_code > 127
		do
			inspect
				non_ascii_representation
			when Native_representation then
				output (code_to_string (a_character_code))
			when Entity_representation then
				if a_character_code > 160 and then a_character_code <= 255 then

					-- if chararacter in iso-8859-1, use an entity reference

					output ("&")
					if not is_error then output (latin1_entities.item (a_character_code)) end
					if not is_error then output (";") end
				else
					output_character_reference (a_character_code)
				end
			when Decimal_representation then
				is_hex_preferred := False
				output_character_reference (a_character_code)
			when Hexadecimal_representation then
				is_hex_preferred := True
				output_character_reference (a_character_code)
			end
		end
		
	maximal_ordinary_string (a_character_string: STRING; a_start_index: INTEGER; special_characters: ARRAY [BOOLEAN]): INTEGER is
			-- Maximal sequence of ordinary characters
		local
			an_index, a_code: INTEGER
			finished: BOOLEAN
		do
			from
				an_index := a_start_index
			until
				finished or else an_index > a_character_string.count
			loop
				a_code := a_character_string.item_code (an_index)
				if a_code < 128 then -- ASCII
					if special_characters.item (a_code) then
						finished := True
					else
						an_index := an_index + 1
					end
				else
					if not outputter.is_bad_character_code (a_code) then
						if non_ascii_representation = Native_representation and then
							a_code /= 160 then
							an_index := an_index + 1
						else
							finished := True
						end
					else
						finished := True
					end
				end
			end
			Result := an_index
		end

	make_entities is
			-- Create Latin-1 entity array.
		once
			if latin1_entities.count = 0 then
				latin1_entities.put ("iexcl", 161)
				latin1_entities.put ("cent", 162)
				latin1_entities.put ("pound", 163)
				latin1_entities.put ("curren", 164)
				latin1_entities.put ("yen", 165)
				latin1_entities.put ("brvbar", 166)
				latin1_entities.put ("sect", 167)
				latin1_entities.put ("uml", 168)
				latin1_entities.put ("copy", 169)
				latin1_entities.put ("ordf", 170)
				latin1_entities.put ("laquo", 171)
				latin1_entities.put ("not", 172)
				latin1_entities.put ("shy", 173)
				latin1_entities.put ("reg", 174)
				latin1_entities.put ("macr", 175)
				latin1_entities.put ("deg", 176)
				latin1_entities.put ("plusmn", 177)
				latin1_entities.put ("sup2", 178)
				latin1_entities.put ("sup3", 179)
				latin1_entities.put ("acute", 180)
				latin1_entities.put ("micro", 181)
				latin1_entities.put ("para", 182)
				latin1_entities.put ("middot", 183)
				latin1_entities.put ("cedil", 184)
				latin1_entities.put ("sup1", 185)
				latin1_entities.put ("ordm", 186)
				latin1_entities.put ("raquo", 187)
				latin1_entities.put ("frac14", 188)
				latin1_entities.put ("frac12", 189)
				latin1_entities.put ("frac34", 190)
				latin1_entities.put ("iquest", 191)
				latin1_entities.put ("Agrave", 192)
				latin1_entities.put ("Aacute", 193)
				latin1_entities.put ("Acirc", 194)
				latin1_entities.put ("Atilde", 195)
				latin1_entities.put ("Auml", 196)
				latin1_entities.put ("Aring", 197)
				latin1_entities.put ("AElig", 198)
				latin1_entities.put ("Ccedil", 199)
				latin1_entities.put ("Egrave", 200)
				latin1_entities.put ("Eacute", 201)
				latin1_entities.put ("Ecirc", 202)
				latin1_entities.put ("Euml", 203)
				latin1_entities.put ("Igrave", 204)
				latin1_entities.put ("Iacute", 205)
				latin1_entities.put ("Icirc", 206)
				latin1_entities.put ("Iuml", 207)
				latin1_entities.put ("ETH", 208)
				latin1_entities.put ("Ntilde", 209)
				latin1_entities.put ("Ograve", 210)
				latin1_entities.put ("Oacute", 211)
				latin1_entities.put ("Ocirc", 212)
				latin1_entities.put ("Otilde", 213)
				latin1_entities.put ("Ouml", 214)
				latin1_entities.put ("times", 215)
				latin1_entities.put ("Oslash", 216)
				latin1_entities.put ("Ugrave", 217)
				latin1_entities.put ("Uacute", 218)
				latin1_entities.put ("Ucirc", 219)
				latin1_entities.put ("Uuml", 220)
				latin1_entities.put ("Yacute", 221)
				latin1_entities.put ("THORN", 222)
				latin1_entities.put ("szlig", 223)
				latin1_entities.put ("agrave", 224)
				latin1_entities.put ("aacute", 225)
				latin1_entities.put ("acirc", 226)
				latin1_entities.put ("atilde", 227)
				latin1_entities.put ("auml", 228)
				latin1_entities.put ("aring", 229)
				latin1_entities.put ("aelig", 230)
				latin1_entities.put ("ccedil", 231)
				latin1_entities.put ("egrave", 232)
				latin1_entities.put ("eacute", 233)
				latin1_entities.put ("ecirc", 234)
				latin1_entities.put ("euml", 235)
				latin1_entities.put ("igrave", 236)
				latin1_entities.put ("iacute", 237)
				latin1_entities.put ("icirc", 238)
				latin1_entities.put ("iuml", 239)
				latin1_entities.put ("eth", 240)
				latin1_entities.put ("ntilde", 241)
				latin1_entities.put ("ograve", 242)
				latin1_entities.put ("oacute", 243)
				latin1_entities.put ("ocirc", 244)
				latin1_entities.put ("otilde", 245)
				latin1_entities.put ("ouml", 246)
				latin1_entities.put ("divide", 247)
				latin1_entities.put ("oslash", 248)
				latin1_entities.put ("ugrave", 249)
				latin1_entities.put ("uacute", 250)
				latin1_entities.put ("ucirc", 251)
				latin1_entities.put ("uuml", 252)
				latin1_entities.put ("yacute", 253)
				latin1_entities.put ("thorn", 254)
				latin1_entities.put ("yuml", 255)
			end
		end

invariant

	empty_tags_set_not_void: empty_tags_set /= Void
	boolean_combinations_set_not_void: boolean_combinations_set /= Void
	boolean_attributes_set_not_void: boolean_attributes_set /= Void
	url_combinations_set_not_void: url_combinations_set /= Void
	url_attributes_set_not_void: url_attributes_set /= Void	

end
	
