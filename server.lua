Citizen.CreateThread(function()	
		local logTypes = {
			["Conexion"] = {"usuario:","fecha:"},
			["Desconexion"] = {"usuario:","razon:","fecha:"}, 
			["Chat"] = {"usuario:","mensaje:","fecha:"},
			["Revividas de EMS"] = {"usuario:","paciente:","fecha:"},
			["Dar Objetos"] = {"usuario:","persona:","objeto:","cantidad:","fecha:"},
			["Tirar Objetos"] = {"usuario:","objeto:","cantidad:","fecha:"},
			["Bloqueo Inventario"] =  {"usuario:","persona:","fecha:"},
			["Propiedades"] = {"usuario:","moneda:","objeto:","cantidad:","fecha:"},
			["Inventario Maletero"] = {"usuario:","accion:","placa:","objeto:","cantidad:","fecha:"},
			["Muertes"] = {"usuario:","asesino:","razon:","fecha:"},
			["Confiscacion Policial"] = {"usuario:","sospechoso","objeto:","cantidad:","fecha:"},
			["Almacen Policia"] = {"usuario:","accion:","objeto:","cantidad:","fecha:"},
			["Servicio Comunitario"] = {"usuario:","yollanan","cantidad:","fecha:"},
			["Proceso Penitenciario"] = {"usuario:","yollanan","tiempo:","fecha:"},	
			["Transferencia de Vehiculos"] = {"usuario:","alan","placa:","fecha:"},
			["Facturas"] = {"usuario:","persona a quien factura:","descripcion:","cantidad:","fecha:"},
			["Acciones Bancarias"] = {"usuario:","accion:","cantidad:","fecha:"},
			["Twitter"] = {"usuario:","log","fecha:"},
			["Seccion Amarilla"] = {"usuario:","log","fecha:"},
			["Llamada Telefonica"] = {"usuario:","log","fecha:"},
			["Mensaje Telefonico"] =  {"usuario:","log","fecha:"},
			["Instagram"] = {"usuario:","log","fecha:"},
			["Crypto Monedas"] = {"usuario:","moneda:","cantidad:","fecha:","accion:"},
		}
		local weaponHashList = {}

		function registerNewLog(logtype,data,extraInfo)
			if extraInfo then
				guzelSendToDiscord(Config.WebhookURLs[logtype],logtype,data,extraInfo)
			else
				guzelSendToDiscord(Config.WebhookURLs[logtype],logtype,data)
			end
		end

		function getPlayerInfo(player)
			local _player = player
			local infoString = GetPlayerName(_player) .. " (" .. _player .. ")"
			if Config.BilgileriPaylas then
				for k,v in pairs(GetPlayerIdentifiers(_player)) do
					if string.sub(v, 1, string.len("discord:")) == "discord:" then
						infoString = infoString .. "\n<@" .. string.gsub(v,"discord:","") .. ">"
					else
						infoString = infoString .. "\n" .. v
					end
				end
			end
			return infoString
		end

		RegisterServerEvent('esx_jail:sendToJail')
		AddEventHandler('esx_jail:sendToJail', function(playerId, jailTime, quiet)
			registerNewLog("Proceso Penitenciario",{
				["usuario:"] = getPlayerInfo(source),
				["yollanan"] = getPlayerInfo(playerId),
				["tiempo:"] = jailTime,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterServerEvent('bank:deposit')
		AddEventHandler('bank:deposit', function(miktar)
			registerNewLog("Acciones Bancarias",{
				["usuario:"] = getPlayerInfo(source),
				["accion:"] = "Deposito",
				["cantidad:"] = miktar,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterServerEvent('bank:withdraw')
		AddEventHandler('bank:withdraw', function(miktar)
			registerNewLog("Acciones Bancarias",{
				["usuario:"] = getPlayerInfo(source),
				["accion:"] = "Retiro",
				["cantidad:"] = miktar,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterServerEvent('bank:transfer')
		AddEventHandler('bank:transfer', function(target,miktar)
			registerNewLog("Acciones Bancarias",{
				["usuario:"] = getPlayerInfo(source),
				["accion:"] = "Transferencia a (Usuario: "..GetPlayerName(target)..")",
				["cantidad:"] = miktar,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterServerEvent('gcPhone:transfer')
		AddEventHandler('gcPhone:transfer', function(target,miktar)
			registerNewLog("Acciones Bancarias",{
				["usuario:"] = getPlayerInfo(source),
				["accion:"] = "Transferencia Movil a (Usuario: "..GetPlayerName(target)..")",
				["cantidad:"] = miktar,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterServerEvent('esx_inventoryhud:disableTargetInv')
		AddEventHandler('esx_inventoryhud:disableTargetInv', function(target)
			registerNewLog("Bloqueo Inventario",{
				["usuario:"] = getPlayerInfo(source),
				["persona:"] = GetPlayerName(target),
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterServerEvent('gcPhone:startCall')
		AddEventHandler('gcPhone:startCall', function(phone_number, rtcOffer, extraData)
			registerNewLog("Llamada Telefonica",{
				["usuario:"] = getPlayerInfo(source),
				["log"] = "Llamada Saliente: "..phone_number,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterServerEvent('gcPhone:sendMessage')
		AddEventHandler('gcPhone:sendMessage', function(phoneNumber, message)
			registerNewLog("Mensaje Telefonico",{
				["usuario:"] = getPlayerInfo(source),
				["log"] = "Numero Telefonico: "..phoneNumber.."\nMensaje: "..message,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('gcPhone:insto_postinstas')
		AddEventHandler('gcPhone:insto_postinstas', function(username, password, message, image, filters)
			registerNewLog("Instagram",{
				["usuario:"] = getPlayerInfo(source),
				["log"] = "Nueva Publicacion: "..message.."\nFotografia: "..image,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			},image)
		end)

		RegisterNetEvent('gcPhone:yellow_postPagess')
		AddEventHandler('gcPhone:yellow_postPagess', function(firstname, phone_number, lastname, message)
			if Config.GCPhone then
			registerNewLog("Seccion Amarilla",{
				["usuario:"] = getPlayerInfo(source),
				["log"] = "Nueva Publicacion: "..message,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end
		end)

		RegisterNetEvent('gcPhone:twitter_postTweets')
		AddEventHandler('gcPhone:twitter_postTweets', function(message, image)
			if Config.CrewPhone then
			registerNewLog("Twitter",{
				["usuario:"] = getPlayerInfo(source),
				["log"] = "Nueva Publicacion: "..message,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			},image)
		end
		end)

		RegisterNetEvent('gcPhone:yellow_postIlan')
		AddEventHandler('gcPhone:yellow_postIlan', function(message, image)
			if Config.CrewPhone then
			registerNewLog("Seccion Amarilla",{
				["usuario:"] = getPlayerInfo(source),
				["log"] = "Nueva Publicacion: "..message,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			},image)
		end
		end)



		RegisterNetEvent('gcPhone:twitter_postTweets')
		AddEventHandler('gcPhone:twitter_postTweets', function(username, password, message)
			if Config.GCPhone then 
			if string.find(message,"http") ~= nil then
				registerNewLog("Twitter",{
					["usuario:"] = getPlayerInfo(source),
					["log"] = "Nuevo Tweet: "..message,
					["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
				},message)	
			else
				registerNewLog("Twitter",{
					["usuario:"] = getPlayerInfo(source),
					["log"] = "Nuevo Tweet: "..message,
					["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
				})
			end
		end
		end)

		RegisterServerEvent('gcPhone:twitter_createAccount')
		AddEventHandler('gcPhone:twitter_createAccount', function(username, password, avatarUrl)
			registerNewLog("Twitter",{
				["usuario:"] = getPlayerInfo(source),
				["log"] = "Nueva Cuenta! \n**Nombre de Usuario:** "..username.."\n**Contraseña:** " .. password,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx_givecarkeys:setVehicleOwnedPlayerId')
		AddEventHandler('esx_givecarkeys:setVehicleOwnedPlayerId', function(playerId, vehicleProps)
			registerNewLog("Transferencia de Vehiculos",{
				["usuario:"] = getPlayerInfo(source),
				["alan"] = GetPlayerName(playerId),
				["placa:"] = vehicleProps.plate,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx_policejob:getStockItem')
		AddEventHandler('esx_policejob:getStockItem', function(itemName, count)
			registerNewLog("Almacen Policia",{
				["usuario:"] = getPlayerInfo(source),
				["accion:"] = "Retiro",
				["objeto:"] = itemName,
				["cantidad:"] = count,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx_policejob:putStockItems')
		AddEventHandler('esx_policejob:putStockItems', function(itemName, count)
			registerNewLog("Almacen Policia",{
				["usuario:"] = getPlayerInfo(source),
				["accion:"] = "Deposito",
				["objeto:"] = item,
				["cantidad:"] = count,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('raiderlog:giris')
		AddEventHandler('raiderlog:giris', function()
			local _source = source
			registerNewLog("Conexion",{
				["usuario:"] = getPlayerInfo(_source),
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		AddEventHandler('playerDropped', function(reason)
			registerNewLog("Desconexion",{
				["usuario:"] = getPlayerInfo(source),
				["razon:"] = reason,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx_communityservice:sendToCommunityService')
		AddEventHandler('esx_communityservice:sendToCommunityService', function(target, actions_count)
			registerNewLog("Servicio Comunitario",{
				["usuario:"] = getPlayerInfo(source),
				["yollanan"] = GetPlayerName(target),
				["cantidad:"] = actions_count,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx_trunk:getItem')
		AddEventHandler('esx_trunk:getItem', function(plate, type, item, count, max, owned)
			registerNewLog("Inventario Maletero",{
				["usuario:"] = getPlayerInfo(source),
				["accion:"] = "Retiro",
				["placa:"] = plate,
				["objeto:"] = item,
				["cantidad:"] = count,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx_trunk:putItem')
		AddEventHandler('esx_trunk:putItem', function(plate, type, item, count, max, owned)
			registerNewLog("Inventario Maletero",{
				["usuario:"] = getPlayerInfo(source),
				["accion:"] = "Deposito",
				["placa:"] = plate,
				["objeto:"] = item,
				["cantidad:"] = count,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		AddEventHandler('chatMessage', function(source, author, message)
			registerNewLog("Chat",{
				["usuario:"] = getPlayerInfo(source),
				["mensaje:"] = message,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx_property:getItem')
		AddEventHandler('esx_property:getItem', function(owner, type, item, count)
			registerNewLog("Propiedades",{
				["usuario:"] = getPlayerInfo(source) .." [ID:"..owner.."]",
				["accion:"] = "Çekme",
				["objeto:"] = item,
				["cantidad:"] = count,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx_property:putItem')
		AddEventHandler('esx_property:putItem', function(owner, type, item, count)
			registerNewLog("Propiedades",{
				["usuario:"] = getPlayerInfo(source) .." [ID:"..owner.."]",
				["accion:"] = "Deposito",
				["objeto:"] = item,
				["cantidad:"] = count,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)


		RegisterNetEvent('lsrp-motels:getItem')
		AddEventHandler('lsrp-motels:getItem', function(owner, type, item, count)
			registerNewLog("Propiedades",{
				["usuario:"] = getPlayerInfo(source) .." [ID:"..owner.."]",
				["accion:"] = "Çekme",
				["objeto:"] = item,
				["cantidad:"] = count,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('lsrp-motels:putItem')
		AddEventHandler('lsrp-motels:putItem', function(owner, type, item, count)
			registerNewLog("Propiedades",{
				["usuario:"] = getPlayerInfo(source) .." [ID:"..owner.."]",
				["accion:"] = "Yatırma",
				["objeto:"] = item,
				["cantidad:"] = count,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('lsrp-motels:getItemBed')
		AddEventHandler('lsrp-motels:getItemBed', function(owner, type, item, count)
			registerNewLog("Propiedades",{
				["usuario:"] = getPlayerInfo(source) .." [ID:"..owner.."]",
				["accion:"] = "Çekme (Yatak)",
				["objeto:"] = item,
				["cantidad:"] = count,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('lsrp-motels:putItemBed')
		AddEventHandler('lsrp-motels:putItemBed', function(owner, type, item, count)
			registerNewLog("Propiedades",{
				["usuario:"] = getPlayerInfo(source) .." [ID:"..owner.."]",
				["accion:"] = "Yatırma (Yatak)",
				["objeto:"] = item,
				["cantidad:"] = count,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx_ambulancejob:revive')
		AddEventHandler('esx_ambulancejob:revive', function(target, type, itemName, itemCount)
			registerNewLog("Revividas de EMS",{
				["usuario:"] = getPlayerInfo(source),
				["paciente:"] = GetPlayerName(target),
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx:giveInventoryItem')
		AddEventHandler('esx:giveInventoryItem', function(target, type, itemName, itemCount)
			registerNewLog("Dar Objetos",{
				["usuario:"] = getPlayerInfo(source),
				["persona:"] = GetPlayerName(target),
				["objeto:"] = itemName,
				["cantidad:"] = itemCount,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx:removeInventoryItem')
		AddEventHandler('esx:removeInventoryItem', function(type, itemName, itemCount)
			registerNewLog("Tirar Objetos",{
				["usuario:"] = getPlayerInfo(source),
				["objeto:"] = itemName,
				["cantidad:"] = itemCount,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx_billing:sendBill')
		AddEventHandler('esx_billing:sendBill', function(playerId, sharedAccountName, label, amount)
			registerNewLog("Facturas",{
				["usuario:"] = getPlayerInfo(source),
				["persona a quien factura:"] = GetPlayerName(playerId),
				["descripcion:"] = label,
				["cantidad:"] = amount,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx_policejob:confiscatePlayerItem')
		AddEventHandler('esx_policejob:confiscatePlayerItem', function(target, itemType, itemName, amount)
			registerNewLog("Confiscacion Policial",{
				["usuario:"] = getPlayerInfo(source) ,
				["sospechoso:"] = GetPlayerName(target),
				["objeto:"] = itemName,
				["cantidad:"] = amount,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterNetEvent('esx:onPlayerDeath')
		AddEventHandler('esx:onPlayerDeath', function(data)
			local olduren = nil
			local sebep = nil
			if data.killedByPlayer then
				olduren = getPlayerInfo(data.killerServerId)
			else
				olduren = "Ninguno"
			end
			if string.len(tostring(data.deathCause)) < 2 then
				sebep = "Muerte Desconocida/Natural"
			else
				if weaponHashList[tostring(data.deathCause)] then
					sebep = weaponHashList[data.deathCause]["nameHash"]
				else
					sebep = "Asesinado por Arma de fuego."
				end
			end
			registerNewLog("Muertes",{
				["usuario:"] = getPlayerInfo(source),
				["asesino:"] = olduren,
				["razon:"] = sebep,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)

		RegisterServerEvent('gcPhone:buyCrypto')
		AddEventHandler('gcPhone:buyCrypto', function(miktar, a,b,c,d)
			print(b)
			registerNewLog("Crypto Monedas",{
				["usuario:"] = getPlayerInfo(source),
				["accion:"] = "Compro / Vendio.",
				["moneda:"] = a,
				["cantidad:"] = b,
				["fecha:"] = os.date('%Y-%m-%d %H:%M:%S')
			})
		end)


		function guzelSendToDiscord(DiscordLog,type,bilgiler,extraInfo)
				local fields = {{["name"] = "TIPO DE REGISTRO:",["value"] = type}}
				local kavesdava = GetConvar("sv_hostname","Bulunamadı.")
				local reklamlar = ("¡Joke Leaks!")
				local DISCORD_NAME = '¡Joke Leks!'
				local DISCORD_IMAGE = 'https://cdn.discordapp.com/attachments/876806885184012358/884240271758475305/Capture_2021-08-08-03-52-44.png'
				for k,v in ipairs(logTypes[type]) do
					table.insert(fields,{["name"] = string.upper(v),["value"] = bilgiler[v]})
				end
				local embed = {
					{
						["author"] = {
							["name"] = kavesdava,
							["url"] = "https://discord.gg/dxHnJb9jNt",
							["icon_url"] = "https://cdn.discordapp.com/attachments/876806885184012358/884240271758475305/Capture_2021-08-08-03-52-44.png"
						},
						["fields"] = fields,
						["color"] = 65425,
						["title"] = title,
						["footer"] = {
						["text"] = reklamlar,
					},}}
				if extraInfo then
					embed[1]["thumbnail"] = {["url"] = extraInfo}
				end
				PerformHttpRequest(DiscordLog, function(err, text, headers) end, 'POST', json.encode({username = DISCORD_NAME, embeds = embed,  avatar_url = DISCORD_IMAGE}), { ['Content-Type'] = 'application/json' })
		end
	end)