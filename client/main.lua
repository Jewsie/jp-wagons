local RSGCore = exports['rsg-core']:GetCoreObject()

local wagonid = nil
local spawnedWagon = nil
local isSpawned = false
local wagonBlip = nil
local ownedCID = nil
local spawnedHorseID = 0
local wagonStorage = 0
local wagonWeight = 0

exports('CheckActiveWagon', function()
    return spawnedWagon
end)

RegisterNetEvent('jp-wagons:client:updatewagonid', function(wagonid, cid)
    ownedCID = cid
    print('Owned CID: ' .. ownedCID)
end)

Citizen.CreateThread(function()
    while true do
        Wait(100)
        if spawnedWagon ~= nil then
            RemoveBlip(wagonBlip)
            local wagonPos = GetEntityCoords(spawnedWagon)
            wagonBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, wagonPos)
            SetBlipSprite(wagonBlip, 874255393)
            SetBlipScale(wagonBlip, 0.2)
            Citizen.InvokeNative(0x9CB1A1623062F402, wagonBlip, 'Owned Wagon')
        end
    end
end)

Citizen.CreateThread(function()
    local model = 'U_M_M_BwmStablehand_01'

    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(1)
    end
    local coords = CONFIG.DealerPos
    local dealer = CreatePed(model, coords.x, coords.y, coords.z - 1.0, coords.w, false, false, 0, 0)
    Citizen.InvokeNative(0x283978A15512B2FE, dealer, true)
    SetEntityCanBeDamaged(dealer, false)
    SetEntityInvincible(dealer, true)
    FreezeEntityPosition(dealer, true)
    SetBlockingOfNonTemporaryEvents(dealer, true)
    Wait(1)
    
    exports['rsg-target']:AddTargetEntity(dealer, {
        options = {
            {
                icon = '',
                label = 'Buy Wagon',
                targeticon = 'fas fa-eye',
                action = function()
                    WagonMenu()
                end
            },
            {
                icon = '',
                label = 'View Wagon',
                targeticon = 'fas fa-eye',
                action = function()
                    TriggerServerEvent('jp-wagons:server:ownedwagons')
                end
            },
            {
                icon = '',
                label = 'Store Wagon',
                targeticon = 'fas fa-eye',
                action = function()
                    local wagonPos = GetEntityCoords(spawnedWagon)
                    local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, wagonPos.x, wagonPos.y, wagonPos.z, true)

                    if spawnedWagon ~= nil then
                        if distance <= 10 then
                            DeleteVehicle(spawnedWagon)
                            spawnedWagon = nil
                            RSGCore.Functions.Notify('You stored your wagon!', 'success', 3000)
                            RemoveBlip(wagonBlip)
                        else
                            RSGCore.Functions.Notify('Your wagon is too far away!', 'error', 3000)
                        end
                    else
                        RSGCore.Functions.Notify('You don\'t have any wagon out!', 'error', 3000)
                    end
                end
            },
            {
                icon = '',
                label = 'Trade Wagon',
                targeticon = 'fas fa-eye',
                action = function()
                    local info = exports['rsg-input']:ShowInput({
                        header = 'Trade your wagon to another player',
                        inputs = {
                            {
                                text = 'Server ID#',
                                name = 'id',
                                type = 'number',
                                isRequired = true
                            }
                        }
                    })

                    TriggerServerEvent('jp-wagons:server:tradewagon', info.id, spawnedWagon)
                    DeleteVehicle(spawnedWagon)
                    spawnedWagon = nil
                end
            },
            {
                icon = '',
                label = 'Sell Wagon',
                targeticon = 'fas fa-eye',
                action = function()
                    local wagonPos = GetEntityCoords(spawnedWagon)
                    local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, wagonPos.x, wagonPos.y, wagonPos.z, true)

                    if spawnedWagon ~= nil then
                        if distance <= 10 then
                            TriggerServerEvent('gs-wagon:server:sellwagon', spawnedWagon)
                            DeleteVehicle(spawnedWagon)
                            spawnedWagon = nil
                        else
                            RSGCore.Functions.Notify('Your wagon is too far away!', 'error', 3000)
                        end
                    else
                        RSGCore.Functions.Notify('You don\'t have any wagon out!', 'error', 3000)
                    end
                end
            }
        }
    })

    local dealerBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords.x, coords.y, coords.z)
    SetBlipSprite(dealerBlip, -1236452613)
    SetBlipScale(dealerBlip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, dealerBlip, 'Wagon Store')
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, RSGCore.Shared.Keybinds['J']) then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local wagonPos = GetEntityCoords(spawnedWagon)
            local distance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, wagonPos.x, wagonPos.y, wagonPos.z, true)
            
            if not isSpawned or (isSpawned and distance > 50) then
                TriggerServerEvent('jp-wagons:server:spawnwagon')
            end

            if isSpawned and distance <= 50 then
                TaskGoToEntity(spawnedWagon, PlayerPedId(), 30000, 5)
            end
        end

        if IsControlJustPressed(0, RSGCore.Shared.Keybinds['B']) then
            local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if currentVehicle == spawnedWagon then
                HorseInventory()
            end
        end
    end
