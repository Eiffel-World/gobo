indexing

	description:

		"Shared exception handling"

	pattern: "Singleton"
	library: "Gobo Eiffel Kernel Library"
	copyright: "Copyright (c) 1999, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class KL_SHARED_EXCEPTIONS

feature -- Access

	Exceptions: KL_EXCEPTIONS is
			-- Exception handling
		once
			create Result
		ensure
			exceptions_not_void: Result /= Void
		end

feature -- Obsolete

	exceptions_: KL_EXCEPTIONS is
			-- Exception handling
		obsolete
			"[040101] Use `Exceptions' instead."
		once
			Result := Exceptions
		ensure
			exceptions_not_void: Result /= Void
		end

end
