indexing

	description:

		"Test character maps and other serialization features."

	library: "Gobo Eiffel XSLT test suite"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_XSLT_TEST_CHARACTER_MAP

inherit

	TS_TEST_CASE

	KL_IMPORTED_STRING_ROUTINES

	XM_XPATH_SHARED_CONFORMANCE

	XM_XPATH_SHARED_NAME_POOL

	XM_XPATH_STANDARD_NAMESPACES

	XM_RESOLVER_FACTORY

	XM_XSLT_SHARED_EMITTER_FACTORY

		-- This class tests various aspects of serialization.
		-- Principally, use of character maps, but also CDATA sections
		--  and user-written QName output methods.

feature -- Access

	expected_result: STRING is "<?xml version=%"1.0%" encoding=%"UTF-8%"?><setProperty name=%"user%" property=%"id%" value='<%%= %"id%" + idValue %%>'/>"
			-- Expected result for `test_character_map'

feature -- Test

	test_xml_character_map is
			-- Test use-character-maps with method=xml
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
			create a_stylesheet_compiler.make (a_configuration)
			create a_uri_source.make ("./data/character_map.xsl")
			a_stylesheet_compiler.prepare (a_uri_source)
			assert ("Stylesheet compiled without errors", not a_stylesheet_compiler.load_stylesheet_module_failed)
			assert ("Stylesheet not void", a_stylesheet_compiler.last_loaded_module /= Void)
			a_transformer := a_stylesheet_compiler.new_transformer
			assert ("transformer", a_transformer /= Void)
			a_transformer.set_initial_template ("first")
			assert ("Initial template set", a_transformer.initial_template /= Void)
			create an_output
			an_output.set_output_to_string 
			create a_result.make (an_output, "string:")
			a_transformer.transform (Void, a_result)
			assert ("Transform successfull", not a_transformer.is_error)
			print (an_output.last_output)
			assert ("Correct result", STRING_.same_string (an_output.last_output, expected_result))
		end

	test_html_character_map is
			-- Test use-character-maps with method=html
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
			a_configuration.set_line_numbering (True)
			create a_stylesheet_compiler.make (a_configuration)
			create a_uri_source.make ("./data/character_map2.xsl")
			a_stylesheet_compiler.prepare (a_uri_source)
			assert ("Stylesheet compiled without errors", not a_stylesheet_compiler.load_stylesheet_module_failed)
			assert ("Stylesheet not void", a_stylesheet_compiler.last_loaded_module /= Void)
			a_transformer := a_stylesheet_compiler.new_transformer
			assert ("transformer", a_transformer /= Void)
			a_transformer.set_initial_template ("first")
			assert ("Initial template set", a_transformer.initial_template /= Void)
			create an_output
			an_output.set_output_to_string 
			create a_result.make (an_output, "string:")
			a_transformer.transform (Void, a_result)
			assert ("Transform successfull", not a_transformer.is_error)
			assert ("Correct result", an_output.last_output.count = 299)
		end

	test_xhtml_character_map is
			-- Test use-character-maps with method=xhtml
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
			a_configuration.set_line_numbering (True)
			create a_stylesheet_compiler.make (a_configuration)
			create a_uri_source.make ("./data/character_map4.xsl")
			a_stylesheet_compiler.prepare (a_uri_source)
			assert ("Stylesheet compiled without errors", not a_stylesheet_compiler.load_stylesheet_module_failed)
			assert ("Stylesheet not void", a_stylesheet_compiler.last_loaded_module /= Void)
			a_transformer := a_stylesheet_compiler.new_transformer
			assert ("transformer", a_transformer /= Void)
			a_transformer.set_initial_template ("first")
			assert ("Initial template set", a_transformer.initial_template /= Void)
			create an_output
			an_output.set_output_to_string 
			create a_result.make (an_output, "string:")
			a_transformer.transform (Void, a_result)
			assert ("Transform successfull", not a_transformer.is_error)
			assert ("Correct result", an_output.last_output.count = 399)
		end

	test_text_character_map is
			-- Test use-character-maps with method=text
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
			a_configuration.set_line_numbering (True)
			create a_stylesheet_compiler.make (a_configuration)
			create a_uri_source.make ("./data/character_map5.xsl")
			a_stylesheet_compiler.prepare (a_uri_source)
			assert ("Stylesheet compiled without errors", not a_stylesheet_compiler.load_stylesheet_module_failed)
			assert ("Stylesheet not void", a_stylesheet_compiler.last_loaded_module /= Void)
			a_transformer := a_stylesheet_compiler.new_transformer
			assert ("transformer", a_transformer /= Void)
			a_transformer.set_initial_template ("first")
			assert ("Initial template set", a_transformer.initial_template /= Void)
			create an_output
			an_output.set_output_to_string 
			create a_result.make (an_output, "string:")
			a_transformer.transform (Void, a_result)
			assert ("Transform successfull", not a_transformer.is_error)
			assert ("Correct result", an_output.last_output.count = 125)
		end

	test_xhtml_character_map_with_cdata is
			-- Test use-character-maps with method=xhtml
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
			a_configuration.set_line_numbering (True)
			create a_stylesheet_compiler.make (a_configuration)
			create a_uri_source.make ("./data/character_map6.xsl")
			a_stylesheet_compiler.prepare (a_uri_source)
			assert ("Stylesheet compiled without errors", not a_stylesheet_compiler.load_stylesheet_module_failed)
			assert ("Stylesheet not void", a_stylesheet_compiler.last_loaded_module /= Void)
			a_transformer := a_stylesheet_compiler.new_transformer
			assert ("transformer", a_transformer /= Void)
			a_transformer.set_initial_template ("first")
			assert ("Initial template set", a_transformer.initial_template /= Void)
			create an_output
			an_output.set_output_to_string 
			create a_result.make (an_output, "string:")
			a_transformer.transform (Void, a_result)
			assert ("Transform successfull", not a_transformer.is_error)
			assert ("Correct result", an_output.last_output.count = 699)
		end

	test_qname_method is
			-- Test use of a QName output method.
		local
			a_stylesheet_compiler: XM_XSLT_STYLESHEET_COMPILER
			a_configuration: XM_XSLT_CONFIGURATION
			a_transformer: XM_XSLT_TRANSFORMER
			a_uri_source: XM_XSLT_URI_SOURCE
			an_output: XM_OUTPUT
			a_result: XM_XSLT_TRANSFORMATION_RESULT
			an_emitter_factory: XM_XSLT_GEXSLT_EXAMPLES_EMITTER_FACTORY
		do
			conformance.set_basic_xslt_processor
			create a_configuration.make_with_defaults
			a_configuration.set_line_numbering (True)
			create an_emitter_factory.make
			emitter_factory.register_extension_emitter_factory (an_emitter_factory)
			create a_stylesheet_compiler.make (a_configuration)
			create a_uri_source.make ("./data/qname_output.xsl")
			a_stylesheet_compiler.prepare (a_uri_source)
			assert ("Stylesheet compiled without errors", not a_stylesheet_compiler.load_stylesheet_module_failed)
			assert ("Stylesheet not void", a_stylesheet_compiler.last_loaded_module /= Void)
			a_transformer := a_stylesheet_compiler.new_transformer
			assert ("transformer", a_transformer /= Void)
			a_transformer.set_initial_template ("first")
			assert ("Initial template set", a_transformer.initial_template /= Void)
			create an_output
			an_output.set_output_to_string 
			create a_result.make (an_output, "string:")
			a_transformer.transform (Void, a_result)
			assert ("Transform successfull", not a_transformer.is_error)
			assert ("Correct result", an_output.last_output.count = 272)
		end

end
