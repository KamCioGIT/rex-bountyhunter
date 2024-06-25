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
