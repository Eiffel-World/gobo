indexing

	description:

		"Gobo Eiffel Test"

	copyright: "Copyright (c) 2000-2001, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class GETEST

inherit

	GETEST_VERSION

	KL_SHARED_EXCEPTIONS
	KL_SHARED_ARGUMENTS
	KL_SHARED_STANDARD_FILES
	KL_SHARED_EXECUTION_ENVIRONMENT

creation

	execute

feature -- Processing

	execute is
			-- Start 'getest' execution.
		local
			a_config: TS_CONFIG
			config_parser: TS_CONFIG_PARSER
			a_file: KL_TEXT_INPUT_FILE
			cannot_read: UT_CANNOT_READ_FILE_ERROR
		do
			Arguments.set_program_name ("getest")
			!! variables.make
			!! error_handler.make_standard
			read_command_line
			!! a_file.make (config_filename)
			a_file.open_read
			if a_file.is_open_read then
				if must_generate then
					std.output.put_line ("Preparing Test Cases")
				elseif must_compile then
					std.output.put_line ("Compiling Test Cases")
				elseif must_execute then
					std.output.put_line ("Running Test Cases")
					std.output.put_new_line
				end
				!! config_parser.make (variables, error_handler)
				config_parser.set_fail_on_rescue (fail_on_rescue)
				config_parser.set_compiler_ise (compiler_ise)
				config_parser.set_compiler_hact (compiler_hact)
				config_parser.set_compiler_se (compiler_se)
				config_parser.set_compiler_ve (compiler_ve)
				config_parser.parse (a_file)
				a_file.close
				a_config := config_parser.last_config
				if compile_command /= Void then
					a_config.set_compile (compile_command)
				end
				process (a_config)
				if error_handler.error_reported then
					Exceptions.die (1)
				end
			else
				!! cannot_read.make (config_filename)
				error_handler.report_error (cannot_read)
				Exceptions.die (1)
			end
		end

	process (a_config: TS_CONFIG) is
			-- Process `a_config'.
		require
			a_config_not_void: a_config /= Void
		do
			if must_generate then
				generate_test (a_config, False)
			end
			if must_compile then
				compile_test (a_config, must_generate)
			end
			if must_execute then
				run_test (a_config, must_generate or must_compile)
			end
		end

	generate_test (a_config: TS_CONFIG; need_header: BOOLEAN) is
			-- Generate Eiffel classes.
		require
			a_config_not_void: a_config /= Void
		local
			testcases: TS_TESTCASES
		do
			if not error_handler.error_reported then
				if need_header then
					std.output.put_line ("Preparing Test Cases")
				end
				!! testcases.make (a_config.testgen, error_handler)
				a_config.process (testcases, error_handler)
				testcases.generate_test_classes
				testcases.generate_root_class (a_config.root_class)
			end
		end

	compile_test (a_config: TS_CONFIG; need_header: BOOLEAN) is
			-- Compile generated testcases.
		require
			a_config_not_void: a_config /= Void
		local
			a_command: DP_SHELL_COMMAND
			a_command_name: STRING
		do
			if not error_handler.error_reported then
				if need_header then
					std.output.put_line ("Compiling Test Cases")
				end
				a_command_name := a_config.compile
				if a_command_name.count > 0 then
					std.output.flush
					!! a_command.make (a_command_name)
					a_command.execute
					if a_command.exit_code /= 0 then
						report_eiffel_compilation_error
					end
				end
			end
		end

	run_test (a_config: TS_CONFIG; need_header: BOOLEAN) is
			-- Execute generated testcases.
		require
			a_config_not_void: a_config /= Void
		local
			a_command: DP_SHELL_COMMAND
			a_command_name: STRING
		do
			if not error_handler.error_reported then
				if need_header then
					std.output.put_line ("Running Test Cases")
					std.output.put_new_line
				end
				a_command_name := a_config.execute
				if a_command_name.count > 0 then
					std.output.flush
					!! a_command.make (a_command_name)
					a_command.execute
					if a_command.exit_code /= 0 then
						Exceptions.die (1)
					end
				end
			end
		end

feature -- Access

	config_filename: STRING
			-- Configuration filename

	compile_command: STRING
			-- Compilation command-line given with
			-- the option --compile=...

	variables: TS_VARIABLES
			-- Defined variables

	error_handler: TS_ERROR_HANDLER
			-- Error handler

feature -- Status report

	must_generate: BOOLEAN
			-- Should the Eiffel classes be generated?

	must_compile: BOOLEAN
			-- Should the testcases be compiled?

	must_execute: BOOLEAN
			-- Should the testcases be executed?

	compiler_ise: BOOLEAN
	compiler_hact: BOOLEAN
	compiler_se: BOOLEAN
	compiler_ve: BOOLEAN
			-- Compiler specified on the command-line
			-- (--ise, --hact, --se or --ve)

	compiler_specified: BOOLEAN is
			-- Has an Eiffel compiler been specified on the command-line?
			-- (--ise, --hact, --se or --ve)
		do
			Result := (compiler_ise or compiler_hact or compiler_se or compiler_ve)
		ensure
			definition: Result = (compiler_ise or compiler_hact or compiler_se or compiler_ve)
		end

	fail_on_rescue: BOOLEAN
			-- Should the test application crash when an error occur?
			-- (By default test case errors are caught by a rescue
			-- clause and reported to the result summary, but during
			-- debugging it might be useful to get the full exception
			-- trace.)

feature {NONE} -- Command line

	read_command_line is
			-- Read command line arguments.
		local
			i, nb: INTEGER
			arg: STRING
			a_file: KL_TEXT_INPUT_FILE
		do
			nb := Arguments.argument_count
			from i := 1 until i > nb loop
				arg := Arguments.argument (i)
				if arg.is_equal ("--version") or arg.is_equal ("-V") then
					report_version_number
				elseif arg.is_equal ("--help") or arg.is_equal ("-h") or arg.is_equal ("-?") then
					report_usage_message
				elseif arg.is_equal ("--se") then
					if compiler_specified then
						report_usage_error
					else
						compiler_se := True
					end
				elseif arg.is_equal ("--ise") then
					if compiler_specified then
						report_usage_error
					else
						compiler_ise := True
					end
				elseif arg.is_equal ("--hact") then
					if compiler_specified then
						report_usage_error
					else
						compiler_hact := True
					end
				elseif arg.is_equal ("--ve") then
					if compiler_specified then
						report_usage_error
					else
						compiler_ve := True
					end
				elseif arg.count >= 9 and then arg.substring (1, 9).is_equal ("--define=") then
					if arg.count > 9 then
						set_defined_variable (arg.substring (10, arg.count))
					else
						report_usage_error
					end
				elseif arg.is_equal ("-D") then
					i := i + 1
					if i <= nb then
						arg := Arguments.argument (i)
						set_defined_variable (arg)
					else
						report_usage_error
					end
				elseif arg.count >= 10 and then arg.substring (1, 10).is_equal ("--compile=") then
					if arg.count > 10 then
						compile_command := arg.substring (11, arg.count)
					else
						report_usage_error
					end
				elseif arg.is_equal ("-g") then
					must_generate := True
				elseif arg.is_equal ("-c") then
					must_compile := True
				elseif arg.is_equal ("-e") then
					must_execute := True
				elseif arg.is_equal ("-a") then
					fail_on_rescue := True
				elseif i = nb then
					if config_filename /= Void then
						report_usage_error
					else
						config_filename := arg
					end
				else
					report_usage_error
				end
				i := i + 1
			end
			if config_filename = Void then
				if compiler_ise then
					!! a_file.make (ISE_config_filename)
					if a_file.exists then
						config_filename := ISE_config_filename
					end
				elseif compiler_hact then
					!! a_file.make (HACT_config_filename)
					if a_file.exists then
						config_filename := HACT_config_filename
					end
				elseif compiler_se then
					!! a_file.make (SE_config_filename)
					if a_file.exists then
						config_filename := SE_config_filename
					end
				elseif compiler_ve then
					!! a_file.make (VE_config_filename)
					if a_file.exists then
						config_filename := VE_config_filename
					end
				end
			end
			if config_filename = Void then
				!! a_file.make (cfg_config_filename)
				if a_file.exists then
					config_filename := cfg_config_filename
				end
			end
			if config_filename = Void then
				config_filename := Execution_environment.variable_value (Getest_config_variable)
				if config_filename = Void or else config_filename.count = 0 then
					report_undefined_environment_variable_error (Getest_config_variable)
				end
			end
			if not (must_generate or must_compile or must_execute) then
				must_generate := True
				must_compile := True
				must_execute := True
			end
		ensure
			config_filename_not_void: config_filename /= Void
		end

	set_defined_variable (arg: STRING) is
			-- Set variable defined in `arg' with format <name>[=<value>].
			-- Report usage error if invalid.
		require
			arg_not_void: arg /= Void
		local
			i: INTEGER
			a_name, a_value: STRING
		do
			i := arg.index_of ('=', 1)
			if i > 1 then
				if i < arg.count then
					a_name := arg.substring (1, i - 1)
					a_value := arg.substring (i + 1, arg.count)
					variables.set_value (a_name, a_value)
				elseif i = arg.count then
					a_name := arg.substring (1, i - 1)
					variables.set_value (a_name, "")
				else
					report_usage_error
				end
			elseif i = 1 then
				report_usage_error
			else
				a_name := arg
				variables.set_value (a_name, "")
			end
		end

