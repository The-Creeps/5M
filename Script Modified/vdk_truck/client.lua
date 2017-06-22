CARITEMS = {}
PLAYTEMS = {}

local is_int = function(n)
  return (type(n) == "number") and (math.floor(n) == n)
end


RegisterNetEvent("car:hoodContent")
AddEventHandler("car:hoodContent", function(items)
    if items then
        CARITEMS = items
        CoffreMenu()
    else
        CARITEMS = {}
        CoffreMenu()
    end
end)

RegisterNetEvent("car:systemMessage")
AddEventHandler("car:systemMessage", function(message)
    Notify(message)
end)

RegisterNetEvent("playercar:hoodContent")
AddEventHandler("playercar:hoodContent", function(items)
    if items then
        PLAYTEMS = items
        DepotMenu()
    else
        PLAYTEMS = {}
        DepotMenu()
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        if IsControlJustPressed(1, 182) then
            local vehFront = VehicleInFront()
            if vehFront > 0 then
                if Menu.hidden then
                    if(GetVehicleDoorLockStatus(vehFront) < 2) then
                        ClearMenu()
                        SetVehicleDoorOpen(vehFront, 5, false, false)
                        MenuTrunk()
                        Menu.hidden = not Menu.hidden
                    end
                else
                    SetVehicleDoorShut(vehFront, 5, false)
                    Menu.hidden = not Menu.hidden
                end
            end
        end
        Menu.renderGUI()
    end
end)

--Notification joueur
function Notify(text)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(text)
	DrawNotification(false, false)
end

--MENU D'ACCUEIL--
function MenuTrunk()
    MenuTitle = "Menu"
    Menu.addButton("Déposer dans le coffre", "GetPlayerItem", ind)
    Menu.addButton("Sortir du coffre", "GetTrunkItem", ind)
end

--MENU POUR RECUPERER LES OBJETS DE L'INVENTAIRE DE LA VOITURE VERS LE JOUEUR--
function CoffreMenu()
    ClearMenu()
    local arg = {}
    MenuTitle = "Coffre"
    for ind, value in pairs(CARITEMS) do
        arg = { ind, value.libelle, value.quantity }
        if (value.quantity > 0) then
            Menu.addButton(value.libelle .. " : " .. tostring(value.quantity), "GetItem", arg)
        end
    end
    Menu.hidden = not Menu.hidden
end

--MENU POUR DEPOSER LES OBJETS DE L'INVENTAIRE DU JOUEUR VERS LA VOITURE--
function DepotMenu()
    ClearMenu()
    local arg = {}
    MenuTitle = "Sac à dos"
    for ind, value in pairs(PLAYTEMS) do
        arg = { ind, value.libelle, value.quantity }
        if (value.quantity > 0) then
            Menu.addButton(value.libelle .. " : " .. tostring(value.quantity), "PutItem", arg)
        end
    end
    Menu.hidden = not Menu.hidden
end

--ACTION DE TRANSFERT DE L'OBJET VERS L'INVENTAIRE DU JOUEUR--
function GetItem(arg)
    local id = tonumber(arg[1])
    local lib = arg[2]
    local qtymax = arg[3]
    local vehFront = VehicleInFront()
    if vehFront > 0 then
        local qty = DisplayInput()
        if (type(qty) ~= "number") then
            Notify("Ceci n'est pas une quantité valide")
            return false
        end
        if tonumber(qty) <= tonumber(qtymax) and tonumber(qty) > -1  then
            TriggerServerEvent("car:looseItem", GetVehicleNumberPlateText(vehFront), id, tonumber(qty))
        else
            Notify("Il n'y a pas autant de " .. lib .. " dans votre inventaire")
        end
    end
    Menu.hidden = true
end

--ACTION DE TRANSFERT DE L'OBJET VERS L'INVENTAIRE DE LA VOITURE--
function PutItem(arg)
    local id = tonumber(arg[1])
    local lib = arg[2]
    local qtymax = arg[3]
    local vehFront = VehicleInFront()
    if vehFront > 0 then
        local qty = DisplayInput()
        if (type(qty) ~= "number") then
            Notify("Ceci n'est pas une quantité valide")
            return false
        end
        if tonumber(qty) <= tonumber(qtymax) and tonumber(qty) > -1 then
            TriggerServerEvent("car:receiveItem", GetVehicleClass(vehFront), GetVehicleNumberPlateText(vehFront), id, lib, tonumber(qty))
        else
            Notify("Il n'y a pas autant de " .. lib .. " dans le coffre")
        end
    end
    Menu.hidden = true
end

--RECUPERATION DE L'INVENTAIRE DU JOUEUR--
function GetPlayerItem(id)
    local vehFront = VehicleInFront()
    if vehFront > 0 then
        TriggerServerEvent("playercar:getItems_s")
    end
    Menu.hidden = true
    MenuTrunk()
end

--RECUPERATION DE L'INVENTAIRE DE LA VOITURE--
function GetTrunkItem(id)
    local vehFront = VehicleInFront()
    if vehFront > 0 then
        TriggerServerEvent("car:getItems", GetVehicleNumberPlateText(vehFront))
    end
    Menu.hidden = true
end

function VehicleInFront()
    local pos = GetEntityCoords(GetPlayerPed(-1))
    local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 3.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
    local a, b, c, d, result = GetRaycastResult(rayHandle)
    return result
end

function DisplayInput()
    DisplayOnscreenKeyboard(1, "FMMC_MPM_TYP8", "", "", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Wait(1)
    end
    if GetOnscreenKeyboardResult() then
        return tonumber(GetOnscreenKeyboardResult())
    end
end

function Chat(debugg)
    TriggerEvent("chatMessage", '', { 0, 0x99, 255 }, tostring(debugg))
end