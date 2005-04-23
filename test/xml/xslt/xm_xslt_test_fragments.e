indexing

	description:

	"Test use of fragment identifiers on source and stylesheet URIs.%
    %Also, stylesheet chaining and xml-stylesheet PI"

	library: "Gobo Eiffel XSLT test suite"
	copyright: "Copyright (c) 2005, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_XSLT_TEST_FRAGMENTS

inherit

	TS_TEST_CASE

	KL_IMPORTED_STRING_ROUTINES

	XM_XPATH_SHARED_CONFORMANCE

	XM_XPATH_SHARED_NAME_POOL

	XM_RESOLVER_FACTORY

	XM_XSLT_CONFIGURATION_CONSTANTS

feature

	test_shorthand_pointer is
			-- Transform books3.xml with books1.xsl.
		local
			a_stylesheet_compiler: XM_XSLT_STYLESHEET_COMPILER
			a_configuration: XM_XSLT_CONFIGURATION
			a_transformer: XM_XSLT_TRANSFORMER
			a_uri_source, another_uri_source: XM_XSLT_URI_SOURCE
			an_output: XM_OUTPUT
			a_result: XM_XSLT_TRANSFORMATION_RESULT
		do
			conformance.set_basic_xslt_processor
			create a_configuration.make_with_defaults
			a_configuration.set_string_mode_ascii   -- make_with_defaults sets to mixed
			a_configuration.use_tiny_tree_model (False)
			create a_stylesheet_compiler.make (a_configuration)
			create a_uri_source.make ("./data/books1.xsl")
			a_stylesheet_compiler.prepare (a_uri_source)
			assert ("Stylesheet compiled without errors", not a_stylesheet_compiler.load_stylesheet_module_failed)
			assert ("Stylesheet not void", a_stylesheet_compiler.last_loaded_module /= Void)
			a_transformer := a_stylesheet_compiler.new_transformer
			assert ("transformer", a_transformer /= Void)
			create another_uri_source.make ("../xpath/data/books3.xml#S")
			create an_output
			an_output.set_output_to_string
			create a_result.make (an_output, "string:")
			a_transformer.transform (another_uri_source, a_result)
			assert ("Transform successfull", not a_transformer.is_error)
			assert ("Correct output", STRING_.same_string (an_output.last_output, expected_output_1))
		end

	test_element_scheme_pointer is
			-- Transform books3.xml with books1.xsl.
		local
			a_stylesheet_compiler: XM_XSLT_STYLESHEET_COMPILER
			a_configuration: XM_XSLT_CONFIGURATION
			a_transformer: XM_XSLT_TRANSFORMER
			a_uri_source, another_uri_source: XM_XSLT_URI_SOURCE
			an_output: XM_OUTPUT
			a_result: XM_XSLT_TRANSFORMATION_RESULT
		do
			conformance.set_basic_xslt_processor
			create a_configuration.make_with_defaults
			a_configuration.set_string_mode_ascii   -- make_with_defaults sets to mixed
			a_configuration.use_tiny_tree_model (False)
			create a_stylesheet_compiler.make (a_configuration)
			create a_uri_source.make ("./data/books1.xsl")
			a_stylesheet_compiler.prepare (a_uri_source)
			assert ("Stylesheet compiled without errors", not a_stylesheet_compiler.load_stylesheet_module_failed)
			assert ("Stylesheet not void", a_stylesheet_compiler.last_loaded_module /= Void)
			a_transformer := a_stylesheet_compiler.new_transformer
			assert ("transformer", a_transformer /= Void)
			create another_uri_source.make ("../xpath/data/books3.xml#element(/1/1/1/1)")
			create an_output
			an_output.set_output_to_string
			create a_result.make (an_output, "string:")
			a_transformer.transform (another_uri_source, a_result)
			assert ("Transform successfull", not a_transformer.is_error)
			assert ("Correct output", STRING_.same_string (an_output.last_output, expected_output_1))
		end

	test_gexslt_xpath_scheme_pointer is
			-- Transform books3.xml with books1.xsl.
		local
			a_stylesheet_compiler: XM_XSLT_STYLESHEET_COMPILER
			a_configuration: XM_XSLT_CONFIGURATION
			a_transformer: XM_XSLT_TRANSFORMER
			a_uri_source, another_uri_source: XM_XSLT_URI_SOURCE
			an_output: XM_OUTPUT
			a_result: XM_XSLT_TRANSFORMATION_RESULT
		do
			conformance.set_basic_xslt_processor
			create a_configuration.make_with_defaults
			a_configuration.set_string_mode_ascii   -- make_with_defaults sets to mixed
			a_configuration.use_tiny_tree_model (False)
			a_configuration.set_recovery_policy (Do_not_recover)
			create a_stylesheet_compiler.make (a_configuration)
			create a_uri_source.make ("./data/books1.xsl")
			a_stylesheet_compiler.prepare (a_uri_source)
			assert ("Stylesheet compiled without errors", not a_stylesheet_compiler.load_stylesheet_module_failed)
			assert ("Stylesheet not void", a_stylesheet_compiler.last_loaded_module /= Void)
			a_transformer := a_stylesheet_compiler.new_transformer
			assert ("transformer", a_transformer /= Void)
			create another_uri_source.make ("../xpath/data/books3.xml#xmlns(gexslt=http://www.gobosoft.com/eiffel/gobo/gexslt/extension)gexslt:xpath(/descendant::AUTHOR%%5B1%%5D)")
			create an_output
			an_output.set_output_to_string
			create a_result.make (an_output, "string:")
			a_transformer.transform (another_uri_source, a_result)
			assert ("Transform successfull", not a_transformer.is_error)
			assert ("Correct output", STRING_.same_string (an_output.last_output, expected_output_2))
		end
	
	test_embedded_stylesheet is
			-- Transform embedded.xml by itself, without using xml-stylesheet-pi
		local
			a_stylesheet_compiler: XM_XSLT_STYLESHEET_COMPILER
			a_configuration: XM_XSLT_CONFIGURATION
			a_transformer: XM_XSLT_TRANSFORMER
			a_uri_source, another_uri_source: XM_XSLT_URI_SOURCE
			an_output: XM_OUTPUT
			a_result: XM_XSLT_TRANSFORMATION_RESULT
		do
			conformance.set_basic_xslt_processor
			create a_configuration.make_with_defaults
			a_configuration.set_string_mode_ascii
			a_configuration.use_tiny_tree_model (False)
			create a_stylesheet_compiler.make (a_configuration)
			create a_uri_source.make ("./data/embedded.xml#style1")
			a_stylesheet_compiler.prepare (a_uri_source)
			assert ("Stylesheet compiled without errors", not a_stylesheet_compiler.load_stylesheet_module_failed)
			assert ("Stylesheet not void", a_stylesheet_compiler.last_loaded_module /= Void)
			a_transformer := a_stylesheet_compiler.new_transformer
			assert ("transformer", a_transformer /= Void)
			create another_uri_source.make ("./data/embedded.xml")
			create an_output
			an_output.set_output_to_string
			create a_result.make (an_output, "string:")
			a_transformer.transform (another_uri_source, a_result)
			assert ("Transform successfull", not a_transformer.is_error)
			assert ("Correct output", an_output.last_output.count = 173)
		end

	test_xml_stylesheet_pi_one is
			-- Transform processing_instructions.xml via PIs.
			-- For "print" medium, preferred style
		local
			a_transformer_factory: XM_XSLT_TRANSFORMER_FACTORY
			a_configuration: XM_XSLT_CONFIGURATION
			a_transformer: XM_XSLT_TRANSFORMER
			a_stylesheet_source: XM_XSLT_SOURCE
			a_uri_source: XM_XSLT_URI_SOURCE
			an_output: XM_OUTPUT
			a_result: XM_XSLT_TRANSFORMATION_RESULT
			a_chooser: XM_XSLT_PREFERRED_PI_CHOOSER
		do
			conformance.set_basic_xslt_processor
			create a_configuration.make_with_defaults
			a_configuration.set_string_mode_ascii
			a_configuration.use_tiny_tree_model (False)
			create a_transformer_factory.make (a_configuration)
			create a_uri_source.make ("./data/processing_instructions.xml")
			create a_chooser.make
			a_stylesheet_source := a_transformer_factory.associated_stylesheet (a_uri_source.system_id, "print", a_chooser)
			assert ("Stylesheet found", a_stylesheet_source /= Void)
			a_transformer_factory.create_new_transformer (a_stylesheet_source)
			assert ("Stylesheet compiled without errors", not a_transformer_factory.was_error)
			a_transformer := a_transformer_factory.created_transformer
			assert ("Transformer not void", a_transformer /= Void)
			create an_output
			an_output.set_output_to_string
			create a_result.make (an_output, "string:")
			a_transformer.transform (a_uri_source, a_result)
			assert ("Transform successfull", not a_transformer.is_error)
			assert ("Correct output", an_output.last_output.count = 309)
		end

	test_xml_stylesheet_pi_two is
			-- Transform processing_instructions.xml via PIs.
			-- For "screen" and alternate style "Alternate"
		local
			a_transformer_factory: XM_XSLT_TRANSFORMER_FACTORY
			a_configuration: XM_XSLT_CONFIGURATION
			a_transformer: XM_XSLT_TRANSFORMER
			a_stylesheet_source: XM_XSLT_SOURCE
			a_uri_source: XM_XSLT_URI_SOURCE
			an_output: XM_OUTPUT
			a_result: XM_XSLT_TRANSFORMATION_RESULT
			a_chooser: XM_XSLT_PI_CHOOSER_BY_NAME
		do
			conformance.set_basic_xslt_processor
			create a_configuration.make_with_defaults
			a_configuration.set_string_mode_ascii
			a_configuration.use_tiny_tree_model (False)
			create a_transformer_factory.make (a_configuration)
			create a_uri_source.make ("./data/processing_instructions.xml")
			create a_chooser.make ("Alternate")
			a_stylesheet_source := a_transformer_factory.associated_stylesheet (a_uri_source.system_id, "screen", a_chooser)
			assert ("Stylesheet found", a_stylesheet_source /= Void)
			a_transformer_factory.create_new_transformer (a_stylesheet_source)
			assert ("Stylesheet compiled without errors", not a_transformer_factory.was_error)
			a_transformer := a_transformer_factory.created_transformer
			assert ("Transformer not void", a_transformer /= Void)
			create an_output
			an_output.set_output_to_string
			create a_result.make (an_output, "string:")
			a_transformer.transform (a_uri_source, a_result)
			assert ("Transform successfull", not a_transformer.is_error)
			assert ("Correct output", an_output.last_output.count = 295)
		end

	test_next_in_chain is
			-- Test gexslt:next-in-chain
		local
			a_stylesheet_compiler: XM_XSLT_STYLESHEET_COMPILER
			a_configuration: XM_XSLT_CONFIGURATION
			a_transformer: XM_XSLT_TRANSFORMER
			a_uri_source: XM_XSLT_URI_SOURCE
			an_output: XM_OUTPUT
			a_result: XM_XSLT_TRANSFORMATION_RESULT
		do
			conformance.set_basic_xslt_processor
			create a_configuration.make_with_defaults
			a_configuration.set_string_mode_ascii   -- make_with_defaults sets to mixed
			a_configuration.use_tiny_tree_model (False)
			create a_stylesheet_compiler.make (a_configuration)
			create a_uri_source.make ("./data/example0.xsl")
			a_stylesheet_compiler.prepare (a_uri_source)
			assert ("Stylesheet compiled without errors", not a_stylesheet_compiler.load_stylesheet_module_failed)
			assert ("Stylesheet not void", a_stylesheet_compiler.last_loaded_module /= Void)
			a_transformer := a_stylesheet_compiler.new_transformer
			assert ("transformer", a_transformer /= Void)
			create an_output
			an_output.set_output_to_string
			create a_result.make (an_output, "string:")
			a_transformer.set_initial_template ("initial")
			a_transformer.transform (Void, a_result)
			assert ("Transform successfull", not a_transformer.is_error)
			assert ("Correct output", an_output.last_output.count = 81)
		end

	expected_output_1: STRING is "<?xml version=%"1.0%" encoding=%"UTF-8%"?><output>Number, the Language of Science</output>"

	expected_output_2: STRING is "<?xml version=%"1.0%" encoding=%"UTF-8%"?><output>Danzig</output>"
																																				 
end
