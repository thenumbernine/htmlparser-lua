args = {...}

local page
if #args > 0 then
	local filename = args[1]
	local file = assert(io.open(filename, 'r'))
	page = file:read('*a')
	file:close()
else
	require 'socket'
	local http = require 'socket.http'

	local mainpage = 'http://christopheremoore.net/home.lua'
	do
		local filename = 'cachedpage.html'
		local file = io.open(filename, 'r')
		if file then
			page = assert(file:read('*a'))
			file:close()
		else
			page = assert(http.request(mainpage))
			file = assert(io.open(filename, 'w'))
			file:write(page)
			file:close()
		end
	end
end

-- [[
local htmlparser = require 'htmlparser'
local tree = htmlparser.parse(page)
htmlparser.prettyprint(tree, {tabchar='', newlinechar=''})
--Parser.debugprint(tree)
--]]

--[[
filename = 'cachedpage.html'
require 'old.autoformat'
--]]
