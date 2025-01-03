 local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()		npcHandler:onThink()		end

local voices = {
	{ text = 'Ask me if you need letters or parcels. I\'ll deliver them via airmail, of course!' },
	{ text = 'Feel the wind in your hair during one of my carpet rides!' }
}

npcHandler:addModule(VoiceModule:new(voices))

-- Travel
local function addTravelKeyword(keyword, cost, destination)
	--if keyword == 'farmine' then
		--keywordHandler:addKeyword({keyword}, StdModule.say, {npcHandler = npcHandler, text = 'Never heard about a place like this.'}, function(player) return player:getStorageValue(PlayerStorageKeys.TheNewFrontier.Mission10) ~= 1 end)
	--end

	local travelKeyword = keywordHandler:addKeyword({keyword}, StdModule.say, {npcHandler = npcHandler, text = 'Do you seek a ride to ' .. titleCase(keyword) .. ' for |TRAVELCOST|?', cost = cost, discount = 'postman'})
		travelKeyword:addChildKeyword({'yes'}, StdModule.travel, {npcHandler = npcHandler, premium = true, text = 'Hold on!', cost = cost, discount = 'postman', destination = destination})
		travelKeyword:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, text = 'You shouldn\'t miss the experience.', reset = true})
end

addTravelKeyword('farmine', 0, Position(32983, 31539, 1))
addTravelKeyword('edron', 0, Position(33193, 31784, 3))
addTravelKeyword('svargrond', 0, Position(32253, 31097, 4))
addTravelKeyword('femor hills', 0, Position(32536, 31837, 4))
addTravelKeyword('kazordoon', 0, Position(32588, 31942, 0))

npcHandler:setMessage(MESSAGE_GREET, 'Daraman\'s blessings, traveller |PLAYERNAME|.')
npcHandler:setMessage(MESSAGE_FAREWELL, 'It was a pleasure to help you, |PLAYERNAME|.')
npcHandler:setMessage(MESSAGE_WALKAWAY, 'It was a pleasure to help you, |PLAYERNAME|.')

npcHandler:addModule(FocusModule:new())
