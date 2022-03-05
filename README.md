# Perek • https://linktr.ee/IamPerek #

# prk-fivem-appearance #

Původní Script: https://github.com/pedr0fontoura/fivem-appearance

ESX Verze: https://github.com/ZiggyJoJo/brp-fivem-appearance

Moja QB-Core Anglická Verzia: https://github.com/IamPerek/prk-fivem-appearance-en

# Požadavky #

- QBCore
- [qb-menu](https://github.com/qbcore-framework/qb-menu)
- [qb-interior](https://github.com/qbcore-framework/qb-interior)
- [qb-input](https://github.com/qbcore-framework/qb-input)
- [qb-drawtext](https://github.com/IdrisDose/qb-drawtext) (není potřeba, ale to jsem ja použil)
- [qb-tattooshop](https://github.com/MrEvilGamer/qb-tattooshop)

# Setup #
- Odstraň script `qb-clothing` ze serveru
- Přejmenuj složku z `prk-fivem-appearance-cs-main` na `fivem-appearance`
- Spusti RunSql.sql
- Vlož `setr fivem-appearance:locale "cs"` do server.cfg
- Vlož `ensure fivem-appearance` do server.cfg
- Nahrad události, postupujte podle níže uvedeného kódu



# Replace the `qb-multicharacter:server:getSkin` callback with:
#### Line: 170 qb-multicharacter/server/main.lua
```lua
QBCore.Functions.CreateCallback("qb-multicharacter:server:getSkin", function(source, cb, cid)
    local result = MySQL.query.await('SELECT * FROM players WHERE citizenid = ?', {cid})
    local PlayerData = result[1]
    PlayerData.model = json.decode(PlayerData.skin)
    if PlayerData.skin ~= nil then
        cb(PlayerData.skin, PlayerData.model.model)
    else
        cb(nil)
    end
end)
```
# Replace the `RegisterNUICallback('cDataPed', function(data)` callback  with:
#### Line: 114 qb-multicharacter/client/main.lua
```lua
RegisterNUICallback('cDataPed', function(data)
    local cData = data.cData  
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    if cData ~= nil then
        QBCore.Functions.TriggerCallback('qb-multicharacter:server:getSkin', function(data, gender)
            model = gender
            if model ~= nil then
                Citizen.CreateThread(function()
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    charPed = CreatePed(2, model, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, Config.PedCoords.w, false, true)
                    SetPedComponentVariation(charPed, 0, 0, 0, 2)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    PlaceObjectOnGroundProperly(charPed)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    data = json.decode(data)
                    exports['fivem-appearance']:setPedAppearance(charPed, data)
                end)
            else
                Citizen.CreateThread(function()
                    local randommodels = {
                        "mp_m_freemode_01",
                        "mp_f_freemode_01",
                    }
                    local model = GetHashKey(randommodels[math.random(1, #randommodels)])
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    charPed = CreatePed(2, model, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, Config.PedCoords.w, false, true)
                    SetPedComponentVariation(charPed, 0, 0, 0, 2)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    PlaceObjectOnGroundProperly(charPed)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                end)
            end
        end, cData.citizenid)
    else
        Citizen.CreateThread(function()
            local randommodels = {
                "mp_m_freemode_01",
                "mp_f_freemode_01",
            }
            local model = GetHashKey(randommodels[math.random(1, #randommodels)])
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end
            charPed = CreatePed(2, model, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, Config.PedCoords.w, false, true)
            SetPedComponentVariation(charPed, 0, 0, 0, 2)
            FreezeEntityPosition(charPed, false)
            SetEntityInvincible(charPed, true)
            PlaceObjectOnGroundProperly(charPed)
            SetBlockingOfNonTemporaryEvents(charPed, true)
        end)
    end
end)
```
# Replace the `qb-clothes:client:CreateFirstCharacter` with:
#### Line: 55 qb-interior/client/main.lua
```lua
fivem-appearance:CreateFirstCharacter
```
# A je mi líto, ale vaši hráči nebudou mít startovací byt
#### musíš nastavit v 'qb-apartments/config.lua' Apartments.Starting na false a také v 'qb-multicharacter/config.lua' Config.StartingApartment na false

# A to je vše #
