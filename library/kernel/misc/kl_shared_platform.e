indexing

	description:

		"Shared platform-dependent properties"

	pattern: "Singleton"
	library: "Gobo Eiffel Kernel Library"
	copyright: "Copyright (c) 1999, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class KL_SHARED_PLATFORM

feature -- Access

	Platform: KL_PLATFORM is
			-- Platform-dependent properties
		once
			create Result
		ensure
			platform_not_void: Result /= Void
		end

feature -- Obsolete

	platform_: KL_PLATFORM is
			-- Platform-dependent properties
		obsolete
			"Use `Platform' instead."
		once
			Result := Platform
		ensure
			platform__not_void: Result /= Void
		end

end
