indexing

	description:

		"Getest tasks"

	library:    "Gobo Eiffel Ant"
	author:     "Sven Ehrke <sven.ehrke@sven-ehrke.de>"
	copyright:  "Copyright (c) 2001, Sven Ehrke and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date$"
	revision:   "$Revision$"


class GEANT_GETEST_TASK

inherit

	GEANT_TASK
		undefine
			make
		redefine
			make_from_element
		end

	GEANT_GETEST_COMMAND

creation

	make_from_element

feature {NONE} -- Initialization

	make_from_element (a_project: GEANT_PROJECT; an_element: GEANT_ELEMENT) is
			-- Create a new task with information held in `an_element'.
		local
			a_name, a_value: STRING
			i, nb: INTEGER
			define_elements: DS_ARRAYED_LIST [GEANT_ELEMENT]
			define_element: GEANT_ELEMENT
		do
			precursor (a_project, an_element)
			if has_uc_attribute (an_element, Config_filename_attribute_name) then
				a_value := uc_attribute_value (an_element, Config_filename_attribute_name).out
				if a_value.count > 0 then
					set_config_filename (a_value)
				end
			end
			if has_uc_attribute (an_element, Compile_attribute_name) then
				a_value := uc_attribute_value (an_element, Compile_attribute_name).out
				set_compile (a_value)
			end
				-- define:
			define_elements := an_element.children_by_name (Define_element_name)
			nb := define_elements.count
			from i := 1 until i > nb loop
				define_element := define_elements.item (i)
				if is_element_enabled (project, define_element) and then
					has_uc_attribute (define_element, Name_attribute_name) and then
					has_uc_attribute (define_element, Value_attribute_name)
				then
					a_name := uc_attribute_value (define_element, Name_attribute_name).out
					a_value := uc_attribute_value (define_element, Value_attribute_name).out
					if a_name.count > 0 then
						defines.force (a_value, a_name)
					end
				end
				i := i + 1
			end
		end

feature {NONE} -- Constants

	Config_filename_attribute_name : UC_STRING is
			-- Name of xml attribute for getest config_filename
		once
			!! Result.make_from_string ("config")
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: not Result.empty
		end

	Compile_attribute_name : UC_STRING is
			-- Name of xml attribute for getest 'compile'
		once
			!! Result.make_from_string ("compile")
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: not Result.empty
		end

	Define_element_name: UC_STRING is
			-- Name of xml subelement for defines
		once
			!! Result.make_from_string ("define")
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: not Result.empty
		end

	Value_attribute_name: UC_STRING is
			-- Name of xml attribute "value" of subelement <define>
		once
			!! Result.make_from_string ("value")
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: not Result.empty
		end

end -- class GEANT_GETEST_TASK
