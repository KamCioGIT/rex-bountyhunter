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
