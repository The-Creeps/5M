RegisterNetEvent('project:notify')
RegisterNetEvent("project:spawnlaspos")

local firstspawn = 0
local loaded = false

--Boucle Thread d'envoie de la position toutes les x secondes vers le serveur pour effectuer la sauvegarde
Citizen.CreateThread(function ()
	while true do
	--Durée entre chaque requêtes : 60000 = 60 secondes
	Citizen.Wait(60000)
		--Récupération de la position x, y, z du joueur
		LastPosX, LastPosY, LastPosZ = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
		--Récupération de l'azimut du joueur
	    local LastPosH = GetEntityHeading(GetPlayerPed(-1))
		--Envoi des données vers le serveur
	    TriggerServerEvent("project:savelastpos", LastPosX , LastPosY , LastPosZ, LastPosH)
	end
end)

--Event permetant au serveur d'envoyez une notification au joueur
RegisterNetEvent('project:notify')
AddEventHandler('project:notify', function(alert)
    if not origin then
        Notify(alert)
    end
end)

--Notification joueur
function Notify(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, false)
end

--Event pour le spawn du joueur vers la dernière position connue
AddEventHandler("project:spawnlaspos", function(PosX, PosY, PosZ)
	if not loaded then
		SetEntityCoords(GetPlayerPed(-1), PosX, PosY, PosZ, 1, 0, 0, 1)
		Notify("Vous voici à votre dernière position")
		loaded = true
	end
	Notify(loaded)
end)

--Action lors du spawn du joueur
AddEventHandler('playerSpawned', function(spawn)
--On verifie que c'est bien le premier spawn du joueur
if firstspawn == 0 then
	TriggerServerEvent("project:SpawnPlayer")
	firstspawn = 1
end
end)