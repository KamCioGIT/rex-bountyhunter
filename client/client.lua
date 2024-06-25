local RSGCore = exports['rsg-core']:GetCoreObject()

CreateThread(function()
    -- create target for the entity
    exports['rsg-target']:AddTargetModel(Config.BountyBoards, {
        options = {
            {
                type = 'client',
                icon = 'far fa-eye',
                label = 'View Bounty Board',
                action = function()
                    TriggerEvent('rex-bountyhunter:client:openboard')
                end
            },
        },
        distance = 3
    })
    -- end of target
end)

-- players options menu
RegisterNetEvent('rex-bountyhunter:client:openboard', function()
    RSGCore.Functions.TriggerCallback('rex-bountyhunter:server:getplayers', function(data)
        local options = {}
        for _, value in pairs(data) do
            local character = json.decode(value.charinfo)
            local metadata = json.decode(value.metadata)
            local firstname = character.firstname
            local lastname = character.lastname
            local citizenid = value.citizenid
            local outlawstatus = metadata.outlawstatus
            if outlawstatus >= 100 then
                options[#options + 1] = {
                    title = firstname..' '..lastname..' ('..citizenid..')',
                    description = 'bounty reward : $'..outlawstatus,
                    icon = 'fa-solid fa-mask',
                }
            end
        end
        lib.registerContext({
            id = 'main_menu',
            title = 'Wanted Outlaws',
            onBack = function() end,
            position = 'top-right',
            options = options
        })
        lib.showContext('main_menu')
    end)
end)
