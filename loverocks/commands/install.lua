local install = {}

function install:build(parser)
	parser:description "Install packages, or add a new one"
	parser:argument "new-package"
		:args("?")
end

install.aliases = {}

return install
