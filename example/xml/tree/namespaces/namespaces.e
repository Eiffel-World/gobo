indexing

	description:

		"Reports information about Namespace declarations in XML files"

	library: "Gobo Eiffel XML Library"
	copyright: "Copyright (c) 2001, Andreas Leitner and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class NAMESPACES

inherit

	KL_SHARED_ARGUMENTS
	KL_SHARED_STANDARD_FILES

creation

	make

feature {NONE} -- Initialization

	make is
			-- Run.
		do
			Arguments.set_program_name ("namespaces")
			!! error_handler.make_standard
			process_arguments
			if not has_error then
				process_data_file
			end
		end

feature -- Processing

	process_data_file is
			-- Parse file.
		local
			formatter: NS_FORMATTER
			in: KL_TEXT_INPUT_FILE
			cannot_read: UT_CANNOT_READ_FILE_ERROR
		do
			error_handler.report_info_message ("parsing data...")
			!! in.make (filename)
			in.open_read
			if not in.is_open_read then
				!! cannot_read.make (filename)
				error_handler.report_error (cannot_read)
				has_error := True
			else
				event_parser.parse_from_stream (in)
				in.close
				if tree_pipe.error.has_error then
					error_handler.report_error_message (tree_pipe.last_error)
					has_error := True
				else
					tree_pipe.document.root_element.resolve_namespaces_start
					tree_pipe.document.root_element.remove_namespace_declarations_from_attributes
					error_handler.report_info_message ("printing document...")
					!! formatter.make
					formatter.process_document (tree_pipe.document)
					std.output.put_string (formatter.last_string)
					std.output.put_new_line
				end
			end
			error_handler.report_info_message ("exiting...")
		end

	process_arguments is
			-- Read command line arguments.
		local
			parser_switch: STRING
		do
			if Arguments.argument_count /= 2 then
				error_handler.report_error (Usage_message)
				has_error := True
			else
				parser_switch := Arguments.argument (1)
				if parser_switch.is_equal ("--expat") then
					if not fact.is_expat_available then
						error_handler.report_error_message ("expat is not availabe, please choose other parser backend")
						has_error := True
					else
						event_parser := fact.new_expat_parser
					end
				else
					!XM_EIFFEL_PARSER! event_parser.make
				end
					-- Create and bind tree pipe.
				!! tree_pipe.make
				event_parser.set_callbacks (tree_pipe.start)
				filename := Arguments.argument (2)
			end
		ensure
			filename_not_void: not has_error implies filename /= Void
			parser_not_void: not has_error implies event_parser /= Void
		end

feature -- Parser

	fact: XM_EXPAT_PARSER_FACTORY is
			-- Expat XML parser factory
		once
			!! Result
		ensure
			factory_not_void: Result /= Void
		end

	event_parser: XM_PARSER
			-- XML parser

	tree_pipe: XM_TREE_CALLBACKS_PIPE
			-- Tree generating callbacks

feature -- Access

	filename: STRING
			-- File name

	has_error: BOOLEAN
			-- Error status

	error_handler: UT_ERROR_HANDLER
			-- Error handler

feature {NONE} -- Implementation

	Usage_message: UT_USAGE_MESSAGE is
			-- Usage message
		local
			a_message: STRING
		once
			a_message := clone ("(")
			if fact.is_expat_available then
				a_message.append_string ("--expat|")
			end
			a_message.append_string ("--eiffel) <input-file>")
			!! Result.make (a_message)
		ensure
			usage_message_not_void: Result /= Void
		end

invariant

	error_handler_not_void: error_handler /= Void

end
