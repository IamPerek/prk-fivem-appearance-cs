QBCore = exports['qb-core']:GetCoreObject()

local LastZone = nil
local CurrentAction = nil
local CurrentActionMsg = ''
local hasAlreadyEnteredMarker = false
local allMyOutfits = {}
local isPurchaseSuccessful = false
local PlayerData = {}

-- Net Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('fivem-appearance:getPlayerSkin', function(appearance)
		exports['fivem-appearance']:setPlayerAppearance(appearance)
		PlayerData = QBCore.Functions.GetPlayerData()
		
		if Config.Debug then
			Wait(5000)
			if GetEntityModel(PlayerPedId()) == `player_zero` then
				print('Player detected as "player_zero", Starting CreateFirstCharacter event')
				TriggerEvent('qb-clothes:client:CreateFirstCharacter')
			end
		end
		
	end)
end)

RegisterNetEvent('qb-clothes:client:CreateFirstCharacter', function()
	QBCore.Functions.GetPlayerData(function(PlayerData)
		local skin = 'mp_m_freemode_01'
		if PlayerData.charinfo.gender == 1 then
            skin = "mp_f_freemode_01" 
        end
		exports['fivem-appearance']:setPlayerModel(skin)
		local config = {
			ped = true,
			headBlend = true,
			faceFeatures = true,
			headOverlays = true,
			components = true,
			props = true,
		}
		exports['fivem-appearance']:setPlayerAppearance(appearance)
		exports['fivem-appearance']:startPlayerCustomization(function(appearance)
			if (appearance) then
				TriggerServerEvent('fivem-appearance:save', appearance)
				--print('Player Clothing Saved')
			else
				--print('Canceled')
			end
		end, config)
	end)
end, false)

AddEventHandler('fivem-appearance:hasExitedMarker', function(zone)
	CurrentAction = nil
end)

RegisterNetEvent('fivem-appearance:clothingShop', function()
	exports['qb-menu']:openMenu({
        {
            header = "👚 | Obchod s oblečením", -- (Možnosti obchodu s oblečením)
            isMenuHeader = true,
        },
        {
            header = "Koupit oblečení - $"..Config.Money,
			txt = "Kupte si skvělé oblečení pro sebe",
            params = {
                event = "fivem-appearance:clothingMenu",
            }
        },
		{
            header = "Změna oblečení",
			txt = "Vyberte si z jakéhokoli uloženého oblečení",
            params = {
                event = "fivem-appearance:pickNewOutfit",
                args = {
                    number = 1,
                    id = 2
                }
            }
        },
		{
            header = "Uložit nový outfit",
			txt = "Uložte si nové oblečení, které můžete použít později",
            params = {
                event = "fivem-appearance:saveOutfit",
            }
        },
		{
            header = "Smazat oblečení",
			txt = "Jo... To se nám taky nelíbilo",
            params = {
                event = "fivem-appearance:deleteOutfitMenu",
                args = {
                    number = 1,
                    id = 2
                }
            }
        },
    })
end)

RegisterNetEvent('fivem-appearance:pickNewOutfit', function(data)
    local id = data.id
    local number = data.number
	TriggerEvent('fivem-appearance:getOutfits')
	Wait(150)
	local outfitMenu = {
        {
            header = '< Jdi zpět',
            params = {
                event = 'fivem-appearance:clothingShop'
            }
        }
    }
    for i=1, #allMyOutfits, 1 do
        outfitMenu[#outfitMenu + 1] = {
            header = allMyOutfits[i].name,
            params = {
                event = 'fivem-appearance:setOutfit',
                args = {
					-- number = (1 + i),
					ped = allMyOutfits[i].pedModel, 
					components = allMyOutfits[i].pedComponents, 
					props = allMyOutfits[i].pedProps
				}
            }
        }
    end
    exports['qb-menu']:openMenu(outfitMenu)
end)

RegisterNetEvent('fivem-appearance:getOutfits', function()
	TriggerServerEvent('fivem-appearance:getOutfits')
end)

