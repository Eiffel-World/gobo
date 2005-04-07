indexing

	description:

		"Eiffel clusters"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_CLUSTER

inherit

	HASHABLE
	DEBUG_OUTPUT
	KL_SHARED_OPERATING_SYSTEM
	KL_SHARED_FILE_SYSTEM
	KL_IMPORTED_STRING_ROUTINES
	KL_IMPORTED_ARRAY_ROUTINES

feature -- Status report

	is_abstract: BOOLEAN
			-- Is there no classes in current cluster?
			-- (i.e. 'abstract' keyword in HACT's LACE.)

	is_fully_abstract: BOOLEAN is
			-- Are current cluster and recursively all its
			-- subclusters abstract?
		local
			i, nb: INTEGER
			a_cluster_list: DS_ARRAYED_LIST [ET_CLUSTER]
		do
			if is_abstract then
				Result := True
				if subclusters /= Void then
					a_cluster_list := subclusters.clusters
					nb := a_cluster_list.count
					from i := 1 until i > nb loop
						if not a_cluster_list.item (i).is_fully_abstract then
							Result := False
							i := nb + 1 -- Jump out of the loop.
						else
							i := i + 1
						end
					end
				end
			end
		end

	is_recursive: BOOLEAN
			-- Is current cluster recursive, in other words
			-- should subdirectories be considered as subclusters?
			-- (i.e. 'all' or 'library' keywords in ISE's LACE.)

	is_relative: BOOLEAN
			-- Is the pathname of current cluster relative to the
			-- pathname of its parent cluster?

	is_override: BOOLEAN
			-- Is current cluster an override cluster?
			-- In other words, do classes in this cluster and other override
			-- clusters take precedence over classes with same names but in
			-- non-override cluster? (see 'override_cluster' in ISE's LACE.)

	is_read_only: BOOLEAN
			-- Is current cluster a read-only cluster?
			-- In other words, are changes in this cluster and in its classes
			-- not taken into account when repreparsing or reparsing
			-- the universe? (see 'library' in ISE's LACE.)

	is_implicit: BOOLEAN
			-- Has current cluster not been explicitly declared
			-- but is instead the result of the fact that its
			-- parent is a recursive cluster?

	has_subcluster (a_cluster: ET_CLUSTER): BOOLEAN is
			-- Is `a_cluster' (recursively) one of the subclusters
			-- of current cluster?
		require
			a_cluster_not_void: a_cluster /= Void
		do
			if subclusters /= Void then
				Result := subclusters.has_subcluster (a_cluster)
			end
		end

	is_valid_eiffel_filename (a_filename: STRING): BOOLEAN is
			-- Is `a_filename' an Eiffel filename which has
			-- not been excluded?
		require
			a_filename_not_void: a_filename /= Void
		do
			Result := has_eiffel_extension (a_filename)
		end

	is_valid_directory_name (a_dirname: STRING): BOOLEAN is
			-- Is `a_dirname' a directory name other than "." and
			-- ".." and which has not been excluded?
		require
			a_dirname_not_void: a_dirname /= Void
		do
			Result := a_dirname.count > 0 and
				not STRING_.same_string (a_dirname, dot_directory_name) and
				not STRING_.same_string (a_dirname, dot_dot_directory_name)
		end

feature -- Access

	name: STRING is
			-- Name
		deferred
		ensure
			name_not_void: Result /= Void
			name_not_empty: Result.count > 0
		end

	lower_name: STRING is
			-- Lower-name of cluster
			-- (May return the same object as `name' if already in lower case.)
		local
			i, nb: INTEGER
			c: CHARACTER
		do
			Result := name
			nb := Result.count
			from i := 1 until i > nb loop
				c := Result.item (i)
				if c >= 'A' and c <= 'Z' then
					Result := Result.as_lower
					i := nb + 1 -- Jump out of the loop.
				else
					i := i + 1
				end
			end
		ensure
			lower_name_not_void: Result /= Void
			lower_name_not_empty: Result.count > 0
			definition: Result.is_equal (name.as_lower)
		end

	prefixed_name: STRING is
			-- Cluster name with possible prefixes
		do
			Result := name
		ensure
			prefixed_name_not_void: Result /= Void
			prefixed_name_not_empty: Result.count > 0
		end

	pathname: STRING is
			-- Directory pathname (may be Void)
		deferred
		end

	full_name (a_separator: CHARACTER): STRING is
			-- Full name (use `a_separator' as separator
			-- between parents' names)
		local
			parent_name: STRING
			a_basename: STRING
		do
			if parent /= Void then
				parent_name := parent.full_name (a_separator)
				a_basename := name
				Result := STRING_.new_empty_string (parent_name, parent_name.count + a_basename.count + 1)
				Result.append_string (parent_name)
				Result.append_character (a_separator)
				Result := STRING_.appended_string (Result, a_basename)
			else
				Result := name
			end
		ensure
			full_name_not_void: Result /= Void
			full_name_not_empty: Result.count > 0
		end

	full_lower_name (a_separator: CHARACTER): STRING is
			-- Full lower_name (use `a_separator' as separator
			-- between parents' names)
		local
			parent_name: STRING
			a_basename: STRING
		do
			if parent /= Void then
				parent_name := parent.full_lower_name (a_separator)
				a_basename := lower_name
				Result := STRING_.new_empty_string (parent_name, parent_name.count + a_basename.count + 1)
				Result.append_string (parent_name)
				Result.append_character (a_separator)
				Result := STRING_.appended_string (Result, a_basename)
			else
				Result := lower_name
			end
		ensure
			full_lower_name_not_void: Result /= Void
			full_lower_name_not_empty: Result.count > 0
			definition: Result.is_equal (full_name (a_separator).as_lower)
		end

	full_pathname: STRING is
			-- Full directory pathname
		local
			a_pathname: STRING
			parent_pathname: STRING
			a_basename: STRING
		do
			a_pathname := pathname
			if is_relative and parent /= Void then
				parent_pathname := parent.full_pathname
				if a_pathname /= Void and then a_pathname.count > 0 then
					a_basename := a_pathname
				else
					a_basename := name
				end
				Result := file_system.pathname (parent_pathname, a_basename)
			elseif a_pathname /= Void and then a_pathname.count > 0 then
				Result := a_pathname
			else
				Result := name
			end
		ensure
			full_pathname_not_void: Result /= Void
			full_pathname_not_empty: Result.count > 0
		end

	hash_code: INTEGER is
			-- Hash code value
		do
			Result := name.hash_code
		end

	data: ANY
			-- Arbitrary user data

feature -- Nested

	parent: ET_CLUSTER
			-- Parent cluster

	subcluster_by_name (a_names: ARRAY [STRING]): ET_CLUSTER is
			-- Subcluster (recursively) named `a_names' in current clusters;
			-- Add missing implicit subclusters if needed;
			-- Void if not such cluster
		require
			a_names_not_void: a_names /= Void
			no_void_name: not STRING_ARRAY_.has (a_names, Void)
			-- no_empty_name: forall n in a_names, n.count > 0
		local
			l_name: STRING
			i, nb: INTEGER
			l_clusters: ET_CLUSTERS
			l_parent_cluster: ET_CLUSTER
		do
			l_parent_cluster := Current
			l_clusters := subclusters
			i := a_names.lower
			nb := a_names.upper
			from until i > nb loop
				if l_clusters /= Void then
					l_name := a_names.item (i)
					Result := l_clusters.cluster_by_name (l_name)
				else
					Result := Void
				end
				if Result /= Void then
					l_parent_cluster := Result
					l_clusters := Result.subclusters
					i := i + 1
				elseif l_parent_cluster /= Void and then l_parent_cluster.is_recursive then
					from until i > nb loop
						l_name := a_names.item (i)
						l_parent_cluster.add_recursive_cluster (l_name)
						l_clusters := l_parent_cluster.subclusters
						if l_clusters /= Void then
							Result := l_clusters.cluster_by_name (l_name)
						else
							Result := Void
						end
						if Result /= Void then
							l_parent_cluster := Result
							i := i + 1
						else
							i := nb + 1 -- Jump out of the loop.
						end
					end
				else
					i := nb + 1 -- Jump out of the loop.
				end
			end
		end

	subclusters: ET_CLUSTERS
			-- Subclusters

feature -- Measurement

	count: INTEGER is
			-- Number (recursively) of non-abstract clusters,
			-- including current cursor
		do
			if not is_abstract then
				Result := 1
			end
			if subclusters /= Void then
				Result := Result + subclusters.count
			end
		ensure
			count_non_negative: Result >= 0
		end

	override_count: INTEGER is
			-- Number (recursively) of non-abstract non-read-only override clusters,
			-- including current cursor
		do
			if not is_read_only and not is_abstract and is_override then
				Result := 1
			end
			if subclusters /= Void then
				Result := Result + subclusters.override_count
			end
		ensure
			override_count_non_negative: Result >= 0
		end

	read_write_count: INTEGER is
			-- Number (recursively) of non-abstract non-read-only clusters,
			-- including current cursor
		do
			if not is_read_only and not is_abstract then
				Result := 1
			end
			if subclusters /= Void then
				Result := Result + subclusters.read_write_count
			end
		ensure
			read_write_count_non_negative: Result >= 0
		end

feature -- Status setting

	set_abstract (b: BOOLEAN) is
			-- Set `is_abstract' to `b'.
		do
			is_abstract := b
		ensure
			abstract_set: is_abstract = b
		end

	set_recursive (b: BOOLEAN) is
			-- Set `is_recursive' to `b'.
		do
			is_recursive := b
		ensure
			recursive_set: is_recursive = b
		end

	set_relative (b: BOOLEAN) is
			-- Set `is_relative' to `b'.
		do
			is_relative := b
		ensure
			relative_set: is_relative = b
		end

	set_override (b: BOOLEAN) is
			-- Set `is_override' to `b'.
		do
			is_override := b
		ensure
			override_set: is_override = b
		end

	set_read_only (b: BOOLEAN) is
			-- Set `is_read_only' to `b'.
		do
			is_read_only := b
		ensure
			read_only_set: is_read_only = b
		end

	set_implicit (b: BOOLEAN) is
			-- Set `is_implicit' to `b'.
		do
			is_implicit := b
		ensure
			implicit_set: is_implicit = b
		end

feature -- Setting

	set_subclusters (a_subclusters: like subclusters) is
			-- Set `subclusters' to `a_subclusters'.
		do
			if subclusters /= Void then
				subclusters.set_parent (Void)
			end
			subclusters := a_subclusters
			if subclusters /= Void then
				subclusters.set_parent (Current)
			end
		ensure
			subclusters_set: subclusters = a_subclusters
		end

	set_data (a_data: like data) is
			-- Set `data' to `a_data'.
		do
			data := a_data
		ensure
			data_set: data = a_data
		end

feature -- Element change

	add_subcluster (a_cluster: like parent) is
			-- Add `a_cluster' to the list of subsclusters.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			a_subclusters: like subclusters
		do
			if subclusters = Void then
				create a_subclusters.make_empty
				set_subclusters (a_subclusters)
			end
			subclusters.put_last (a_cluster)
			a_cluster.set_parent (Current)
		end

	add_recursive_cluster (a_name: STRING) is
			-- Add recursive cluster named `s' to `subclusters'
			-- if not present yet.
		require
			a_name_not_void: a_name /= Void
			a_name_not_empty: a_name.count > 0
		local
			a_cluster: ET_CLUSTER
			a_cluster_list: DS_ARRAYED_LIST [ET_CLUSTER]
			found: BOOLEAN
			i, nb: INTEGER
		do
			if subclusters /= Void then
				a_cluster_list := subclusters.clusters
				nb := a_cluster_list.count
				from i := 1 until i > nb loop
					a_cluster := a_cluster_list.item (i)
					if a_cluster.is_implicit then
						if STRING_.same_case_insensitive (a_name, a_cluster.name) then
							found := True
							i := nb + 1 -- Jump out of the loop.
						end
					end
					i := i + 1
				end
			end
			if not found then
				add_subcluster (new_recursive_cluster (a_name))
			end
		end

feature {ET_CLUSTER, ET_CLUSTERS} -- Setting

	set_parent (a_parent: like parent) is
			-- Set `parent' to `a_parent'.
		do
			parent := a_parent
		ensure
			parent_set: parent = a_parent
		end

feature -- Output

	debug_output: STRING is
			-- String that should be displayed in debugger to represent `Current'
		do
			Result := full_name ('.')
		end

feature {NONE} -- Implementation

	new_recursive_cluster (a_name: STRING): like Current is
			-- New recursive cluster
		require
			a_name_not_void: a_name /= Void
			a_name_not_empty: a_name.count > 0
		deferred
		ensure
			cluster_not_void: Result /= Void
			name_set: Result.name = a_name
			parent_set: Result.parent = Current
			recursive: Result.is_recursive
			implicit: Result.is_implicit
		end

	has_eiffel_extension (a_filename: STRING): BOOLEAN is
			-- Has `a_filename' an Eiffel extension (.e)?
		require
			a_filename_not_void: a_filename /= Void
		local
			nb: INTEGER
			c: CHARACTER
		do
			nb := a_filename.count
			if nb > 2 and then a_filename.item (nb - 1) = '.' then
				c := a_filename.item (nb)
				if c = 'e' then
					Result := True
				elseif operating_system.is_windows and then c = 'E' then
					Result := True
				end
			end
		ensure
			definition: Result = (a_filename.count > 2 and then
				((a_filename.item (a_filename.count) = 'e' or
				(operating_system.is_windows and then
				a_filename.item (a_filename.count) = 'E')) and
				a_filename.item (a_filename.count - 1) = '.'))
		end

feature {NONE} -- Constants

	dot_directory_name: STRING is "."
	dot_dot_directory_name: STRING is ".."
			-- Directory names

end
