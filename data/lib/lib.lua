-- Core API functions implemented in Lua
dofile('data/lib/core/core.lua')

-- Compatibility library for our old Lua API
dofile('data/lib/compat/compat.lua')

-- Debugging helper function for Lua developers
dofile('data/lib/debugging/dump.lua')

-- Area constants and spell helpers must be available before scripts/lib/combats/ loads
dofile('data/scripts/lib/spell_lib.lua')

-- Real-map datapack quest libs (Storage constants + quest helpers).
-- Loaded protected so a single failing lib can't break the global script env.
for _, __dpLib in ipairs({
	'051-storages', '055-teleport_item_destinations', 'achievements_lib',
	'demonOakQuest', 'killingInTheNameOfQuest', 'svargrondArenaQuest'
}) do
	local __ok, __err = pcall(dofile, 'data/lib/datapack/' .. __dpLib .. '.lua')
	if not __ok then print('[datapack-lib] failed to load ' .. __dpLib .. ': ' .. tostring(__err)) end
end
