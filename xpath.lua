local htmlparser = require 'htmlparser'
local common = require 'htmlparser.common'
local table = require 'ext.table'
local string = require 'ext.string'	-- not applied to string's metatable

local wildcard = {}

local function find(list, p)
	if type(list) ~= 'table' then return {} end
	local list = common.findnode(list, function(n)
		if type(n) ~= 'table' then return false end
		if p.tag and n.tag ~= p.tag then return false end
		if p.attrs then
			for k,v in pairs(p.attrs) do
				local found = false
				if n.attrs then
					for _,kv in ipairs(n.attrs) do
						if kv.name == k then
							if v ~= wildcard then
								if kv.value ~= v then return false end
							end
							found = true
						end
					end
				end
				if not found then return false end
			end
		end
		return true
	end)
	-- TODO support for ranges and subset matching
	if p.index then
		return {list[p.index]}
	end
	return list
end

local function rfind(list, pathseg, accum)
	accum = accum or table()
	if type(list) == 'table' then
		accum:append(find(list, pathseg))
		for _,n in ipairs(list) do
			if n.child then rfind(n.child, pathseg, accum) end
		end
	end
	return accum
end

-- incomplete, but xpath sucks 
local function xpath(tree, path)
	-- root is different than children... why is that?
	tree = {child=tree}
	
	-- is root implied or required? what does its omission do?
	assert(path:sub(1,1) == '/', "expected /")
	
	local paths = string.split(path:sub(2),'/'):mapi(function(s) return {tag=s} end)
	-- // means 'recursive search under'
	for i=#paths,1,-1 do
		if paths[i].tag == '' then	
			table.remove(paths, i)
			paths[i].recurse = true
		end
	end

	for _,path in ipairs(paths) do
		do
			local prefix, index = path.tag:match('^(.*)%[(.*)%]$')
			if prefix and index then
				path.tag = prefix
				path.index = tonumber(index)
				-- TODO indexes can be used to attr-filter
				-- using the same @ that is allowed outside [] 
			end
		end
		
		local tag = path.tag
		if tag:sub(1,1) == '@' then
			path.tag = nil
			local attr = tag:sub(2)
			local k,v = attr:match('^(.*)=(.*)$')
			if not k or not v then
				k = attr
				v = wildcard
			end
			path.attrs = {[k]=v}
		end

	end

	local nodes = table{tree}
	for i=1,#paths do
		local path = paths[i]
		local newnodes = table()
		local findop = path.recurse and rfind or find
		for _,node in ipairs(nodes) do
			if node.child then
				for _,ch in ipairs(findop(node.child, path)) do
					newnodes:insert(ch)
				end
			end
		end
		nodes = newnodes
	end
	return nodes
end

return xpath