RegisterNetEvent('fivem-appearance:sendOutfits', function(myOutfits)
	local Outfits = {}
	for i=1, #myOutfits, 1 do
		table.insert(Outfits, {id = myOutfits[i].id, name = myOutfits[i].name, pedModel = myOutfits[i].ped, pedComponents = myOutfits[i].components, pedProps = myOutfits[i].props})
	end
	allMyOutfits = Outfits
end)

RegisterNetEvent('fivem-appearance:setOutfit', function(data)
	local pedModel = data.ped
	local pedComponents = data.components
	local pedProps = data.props
	local playerPed = PlayerPedId()
	local currentPedModel = exports['fivem-appearance']:getPedModel(playerPed)
	if currentPedModel ~= pedModel then
    	exports['fivem-appearance']:setPlayerModel(pedModel)
		Wait(500)
		playerPed = PlayerPedId()
		exports['fivem-appearance']:setPedComponents(playerPed, pedComponents)
		exports['fivem-appearance']:setPedProps(playerPed, pedProps)
		local appearance = exports['fivem-appearance']:getPedAppearance(playerPed)
		TriggerServerEvent('fivem-appearance:save', appearance)
	else
		exports['fivem-appearance']:setPedComponents(playerPed, pedComponents)
		exports['fivem-appearance']:setPedProps(playerPed, pedProps)
		local appearance = exports['fivem-appearance']:getPedAppearance(playerPed)
		TriggerServerEvent('fivem-appearance:save', appearance)
	end
	-- TriggerEvent('fivem-appearance:clothingShop')
end)

RegisterNetEvent('fivem-appearance:saveOutfit', function()
	local keyboard = exports['qb-input']:ShowInput({
        header = "Pojmenujte svůj outfit",
        submitText = "Vytvořit outfit",
        inputs = {
            {
                text = "Název outfitu",
                name = "input",
                type = "text",
                isRequired = true
            },
        },
    })

	if keyboard ~= nil then
		local playerPed = PlayerPedId()
		local pedModel = exports['fivem-appearance']:getPedModel(playerPed)
		local pedComponents = exports['fivem-appearance']:getPedComponents(playerPed)
		local pedProps = exports['fivem-appearance']:getPedProps(playerPed)
		Wait(500)
		TriggerServerEvent('fivem-appearance:saveOutfit', keyboard.input, pedModel, pedComponents, pedProps)
		QBCore.Functions.Notify('Outfit '..keyboard.input.. ' byl uložen', 'success')
	end
end)

RegisterNetEvent('fivem-appearance:deleteOutfitMenu', function(data)
    local id = data.id
    local number = data.number
	TriggerEvent('fivem-appearance:getOutfits')
	Wait(150)
	local DeleteMenu = {
        {
            header = '< Jdi zpět',
            params = {
                event = 'fivem-appearance:clothingShop'
            }
        }
    }
    for i=1, #allMyOutfits, 1 do
        DeleteMenu[#DeleteMenu + 1] = {
            header = 'Vymazat "'..allMyOutfits[i].name..'"',
			txt = 'Tohle už nikdy nebudete moci získat zpět!',
            params = {
				event = 'fivem-appearance:deleteOutfit',
				args = allMyOutfits[i].id
			}
        }
    end
    exports['qb-menu']:openMenu(DeleteMenu)
end)

RegisterNetEvent('fivem-appearance:deleteOutfit', function(id)
	TriggerServerEvent('fivem-appearance:deleteOutfit', id)
	-- TriggerEvent('fivem-appearance:clothingShop')
	QBCore.Functions.Notify('Outfit Smazáno', 'error')
end)

RegisterNetEvent("fivem-appearance:purchase", function(bool)
    isPurchaseSuccessful = bool
end)

RegisterNetEvent('fivem-appearance:clothingMenu', function()
	TriggerServerEvent('fivem-appearances:buyclothing')
	Wait(500)
	if isPurchaseSuccessful then
		local config = {
			ped = false,
			headBlend = false,
			faceFeatures = false,
			headOverlays = false,
			components = true,
			props = true
		}
		
		exports['fivem-appearance']:startPlayerCustomization(function(appearance)
			if appearance then
				TriggerServerEvent('fivem-appearance:save', appearance)
				--print('Player Clothing Saved')
				Wait(1000)
				TriggerServerEvent('Select:Tattoos')
			else
				--print('Canceled')
				Wait(1000)
				TriggerServerEvent('Select:Tattoos')
			end
		end, config)
	end
end)

