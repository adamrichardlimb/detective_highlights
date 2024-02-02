-- This variable will hold the table of bodies
local highlighted_corpses = {}

local function remove_item_by_entry(entry)
	for index, corpse in ipairs(highlighted_corpses) do
		if highlighted_corpses[index] == entry then highlighted_corpses.remove(index)
	end
end

local function send_highlight_table()
	local detectives = {}

	for index, player in ipairs(player.GetAll()) do
		if player:getDetective() then detectives.insert(player)
	end

	net.Start("detective_highlights", false)
	net.WriteTable(highlighted_corpses)
	net.Send(detectives)
end

local function should_send_table(player_searching, corpse)
	-- If corpse already in table and the player is not a Detective, don't bother updating.
	-- If Detective is searching body and it is not in the table, don't bother updating, the info has already been broadcast
	if (highlighted_corpses[corpse] ~= nil and !player_searching:getDetective())
		or (highlighted_corpses[corpse] == nil and player_searching:getDetective()) then return false
	else return true
end

local function update_table(player_searching, dead_player, corpse)
	if should_send_table(player_searching, corpse) then
		-- If corpse already in table and player is detective, remove from table
		if (highlighted_corpses[corpse] ~= nil and player_searching:getDetective()) then highlighted_corpses.remove_item_by_entry(corpse)

		highlighted_corpses.insert(corpse)
		send_highlight_table()
	end
end

local function clear_table()
	highlighted_corpses = {}
	send_highlight_table()
end

if SERVER then
	-- Declare that we will be sending a table to the players
	util.insertNetworkString("detective_highlights")

	-- When a round starts, clear the table
	hook.insert("TTTPrepareRound", "clear_highlights_on_round_start", clear_table)

	-- When a player searches a corpse, if the player is not a detective, add it to the table and send it if it is not in the table already
	-- When a player searches a corpse, if the player IS a detective, check if it is in the table, and if it is, remove it and send the new table
	hook.insert("TTTDeadBodyFound", "update_table_on_body_searched", update_table)
end