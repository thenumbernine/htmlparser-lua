-- TODO -move to htmlparser and make instances of the tree nodes
local table = require 'ext.table'

local function findnode(list, callback)
	local res = {}
	assert(type(list) == 'table')
	for _,v in ipairs(list) do
		if callback(v) then
			table.insert(res, v)
		end
	end
	return res
end

local function findtags(list, tagname, attrs)
	return findnode(list, function(n)
		if type(n) ~= 'table' then return false end
		if n.tag ~= tagname then return false end
		if attrs then
			for k,v in pairs(attrs) do
				local found = false
				if n.attrs then
					for _,kv in ipairs(n.attrs) do
						if kv.name == k then
							if kv.value ~= v then return false end
							found = true
						end
					end
				end
				if not found then return false end
			end
		end
		return true
	end)
end

local function findtag(...)
	return (findtags(...))[1]
end

local function findchild(node, ...)
	return findtag(node.child, ...)
end

local function findchilds(node, ...)
	return findtags(node.child, ...)
end

local function findattr(node, name)
	if node.attrs then
		for _,kv in ipairs(node.attrs) do
			if kv.name == name then return kv.value end
		end
	end
end

local function flattenText(n)
	if type(n) == 'string' then return n end
	if n.tag == 'br' then return '.  ' end
	if not n.child then return '' end
	return table.mapi(n.child, function(ch) return flattenText(ch) end):concat()
end

return {
	findnode = findnode,
	findtags = findtags,
	findtag = findtag,
	findchild = findchild,
	findchilds = findchilds,
	findattr = findattr,
	flattenText = flattenText,
}
