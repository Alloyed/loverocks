local log = require 'loverocks.log'
local util = require 'loverocks.util'
local config = require 'loverocks.config'
local fs = require 'luarocks.fs'
local pack = {}

function pack:build(parser)
	parser:description "Pack project into a .love file"
	-- parser:argument "filter"
	-- 	:args("*")
	-- 	:description "Only return dependencies matching this substring."
	-- parser:flag "--outdated"
	-- 	:description "Only return dependencies that have newer versions available."
end

function pack:run(args)
	local rspec = false
	if args.rockspec then
		rspec = ("%q"):format(args.rockspec)
	else
		rspec = assert(util.get_first(".", "%.rockspec$"))
	end
	assert(rspec, "rockspec not found")
	local cfg = {}
	config.open(rspec, cfg)

	local seq = {}
	for _, fname in ipairs(util.files('.')) do
		if not (fname:match("%.git/") or
			    fname:match("%.hg/") or
				fname:match("%.love$")) then
			table.insert(seq, fname)
		end
	end

	local fname = cfg.package .. ".love"

	fs.zip(fname, unpack(seq))
	log:info("Finished: " .. fname)
end

return pack
