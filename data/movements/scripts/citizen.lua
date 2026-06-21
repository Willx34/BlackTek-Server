function onStepIn(creature, item, position, fromPosition)
	-- upper limit was 30050, increased for higher town ids
	if item.actionid > 30020 and item.actionid < 30060 then
		if not creature:isPlayer() then
			return false
		end

		creature:setTown(Town(item.actionid - 30020))
	end
	return true
end
