indexing

	description:

		"Interface for directories"

	library: "Gobo Eiffel Kernel Library"
	copyright: "Copyright (c) 2001, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class KI_DIRECTORY

inherit

	KI_FILE_SYSTEM_ENTRY
		rename
			open as open_read,
			is_open as is_open_read
		redefine
			open_read
		end

	KI_INPUT_STREAM [STRING]
		rename
			read as read_entry,
			unread as unread_entry,
			last_item as last_entry,
			valid_unread_item as valid_unread_entry
		undefine
			is_closable, close
		redefine
			read_entry, last_entry
		end

feature -- Access

	last_entry: STRING is
			-- Last entry (file or subdirectory name) read
			-- (Note: this query returns the new object after
			-- each call to `read_entry'.)
		deferred
		end

	filenames: ARRAY [STRING] is
			-- Names of readable files in current directory;
			-- Void if current directory could not be searched
		deferred
		ensure
			-- no_void_filename: Result /= Void implies not Result.has (Void)
			-- no_empty_filename: Result /= Void implies forall s in Result, s.count > 0
		end

	directory_names: ARRAY [STRING] is
			-- Names of readable subdirectories in current directory;
			-- Void if current directory could not be searched
			-- (Do not include parent and current directory names.)
		deferred
		ensure
			-- no_void_filename: Result /= Void implies not Result.has (Void)
			-- no_empty_filename: Result /= Void implies forall s in Result, s.count > 0
		end

feature -- Status report

	valid_unread_entry (an_entry: STRING): BOOLEAN is
			-- Can `an_entry' be put back in input stream?
		do
			Result := an_entry /= Void and then an_entry.count > 0
		ensure then
			an_entry_not_void: Result implies an_entry /= Void
			an_entry_not_empty: Result implies an_entry.count > 0
		end

feature -- Basic operations

	open_read is
			-- Try to open directory in read mode.  Set `is_open_read'
			-- to true and is ready to read first entry in directory
			-- if operation was successful.
		deferred
		ensure then
			not_end_of_input: is_open_read implies not end_of_input
		end

	create_directory is
			-- Create current directory on disk.
			-- Do nothing if the directory could not
			-- be created, if it already existed or if
			-- `name' is a nested directory name and
			-- the parent directory does not exist.
		require
			is_closed: is_closed
		deferred
		end

	recursive_create_directory is
			-- Create current directory on disk.
			-- Create its parent directories if they do not exist yet.
			-- Do nothing if the directory could not be created,
			-- if it already existed or `name' is a nested directory
			-- name and its parent directory does not exist and 
			-- could not be created.
		require
			is_closed: is_closed
		deferred
		end

	recursive_delete is
			-- Delete current directory, its files
			-- and its subdirectories recursively.
			-- Do nothing if the directory could not
			-- be deleted, if it did not exist.
		require
			is_closed: is_closed
		deferred
		end

feature -- Input

	read_entry is
			-- Read next entry in directory.
			-- Make result available in `last_entry'.
		deferred
		ensure then
			last_entry_not_void: not end_of_input implies last_entry /= Void
			last_entry_not_empty: not end_of_input implies last_entry.count > 0
		end

end
