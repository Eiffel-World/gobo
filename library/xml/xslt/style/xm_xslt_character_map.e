indexing

	description:

		"xsl:charachter-map element nodes"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_CHARACTER_MAP

inherit

	XM_XSLT_STYLE_ELEMENT
		redefine
			validate
		end

creation

	make_style_element

feature -- Access

	character_map_fingerprint: INTEGER
			-- Fingerprint of name attribute

	used_character_maps: STRING
			-- Value of 'use-character-maps' attribute

	character_maps_used: DS_ARRAYED_LIST [XM_XSLT_CHARACTER_MAP]
			-- Characters maps used by `Current'

feature -- Status report

	is_redundant: BOOLEAN
			-- Is `Current' redundant?

feature -- Element change

	prepare_attributes is
			-- Set the attribute list for the element.
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [INTEGER]
			a_name_code: INTEGER
			an_expanded_name, a_name_attribute: STRING
			an_error: XM_XPATH_ERROR_VALUE
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
				if STRING_.same_string (an_expanded_name, Name_attribute) then
					a_name_attribute := attribute_value_by_index (a_cursor.index)
					STRING_.left_adjust (a_name_attribute)
					STRING_.right_adjust (a_name_attribute)
				elseif STRING_.same_string (an_expanded_name, Use_character_maps_attribute) then
					used_character_maps := attribute_value_by_index (a_cursor.index)
					STRING_.left_adjust (used_character_maps)
					STRING_.right_adjust (used_character_maps)
				else
					check_unknown_attribute (a_name_code)
				end
				a_cursor.forth
			end
			if a_name_attribute = Void then
				report_absence ("name")
			else
				generate_name_code (a_name_attribute)
				character_map_fingerprint := last_generated_name_code
				if character_map_fingerprint = -1 then
					create an_error.make_from_string ("Name attribute of xsl:character-map is not a lexical QName", "", "XT0280", Static_error)
					report_compile_error (an_error)
				else
					character_map_fingerprint := shared_name_pool.fingerprint_from_name_code (character_map_fingerprint)
				end
			end
			attributes_prepared := True
		end

	validate is
			-- Check that the stylesheet element is valid.
		local
			a_child_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
			an_output_character: XM_XSLT_OUTPUT_CHARACTER
			a_stylesheet: XM_XSLT_STYLESHEET
			another_character_map: like Current
			a_splitter: ST_SPLITTER
			character_maps, qname_parts: DS_LIST [STRING]
			a_cursor: DS_LIST_CURSOR [STRING]
			a_uri, a_local_name, an_xml_prefix, a_message: STRING
			a_name_code: INTEGER
			another_cursor: DS_ARRAYED_LIST_CURSOR [XM_XSLT_CHARACTER_MAP]
			an_error: XM_XPATH_ERROR_VALUE
		do
			if not validated then
				check_top_level
				from
					a_child_iterator := new_axis_iterator (Child_axis)
					a_child_iterator.start
				until
					any_compile_errors or else a_child_iterator.after
				loop
					an_output_character ?= a_child_iterator.item
					if an_output_character = Void then
						create an_error.make_from_string ("Only xsl:output-character is allowed within xsl:character-map", "", "XT0010", Static_error)
						report_compile_error (an_error)
					end
					a_child_iterator.forth
				end

				-- Check that there isn't another character-map with the same name and import precedence.

				a_stylesheet := principal_stylesheet
				another_character_map := a_stylesheet.character_map (character_map_fingerprint)
				if another_character_map /= Current then
					if precedence = another_character_map.precedence then
						create an_error.make_from_string ("There are two character-maps with the same name and import precedence", "", "XT1580", Static_error)
						report_compile_error (an_error)
					else
						if precedence < another_character_map.precedence then
							is_redundant := True
						end
					end
				end

				if used_character_maps /= Void then

					-- Identify any character maps to which `Current' refers.

					create a_splitter.make
					character_maps := a_splitter.split (used_character_maps)
					create character_maps_used.make (character_maps.count)
					a_splitter.set_separators (":")
					from
						a_cursor := character_maps.new_cursor; a_cursor.start
					variant
						character_maps.count + 1 - a_cursor.index
					until
						a_cursor.after
					loop
						qname_parts := a_splitter.split (a_cursor.item)
						if qname_parts.count = 0 or else qname_parts.count > 2 then
							create an_error.make_from_string (STRING_.concat ("Invalid character-map name: ", a_cursor.item), "", "XT1590", Static_error)
							report_compile_error (an_error)
							a_cursor.go_after
						else
							if qname_parts.count = 1 then
								a_uri := ""
								an_xml_prefix := ""
								a_local_name := qname_parts.item (1)
							else
								an_xml_prefix := qname_parts.item (1)
								a_uri := uri_for_prefix (an_xml_prefix, False)
								a_local_name := qname_parts.item (2)
							end
							if shared_name_pool.is_name_code_allocated (an_xml_prefix, a_uri, a_local_name) then
								a_name_code := shared_name_pool.name_code (an_xml_prefix, a_uri, a_local_name)
							else
								shared_name_pool.allocate_name (an_xml_prefix, a_uri, a_local_name)
								a_name_code := shared_name_pool.last_name_code
							end
							if a_name_code = -1 then
								create an_error.make_from_string (STRING_.concat ("Invalid character-map name: ", a_cursor.item), "", "XT1590", Static_error)
								report_compile_error (an_error)
								a_cursor.go_after
							else
								a_name_code := shared_name_pool.fingerprint_from_name_code (a_name_code)
								another_character_map := a_stylesheet.character_map (a_name_code)
								if another_character_map = Void then
									a_message := STRING_.concat ("No character map named ", shared_name_pool.display_name_from_name_code (a_name_code))
									a_message := STRING_.appended_string (a_message, "has been defined.")
									create an_error.make_from_string (a_message, "", "XT1590", Static_error)
									report_compile_error (an_error)

									a_cursor.go_after
								else
									character_maps_used.put_last (another_character_map)
									a_cursor.forth
								end
							end
						end
					end

					-- Check for circularity.

					from
						another_cursor := character_maps_used.new_cursor; another_cursor.start
					variant
						character_maps_used.count + 1 - another_cursor.index
					until
						another_cursor.after
					loop
						another_cursor.item.check_circularity (Current)
						if any_compile_errors then
							another_cursor.go_after
						else
							another_cursor.forth
						end
					end
				end
				validated := True
			end
		end

	compile (an_executable: XM_XSLT_EXECUTABLE) is
			-- Compile `Current' to an excutable instruction.
		do
			last_generated_instruction := Void
		end

	assemble (a_map: DS_HASH_TABLE [STRING, INTEGER]) is
			-- Assemble all the mappings defined by `Current' into `a_map'.
		require
			map_not_void: a_map /= Void
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XSLT_CHARACTER_MAP]
			an_output_character: XM_XSLT_OUTPUT_CHARACTER
			a_child_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
		do
			if character_maps_used /= Void then
				from
					a_cursor := character_maps_used.new_cursor; a_cursor.start
				variant
					character_maps_used.count + 1 - a_cursor.index
				until
					a_cursor.after
				loop
					a_cursor.item.assemble (a_map)
					a_cursor.forth
				end
			end
			from
				a_child_iterator := new_axis_iterator (Child_axis)
				a_child_iterator.start
			until
				a_child_iterator.after
			loop
				an_output_character ?= a_child_iterator.item
				check
					output_character_not_void: an_output_character /= Void
					-- Validate ensured this
				end
				a_map.force (an_output_character.replacement_string, an_output_character.code_point)
				a_child_iterator.forth
			end
		end

feature {XM_XSLT_CHARACTER_MAP} -- Implementation

	check_circularity (origin: like Current) is
			-- Check for any cirular references to `Current'.
		require
			other_character_map_not_void: origin /= Void
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XSLT_CHARACTER_MAP]
			an_error: XM_XPATH_ERROR_VALUE
		do
			if Current = origin then
				create an_error.make_from_string ("xsl:character-map definition is circular", "", "XT1600", Static_error)
				report_compile_error (an_error)
			else
				if validated then
					from
						a_cursor := character_maps_used.new_cursor; a_cursor.start
					variant
						character_maps_used.count + 1 - a_cursor.index
					until
						a_cursor.after
					loop
						a_cursor.item.check_circularity (origin)
						if any_compile_errors then
							a_cursor.go_after
						else
							a_cursor.forth
						end
					end
				else
					
					-- The circularity will be detected when the last character-map in the cycle gets validated
					
				end
			end
		end

end
