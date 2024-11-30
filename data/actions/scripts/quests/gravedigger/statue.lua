function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	--if target.itemid ~= 21429 then
		--return false
	--end

	if player:getStorageValue(PlayerStorageKeys.GravediggerOfDrefia.Mission20) >= 1 and player:getStorageValue(PlayerStorageKeys.GravediggerOfDrefia.Mission25) < 1 then
		
player:setStorageValue(PlayerStorageKeys.GravediggerOfDrefia.Mission25,1)
		
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, '<BOOOOOOOONGGGGGG> A slow throbbing, like blood pulsing, runs through the floor.')
		player:getPosition():sendMagicEffect(CONST_ME_SOUND_GREEN)
	end
	return true
end


--function onUse(cid, item, fromPosition, itemEx, toPosition)

--if(getPlayerStorageValue(cid, PlayerStorageKeys.GravediggerOfDrefia.Mission24) == 1 and getPlayerStorageValue(PlayerStorageKeys.GravediggerOfDrefia.Mission25) < 1) then
	
	--setPlayerStorageValue(cid, PlayerStorageKeys.GravediggerOfDrefia.Mission25, 1)
	--doCreatureSay(cid, "<BOOOOOOOONGGGGGG> A slow throbbing, like blood pulsing, runs through the floor.", TALKTYPE_ORANGE_1)
--return true
--end

--end