RegisterNetEvent('fivem-appearance:barberMenu', function()
	local config = {
		ped = false,
		headBlend = false,
		faceFeatures = false,
		headOverlays = true,
		components = false,
		props = false
	}

	exports['fivem-appearance']:startPlayerCustomization(function (appearance)
		if appearance then
			TriggerServerEvent('fivem-appearance:save', appearance)
			--print('Player Clothing Saved')
			Wait(1000)
			TriggerServerEvent('Select:Tattoos')
		else
			--print('Canceled')
			Wait(1000)
			TriggerServerEvent('Select:Tattoos')
		end
	end, config)
end)

RegisterNetEvent('qb-clothing:client:openMenu', function()  -- Admin Menu clothing event
	Wait(500)
	local config = {
		ped = true,
		headBlend = true,
		faceFeatures = true,
		headOverlays = true,
		components = true,
		props = true
	}
	
	exports['fivem-appearance']:startPlayerCustomization(function(appearance)
		if appearance then
			TriggerServerEvent('fivem-appearance:save', appearance)
			--print('Player Clothing Saved')
			Wait(1000)
			TriggerServerEvent('Select:Tattoos')
		else
			--print('Canceled')
			Wait(1000)
			TriggerServerEvent('Select:Tattoos')
		end
	end, config)
end)

RegisterNetEvent('qb-clothing:client:openOutfitMenu', function()
	exports['qb-menu']:openMenu({
        {
            header = "👔 | Možnosti oblečení",
            isMenuHeader = true,
        },
		{
            header = "Změna oblečení",
			txt = "Vyberte si z jakéhokoli uloženého oblečení",
            params = {
                event = "fivem-appearance:pickNewOutfitApp",
                args = {
                    number = 1,
                    id = 2
                }
            }
        },
		{
            header = "Uložit nový outfit",
			txt = "Uložte si nové oblečení, které můžete použít později",
            params = {
                event = "fivem-appearance:saveOutfit",
            }
        },
		{
            header = "Smazat oblečení",
			txt = "Jo... To se nám taky nelíbilo",
            params = {
                event = "fivem-appearance:deleteOutfitMenu",
                args = {
                    number = 1,
                    id = 2
                }
            }
        },
    })
end)


RegisterNetEvent('fivem-appearance:pickNewOutfitApp', function(data)
    local id = data.id
    local number = data.number
	TriggerEvent('fivem-appearance:getOutfits')
	Wait(150)
	local outfitMenu = {
        {
            header = '< Jdi zpět',
            params = {
                event = 'qb-clothing:client:openOutfitMenu'
            }
        }
    }
    for i=1, #allMyOutfits, 1 do
        outfitMenu[#outfitMenu + 1] = {
            header = allMyOutfits[i].name,
            params = {
                event = 'fivem-appearance:setOutfit',
                args = {
					-- number = (1 + i),
					ped = allMyOutfits[i].pedModel, 
					components = allMyOutfits[i].pedComponents, 
					props = allMyOutfits[i].pedProps
				}
            }
        }
    end
    exports['qb-menu']:openMenu(outfitMenu)
end)

RegisterNetEvent('fivem-appearance:deleteOutfitMenuApp', function(data)
    local id = data.id
    local number = data.number
	TriggerEvent('fivem-appearance:getOutfits')
	Wait(150)
	local DeleteMenu = {
        {
            header = '< Jdi zpět',
            params = {
                event = 'fivem-appearance:clothingShop'
            }
        }
    }
    for i=1, #allMyOutfits, 1 do
        DeleteMenu[#DeleteMenu + 1] = {
            header = 'Vymazat "'..allMyOutfits[i].name..'"',
			txt = 'Tohle už nikdy nebudete moci získat zpět!',
            params = {
				event = 'fivem-appearance:deleteOutfit',
				args = allMyOutfits[i].id
			}
        }
    end
    exports['qb-menu']:openMenu(DeleteMenu)
end)

-- Theads

