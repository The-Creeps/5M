require "resources/mysql-async/lib/MySQL"

local CARS = {}
local maxCapacity = {
    [0] = { ["size"] = 13}, --Compact
    [1] = { ["size"] = 20}, --Sedan
    [2] = { ["size"] = 30}, --SUV
    [3] = { ["size"] = 24}, --Coupes
    [4] = { ["size"] = 28}, --Muscle
    [5] = { ["size"] = 10}, --Sports Classics
    [6] = { ["size"] = 8}, --Sports
    [7] = { ["size"] = 5}, --Super
    [8] = { ["size"] = 2}, --Motorcycles
    [9] = { ["size"] = 25}, --Off-road
    [10] = { ["size"] = 100}, --Industrial
    [11] = { ["size"] = 60}, --Utility
    [12] = { ["size"] = 40}, --Vans
    [13] = { ["size"] = 0}, --Cycles
    [14] = { ["size"] = 0}, --Boats
    [15] = { ["size"] = 0}, --Helicopters
    [16] = { ["size"] = 0}, --Planes
    [17] = { ["size"] = 0}, --Service
    [18] = { ["size"] = 0}, --Emergency
    [19] = { ["size"] = 0}, --Military
    [20] = { ["size"] = 500}, --Commercial
    [21] = { ["size"] = 0}, --Trains
}

MySQL.Async.fetchAll("SELECT vehicle_plate AS plate, items.id AS id, items.libelle AS libelle, quantity FROM user_vehicle LEFT JOIN vehicle_inventory ON `user_vehicle`.`vehicle_plate` = `vehicle_inventory`.`plate` LEFT JOIN items ON `vehicle_inventory`.`item` = `items`.`id`", {}, 
    function (result)
    if (result) then
        for _, v in ipairs(result) do
            if (not IndexSearch(v.plate)) then
                CARS[v.plate] = {}
            end
            if (v.id and v.libelle and v.quantity) then
                table.insert(CARS[v.plate], v.id, {libelle = v.libelle, quantity = v.quantity})
            end
        end
    end
end)


RegisterServerEvent("playercar:getItems_s")
AddEventHandler("playercar:getItems_s", function()
  TriggerEvent('es:getPlayerFromId', source, function(user)
    items = {}
    local player = user.identifier
    
    MySQL.Async.fetchAll("SELECT * FROM user_inventory JOIN items ON `user_inventory`.`item_id` = `items`.`id` WHERE user_id = @username", {
      ['@username'] = player
    }, function (result)
      if (result) then
        for _, v in ipairs(result) do
         table.insert(items, tonumber(v.item_id), {libelle = v.libelle, quantity = v.quantity})
        end
      end
      TriggerClientEvent("playercar:hoodContent", source, items)
    end)
  end)
end)

RegisterServerEvent("car:getItems")
AddEventHandler("car:getItems", function(plate)
    local res = nil
    if CARS[plate] then
        res = CARS[plate]
    end
    TriggerClientEvent("car:hoodContent", source, res)
end)

RegisterServerEvent("car:receiveItem")
AddEventHandler("car:receiveItem", function(vehclass, plate, item, lib, quantity)
    local ActualSlotUsed = getSlots(plate)
    local limitslots = ActualSlotUsed + quantity
    if (limitslots <= maxCapacity[vehclass].size) then
        if not IndexSearch(plate) then
            CARS[plate] = {}
        end
        add({ item, quantity, plate, lib })
        TriggerClientEvent("player:looseItem", source, item, quantity)
    else
        if quantity > maxCapacity[vehclass].size then
            TriggerClientEvent("car:systemMessage", source, "Ce vehicule ne peut contenir que " .. maxCapacity[vehclass].size .. " objets")
        elseif ActualSlotUsed >= maxCapacity[vehclass].size then
            TriggerClientEvent("car:systemMessage", source, "Le coffre de ce vehicule est plein !")
        elseif limitslots > maxCapacity[vehclass].size then
            TriggerClientEvent("car:systemMessage", source, "Il n'y a plus assez de place !'")
        end 
    end
end)

RegisterServerEvent("car:looseItem")
AddEventHandler("car:looseItem", function(plate, item, quantity)
    local cItem = CARS[plate][item]
    if (cItem.quantity >= quantity) then
        delete({ item, quantity, plate })
        TriggerClientEvent("player:receiveItem", source, item, quantity)
    end
end)

AddEventHandler('BuyForVeh', function(name, vehicle, price, plate, primarycolor, secondarycolor, pearlescentcolor, wheelcolor)
    CARS[plate] = {}
end)

function add(arg)
    local itemId = tonumber(arg[1])
    local qty = arg[2]
    local plate = arg[3]
    local lib = arg[4]
    local query
    local item
    if CARS[plate][itemId] then
        item = CARS[plate][itemId]
        query = "UPDATE vehicle_inventory SET `quantity` = @qty WHERE `plate` = @plate AND `item` = @item"
        item.quantity = item.quantity + qty
    else
        CARS[plate][itemId] = {quantity = qty, libelle = lib}
        item = CARS[plate][itemId]
        print(CARS[plate][itemId].libelle)
        query = "INSERT INTO vehicle_inventory (`quantity`,`plate`,`item`) VALUES (@qty,@plate,@item)"
    end
    MySQL.Async.execute(query,{ ['@plate'] = plate, ['@qty'] = item.quantity, ['@item'] = itemId })
end

function delete(arg)
    local itemId = tonumber(arg[1])
    local qty = arg[2]
    local plate = arg[3]
    local item = CARS[plate][itemId]
    item.quantity = item.quantity - qty
    MySQL.Async.execute("UPDATE vehicle_inventory SET `quantity` = @qty WHERE `plate` = @plate AND `item` = @item",
    { ['@plate'] = plate, ['@qty'] = item.quantity, ['@item'] = itemId })
end

function getSlots(plate)
    local pods = 0
    if (IndexSearch(plate)) then
        for _, v in pairs(CARS[plate]) do
            pods = pods + v.quantity
        end
    end
    return pods
end

-- get's the player id without having to use bugged essentials
function getPlayerID(source)
    local identifiers = GetPlayerIdentifiers(source)
    local player = getIdentifiant(identifiers)
    return player
end

-- gets the actual player id unique to the player,
-- independent of whether the player changes their screen name
function getIdentifiant(id)
    for _, v in ipairs(id) do
        return v
    end
end

function stringSplit(self, delimiter)
  local a = self:Split(delimiter)
  local t = {}

  for i = 0, #a - 1 do
     table.insert(t, a[i])
  end

  return t
end

function IndexSearch(plate)
    for key, value in pairs(CARS) do
        if (key == plate) then
            return true
        end
    end
    print("vehicule immatriculé " .. plate .. " chargé")
    return false
end