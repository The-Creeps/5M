--Version 1.5
require "resources/mysql-async/lib/MySQL"

--Déclaration des EventHandler
RegisterServerEvent("projectEZ:savelastpos")
RegisterServerEvent("projectEZ:SpawnPlayer")

--Intégration de la position dans MySQL
AddEventHandler("projectEZ:savelastpos", function( LastPosX , LastPosY , LastPosZ , LastPosH )
	TriggerEvent('es:getPlayerFromId', source, function(user)
		--Récupération du SteamID.
		local player = user.identifier
		--Formatage des données en JSON pour intégration dans MySQL.
		local LastPos = "{" .. LastPosX .. ", " .. LastPosY .. ",  " .. LastPosZ .. ", " .. LastPosH .. "}"
		--Exécution de la requêtes SQL.
		MySQL.Async.execute("UPDATE users SET `lastpos`=@lastpos WHERE identifier = @username", {['@username'] = player, ['@lastpos'] = LastPos})
	end)
end)

AddEventHandler("projectEZ:SpawnPlayer", function()
	TriggerEvent('es:getPlayerFromId', source, function(user)
		--Récupération du SteamID.
		local player = user.identifier
		--Récupération des données générée par la requête.
		local result = MySQL.Sync.fetchScalar("SELECT lastpos FROM users WHERE identifier = @username", {['@username'] = player})	
		-- Vérification de la présence d'un résultat avant de lancer le traitement.
		if(result ~= nil)then
				-- Décodage des données récupérées
				local ToSpawnPos = json.decode(result)
				print(ToSpawnPos[1])
				-- On envoie la derniere position vers le client pour le spawn
				TriggerClientEvent("projectEZ:spawnlaspos", source, ToSpawnPos[1], ToSpawnPos[2], ToSpawnPos[3])
		end
	end)
end)

-- Sauvegarde de la position lors de la deconnexion
AddEventHandler('playerDropped', function()
	TriggerEvent('es:getPlayerFromId', source, function(user)
		--Formatage des données en JSON pour intégration dans MySQL.
		local LastPos = "{" .. user.coords.x .. ", " .. user.coords.y .. ",  " .. user.coords.z .. ", " .. user.coords.h .. "}"
		--Exécution de la requêtes SQL.
		MySQL.Async.execute("UPDATE users SET `lastpos`=@lastpos WHERE identifier = @identifier",{["@lastpos"] = LastPos, ['@identifier'] = user.identifier})
  	end)
end)