end)

RegisterNetEvent('jp-wagons:client:spawnwagon', function(model, ownedCid, spawnedwagonid, storage, weight)
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local citizenid = PlayerData.citizenid
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 10.0, 0.0)
    RemoveBlip(wagonBlip)
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(1)
    end

    if spawnedWagon ~= nil then
        DeleteVehicle(spawnedWagon)
        spawnedWagon = nil
    end
    
    spawnedWagon = CreateVehicle(model, offset.x, offset.y, offset.z, playerCoords.z, true, false, false)
    isSpawned = true
    local wagonPos = GetEntityCoords(spawnedWagon)

    if citizenid == ownedCid then
        wagonBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, wagonPos)
        SetBlipSprite(wagonBlip, 874255393)
        SetBlipScale(wagonBlip, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, wagonBlip, 'Owned Wagon')
    end

    wagonStorage = storage
    wagonWeight = weight
    wagonid = spawnedwagonid
    spawnedHorseID = spawnedWagon

    TriggerServerEvent('jp-wagons:server:updatetempwagon', spawnedWagon)
end)

function WagonMenu()
    menuData = {}

    table.insert(menuData, {
        header = 'Wagon Store',
        isMenuHeader = true
    })

    for _, wagons in ipairs(CONFIG.wagonid) do
        table.insert(menuData, {
            header = wagons.name,
            txt = 'Price: $' .. wagons.price .. ' Space: ' .. wagons.storage,
            params = {
                event = 'jp-wagons:client:wagoninfo',
                isServer = false,
                args = {
                    price = wagons.price,
                    model = wagons.model,
                    storage = wagons.storage,
                    weight = wagons.weight,
                    model = wagons.model
                }
            }
        })
    end

    table.insert(menuData, {
        header = 'Close Menu',
        txt = '',
        params = {
            event = 'rsg-menu:closeMenu'
        }
    })

    exports['rsg-menu']:openMenu(menuData)
end

RegisterNetEvent('jp-wagons:client:wagoninfo', function(data)
    local price = data.price
    local model = data.model
    local storage = data.storage
    local weight = data.weight

    local info = exports['rsg-input']:ShowInput({
        header = 'Wagon Info',
        inputs = {
            {
                text = 'Wagon Name',
                name = 'name',
                type = 'text',
                isRequired = true
            }
        }
    })

    TriggerServerEvent('jp-wagons:server:buywagon', info.name, price, model, storage, weight)
end)

RegisterNetEvent('jp-wagons:client:ownedwagons', function(storeWagons)
    menuData = {}

    table.insert(menuData, {
        header = 'Owned Wagons',
        isMenuHeader = true
    })

    for i = 1, #storeWagons do
        local wagons = storeWagons[i]
        table.insert(menuData, {
            header = wagons.name,
            txt = 'Wagon ID: ' .. wagons.wagonid .. ' Storage: ' .. wagons.storage .. ' Active: ' .. wagons.active,
            params = {
                event = 'jp-wagons:server:activatewagon',
                isServer = true,
                args = {
                    wagonid = wagons.wagonid
                }
            }
        })
    end

    table.insert(menuData, {
        header = 'Close Menu',
        txt = '',
        params = {
            event = 'rsg-menu:closeMenu'
        }
    })

    exports['rsg-menu']:openMenu(menuData)
end)

function HorseInventory()
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'player_' .. wagonid, {
        maxweight = wagonWeight,
        slots = wagonStorage,
    })
    TriggerEvent('inventory:client:SetCurrentStash', 'player_' .. wagonid)
end