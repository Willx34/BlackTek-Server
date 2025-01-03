local config = {
	[6087] = {storage = PlayerStorageKeys.OutfitQuest.MusicSheet01, text = 'first'},
	[6088] = {storage = PlayerStorageKeys.OutfitQuest.MusicSheet02, text = 'second'},
	[6089] = {storage = PlayerStorageKeys.OutfitQuest.MusicSheet03, text = 'third'},
	[6090] = {storage = PlayerStorageKeys.OutfitQuest.MusicSheet04, text = 'fourth'},
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local useItem = config[item.itemid]
	if not useItem then
		return true
	end

	local cStorage = useItem.storage
	if player:getStorageValue(cStorage) ~= 1 then
		player:setStorageValue(cStorage, 1)
		player:sendTextMessage(MESSAGE_STATUS_WARNING, 'You have learned the ' .. useItem.text .. ' part of a hymn.')
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		item:remove(1)
	else
		player:sendTextMessage(MESSAGE_STATUS_WARNING, 'You already know the ' .. useItem.text .. ' verse of the hymn.')
	end
	return true
end
