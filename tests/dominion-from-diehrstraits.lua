#!/usr/bin/env lua
require 'ext'
-- this has to match up with the require in xpath
-- so TODO ... don't have xpath modify htmlparser 
local htmlparser = require 'htmlparser'
local socket = require 'socket'
local common = require 'htmlparser.common'
local xpath = require 'htmlparser.xpath'
local http = require 'socket.http'
local json = require 'dkjson'

local url = [[http://dominion.diehrstraits.com/?set=All&f=list]]
local page = assert(http.request(url))
local tree = htmlparser.parse(page)

local h2s = xpath(tree, '//h2')
local tables = xpath(tree, '//table')
assert(#h2s == #tables)
local decks = {}
for i=1,#tables do
	local deckName = common.flattenText(h2s[i]):match('^Dominion: (.*)$')
	if deckName == 'Base Cards' then
	elseif deckName == 'Common' then
	else
		local cards = {}
		local tabl = tables[i]
		local trs = xpath(tabl.child, '//tr')
		for j=2,#trs do	-- first tr is the header
			local tr = trs[j]
			local tds = xpath(tr.child, '//td')
			assert(#tds == 6, "expected 6 children but found "..#tds)
			local index = assert(tonumber(common.flattenText(tds[1])))
			assert(index == j-1)
			assert(common.flattenText(tds[3]) == deckName)
			
			local title = common.flattenText(tds[2])
			local cardtype = common.flattenText(tds[4])	

	-- [[ shared with 'dominion.lua'
			-- Dark Ages
			if title == 'Ruins' then
			elseif cardtype:sub(-8) == ' - Ruins' then
			elseif title == 'Shelters' then
			elseif cardtype:sub(-10) == ' - Shelter' then
			elseif cardtype:sub(-9) == ' - Knight' then
			elseif title == 'Knights' then
				cards:insert{
					name=title, 
					type='Action - Attack - Knight', 
					cost='$5',
					text=text,
				}
			elseif title == 'Spoils' then
			elseif title == 'Madman' then
			elseif title == 'Mercenary' then
			-- Prosperity
			elseif title == 'Platinum' then
			elseif title == 'Colony' then
			-- Alchemy
			elseif title == 'Potion' then
			-- Cornucopia:
			elseif title == 'Bag of Gold' then
			elseif title == 'Diadem' then
			elseif title == 'Followers' then
			elseif title == 'Princess' then
			elseif title == 'Trusty Steed' then
			-- all else:
			else
	--]]

				table.insert(cards, {
					name = title,
					type = cardtype,
					cost = common.flattenText(tds[5]),
					text = common.flattenText(tds[6]),
				})
			end
		end
		
		if deckName == 'Base' then deckName = 'Dominion' end
		table.insert(decks, {
			name = deckName,
			cards = cards,
		})
	end
end
print('decks = '..json.encode(decks, {indent=true}))
