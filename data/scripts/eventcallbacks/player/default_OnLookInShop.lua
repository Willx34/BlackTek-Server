local ec = EventCallback

ec.onLookInShop = function(self, itemType, count, description)
	local itemId = itemType:getId()
    local item = Game.createItem(itemId)	
	local description = "You see " .. item:getDescription(0)

    if self:getGroup():getAccess() then
        description = string.format("%s\nItem ID: %d", description, item:getId())

        local actionId = item:getActionId()
        if actionId ~= 0 then
            description = string.format("%s, Action ID: %d", description, actionId)
        end

        local uniqueId = item:getAttribute(ITEM_ATTRIBUTE_UNIQUEID)
        if uniqueId > 0 and uniqueId < 65536 then
            description = string.format("%s, Unique ID: %d", description, uniqueId)
        end

        local itemType = item:getType()

        local transformEquipId = itemType:getTransformEquipId()
        local transformDeEquipId = itemType:getTransformDeEquipId()
        if transformEquipId ~= 0 then
            description = string.format("%s\nTransforms to: %d (onEquip)", description, transformEquipId)
        elseif transformDeEquipId ~= 0 then
            description = string.format("%s\nTransforms to: %d (onDeEquip)", description, transformDeEquipId)
        end

        local decayId = itemType:getDecayId()
        if decayId ~= -1 then
            description = string.format("%s\nDecays to: %d", description, decayId)
        end
    end

    local totalSlots = item:getImbuementSlots()

    if totalSlots > 0 then
        local occupiedSlotsDescriptions = {}
        local emptySlotsDescriptions = {}
        local imbuments = item:getImbuements()

        for slot = 1, totalSlots do
            local imbue = imbuments[slot]
            if imbue and imbue.getType then
                local imbueId = imbue:getType()
                local imbueDuration = imbue:getDuration()
                local imbueValue = imbue:getValue()
                
                local imbueName = "Unknown"
                local imbueLevelName = "Unknown"

                if imbueId then
                    local hours = math.floor(imbueDuration / 3600)
                    local remainingMinutes = math.floor((imbueDuration % 3600) / 60)
                    local formattedOutput

                    if imbueDuration < 60 then
                        formattedOutput = "less than a minute"
                    elseif imbueDuration < 3600 then
                        formattedOutput = string.format("%d min", remainingMinutes)
                    else
                        formattedOutput = string.format("%d:%02dh", hours, remainingMinutes)
                    end
                    
                    table.insert(occupiedSlotsDescriptions, imbueLevelName .. " " .. imbueName .. " " .. formattedOutput)
                end
            else
                table.insert(emptySlotsDescriptions, "Empty Slot")
            end
        end

        local slotsDescriptions = {}
        for _, desc in ipairs(occupiedSlotsDescriptions) do
            table.insert(slotsDescriptions, desc)
        end
        for _, desc in ipairs(emptySlotsDescriptions) do
            table.insert(slotsDescriptions, desc)
        end

        if #slotsDescriptions > 0 then
            local imbuementsDescription = "Imbuements: (" .. table.concat(slotsDescriptions, ", ") .. ")."
            description = description .. "\n" .. imbuementsDescription
        end
    end

    return description
end

ec:register()
