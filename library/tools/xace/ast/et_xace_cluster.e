indexing

	description:

		"Eiffel clusters"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2001-2002, Andreas Leitner and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_XACE_CLUSTER

inherit

	ET_CLUSTER
		redefine
			prefixed_name,
			parent, subclusters,
			is_valid_eiffel_filename,
			is_valid_directory_name
		end

creation

	make

feature {NONE} -- Initialization

	make (a_name: like name; a_pathname: like pathname) is
			-- Create a new cluster.
		require
			a_name_not_void: a_name /= Void
			a_name_not_empty: a_name.count > 0
		do
			name := a_name
			pathname := a_pathname
			is_relative := (a_pathname = Void)
			library_prefix := empty_prefix
			cluster_prefix := empty_prefix
		ensure
			name_set: name = a_name
			pathname_set: pathname = a_pathname
			prefixed_name_set: prefixed_name = a_name
			is_relative: is_relative = (a_pathname = Void)
			no_library_prefix: library_prefix.count = 0
			no_cluster_prefix: cluster_prefix.count = 0
		end

feature -- Access

	name: STRING
			-- Name

	prefixed_name: STRING is
			-- Cluster name with possible prefixes
		do
			if library_prefix.count > 0 then
				if cluster_prefix.count > 0 then
					Result := STRING_.new_empty_string (library_prefix, library_prefix.count + cluster_prefix.count + name.count)
					Result.append_string (library_prefix)
					Result := STRING_.appended_string (Result, cluster_prefix)
					Result := STRING_.appended_string (Result, name)
				else
					Result := STRING_.concat (library_prefix, name)
				end
			else
				if cluster_prefix.count > 0 then
					Result := STRING_.concat (cluster_prefix, name)
				else
					Result := name
				end
			end
		ensure then
			-- TODO:
			--definition: STRING_.same_string (Result, STRING_.concat_n (<<library_prefix, cluster_prefix, name>>))
		end

	library_prefix: STRING
			-- Cluster name prefix specified in <mount>

	cluster_prefix: STRING
			-- Cluster name prefix specified in <cluster>

	pathname: STRING
			-- Directory pathname (may be Void)

	libraries: ET_XACE_MOUNTED_LIBRARIES
			-- Mounted libraries

	options: ET_XACE_OPTIONS
			-- Options

	class_options: DS_LINKED_LIST [ET_XACE_CLASS_OPTIONS]
			-- Class options

feature -- Status report

	is_mounted: BOOLEAN
			-- Has cluster been mounted?

feature -- Nested

	parent: ET_XACE_CLUSTER
			-- Parent cluster

	subclusters: ET_XACE_CLUSTERS
			-- Subclusters

feature -- Setting

	set_libraries (a_libraries: like libraries) is
			-- Set `libraries' to `a_libraries'.
		do
			libraries := a_libraries
		ensure
			libraries_set: libraries = a_libraries
		end

	set_options (an_options: like options) is
			-- Set `options' to `an_options'.
		do
			options := an_options
		ensure
			options_set: options = an_options
		end

	set_library_prefix (a_prefix: STRING) is
			-- Set `library_prefix' to `a_prefix',
			-- and recursively in the subclusters.
		require
			a_prefix_not_void: a_prefix /= Void
		do
			library_prefix := a_prefix
			if subclusters /= Void then
				subclusters.set_library_prefix (a_prefix)
			end
		ensure
			library_prefix_set: library_prefix = a_prefix
		end

	set_cluster_prefix (a_prefix: STRING) is
			-- Set `cluster_prefix' to `a_prefix'.
		require
			a_prefix_not_void: a_prefix /= Void
		do
			cluster_prefix := a_prefix
		ensure
			cluster_prefix_set: cluster_prefix = a_prefix
		end

feature -- Element change

	put_class_option (an_option: ET_XACE_CLASS_OPTIONS) is
			-- Add `an_option' to `class_options'.
		require
			an_option_not_void: an_option /= Void
		do
			if class_options = Void then
				create class_options.make
			end
			class_options.put_last (an_option)
		end

feature -- Status setting

	set_mounted (b: BOOLEAN) is
			-- Set `is_mounted' to `b'.
		do
			is_mounted := b
		ensure
			mounted_set: is_mounted = b
		end

