indexing

	description:
	
		"Standard pipe of callbacks filter leading to construction of a tree of XM_NODEs"
	
	library: "Gobo Eiffel XML Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"
	
class XM_TREE_CALLBACKS_PIPE

inherit

	ANY

	XM_CALLBACKS_FILTER_FACTORY
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Make

	make is
			-- Create pipe.
		local
			a_dummy: XM_CALLBACKS
		do
			start := new_end_tag_checker
			error := new_stop_on_error
			tree := new_tree_builder
			last := tree
			
			-- dummy because we already store 'start' in 
			-- a variable of a descendant type
			a_dummy := callbacks_pipe (<<
					start,
					-- new_namespace_resolver,
					-- -- should be used once tree does not 
					-- -- resolve namespaces itself
					-- new_shared_strings,
					-- -- check this is valuable?
					error,
					tree >>)
		end
		
feature -- Filters (part of the pipe)

	start: XM_CALLBACKS_FILTER
			-- Starting point for XM_CALLBACKS_SOURCE (e.g. parser)

	error: XM_STOP_ON_ERROR_FILTER
			-- Error collector.

	tree: XM_CALLBACKS_TO_TREE_FILTER
			-- Tree construction. 

	last: XM_CALLBACKS_FILTER
			-- Last element in the pipe, to which further filters 
			-- can be added.

feature -- Shortcuts

	document: XM_DOCUMENT is
			-- Document (from tree building filter).
		require
			not_error: not error.has_error
		do
			Result := tree.document
		end

	last_error: STRING is
			-- Error (from error filter).
		require
			error: error.has_error
		do
			Result := error.last_error
		ensure
			not_void: Result /= Void
		end

invariant

	tree_not_void: tree /= Void

end
