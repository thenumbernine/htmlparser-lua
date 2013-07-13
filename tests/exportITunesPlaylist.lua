local args = {...}
assert(#args > 0)
local filename = args[1]
local selectedPlaylist = args[2]

require 'lfs'
require 'htmlparser'

htmlparser.Parser.htmlnonclosing = {}	-- get rid of non-closing html parser symbols (i.e. interpret xml)

function getITunesXmlTree(filename)
	local f = assert(io.open(filename, 'r'))
	f:read('*l')	-- xml type -- haven't got it in my parser yet...
	f:read('*l')	-- doctype -- same issue
	local d = f:read('*a')
	f:close()
	local p = htmlparser.new(d)
	return p:parse()
end

function getNodeForKey(dict, key)
	local i = 1
	while i <= #dict.child do
		local ch = dict.child[i]
		if ch.tag == 'key'
		and #ch.child > 0
		and type(ch.child[1]) == 'string'
		and ch.child[1] == key
		and i+1 <= #dict.child
		then
			local tracks = dict.child[i+1]
			return tracks
		end
		i = i + 1
	end
	error("Couldn't find key "..key.." in dict "..dict.tag)
end

local locationPrefix = 'file://localhost'
function getFileFromITunesXmlTrack(track)
	assert(#track.child > 0)
	local n = getNodeForKey(track, 'Location')
	assert(n.tag == 'string')
	assert(type(n.child[1]) == 'string')
	local d = n.child[1]
	if d:sub(1,#locationPrefix) ~= locationPrefix then
		io.stderr:write("expected "..d.." to be within "..locationPrefix.."\n")
		return ''
	end
	d = d:sub(#locationPrefix+1)
	d = d:gsub('%%[0-9,a-z,A-Z][0-9,a-z,A-Z]', function(pattern)
		return string.char(tonumber('0x'..pattern:sub(2)))
	end)
	d = d:gsub('&#%d+;', function(pattern)
		return string.char(tonumber(pattern:match('^&#(%d+);$')))
	end)
	return d
end

function reapITunesXmlFileListFromTracks(tracks)
	local files = {}
	local lastKey
	for _,ch in ipairs(tracks.child) do
		if ch.tag == 'key' then
			lastKey = ch.child[1]
		end
		if ch.tag == 'dict' then
			assert(lastKey)
			local value = getFileFromITunesXmlTrack(ch)
			local skey = lastKey
			lastKey = nil
			local key = tonumber(skey)
			assert(tostring(key) == skey, "got a bad key "..skey)
			files[key] = value
		end
	end
	return files
end

function reapITunesXmlFileList(tree)
	assert(#tree > 1)
	local plist = tree[1]
	assert(plist.tag == 'plist')
	assert(#plist.child == 1)
	local dict = plist.child[1]
	assert(dict.tag == 'dict')
	assert(#dict.child > 0)

	-- find the child of tag 'key' with child data 'Tracks'
	-- then next child should be of tag 'dict'
	local tracks = getNodeForKey(dict, 'Tracks')
	local musicFiles = reapITunesXmlFileListFromTracks(tracks)
	
	local playlistFiles = {}
	
	local playlists = {}
	local playlistArray = getNodeForKey(dict, 'Playlists')
	for _,playlistDict in ipairs(playlistArray.child) do
		local playlistName = getNodeForKey(playlistDict, 'Name').child[1]

		if selectedPlaylist == playlistName then
			local playlistItems = getNodeForKey(playlistDict, 'Playlist Items')
			
			for _,track in ipairs(playlistItems.child) do
				local sid = getNodeForKey(track, 'Track ID').child[1]
				local id = tonumber(sid)
				if not id then
					print("failed to decode id "..sid)
				end
				
				local file = assert(musicFiles[id])
				table.insert(playlistFiles, file)
			end
		end
	end
	
	if not selectedPlaylist then
		for i=1,table.maxn(filelist) do
			local file = filelist[i]
			if file then
				table.insert(playlistFiles, file)
			end
		end
	end
	
	return playlistFiles
end

function getITunesXmlFileList(filename)
	local tree = getITunesXmlTree(filename)
	return reapITunesXmlFileList(tree)
end

local playlistFiles = getITunesXmlFileList(filename)
for _,file in ipairs(playlistFiles) do
	print(file)
	if file:sub(-4) == '.mp3' then
		print('...is mp3')
	else
		local mp3file = file:sub(1,-5)..'.mp3'
		print('...mp3: '..tostring(lfs.attributes(mp3file) ~= nil))
		local mp3file2 = mp3file:gsub('iTunes Media', 'iTunes Music')
		if mp3file ~= mp3file2 then
			print('...mp3: '..tostring(lfs.attributes(mp3file2) ~= nil))
		end
		local mp3file3 = mp3file:gsub('iTunes Music', 'iTunes Media')
		if mp3file ~= mp3file3 then
			print('...mp3: '..tostring(lfs.attributes(mp3file3) ~= nil))
		end
		local mp3file4 = mp3file:gsub('/Volumes/BackupDrive1/', '/Users/twmoore/')
		if mp3file4 ~= mp3file then
			print('...mp3: '..tostring(lfs.attributes(mp3file4) ~= nil))
		end
		local mp3file5 = mp3file:gsub('/Volumes/BackupDrive1/', '/Users/twmoore/'):gsub('iTunes Music', 'iTunes Media')
		if mp3file5 ~= mp3file then
			print('...mp3: '..tostring(lfs.attributes(mp3file5) ~= nil))
		end
	end
end

-- now mkdirsForFile(v) and copy(v) into the new dir ...

