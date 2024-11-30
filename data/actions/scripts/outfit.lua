function onUse(cid, item, fromPosition, itemEx, toPosition)
-- player:setStorageValue(PlayerStorageKeys.TheNewFrontier.Questline, 25)
if (getPlayerStorageValue(cid, PlayerStorageKeys.TheNewFrontier.Questline) < 26) then
doPlayerAddOutfit(cid, 335, 0) 
doPlayerAddOutfit(cid, 336, 0)
doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You have gained your new outfit and my leave the reward room now!")
--player:setStorageValue(PlayerStorageKeys.TheNewFrontier.Questline, 26)
setPlayerStorageValue(cid, PlayerStorageKeys.TheNewFrontier.Questline, 26)
else doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You already take the outfit, ask about mission for Chrak.")
end
return TRUE
end