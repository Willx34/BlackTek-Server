local config = {
	[50500] = Position(33538, 32013, 6),
	[50501] = Position(33491, 31985, 7)
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local targetPosition = config[item.uid]
	if not targetPosition then
		return false
	end

	player:teleportTo(targetPosition)
	targetPosition:sendMagicEffect(CONST_ME_WATERSPLASH)
	return true
end
