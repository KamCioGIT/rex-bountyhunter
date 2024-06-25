local RSGCore = exports['rsg-core']:GetCoreObject()

---------------------------------
-- get all players
---------------------------------
RSGCore.Functions.CreateCallback('rex-bountyhunter:server:getplayers', function(source, cb)
    MySQL.query('SELECT * FROM players', {}, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

---------------------------------
-- add bounty to player
---------------------------------
RegisterNetEvent('rex-bountyhunter:server:addplayerbounty', function(amount, newreward, citizenid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local currentCash = Player.Functions.GetMoney('cash')
    if currentCash > tonumber(amount) then
        MySQL.query('SELECT * FROM players WHERE citizenid = ?', { citizenid }, function(result)
            local json_string = result[1].metadata
            local json_data = json.decode(json_string)
            json_data.outlawstatus = newreward
            local updated_json_string = json.encode(json_data)
            MySQL.update('UPDATE players SET metadata = ? WHERE citizenid = ?', { updated_json_string, citizenid })
        end)
        Player.Functions.RemoveMoney('cash', tonumber(amount))
    else
        TriggerClientEvent('ox_lib:notify', src, {title = 'Not Enough Cash! $' .. amount, description = 'you need more cash to do that!', type = 'error', duration = 7000 })
    end
end)

---------------------------------
-- get players for reward
---------------------------------
RSGCore.Functions.CreateCallback('rex-bountyhunter:server:getrewardplayers', function(source, cb)
    local src = source
    local players = {}
    for k,v in pairs(RSGCore.Functions.GetPlayers()) do
        local target = GetPlayerPed(v)
        local ped = RSGCore.Functions.GetPlayer(v)
        players[#players + 1] = {
        name = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname .. ' | (' .. GetPlayerName(v) .. ')',
        id = v,
        coords = GetEntityCoords(target),
        citizenid = ped.PlayerData.citizenid,
        sources = GetPlayerPed(ped.PlayerData.source),
        sourceplayer = ped.PlayerData.source
        }
    end

    table.sort(players, function(a, b)
        return a.id < b.id
    end)

    cb(players)
end)

RegisterNetEvent('rex-bountyhunter:server:payplayer', function(data)
    print(data.rewardplayer, data.rewardplayername, data.rewardamount, data.bountyplayer)
end)