indexing

	description:

		"XSLT patterns that matches a particular name and node kind"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_XSLT_NODE_TEST

inherit

	XM_XSLT_PATTERN
		rename
			original_text as pattern_text
		undefine
			fingerprint, set_original_text, node_kind
		end
	
	XM_XPATH_NODE_TEST
	
feature -- Access

	node_test: XM_XSLT_NODE_TEST is
			-- Retrieve an `XM_XSLT_NODE_TEST' that all nodes matching this pattern must satisfy
		do
			Result := Current
		end

feature -- Matching

	frozen matches (a_node: XM_XPATH_NODE;  a_transformer: XM_XSLT_TRANSFORMER): BOOLEAN is
			-- Determine whether this Pattern matches the given Node;
		do
			Result := matches_node (a_node.node_type, a_node.fingerprint, a_node.type_annotation) 
		end

end
	
