indexing

	description:

		"Test XM_CATALOG"

	library: "Gobo Eiffel XML test suite"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_TEST_CATALOG

inherit

	TS_TEST_CASE
		redefine
			set_up
		end

	KL_IMPORTED_STRING_ROUTINES

	KL_SHARED_EXECUTION_ENVIRONMENT

	XM_SHARED_CATALOG_MANAGER

feature -- Tests

	test_resolve_public is
			-- Test resolving an fpi via nextCatalog
		local
			a_uri: STRING
		do
			shared_catalog_manager.set_debug_level (0)
			a_uri := shared_catalog_manager.resolved_fpi ("ISO 8879:1986//ENTITIES Box and Line Drawing//EN", True)
			assert ("PUBLIC resolved", a_uri /= Void and then a_uri.count > 34 and then STRING_.same_string (a_uri.substring (a_uri.count - 34, a_uri.count), "/xml-dtd-4.2-1.0-24/ent/iso-box.ent"))
		end

	test_resolve_public_delegate is
			-- Test resolving an fpi via delegated catalog
		local
			a_uri: STRING
		do
			shared_catalog_manager.set_debug_level (0)
			a_uri := shared_catalog_manager.resolved_fpi ("-//OASIS//ENTITIES DocBook XML Character Entities V4.1.2//EN",True)
			assert ("PUBLIC resolved via delegation", a_uri /= Void and then a_uri.count > 32 and then STRING_.same_string (a_uri.substring (a_uri.count - 32, a_uri.count), "/xml-dtd-4.1.2-1.0-24/dbcentx.mod"))
		end

	--  TODO - add tests for prefer=public versus prefer=system (requires more complex test catalog structure)

	test_resolve_system is
			-- Test resolving an fsi via nextCatalog with base URI
		local
			a_uri: STRING
		do
			shared_catalog_manager.set_debug_level (0)
			a_uri := shared_catalog_manager.resolved_fsi ("http://www.gobosoft.com/test/system-id-one")
			assert ("SYSTEM resolved", a_uri /= Void and then STRING_.same_string (a_uri, "http://colina.demon.co.uk/gobo/system-id-one"))
		end

	test_rewrite_system is
			-- Test resolving an fsi via nextCatalog with rewriteSystem and group base URI 
		local
			a_uri: STRING
		do
			shared_catalog_manager.set_debug_level (0)
			a_uri := shared_catalog_manager.resolved_fsi ("http://www.oasis-open.org/docbook/xml/4.1.2/test.system")
			assert ("SYSTEM resolved via rewrite", a_uri /= Void and then STRING_.same_string (a_uri, "ftp://ftp.gobosoft.com/pub/xml-dtd-4.1.2-1.0-24/test.system"))
		end

	test_resolve_system_delegate is
			-- Test resolving an fsi via delegated catalog
		local
			a_uri: STRING
		do
			shared_catalog_manager.set_debug_level (0)
			a_uri := shared_catalog_manager.resolved_fsi ("http://www.colina.demon.co.uk/test/system-id-two")
			assert ("SYSTEM resolved via delegation", a_uri /= Void and then STRING_.same_string (a_uri, "ftp://colina.demon.co.uk/gobo/system-id-two"))
		end

	test_resolve_uri is
			-- Test resolving a uri reference via nextCatalog with base URI
		local
			a_uri: STRING
		do
			shared_catalog_manager.set_debug_level (0)
			a_uri := shared_catalog_manager.resolved_uri ("http://www.gobosoft.com/test/system-id-one")
			assert ("URI reference resolved", a_uri /= Void and then STRING_.same_string (a_uri, "http://colina.demon.co.uk/gobo/system-id-one"))
		end

	test_rewrite_uri is
			-- Test resolving a uri reference via nextCatalog with rewriteuri and group base URI 
		local
			a_uri: STRING
		do
			shared_catalog_manager.set_debug_level (0)
			a_uri := shared_catalog_manager.resolved_uri ("http://www.oasis-open.org/docbook/xml/4.1.2/test.system")
			assert ("URI reference resolved via rewrite", a_uri /= Void and then STRING_.same_string (a_uri, "ftp://ftp.gobosoft.com/pub/xml-dtd-4.1.2-1.0-24/test.system"))
		end

	test_resolve_uri_delegate is
			-- Test resolving a uri reference via delegated catalog
		local
			a_uri: STRING
		do
			shared_catalog_manager.set_debug_level (0)
			a_uri := shared_catalog_manager.resolved_uri ("http://www.colina.demon.co.uk/test/system-id-two")
			assert ("URI reference resolved via delegation", a_uri /= Void and then STRING_.same_string (a_uri, "ftp://colina.demon.co.uk/gobo/system-id-two"))
		end

	
feature -- Setting

	set_up is
		do
			Execution_environment.set_variable_value ("XML_CATALOG_FILES", "./data/test-catalog-1.xml")
			shared_catalog_manager.reinit
		end
		
end
	
