indexing

	description:

		"Getest tasks"

	library: "Gobo Eiffel Ant"
	copyright: "Copyright (c) 2001, Sven Ehrke and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class GEANT_GETEST_TASK

inherit

	GEANT_TASK
		rename
			make as task_make
		redefine
			command
		end

creation

	make

feature {NONE} -- Initialization

	make (a_project: GEANT_PROJECT; an_xml_element: XM_ELEMENT) is
			-- Create a new task with information held in `an_element'.
		local
			a_name, a_value: STRING
			define_elements: DS_LINKED_LIST [XM_ELEMENT]
			cs: DS_LINKED_LIST_CURSOR [XM_ELEMENT]
			define_element: GEANT_DEFINE_ELEMENT
		do
			!! command.make (a_project)
			task_make (command, an_xml_element)
			if has_attribute (Config_filename_attribute_name) then
				a_value := attribute_value (Config_filename_attribute_name)
				if a_value.count > 0 then
					command.set_config_filename (a_value)
				end
			end
			if has_attribute (Compile_attribute_name) then
				a_value := attribute_value (Compile_attribute_name)
				command.set_compile (a_value)
			end
			if has_attribute (Class_attribute_name) then
				a_value := attribute_value (Class_attribute_name)
				command.set_class_regexp (a_value)
			end
			if has_attribute (Feature_attribute_name) then
				a_value := attribute_value (Feature_attribute_name)
				command.set_feature_regexp (a_value)
			end
				-- define:
			define_elements := elements_by_name (Define_element_name)
			cs := define_elements.new_cursor
			from cs.start until cs.after loop
				create define_element.make (project, cs.item)
				if
					define_element.is_enabled and then
					define_element.has_name and then
					define_element.has_value
				then
					a_name := define_element.name
					a_value := define_element.value
					if a_name.count > 0 then
						command.defines.force (a_value, a_name)
					end
				end
				cs.forth
			end
		end

feature -- Access

	command: GEANT_GETEST_COMMAND
			-- Getest commands

feature {NONE} -- Constants

	Config_filename_attribute_name: STRING is
			-- Name of xml attribute for getest config_filename
		once
			Result := "config"
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Compile_attribute_name: STRING is
			-- Name of xml attribute for getest 'compile'
		once
			Result := "compile"
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Class_attribute_name: STRING is
			-- Name of xml attribute for getest 'class'
		once
			Result := "class"
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Feature_attribute_name: STRING is
			-- Name of xml attribute for getest 'feature'
		once
			Result := "feature"
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Define_element_name: STRING is
			-- Name of xml subelement for defines
		once
			Result := "define"
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Value_attribute_name: STRING is
			-- Name of xml attribute "value" of subelement <define>
		once
			Result := "value"
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

end
