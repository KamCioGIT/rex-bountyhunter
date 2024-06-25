local RSGCore = exports['rsg-core']:GetCoreObject()

--------------------------------
-- target bounty board
--------------------------------
CreateThread(function()
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
            {
                type = 'client',
                icon = 'far fa-eye',
                label = 'Create New Bounty',
                action = function()
                    TriggerEvent('rex-bountyhunter:client:createbounty')
                end
            },
        },
        distance = 3
    })
end)

--------------------------------
-- sort table function
--------------------------------
local function sortOrder(a, b)
    return a.value < b.value
end

--------------------------------
-- bounty board
--------------------------------
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

            -- table sort
            table.sort(options, sortOrder)

            if outlawstatus >= 100 then
                options[#options + 1] = {
                    title = firstname..' '..lastname..' ('..citizenid..')',
                    description = 'bounty reward : $'..outlawstatus,
                    icon = 'fa-solid fa-mask',
                    event = 'rex-bountyhunter:client:viewoutlaw',
                    args = {
                        firstname = firstname,
                        lastname = lastname,
                        citizenid = citizenid,
                        reward = outlawstatus
                    },
                    arrow = true
                }
            end
        end
        lib.registerContext({
            id = 'main_menu',
            title = 'Wanted Outlaws',
            position = 'top-right',
            options = options
        })
        lib.showContext('main_menu')
    end)
end)

--------------------------------
-- view outlaw
--------------------------------
RegisterNetEvent('rex-bountyhunter:client:viewoutlaw', function(data)
    lib.registerContext({
        id = 'outlaw_menu',
        menu = 'main_menu',
        title = 'Outlaw '..data.firstname..' '..data.lastname,
        options = {
            {
                title = 'Add Bounty (Law Only)',
                description = 'add bounty to a player',
                icon = 'fa-solid fa-money-bill-transfer',
                event = 'rex-bountyhunter:client:addplayerbounty',
                args = {
                    reward = data.reward,
                    citizenid = data.citizenid,
                },
                arrow = true
            },
            {
                title = 'Pay Bounty (Law Only)',
                description = 'pay bounty of $'..data.reward..' to player',
                icon = 'fa-solid fa-money-bill-transfer',
                event = 'rex-bountyhunter:client:paybountyhunter',
                args = {
                    reward = data.reward,
                    citizenid = data.citizenid,
                },
                arrow = true
            },
        }
    })
    lib.showContext('outlaw_menu')
end)

--------------------------------
-- add more bounty to an outlaw
--------------------------------
RegisterNetEvent('rex-bountyhunter:client:addplayerbounty', function(data)
    RSGCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.job.type == "leo" then
            print(data.reward, data.citizenid)
        else
            lib.notify({ title = 'You are not Law Enforcement', type = 'inform', duration = 7000 })
        end
    end)
end)

--------------------------------
-- pay bounty
--------------------------------
RegisterNetEvent('rex-bountyhunter:client:paybountyhunter', function(data)
    RSGCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.job.type == "leo" then
            print(data.reward, data.citizenid)
        else
            lib.notify({ title = 'You are not Law Enforcement', type = 'inform', duration = 7000 })
        end
    end)
end)

--------------------------------
-- create bounty
--------------------------------
RegisterNetEvent('rex-bountyhunter:client:createbounty', function()
	print('create bounty workings')
end)
