-- vim:set ft=lua
std = "lua51"

files["spec/*.lua"].std = "+busted"
files["spec/commands/*.lua"].std = "+busted"

files["rockspecs/*.rockspec"].std = "rockspec"
files["./*.rockspec"].std = "rockspec"
