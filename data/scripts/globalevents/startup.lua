local global_startup = GlobalEvent("global_startup_event")

global_startup.onStartup = function()

	db.query("TRUNCATE TABLE `players_online`")
	db.asyncQuery("DELETE FROM `guild_wars` WHERE `status` = 0")
	db.asyncQuery("DELETE FROM `players` WHERE `deletion` != 0 AND `deletion` < " .. os.time())
	db.asyncQuery("DELETE FROM `ip_bans` WHERE `expires_at` != 0 AND `expires_at` <= " .. os.time())
	db.asyncQuery("DELETE FROM `market_history` WHERE `inserted` <= " .. (os.time() - configManager.getNumber(configKeys.MARKET_OFFER_DURATION)))

	-- Move expired bans to ban history
	local resultId = db.storeQuery("SELECT * FROM `account_bans` WHERE `expires_at` != 0 AND `expires_at` <= " .. os.time())
	if resultId ~= false then
		repeat
			local accountId = result.getNumber(resultId, "account_id")
			db.asyncQuery("INSERT INTO `account_ban_history` (`account_id`, `reason`, `banned_at`, `expired_at`, `banned_by`) VALUES (" .. accountId .. ", " .. db.escapeString(result.getString(resultId, "reason")) .. ", " .. result.getNumber(resultId, "banned_at") .. ", " .. result.getNumber(resultId, "expires_at") .. ", " .. result.getNumber(resultId, "banned_by") .. ")")
			db.asyncQuery("DELETE FROM `account_bans` WHERE `account_id` = " .. accountId)
		until not result.next(resultId)
		result.free(resultId)
	end

	-- Check house auctions
	local resultId = db.storeQuery("SELECT `id`, `highest_bidder`, `last_bid`, (SELECT `balance` FROM `players` WHERE `players`.`id` = `highest_bidder`) AS `balance` FROM `houses` WHERE `owner` = 0 AND `bid_end` != 0 AND `bid_end` < " .. os.time())
	if resultId ~= false then
		repeat
			local house = House(result.getNumber(resultId, "id"))
			if house then
				local highestBidder = result.getNumber(resultId, "highest_bidder")
				local balance = result.getNumber(resultId, "balance")
				local lastBid = result.getNumber(resultId, "last_bid")
				if balance >= lastBid then
					db.query("UPDATE `players` SET `balance` = " .. (balance - lastBid) .. " WHERE `id` = " .. highestBidder)
					house:setOwnerGuid(highestBidder)
				end
				db.asyncQuery("UPDATE `houses` SET `last_bid` = 0, `bid_end` = 0, `highest_bidder` = 0, `bid` = 0 WHERE `id` = " .. house:getId())
			end
		until not result.next(resultId)
		result.free(resultId)
	end

	-- store towns in database
	db.query("TRUNCATE TABLE `towns`")
	for i, town in ipairs(Game.getTowns()) do
		local position = town:getTemplePosition()
		db.query("INSERT INTO `towns` (`id`, `name`, `posx`, `posy`, `posz`) VALUES (" .. town:getId() .. ", " .. db.escapeString(town:getName()) .. ", " .. position.x .. ", " .. position.y .. ", " .. position.z .. ")")
	end
	
	-- check for duplicate storages
	if configManager.getBoolean(configKeys.CHECK_DUPLICATE_STORAGE_KEYS) then
		local variableNames = {"AccountStorageKeys", "PlayerStorageKeys", "GlobalStorageKeys", "actionIds", "uniqueIds"}
		for _, variableName in ipairs(variableNames) do
			local duplicates = checkDuplicateStorageKeys(variableName)
			if duplicates then
				local message = "Duplicate keys found: " .. table.concat(duplicates, ", ")
				print(">> Checking " .. variableName .. ": " .. message)
			else
				print(">> Checking " .. variableName .. ": No duplicate keys found.")
			end
		end
	end

	-- Permanent daylight for dev/test (revert by setting default_world_light = true in gameplay.toml)
	setWorldLight(250, 215)

	-- Spawn the leave-Rookgaard Oracle. This real map has no Oracle placed in the
	-- .otbm, so create it programmatically next to the Rookgaard temple (town 6).
	-- It promotes a level 8+ vocationless Rook and teleports them to their chosen
	-- mainland town (see data/npc/scripts/The Oracle3.lua via data/npc/Oracle.xml).
	local rookgaard = Town(6)
	if rookgaard then
		local t = rookgaard:getTemplePosition()
		local offsets = {{1, 0}, {-1, 0}, {0, -1}, {0, 1}, {2, 0}, {-2, 0}, {0, 0}}
		local oracleNpc
		for _, o in ipairs(offsets) do
			local pos = Position(t.x + o[1], t.y + o[2], t.z)
			oracleNpc = Game.createNpc("Oracle", pos)
			if oracleNpc then
				print(string.format(">> Rookgaard Oracle spawned at %d, %d, %d", pos.x, pos.y, pos.z))
				break
			end
		end
		if not oracleNpc then
			print(">> WARNING: could not spawn the Rookgaard Oracle near temple " .. t.x .. "," .. t.y .. "," .. t.z)
		end
	else
		print(">> WARNING: Rookgaard (town 6) not found; Oracle not spawned")
	end
end

global_startup:type("startup")
global_startup:register()