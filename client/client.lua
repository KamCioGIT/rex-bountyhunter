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
    return (a.args and a.args.reward or 0) > (b.args and b.args.reward or 0)
end

--------------------------------
-- bounty board
--------------------------------
RegisterNetEvent('rex-bountyhunter:client:openboard', function()
    RSGCore.Functions.TriggerCallback('rex-bountyhunter:server:getplayers', function(data)
        local options = {}
        for _, value in pairs(data) do
            local character = json.decode(value.charinfo)
            local firstname = character.firstname
            local lastname = character.lastname
            local citizenid = value.citizenid
            local outlawstatus = value.outlawstatus

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
        
        -- table sort
        table.sort(options, sortOrder)

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
                    firstname = data.firstname,
                    lastname = data.lastname,
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
                    firstname = data.firstname,
                    lastname = data.lastname,
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
            local input = lib.inputDialog('Additional Bounty', {
                { 
                    label = 'Amount',
                    type = 'input',
                    required = true,
                    icon = 'fa-solid fa-dollar-sign'
                },
            })
    
            if not input then
                return
            end
            
            local newreward = (tonumber(input[1]) or 0) + data.reward
            TriggerServerEvent('rex-bountyhunter:server:addplayerbounty', input[1], newreward, data)
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
            RSGCore.Functions.TriggerCallback('rex-bountyhunter:server:getrewardplayers', function(players)
                local options = {}
                for k, v in pairs(players) do
                    options[#options + 1] = {
                        title = 'ID: ' ..v.id..' | '..v.name,
                        icon = 'fa-solid fa-circle-user',
                        event = 'rex-bountyhunter:client:giveplayerbounty',
                        args = { 
                            rewardplayer = v.id,
                            rewardplayername = v.name,
                            rewardamount = data.reward,
                            bountycitizenid = data.citizenid,
                            bountyfirstname = data.firstname,
                            bountylastname = data.lastname
                        },
                        arrow = true,
                    }
                end
                lib.registerContext({
                    id = 'leo_givebounty',
                    title = 'Bounty Reward',
                    menu = 'outlaw_menu',
                    position = 'top-right',
                    options = options
                })
                lib.showContext('leo_givebounty')
            end)
        else
            lib.notify({ title = 'You are not Law Enforcement', type = 'inform', duration = 7000 })
        end
    end)
end)

--------------------------------
-- confirm payment
--------------------------------
RegisterNetEvent('rex-bountyhunter:client:giveplayerbounty', function(data)
    local input = lib.inputDialog('Pay '..data.rewardplayername, {
        {
            label = 'Confirm Payment of $'..data.rewardamount,
            type = 'select',
            options = {
                { value = 'yes', label = 'Yes' },
                { value = 'no',  label = 'No' }
            },
            required = true
        },
    })

    if not input then
        return 
    end

    if input[1] == 'no' then
        return
    end

    TriggerServerEvent('rex-bountyhunter:server:payplayer', data)
end)

--------------------------------
-- create bounty
--------------------------------
RegisterNetEvent('rex-bountyhunter:client:createbounty', function()
    RSGCore.Functions.TriggerCallback('rex-bountyhunter:server:getplayers', function(result)
        local options = {}
        for _, value in pairs(result) do
            local character = json.decode(value.charinfo)
            local firstname = character.firstname
            local lastname = character.lastname
            local citizenid = value.citizenid
            local outlawstatus = value.outlawstatus

            if outlawstatus < 100 then
                options[#options + 1] = {
                    title = firstname..' '..lastname..' ('..citizenid..')',
                    icon = 'fa-solid fa-mask',
                    event = 'rex-bountyhunter:client:setbountyamount',
                    args = {
                        firstname = firstname,
                        lastname = lastname,
                        citizenid = citizenid,
                        currentreward = outlawstatus
                    },
                    arrow = true
                }
            end
        end
        
        -- table sort
        table.sort(options, function(a, b) return a.title < b.title end)

        lib.registerContext({
            id = 'create_bounty',
            title = 'Create Bounty',
            position = 'top-right',
            options = options
        })
        lib.showContext('create_bounty')
    end)
end)

RegisterNetEvent('rex-bountyhunter:client:setbountyamount', function(data)
    local input = lib.inputDialog('Set Bounty for '..data.firstname..' '..data.lastname, {
        {
            label = 'Amount',
            type = 'input',
            icon = 'fa-solid fa-dollar-sign',
            description = 'min = $100 : max = $'..Config.MaxBounty,
            required = true
        },
    })

    if not input then
        return 
    end

    local amount = tonumber(input[1])
    if not amount then
        lib.notify({ title = 'Invalid amount', type = 'error', duration = 7000 })
        return
    end

    if amount > Config.MaxBounty then
        lib.notify({ title = 'Greater than Max Bounty', type = 'inform', duration = 7000 })
        return 
    end

    if amount < 100 then
        lib.notify({ title = 'Minimum amount is $100', type = 'inform', duration = 7000 })
        return 
    end

    local bountyadjust = amount + tonumber(data.currentreward)

    TriggerServerEvent('rex-bountyhunter:server:createnewbounty', data, bountyadjust, amount)
end)
