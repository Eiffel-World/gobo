indexing

	description:

		"Build commands for 'gexace'"

	system: "Gobo Eiffel Xace"
	copyright: "Copyright (c) 2001, Andreas Leitner and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class GEXACE_BUILD_COMMAND

inherit

	GEXACE_COMMAND

feature -- Access

	generators: DS_LINKED_LIST [ET_XACE_GENERATOR]
			-- Ace file generators

invariant

	generators_not_void: generators /= Void
	no_void_generator: not generators.has (Void)

end