CreateThread(function()
	while true do

		Wait(0)

		if CurrentAction ~= nil then

			if IsControlPressed(1, 38) then
				Wait(500)

				if CurrentAction == 'clothingMenu' then
					TriggerEvent("fivem-appearance:clothingShop")
				end
				
				if CurrentAction == 'barberMenu' then
					TriggerEvent("fivem-appearance:barberMenu")
				end

			end
		end
	end
end)

CreateThread(function()
	for k,v in ipairs(Config.BarberShops) do
		local blip = AddBlipForCoord(v)

		SetBlipSprite (blip, 71)
		-- SetBlipColour (blip, 47)
		SetBlipScale (blip, 0.6)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName('Kadernictví')
		EndTextCommandSetBlipName(blip)
	end
	for k,v in ipairs(Config.ClothingShops) do
		local data = v
		if data.blip == true then
			local blip = AddBlipForCoord(data.coords)

			SetBlipSprite (blip, 73)
			-- SetBlipColour (blip, 47)
			SetBlipScale (blip, 0.6)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName('Obchod s oblecením')
			EndTextCommandSetBlipName(blip)
		end
	end
end)

CreateThread(function()
	while true do
		local playerCoords, isInClothingShop, isInPDPresets, isInBarberShop, currentZone, letSleep = GetEntityCoords(PlayerPedId()), false, false, nil, true
		local sleep = 2000
		for k,v in pairs(Config.ClothingShops) do
			local data = v
			local distance = #(playerCoords - data.coords)

			if distance < Config.DrawDistance then
				sleep = 0
				if distance < data.MarkerSize.x then
					isInClothingShop, currentZone = true, k
				end
			end
		end

		for k,v in pairs(Config.BarberShops) do
			local distance = #(playerCoords - v)

			if distance < Config.DrawDistance then
				sleep = 0
				if distance < Config.MarkerSize.x then
					isInBarberShop, currentZone = true, k
				end
			end
		end
		
		if (isInClothingShop and not hasAlreadyEnteredMarker) or (isInClothingShop and LastZone ~= currentZone) then
			hasAlreadyEnteredMarker, LastZone = true, currentZone
			CurrentAction     = 'clothingMenu'
			exports['qb-drawtext']:DrawText('[E] Oblečení','left')
		end

		if (isInBarberShop and not hasAlreadyEnteredMarker) or (isInBarberShop and LastZone ~= currentZone) then
			hasAlreadyEnteredMarker, LastZone = true, currentZone
			CurrentAction     = 'barberMenu'
			exports['qb-drawtext']:DrawText('[E] Kadeřnictví','left')
		end

		if not isInClothingShop and not isInBarberShop and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			sleep = 1000
			TriggerEvent('fivem-appearance:hasExitedMarker', LastZone)
			exports['qb-drawtext']:HideText()
		end
		Wait(sleep)
	end
end)

-- Command(s)

RegisterCommand('reloadskin', function()
	local playerPed = PlayerPedId()
	local maxhealth = GetEntityMaxHealth(playerPed)
	local health = GetEntityHealth(playerPed)
	QBCore.Functions.TriggerCallback('fivem-appearance:getPlayerSkin', function(appearance)
		exports['fivem-appearance']:setPlayerAppearance(appearance)
	end)
	for k, v in pairs(GetGamePool('CObject')) do
        if IsEntityAttachedToEntity(PlayerPedId(), v) then
            SetEntityAsMissionEntity(v, true, true)
            DeleteObject(v)
            DeleteEntity(v)
        end
	SetPedMaxHealth(PlayerId(), maxhealth)
	Citizen.Wait(1000) -- Safety Delay
	SetEntityHealth(PlayerPedId(), health)
    end
end)

-- Testing Command

RegisterCommand('clothingmenu', function()
	local config = {
		ped = true,
		headBlend = true,
		faceFeatures = true,
		headOverlays = true,
		components = true,
		props = true,
	}
	exports['fivem-appearance']:startPlayerCustomization(function (appearance)
		if (appearance) then
			TriggerServerEvent('fivem-appearance:save', appearance)
			--print('Player Clothing Saved')
			Wait(1000)
			TriggerServerEvent('Select:Tattoos')
		else
			--print('Canceled')
			Wait(1000)
			TriggerServerEvent('Select:Tattoos')
		end
	end, config)
end, false)