feature {NONE} -- Error handling

	report_usage_error is
			-- Report usage error and then terminate
			-- with exit status 1.
		do
			error_handler.report_error (Usage_message)
			Exceptions.die (1)
		end

	report_undefined_environment_variable_error (a_variable: STRING) is
			-- Report that environment variable `a_variable' is not
			-- defined and then terminate with exit status 1.
		require
			a_variable_not_void: a_variable /= Void
		local
			an_error: UT_UNDEFINED_ENVIRONMENT_VARIABLE_ERROR
		do
			!! an_error.make (a_variable)
			error_handler.report_error (an_error)
			Exceptions.die (1)
		end

	report_eiffel_compilation_error is
			-- Report that an Eiffel compilation error occurred
			-- and then terminate with exit status 1.
		do
			error_handler.report_eiffel_compilation_error
			Exceptions.die (1)
		end

	report_usage_message is
			-- Report usage message and exit.
		do
			error_handler.report_info (Usage_message)
			Exceptions.die (0)
		end

	report_version_number is
			-- Report version number and exit.
		local
			a_message: UT_VERSION_NUMBER
		do
			!! a_message.make (Version_number)
			error_handler.report_info (a_message)
			Exceptions.die (0)
		end

	Usage_message: UT_USAGE_MESSAGE is
			-- Getest usage message
		once
			!! Result.make ("[-aceghV?][--help][--version]%N%
				%%T[-D <name>=<value>|--define=<name>=<value>]*%N%
				%%T[-C <command>|--compile=<command>]%N%
				%%T[--se|--ise|--hact|--ve|<filename>]")
		ensure
			usage_message_not_void: Result /= Void
		end

feature {NONE} -- Constants

	Getest_config_variable: STRING is "GETEST_CONFIG"
			-- Environment variable

	HACT_config_filename: STRING is "getest.hact"
	ISE_config_filename: STRING is "getest.ise"
	SE_config_filename: STRING is "getest.se"
	VE_config_filename: STRING is "getest.ve"
	cfg_config_filename: STRING is "getest.cfg"
			-- Default configuration filenames

invariant

	error_handler_not_void: error_handler /= Void
	variables_not_void: variables /= Void

end
