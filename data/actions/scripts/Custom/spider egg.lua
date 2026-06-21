local r = {
    ["500-830"] = "Spider",
    ["830-970"] = "Poison Spider",
    ["970-999"] = "Tarantula",
	["999-1000"] = "Giant Spider"
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local name
    local chance = math.random(1000)
    for range, mob in pairs(r) do
        local rand = range:split("-")
        if chance >= tonumber(rand[1]) and chance < tonumber(rand[2]) then
            name = mob
            break
        end
    end

    if name then
        Game.createMonster(name, fromPosition)
    end
    item:transform(7536)
    item:decay()
    item:getPosition():sendMagicEffect(CONST_ME_POFF)
    return true
end

 