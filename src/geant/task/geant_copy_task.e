indexing

	description:

		"Copy tasks"

	library: "Gobo Eiffel Ant"
	copyright: "Copyright (c) 2001, Sven Ehrke and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class GEANT_COPY_TASK

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

	make (a_project: GEANT_PROJECT; a_xml_element: XM_ELEMENT) is
			-- Create a new task with information held in `an_element'.
		local
			a_value: STRING
			a_xml_subelement: XM_ELEMENT
			a_fs_element: GEANT_FILESET_ELEMENT
		do
			!! command.make (a_project)
			task_make (command, a_xml_element)
			if has_attribute (File_attribute_name) then
				a_value := attribute_value (File_attribute_name.out)
				if a_value.count > 0 then
					command.set_file (a_value.out)
				end
			end

			if has_attribute (To_file_attribute_name) then
				a_value := attribute_value (To_file_attribute_name.out)
				if a_value.count > 0 then
					command.set_to_file (a_value.out)
				end
			end

			if has_attribute (To_directory_attribute_name) then
				a_value := attribute_value (To_directory_attribute_name.out)
				if a_value.count > 0 then
					command.set_to_directory (a_value.out)
				end
			end

			if has_attribute (Force_attribute_name) then
				command.set_force (boolean_value (Force_attribute_name))
			end

			a_xml_subelement := xml_element.element_by_name (Fileset_element_name)
			if a_xml_subelement /= Void then
				!! a_fs_element.make (project, a_xml_subelement)
				command.set_fileset (a_fs_element.fileset)
			end

		end

feature -- Access

	command: GEANT_COPY_COMMAND
			-- Copy commands

feature {NONE} -- Constants

	File_attribute_name: STRING is
			-- Name of xml attribute file.
		once
			Result := "file"
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	To_file_attribute_name: STRING is
			-- Name of xml attribute to_file.
		once
			Result := "to_file"
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end
		
	To_directory_attribute_name: STRING is
			-- Name of xml attribute to_directory.
		once
			Result := "to_directory"
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Force_attribute_name: STRING is
			-- Name of xml attribute for force
		once
			Result := "force"
		ensure
			attribute_name_not_void: Result /= Void
			atribute_name_not_empty: Result.count > 0
		end

	Fileset_element_name: STRING is
			-- Name of xml subelement for fileset
		once
			Result := "fileset"
		ensure
			element_name_not_void: Result /= Void
			element_name_not_empty: Result.count > 0
		end

end
