local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterServerEvent('jp-wagons:server:buywagon', function(name, price, model, storage, weight)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local randomLetters = string.char(math.random(65, 90), math.random(65, 90), math.random(65, 90))
    local wagonid = randomLetters .. math.random(100, 999)
    local citizenid = Player.PlayerData.citizenid

    MySQL.insert('INSERT INTO `player_wagons` (citizenid, wagonid, model, name, storage, weight) VALUES (?, ?, ?, ?, ?, ?)', {
        citizenid, wagonid, model, name, storage, weight
    }, function(id)
        print(id)
    end)

    Player.Functions.RemoveMoney('cash', price)
end)

RegisterServerEvent('jp-wagons:server:ownedwagons', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    MySQL.query('SELECT `wagonid`, `name`, `storage`, `active` FROM `player_wagons` WHERE `citizenid` = ?', {
        citizenid
    }, function(response)
        if response then
            local storeWagons = {}
            for i = 1, #response do
                local row = response[i]
                table.insert(storeWagons, {
                    wagonid = row.wagonid,
                    name = row.name,
                    storage = row.storage,
                    active = row.active
                })
            end
            TriggerClientEvent('jp-wagons:client:ownedwagons', src, storeWagons)
        end
    end)
end)

RegisterServerEvent('jp-wagons:server:activatewagon', function(data)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local currentActive = 1
    local newActive = 0

    MySQL.update('UPDATE player_wagons SET active = ? WHERE citizenid = ? AND active = ?', {
        newActive, citizenid, currentActive
    }, function(affectedRows)
        print(affectedRows)
    end)

    MySQL.update('UPDATE player_wagons SET active = ? WHERE wagonid = ?', {
        currentActive, data.wagonid
    }, function(affectedRows)
        print(affectedRows)
    end)
end)

RegisterServerEvent('jp-wagons:server:spawnwagon')
AddEventHandler('jp-wagons:server:spawnwagon', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local isActive = 1

    MySQL.query('SELECT `model`, `citizenid`, `wagonid`, `storage`, `weight` FROM `player_wagons` WHERE `citizenid` = ? AND `active` = ?', {citizenid, isActive}, function(result)
        if result and #result > 0 then
            for i = 1, #result do
                local row = result[i]
                local model = row.model
                local ownedCid = row.citizenid
                local storage = row.storage
                local weight = row.weight
                local wagonid = row.wagonid
                TriggerClientEvent('jp-wagons:client:spawnwagon', src, model, ownedCid, wagonid, storage, weight)
            end
        else
            RSGCore.Functions.Notify(src, 'You don\'t have any active wagons!', 'error', 3000)
        end
    end)  
end)

RegisterServerEvent('jp-wagons:server:updatetempwagon')
AddEventHandler('jp-wagons:server:updatetempwagon', function(tempwagon)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local isActive = 1

    MySQL.update('UPDATE player_wagons SET tempwagon = ? WHERE citizenid = ? AND active = ?', {
        tempwagon, citizenid, isActive
    }, function(affectedRows)
    end)
end)

RegisterServerEvent('gs-wagon:server:sellwagon', function(wagon)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local model = nil
    local price = 0

    MySQL.query('SELECT `model` FROM `player_wagons` WHERE tempwagon = ?', {wagon}, function(result)
        if result and #result > 0 then
            for i = 1, #result do
                local row = result[i]
                model = row.model

                for i = 1, #CONFIG.wagonid do
                    if model == CONFIG.wagonid[i].model then
                        price = CONFIG.wagonid[i].price
                        break
                    end
                end

                Player.Functions.AddMoney('cash', price)

                MySQL.execute('DELETE FROM `player_wagons` WHERE tempwagon = ?', { wagon }, function(rowsChanged)
                    if rowsChanged > 0 then
                    else
                        print('No matching rows found.')
                    end
                end)
            end
        else
            RSGCore.Functions.Notify(src, 'You don\'t have any active wagons!', 'error', 3000)
        end
    end)  
end)

RegisterServerEvent('jp-wagons:server:checkownedwagons', function(wagon)
    local src = source

    MySQL.query('SELECT `tempwagon`, `citizenid` FROM `player_wagons` WHERE tempwagon = ?', {citizenid}, function(result)
        if result and #result > 0 then
            for i = 1, #result do
                local row = result[i]
                local wagonid = tempwagon
                local cid = row.citizenid

                TriggerClientEvent('jp-wagons:client:updatewagonid', src, wagonid, cid)
            end
        else
            RSGCore.Functions.Notify(src, 'You don\'t have any active wagons!', 'error', 3000)
        end
    end)  
end)

RegisterServerEvent('jp-wagons:server:tradewagon', function(id, wagon)
    local src = source
    local player = RSGCore.Functions.GetPlayer(src)
    local recipient = RSGCore.Functions.GetPlayer(id)
    local rcid = recipient.PlayerData.citizenid
    local cid = player.PlayerData.citizenid

    if rcid ~= nil then
        MySQL.update('UPDATE player_ranches SET citizenid = ? WHERE citizenid = ? AND tempwagon = ?', {
            rcid, cid, wagon
        }, function(affectedRows)
            print(affectedRows)
        end)
    else
        RSGCore.Functions.Notify(src, 'No player found!', 'error', 3000)
    end
end)