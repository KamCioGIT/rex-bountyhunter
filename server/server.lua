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
    if Player.PlayerData.job.type ~= "leo" then
        TriggerClientEvent('ox_lib:notify', src, {title = 'You are not authorized', type = 'error', duration = 7000 })
        return
    end
    
    if newreward < Config.MaxBounty then
        MySQL.update('UPDATE players SET outlawstatus = ? WHERE citizenid = ?', { newreward, citizenid })
        TriggerClientEvent('ox_lib:notify', src, {title = 'Additional Bounty Added!', type = 'success', duration = 7000 })
    else
        TriggerClientEvent('ox_lib:notify', src, {title = 'Max Bounty Reached!', type = 'info', duration = 7000 })
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

---------------------------------
-- pay bounty amount to a player
---------------------------------
RegisterNetEvent('rex-bountyhunter:server:payplayer', function(data)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.type ~= "leo" then
        TriggerClientEvent('ox_lib:notify', src, {title = 'You are not authorized', type = 'error', duration = 7000 })
        return
    end

    local RewardPlayer = RSGCore.Functions.GetPlayer(tonumber(data.rewardplayer))
    if RewardPlayer then
        RewardPlayer.Functions.AddMoney('cash', tonumber(data.rewardamount))
        MySQL.update('UPDATE players SET outlawstatus = ? WHERE citizenid = ?', { 0, data.bountyplayer })
        TriggerClientEvent('ox_lib:notify', src, {title = 'Bounty Paid!', type = 'success', duration = 7000 })
        TriggerClientEvent('ox_lib:notify', RewardPlayer.PlayerData.source, {title = 'You received a bounty reward of $'..data.rewardamount, type = 'success', duration = 7000 })
    else
        TriggerClientEvent('ox_lib:notify', src, {title = 'Player Not Found', type = 'error', duration = 7000 })
    end
end)

---------------------------------
-- create a new bounty
---------------------------------
RegisterNetEvent('rex-bountyhunter:server:createnewbounty', function(data, bountyamount, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local jobtype = Player.PlayerData.job.type
    
    if jobtype == 'leo' then
        MySQL.update('UPDATE players SET outlawstatus = ? WHERE citizenid = ?', { bountyamount, data.citizenid })
        TriggerClientEvent('ox_lib:notify', src, {title = 'Bounty Added!', type = 'success', duration = 7000 })
        TriggerEvent('rsg-log:server:CreateLog', 'outlaw', 'New Bounty Created', 'green', 'Bounty created : '..data.firstname..' '..data.lastname..' for $'..bountyamount)
    else
        local cashBalance = Player.PlayerData.money['cash']
        if cashBalance >= amount then
            Player.Functions.RemoveMoney('cash', amount)
            MySQL.update('UPDATE players SET outlawstatus = ? WHERE citizenid = ?', { bountyamount, data.citizenid })
            TriggerClientEvent('ox_lib:notify', src, {title = 'Bounty Added!', type = 'success', duration = 7000 })
            TriggerEvent('rsg-log:server:CreateLog', 'outlaw', 'New Bounty Created', 'green', 'Bounty created : '..data.firstname..' '..data.lastname..' for $'..bountyamount)
        else
            TriggerClientEvent('ox_lib:notify', src, {title = 'Not enough cash!', type = 'error', duration = 7000 })
        end
    end
end)