feature -- Basic operations

	merge_libraries (a_libraries: ET_XACE_MOUNTED_LIBRARIES; an_error_handler: ET_XACE_ERROR_HANDLER) is
			-- Add `libraries', and recursively the libraries of subclusters, to `a_libraries'.
			-- Report any error (e.g. incompatible prefixes) in `an_error_handler'.
		require
			a_libraries_not_void: a_libraries /= Void
			an_error_handler_not_void: an_error_handler /= Void
		do
			if libraries /= Void then
				libraries.merge_libraries (a_libraries, an_error_handler)
			end
			if subclusters /= Void then
				subclusters.merge_libraries (a_libraries, an_error_handler)
			end
		end

	merge_externals (an_externals: ET_XACE_EXTERNALS) is
			-- Merge current cluster's externals and those
			-- of subclusters to `an_externals'.
		require
			an_externals_not_void: an_externals /= Void
		local
			a_cursor: DS_HASH_SET_CURSOR [STRING]
		do
			if options /= Void then
				a_cursor := options.header.new_cursor
				from a_cursor.start until a_cursor.after loop
					an_externals.put_include_directory (a_cursor.item)
					a_cursor.forth
				end
				a_cursor := options.link.new_cursor
				from a_cursor.start until a_cursor.after loop
					an_externals.put_link_library (a_cursor.item)
					a_cursor.forth
				end
			end
			if subclusters /= Void then
				subclusters.merge_externals (an_externals)
			end
		end

	merge_exported_features (an_export: DS_LIST [ET_XACE_EXPORTED_FEATURE]) is
			-- Merge current cluster's exported features and those
			-- of subclusters to `an_export'.
		require
			an_export_not_void: an_export /= Void
			no_void_export: not an_export.has (Void)
		local
			an_exported_feature: ET_XACE_EXPORTED_FEATURE
			a_class_cursor: DS_LINKED_LIST_CURSOR [ET_XACE_CLASS_OPTIONS]
			a_class_options: ET_XACE_CLASS_OPTIONS
			a_feature_options_list: DS_LINKED_LIST [ET_XACE_FEATURE_OPTIONS]
			a_feature_cursor: DS_LINKED_LIST_CURSOR [ET_XACE_FEATURE_OPTIONS]
			a_feature_options: ET_XACE_FEATURE_OPTIONS
			an_options: ET_XACE_OPTIONS
		do
			if class_options /= Void then
				a_class_cursor := class_options.new_cursor
				from a_class_cursor.start until a_class_cursor.after loop
					a_class_options := a_class_cursor.item
					a_feature_options_list := a_class_options.feature_options
					if a_feature_options_list /= Void then
						a_feature_cursor := a_feature_options_list.new_cursor
						from a_feature_cursor.start until a_feature_cursor.after loop
							a_feature_options := a_feature_cursor.item
							an_options := a_feature_options.options
							if an_options.is_export_option_declared then
								create an_exported_feature.make (a_class_options.class_name, a_feature_options.feature_name, an_options.export_option)
								an_export.force_last (an_exported_feature)
							end
							a_feature_cursor.forth
						end
					end
					a_class_cursor.forth
				end
			end
			if subclusters /= Void then
				subclusters.merge_exported_features (an_export)
			end
		ensure
			no_void_export: not an_export.has (Void)
		end

	merge_components (a_components: DS_LIST [ET_XACE_COMPONENT]) is
			-- Merge current cluster's components and those
			-- of subclusters to `a_components'.
		require
			a_components_not_void: a_components /= Void
			no_void_component: not a_components.has (Void)
		local
			a_component: ET_XACE_COMPONENT
		do
			if options /= Void then
				if options.is_component_declared then
					create a_component.make (name, options.component)
					a_components.force_last (a_component)
				end
			end
			if subclusters /= Void then
				subclusters.merge_components (a_components)
			end
		ensure
			no_void_component: not a_components.has (Void)
		end

	merge_assemblies (an_assemblies: DS_LIST [ET_XACE_ASSEMBLY]) is
			-- Merge current cluster's assemblies and those
			-- of subclusters to `an_assemblies'.
		require
			an_assemblies_not_void: an_assemblies /= Void
			no_void_assembly: not an_assemblies.has (Void)
		local
			an_assembly: ET_XACE_ASSEMBLY
		do
			if options /= Void then
				if options.is_assembly_declared then
					create an_assembly.make (name, options.assembly, options.version,
						options.culture, options.public_key_token, options.prefix_option)
					an_assemblies.force_last (an_assembly)
				end
			end
			if subclusters /= Void then
				subclusters.merge_assemblies (an_assemblies)
			end
		ensure
			no_void_assembly: not an_assemblies.has (Void)
		end

feature {NONE} -- Implementation

	new_recursive_cluster (a_name: STRING): like Current is
			-- New recursive cluster
		do
			create Result.make (a_name, Void)
			Result.set_parent (Current)
			Result.set_recursive (True)
		end

	is_valid_eiffel_filename (a_filename: STRING): BOOLEAN is
			-- Is `a_filename' an Eiffel filename which has
			-- not been excluded?
		local
			an_exclude: DS_HASH_SET [STRING]
		do
			if precursor (a_filename) then
				if options /= Void and then options.is_exclude_declared then
					an_exclude := options.exclude
					Result := not an_exclude.has (a_filename)
				else
					Result := True
				end
			end
		end

	is_valid_directory_name (a_dirname: STRING): BOOLEAN is
			-- Is `a_dirname' a directory name other than "." and
			-- ".." and which has not been excluded?
		local
			an_exclude: DS_HASH_SET [STRING]
		do
			if precursor (a_dirname) then
				if options /= Void and then options.is_exclude_declared then
					an_exclude := options.exclude
					Result := not an_exclude.has (a_dirname)
				else
					Result := True
				end
			end
		end

feature {NONE} -- Constants

	empty_prefix: STRING is ""
			-- Empty prefix

invariant

	library_prefix_not_void: library_prefix /= Void
	cluster_prefix_not_void: cluster_prefix /= Void
	no_void_class_option: class_options /= Void implies not class_options.has (Void)

end
