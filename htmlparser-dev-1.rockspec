package = "htmlparser"
version = "dev-1"
source = {
	url = "git+https://github.com/thenumbernine/htmlparser-lua"
}
description = {
	summary = [[HTML parser]],
	detailed = [[HTML parser]],
	homepage = "https://github.com/thenumbernine/htmlparser-lua",
	license = "MIT"
}
dependencies = {
	"lua >= 5.1"
}
build = {
	type = "builtin",
	modules = {
		["htmlparser.common"] = "common.lua",
		["htmlparser"] = "htmlparser.lua",
		["htmlparser.tests.dominion"] = "tests/dominion.lua",
		["htmlparser.tests.dominion-from-diehrstraits"] = "tests/dominion-from-diehrstraits.lua",
		["htmlparser.tests.exportITunesPlaylist"] = "tests/exportITunesPlaylist.lua",
		["htmlparser.tests.prettyprint"] = "tests/prettyprint.lua",
		["htmlparser.tests.yqlkey"] = "tests/yqlkey.lua",
		["htmlparser.xpath"] = "xpath.lua"
	},
	copy_directories = {
		"tests"
	}
}
