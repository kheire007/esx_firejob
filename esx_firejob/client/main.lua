local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData                = {}
local GUI                       = {}
local HasAlreadyEnteredMarker   = false
local LastStation               = nil
local LastPart                  = nil
local LastPartNum               = nil
local LastEntity                = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local IsHandcuffed              = false
local IsDragged                 = false
local CopPed                    = 0

ESX                             = nil
GUI.Time                        = 0

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

function SetVehicleMaxMods(vehicle)

  local props = {
    modEngine       = 2,
    modBrakes       = 2,
    modTransmission = 2,
    modSuspension   = 3,
    modTurbo        = true,
  }

  ESX.Game.SetVehicleProperties(vehicle, props)

end

function RespawnPed(ped, coords)
  SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
  NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false)
  SetPlayerInvincible(ped, false)
  TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, coords.heading)
  ClearPedBloodDamage(ped)
  if RespawnToHospitalMenu ~= nil then
    RespawnToHospitalMenu.close()
    RespawnToHospitalMenu = nil
  end
  ESX.UI.Menu.CloseAll()
end

function OpenCloakroomMenu()

  local elements = {
    {label = _U('citizen_wear'), value = 'citizen_wear'},
    {label = _U('ambulance_wear'), value = 'ambulance_wear'}
}

  ESX.UI.Menu.CloseAll()

  if Config.EnableNonFreemodePeds then
      table.insert(elements, {label = _U('mems_clothes_ems'), value = 'mamb_wear'})
      table.insert(elements, {label = _U('fems_clothes_ems'), value = 'famb_wear'})
      table.insert(elements, {label = _U('fire_clothes'), value = 'fire_cloth'})
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'cloakroom',
      {
        title    = _U('cloakroom'),
        align    = 'bottom-right',
        elements = elements,
        },

        function(data, menu)

      menu.close()
      
      if data.current.value == 'citizen_wear' then
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
          local model = nil

          if skin.sex == 0 then
            model = GetHashKey("mp_m_freemode_01")
          else
            model = GetHashKey("mp_f_freemode_01")
          end

          RequestModel(model)
          while not HasModelLoaded(model) do
            RequestModel(model)
            Citizen.Wait(1)
          end

          SetPlayerModel(PlayerId(), model)
          SetModelAsNoLongerNeeded(model)

          TriggerEvent('skinchanger:loadSkin', skin)
          TriggerEvent('esx:restoreLoadout')
        end)
      end

      if data.current.value == 'ambulance_wear' then

        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)

          if skin.sex == 0 then
            TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
          else
            TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
          end

        end)

      end

      if data.current.value == 'famb_wear' then

            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)

            if skin.sex == 0 then

                local model = GetHashKey("s_f_y_scrubs_01")

                RequestModel(model)
                while not HasModelLoaded(model) do
                  RequestModel(model)
                  Citizen.Wait(0)
                end

                SetPlayerModel(PlayerId(), model)
                SetModelAsNoLongerNeeded(model)
          else
              local model = GetHashKey("s_f_y_scrubs_01")

              RequestModel(model)
              while not HasModelLoaded(model) do
                RequestModel(model)
                Citizen.Wait(0)
              end

              SetPlayerModel(PlayerId(), model)
            SetModelAsNoLongerNeeded(model)
              end

            end)
      end

          if data.current.value == 'mamb_wear' then

            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)

            if skin.sex == 0 then

                local model = GetHashKey("S_M_M_Paramedic_01")

                RequestModel(model)
                while not HasModelLoaded(model) do
                  RequestModel(model)
                  Citizen.Wait(0)
              end

                SetPlayerModel(PlayerId(), model)
                SetModelAsNoLongerNeeded(model)
          else
              local model = GetHashKey("S_M_M_Paramedic_01")

              RequestModel(model)
              while not HasModelLoaded(model) do
                RequestModel(model)
                Citizen.Wait(0)
              end

              SetPlayerModel(PlayerId(), model)
            SetModelAsNoLongerNeeded(model)
          end

            end)
      end          

          if data.current.value == 'fire_cloth' then

            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)

            if skin.sex == 0 then

                local model = GetHashKey("s_m_y_fireman_01")

                RequestModel(model)
                while not HasModelLoaded(model) do
                  RequestModel(model)
                  Citizen.Wait(0)
                end

                SetPlayerModel(PlayerId(), model)
                SetModelAsNoLongerNeeded(model)
          else
              local model = GetHashKey("s_m_y_fireman_01")

              RequestModel(model)
              while not HasModelLoaded(model) do
                RequestModel(model)
                Citizen.Wait(0)
              end

              SetPlayerModel(PlayerId(), model)
              SetModelAsNoLongerNeeded(model)
              end
          end)
      end     

      CurrentAction     = 'menu_cloakroom'
      CurrentActionMsg  = _U('open_cloackroom')
      CurrentActionData = {}

    end,
    function(data, menu)

      menu.close()

      CurrentAction     = 'menu_cloakroom'
      CurrentActionMsg  = _U('open_cloackroom')
      CurrentActionData = {}
    end
  )

end

function OpenArmoryMenu(station)

  if Config.EnableArmoryManagement then

    local elements = {
      {label = _U('get_weapon'), value = 'get_weapon'},
      {label = _U('put_weapon'), value = 'put_weapon'},
      {label = _U('evidence_out'),  value = 'get_stock'},
      {label = _U('evidence_in'),  value = 'put_stock'}
    }

    if PlayerData.job.grade_name == 'boss' then
      table.insert(elements, {label = _U('buy_weapons'), value = 'buy_weapons'})
    end

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'armory',
      {
        title    = _U('armory'),
        align    = 'bottom-right',
        elements = elements,
      },
      function(data, menu)

        if data.current.value == 'get_weapon' then
          OpenGetWeaponMenu()
        end

        if data.current.value == 'put_weapon' then
          OpenPutWeaponMenu()
        end

        if data.current.value == 'buy_weapons' then
          OpenBuyWeaponsMenu(station)
        end

        if data.current.value == 'put_stock' then
          OpenPutStocksMenu()
        end

        if data.current.value == 'get_stock' then
          OpenGetStocksMenu()
        end

      end,
      function(data, menu)

        menu.close()

        CurrentAction     = 'menu_armory'
        CurrentActionMsg  = _U('open_armory')
        CurrentActionData = {station = station}
      end
    )

  else

    local elements = {}

    for i=1, #Config.FireStations[station].AuthorizedWeapons, 1 do
      local weapon = Config.FireStations[station].AuthorizedWeapons[i]
      table.insert(elements, {label = ESX.GetWeaponLabel(weapon.name), value = weapon.name})
    end

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'armory',
      {
        title    = _U('armory'),
        align    = 'bottom-right',
        elements = elements,
      },
      function(data, menu)
        local weapon = data.current.value
        TriggerServerEvent('esx_firejob:giveWeapon', weapon,  1000)
      end,
      function(data, menu)

        menu.close()

        CurrentAction     = 'menu_armory'
        CurrentActionMsg  = _U('open_armory')
        CurrentActionData = {station = station}

      end
    )

  end

end

function OpenVehicleSpawnerMenu(station, partNum)

  local vehicles = Config.FireStations[station].Vehicles

  ESX.UI.Menu.CloseAll()

  if Config.EnableSocietyOwnedVehicles then

    local elements = {}

    ESX.TriggerServerCallback('esx_society:getVehiclesInGarage', function(garageVehicles)

      for i=1, #garageVehicles, 1 do
        table.insert(elements, {label = GetDisplayNameFromVehicleModel(garageVehicles[i].model) .. ' [' .. garageVehicles[i].plate .. ']', value = garageVehicles[i]})
      end

      ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'vehicle_spawner',
        {
          title    = _U('vehicle_menu'),
          align    = 'bottom-right',
          elements = elements,
        },
        function(data, menu)

          menu.close()

          local vehicleProps = data.current.value

          ESX.Game.SpawnVehicle(vehicleProps.model, vehicles[partNum].SpawnPoint, 270.0, function(vehicle)
            ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
            local playerPed = GetPlayerPed(-1)
            TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
          end)

          TriggerServerEvent('esx_society:removeVehicleFromGarage', 'fire', vehicleProps)

        end,
        function(data, menu)

          menu.close()

          CurrentAction     = 'menu_vehicle_spawner'
          CurrentActionMsg  = _U('vehicle_spawner')
          CurrentActionData = {station = station, partNum = partNum}

        end
      )

    end, 'fire')

  else

    local elements = {}

    for i=1, #Config.FireStations[station].AuthorizedVehicles, 1 do
      local vehicle = Config.FireStations[station].AuthorizedVehicles[i]
      table.insert(elements, {label = vehicle.label, value = vehicle.name})
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'vehicle_spawner',
      {
        title    = _U('vehicle_menu'),
        align    = 'bottom-right',
        elements = elements,
      },
      function(data, menu)

        menu.close()

        local model = data.current.value

        local vehicle = GetClosestVehicle(vehicles[partNum].SpawnPoint.x,  vehicles[partNum].SpawnPoint.y,  vehicles[partNum].SpawnPoint.z,  3.0,  0,  71)

        if not DoesEntityExist(vehicle) then

          local playerPed = GetPlayerPed(-1)

          if Config.MaxInService == -1 then

            ESX.Game.SpawnVehicle(model, {
              x = vehicles[partNum].SpawnPoint.x,
              y = vehicles[partNum].SpawnPoint.y,
              z = vehicles[partNum].SpawnPoint.z
            }, vehicles[partNum].Heading, function(vehicle)
              TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
              SetVehicleMaxMods(vehicle)
            end)

          else

            ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)

              if canTakeService then

                ESX.Game.SpawnVehicle(model, {
                  x = vehicles[partNum].SpawnPoint.x,
                  y = vehicles[partNum].SpawnPoint.y,
                  z = vehicles[partNum].SpawnPoint.z
                }, vehicles[partNum].Heading, function(vehicle)
                  TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
                  SetVehicleMaxMods(vehicle)
                end)

              else
                ESX.ShowNotification(_U('service_max') .. inServiceCount .. '/' .. maxInService)
              end

            end, 'fire')

          end

        else
          ESX.ShowNotification(_U('vehicle_out'))
        end

      end,
      function(data, menu)

        menu.close()

        CurrentAction     = 'menu_vehicle_spawner'
        CurrentActionMsg  = _U('vehicle_spawner')
        CurrentActionData = {station = station, partNum = partNum}

      end
    )

  end

end

function OpenFireActionsMenu()

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'fire_actions',
    {
      title    = 'Fire',
      align    = 'bottom-right',
      elements = {
        {label = _U('citizen_interaction'), value = 'citizen_interaction'},
        {label = _U('vehicle_interaction'), value = 'vehicle_interaction'},
        {label = _U('object_spawner'),      value = 'object_spawner'},
      },
    },
    function(data, menu)

      if data.current.value == 'citizen_interaction' then

        ESX.UI.Menu.Open(
          'default', GetCurrentResourceName(), 'citizen_interaction',
          {
            title    = _U('citizen_interaction'),
            align    = 'bottom-right',
            elements = {
              {label = _U('id_card'),       value = 'identity_card'},
              --{label = _U('search'),        value = 'body_search'},
              {label = _U('drag'),      value = 'drag'},
              {label = _U('put_in_vehicle'),  value = 'put_in_vehicle'},
              {label = _U('out_the_vehicle'), value = 'out_the_vehicle'},
              {label = _U('fine'),            value = 'fine'},
              {label = _U('fire_menu_revive'),             value = 'revive'}
            },
          },
          function(data2, menu2)

            local player, distance = ESX.Game.GetClosestPlayer()

            if distance ~= -1 and distance <= 3.0 then

              if data2.current.value == 'identity_card' then
                OpenIdentityCardMenu(player)
              end

              if data2.current.value == 'body_search' then
                OpenBodySearchMenu(player)
              end

              if data2.current.value == 'drag' then
                TriggerServerEvent('esx_firejob:drag', GetPlayerServerId(player))
              end

              if data2.current.value == 'put_in_vehicle' then
                TriggerServerEvent('esx_firejob:putInVehicle', GetPlayerServerId(player))
              end

              if data2.current.value == 'out_the_vehicle' then
                  TriggerServerEvent('esx_firejob:OutVehicle', GetPlayerServerId(player))
              end

              if data2.current.value == 'fine' then
                OpenFineMenu(player)
              end

              if data2.current.value == 'revive' then
                menu.close()

                local ped    = GetPlayerPed(player)
                local health = GetEntityHealth(ped)

                if health == 0 then

                local playerPed        = GetPlayerPed(-1)
                local closestPlayerPed = GetPlayerPed(player)

                Citizen.CreateThread(function()

                  ESX.ShowNotification(_U('revive_inprogress'))

                  TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                  Citizen.Wait(10000)
                  ClearPedTasks(playerPed)

                  if GetEntityHealth(closestPlayerPed) == 0 then
                    TriggerServerEvent('esx_firejob:revive', GetPlayerServerId(player))
                    ESX.ShowNotification(_U('revive_complete') .. GetPlayerName(player))
                  else
                    ESX.ShowNotification(GetPlayerName(player) .. _U('isdead'))
                  end

                end)

              else
                ESX.ShowNotification(GetPlayerName(player) .. _U('unconscious'))
              end

            end

            else
              ESX.ShowNotification(_U('no_players_nearby'))
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end

      if data.current.value == 'vehicle_interaction' then

        ESX.UI.Menu.Open(
          'default', GetCurrentResourceName(), 'vehicle_interaction',
          {
            title    = _U('vehicle_interaction'),
            align    = 'bottom-right',
            elements = {
              {label = _U('vehicle_info'), value = 'vehicle_infos'},
              {label = _U('pick_lock'),    value = 'hijack_vehicle'},
            },
          },
          function(data2, menu2)

            local playerPed = GetPlayerPed(-1)
            local coords    = GetEntityCoords(playerPed)
            local vehicle   = GetClosestVehicle(coords.x,  coords.y,  coords.z,  3.0,  0,  71)

            if DoesEntityExist(vehicle) then

              local vehicleData = ESX.Game.GetVehicleProperties(vehicle)

              if data2.current.value == 'vehicle_infos' then
                OpenVehicleInfosMenu(vehicleData)
              end

              if data2.current.value == 'hijack_vehicle' then

                local playerPed = GetPlayerPed(-1)
                local coords    = GetEntityCoords(playerPed)

                if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then

                  local vehicle = GetClosestVehicle(coords.x,  coords.y,  coords.z,  3.0,  0,  71)

                  if DoesEntityExist(vehicle) then

                    Citizen.CreateThread(function()

                      TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)

                      Wait(20000)

                      ClearPedTasksImmediately(playerPed)

                      SetVehicleDoorsLocked(vehicle, 1)
                      SetVehicleDoorsLockedForAllPlayers(vehicle, false)

                      TriggerEvent('esx:showNotification', _U('vehicle_unlocked'))

                    end)

                  end

                end

              end

            else
              ESX.ShowNotification(_U('no_vehicles_nearby'))
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end

      if data.current.value == 'object_spawner' then

        ESX.UI.Menu.Open(
          'default', GetCurrentResourceName(), 'citizen_interaction',
          {
            title    = _U('traffic_interaction'),
            align    = 'bottom-right',
            elements = {
              {label = _U('cone'),     value = 'prop_roadcone02a'},
              {label = _U('barrier'), value = 'prop_barrier_work06a'}
            },
          },
          function(data2, menu2)


            local model     = data2.current.value
            local playerPed = GetPlayerPed(-1)
            local coords    = GetEntityCoords(playerPed)
            local forward   = GetEntityForwardVector(playerPed)
            local x, y, z   = table.unpack(coords + forward * 1.0)

            if model == 'prop_roadcone02a' then
              z = z - 2.0
            end

            ESX.Game.SpawnObject(model, {
              x = x,
              y = y,
              z = z
            }, function(obj)
              SetEntityHeading(obj, GetEntityHeading(playerPed))
              PlaceObjectOnGroundProperly(obj)
            end)

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end

    end,
    function(data, menu)

      menu.close()

    end
  )

end

function OpenIdentityCardMenu(player)

  if Config.EnableESXIdentity then

    ESX.TriggerServerCallback('esx_firejob:getOtherPlayerData', function(data)

      local jobLabel    = nil
      local sexLabel    = nil
      local sex         = nil
      local dobLabel    = nil
      local heightLabel = nil
      local idLabel     = nil

      if data.job.grade_label ~= nil and  data.job.grade_label ~= '' then
        jobLabel = 'Job : ' .. data.job.label .. ' - ' .. data.job.grade_label
      else
        jobLabel = 'Job : ' .. data.job.label
      end

      if data.sex ~= nil then
        if (data.sex == 'm') or (data.sex == 'M') then
          sex = 'Male'
        else
          sex = 'Female'
        end
        sexLabel = 'Sex : ' .. sex
      else
        sexLabel = 'Sex : Unknown'
      end

      if data.dob ~= nil then
        dobLabel = 'DOB : ' .. data.dob
      else
        dobLabel = 'DOB : Unknown'
      end

      if data.height ~= nil then
        heightLabel = 'Height : ' .. data.height
      else
        heightLabel = 'Height : Unknown'
      end

      if data.name ~= nil then
        idLabel = 'ID : ' .. data.name
      else
        idLabel = 'ID : Unknown'
      end

      local elements = {
        {label = _U('name') .. data.firstname .. " " .. data.lastname, value = nil},
        {label = sexLabel,    value = nil},
        {label = dobLabel,    value = nil},
        {label = heightLabel, value = nil},
        {label = jobLabel,    value = nil},
        {label = idLabel,     value = nil},
      }

      if data.drunk ~= nil then
        table.insert(elements, {label = _U('bac') .. data.drunk .. '%', value = nil})
      end

      if data.licenses ~= nil then

        table.insert(elements, {label = '--- Licenses ---', value = nil})

        for i=1, #data.licenses, 1 do
          table.insert(elements, {label = data.licenses[i].label, value = nil})
        end

      end

      ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'citizen_interaction',
        {
          title    = _U('citizen_interaction'),
          align    = 'bottom-right',
          elements = elements,
        },
        function(data, menu)

        end,
        function(data, menu)
          menu.close()
        end
      )

    end, GetPlayerServerId(player))

  else

    ESX.TriggerServerCallback('esx_firejob:getOtherPlayerData', function(data)

      local jobLabel = nil

      if data.job.grade_label ~= nil and  data.job.grade_label ~= '' then
        jobLabel = 'Job : ' .. data.job.label .. ' - ' .. data.job.grade_label
      else
        jobLabel = 'Job : ' .. data.job.label
      end

        local elements = {
          {label = _U('name') .. data.name, value = nil},
          {label = jobLabel,              value = nil},
        }

      if data.drunk ~= nil then
        table.insert(elements, {label = _U('bac') .. data.drunk .. '%', value = nil})
      end

      if data.licenses ~= nil then

        table.insert(elements, {label = '--- Licenses ---', value = nil})

        for i=1, #data.licenses, 1 do
          table.insert(elements, {label = data.licenses[i].label, value = nil})
        end

      end

      ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'citizen_interaction',
        {
          title    = _U('citizen_interaction'),
          align    = 'bottom-right',
          elements = elements,
        },
        function(data, menu)

        end,
        function(data, menu)
          menu.close()
        end
      )

    end, GetPlayerServerId(player))

  end

end

function OpenBodySearchMenu(player)

  ESX.TriggerServerCallback('esx_firejob:getOtherPlayerData', function(data)

    local elements = {}

    local blackMoney = 0

    for i=1, #data.accounts, 1 do
      if data.accounts[i].name == 'black_money' then
        blackMoney = data.accounts[i].money
      end
    end

    table.insert(elements, {
      label          = _U('confiscate_dirty') .. blackMoney,
      value          = 'black_money',
      itemType       = 'item_account',
      amount         = blackMoney
    })

    table.insert(elements, {label = '--- Armes ---', value = nil})

    for i=1, #data.weapons, 1 do
      table.insert(elements, {
        label          = _U('confiscate') .. ESX.GetWeaponLabel(data.weapons[i].name),
        value          = data.weapons[i].name,
        itemType       = 'item_weapon',
        amount         = data.ammo,
      })
    end

    table.insert(elements, {label = _U('inventory_label'), value = nil})

    for i=1, #data.inventory, 1 do
      if data.inventory[i].count > 0 then
        table.insert(elements, {
          label          = _U('confiscate_inv') .. data.inventory[i].count .. ' ' .. data.inventory[i].label,
          value          = data.inventory[i].name,
          itemType       = 'item_standard',
          amount         = data.inventory[i].count,
        })
      end
    end


    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'body_search',
      {
        title    = _U('search'),
        align    = 'bottom-right',
        elements = elements,
      },
      function(data, menu)

        local itemType = data.current.itemType
        local itemName = data.current.value
        local amount   = data.current.amount

        if data.current.value ~= nil then

          TriggerServerEvent('esx_firejob:confiscatePlayerItem', GetPlayerServerId(player), itemType, itemName, amount)

          OpenBodySearchMenu(player)

        end

      end,
      function(data, menu)
        menu.close()
      end
    )

  end, GetPlayerServerId(player))

end

function OpenFineMenu(player)

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'fine',
    {
      title    = _U('fine'),
      align    = 'bottom-right',
      elements = {
        {label = _U('traffic_offense'),   value = 0},
        {label = _U('minor_offense'),     value = 1},
        {label = _U('average_offense'),   value = 2},
        {label = _U('major_offense'),     value = 3}
      },
    },
    function(data, menu)

      OpenFineCategoryMenu(player, data.current.value)

    end,
    function(data, menu)
      menu.close()
    end
  )

end

function OpenFineCategoryMenu(player, category)

  ESX.TriggerServerCallback('esx_firejob:getFineList', function(fines)

    local elements = {}

    for i=1, #fines, 1 do
      table.insert(elements, {
        label     = fines[i].label .. ' $' .. fines[i].amount,
        value     = fines[i].id,
        amount    = fines[i].amount,
        fineLabel = fines[i].label
      })
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'fine_category',
      {
        title    = _U('fine'),
        align    = 'bottom-right',
        elements = elements,
      },
      function(data, menu)

        local label  = data.current.fineLabel
        local amount = data.current.amount

        menu.close()

        if Config.EnablePlayerManagement then
          TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_fire', _U('fine_total') .. label, amount)
        else
          TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), '', _U('fine_total') .. label, amount)
        end

        ESX.SetTimeout(300, function()
          OpenFineCategoryMenu(player, category)
        end)

      end,
      function(data, menu)
        menu.close()
      end
    )

  end, category)

end

function OpenVehicleInfosMenu(vehicleData)

  ESX.TriggerServerCallback('esx_firejob:getVehicleInfos', function(infos)

    local elements = {}

    table.insert(elements, {label = _U('plate') .. infos.plate, value = nil})

    if infos.owner == nil then
      table.insert(elements, {label = _U('owner_unknown'), value = nil})
    else
      table.insert(elements, {label = _U('owner') .. infos.owner, value = nil})
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'vehicle_infos',
      {
        title    = _U('vehicle_info'),
        align    = 'bottom-right',
        elements = elements,
      },
      nil,
      function(data, menu)
        menu.close()
      end
    )

  end, vehicleData.plate)

end

function OpenGetWeaponMenu()

  ESX.TriggerServerCallback('esx_firejob:getArmoryWeapons', function(weapons)

    local elements = {}

    for i=1, #weapons, 1 do
      if weapons[i].count > 0 then
        table.insert(elements, {label = 'x' .. weapons[i].count .. ' ' .. ESX.GetWeaponLabel(weapons[i].name), value = weapons[i].name})
      end
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'armory_get_weapon',
      {
        title    = _U('get_weapon_menu'),
        align    = 'bottom-right',
        elements = elements,
      },
      function(data, menu)

        menu.close()

        ESX.TriggerServerCallback('esx_firejob:removeArmoryWeapon', function()
          OpenGetWeaponMenu()
        end, data.current.value)

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

function OpenPutWeaponMenu()

  local elements   = {}
  local playerPed  = GetPlayerPed(-1)
  local weaponList = ESX.GetWeaponList()

  for i=1, #weaponList, 1 do

    local weaponHash = GetHashKey(weaponList[i].name)

    if HasPedGotWeapon(playerPed,  weaponHash,  false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
      local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
      table.insert(elements, {label = weaponList[i].label, value = weaponList[i].name})
    end

  end

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'armory_put_weapon',
    {
      title    = _U('put_weapon_menu'),
      align    = 'bottom-right',
      elements = elements,
    },
    function(data, menu)

      menu.close()

      ESX.TriggerServerCallback('esx_firejob:addArmoryWeapon', function()
        OpenPutWeaponMenu()
      end, data.current.value)

    end,
    function(data, menu)
      menu.close()
    end
  )

end

function OpenBuyWeaponsMenu(station)

  ESX.TriggerServerCallback('esx_firejob:getArmoryWeapons', function(weapons)

    local elements = {}

    for i=1, #Config.FireStations[station].AuthorizedWeapons, 1 do

      local weapon = Config.FireStations[station].AuthorizedWeapons[i]
      local count  = 0

      for i=1, #weapons, 1 do
        if weapons[i].name == weapon.name then
          count = weapons[i].count
          break
        end
      end

      table.insert(elements, {label = 'x' .. count .. ' ' .. ESX.GetWeaponLabel(weapon.name) .. ' $' .. weapon.price, value = weapon.name, price = weapon.price})

    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'armory_buy_weapons',
      {
        title    = _U('buy_weapon_menu'),
        align    = 'bottom-right',
        elements = elements,
      },
      function(data, menu)

        ESX.TriggerServerCallback('esx_firejob:buy', function(hasEnoughMoney)

          if hasEnoughMoney then
            ESX.TriggerServerCallback('esx_firejob:addArmoryWeapon', function()
              OpenBuyWeaponsMenu(station)
            end, data.current.value)
          else
            ESX.ShowNotification(_U('not_enough_money'))
          end

        end, data.current.price)

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

function OpenGetStocksMenu()

  ESX.TriggerServerCallback('esx_firejob:getStockItems', function(items)

    print(json.encode(items))

    local elements = {}

    for i=1, #items, 1 do
      table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name})
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'stocks_menu',
      {
        title    = _U('fire_stock'),
        elements = elements
      },
      function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
          {
            title = _U('quantity')
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil then
              ESX.ShowNotification(_U('quantity_invalid'))
            else
              menu2.close()
              menu.close()
              OpenGetStocksMenu()

              TriggerServerEvent('esx_firejob:getStockItem', itemName, count)
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

function OpenPutStocksMenu()

  ESX.TriggerServerCallback('esx_firejob:getPlayerInventory', function(inventory)

    local elements = {}

    for i=1, #inventory.items, 1 do

      local item = inventory.items[i]

      if item.count > 0 then
        table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
      end

    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'stocks_menu',
      {
        title    = _U('inventory'),
        elements = elements
      },
      function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
          {
            title = _U('quantity')
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil then
              ESX.ShowNotification(_U('quantity_invalid'))
            else
              menu2.close()
              menu.close()
              OpenPutStocksMenu()

              TriggerServerEvent('esx_firejob:putStockItems', itemName, count)
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)

  local specialContact = {
    name       = 'Fire',
    number     = 'fire',
    base64Icon = 'data:image/jpeg;base64,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'
  }

  TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)

end)

AddEventHandler('esx_firejob:hasEnteredMarker', function(station, part, partNum)

  if part == 'Cloakroom' then
    CurrentAction     = 'menu_cloakroom'
    CurrentActionMsg  = _U('open_cloackroom')
    CurrentActionData = {}
  end

  if part == 'Armory' then
    CurrentAction     = 'menu_armory'
    CurrentActionMsg  = _U('open_armory')
    CurrentActionData = {station = station}
  end

  if part == 'VehicleSpawner' then
    CurrentAction     = 'menu_vehicle_spawner'
    CurrentActionMsg  = _U('vehicle_spawner')
    CurrentActionData = {station = station, partNum = partNum}
  end

  if part == 'HelicopterSpawner' then

    local helicopters = Config.FireStations[station].Helicopters

    if not IsAnyVehicleNearPoint(helicopters[partNum].SpawnPoint.x, helicopters[partNum].SpawnPoint.y, helicopters[partNum].SpawnPoint.z,  3.0) then

      ESX.Game.SpawnVehicle('polmav', {
        x = helicopters[partNum].SpawnPoint.x,
        y = helicopters[partNum].SpawnPoint.y,
        z = helicopters[partNum].SpawnPoint.z
      }, helicopters[partNum].Heading, function(vehicle)
        SetVehicleModKit(vehicle, 0)
        SetVehicleLivery(vehicle, 0)
      end)

    end

  end

  if part == 'VehicleDeleter' then

    local playerPed = GetPlayerPed(-1)
    local coords    = GetEntityCoords(playerPed)

    if IsPedInAnyVehicle(playerPed,  false) then

      local vehicle = GetVehiclePedIsIn(playerPed, false)

      if DoesEntityExist(vehicle) then
        CurrentAction     = 'delete_vehicle'
        CurrentActionMsg  = _U('store_vehicle')
        CurrentActionData = {vehicle = vehicle}
      end

    end

  end

  if part == 'BossActions' then
    CurrentAction     = 'menu_boss_actions'
    CurrentActionMsg  = _U('open_bossmenu')
    CurrentActionData = {}
  end

end)

AddEventHandler('esx_firejob:hasExitedMarker', function(station, part, partNum)
  ESX.UI.Menu.CloseAll()
  CurrentAction = nil
end)

AddEventHandler('esx_firejob:hasEnteredEntityZone', function(entity)

  local playerPed = GetPlayerPed(-1)

  if PlayerData.job ~= nil and PlayerData.job.name == 'fire' and not IsPedInAnyVehicle(playerPed, false) then
    CurrentAction     = 'remove_entity'
    CurrentActionMsg  = _U('remove_object')
    CurrentActionData = {entity = entity}
  end

  if GetEntityModel(entity) == GetHashKey('p_ld_stinger_s') then

    local playerPed = GetPlayerPed(-1)
    local coords    = GetEntityCoords(playerPed)

    if IsPedInAnyVehicle(playerPed,  false) then

      local vehicle = GetVehiclePedIsIn(playerPed)

      for i=0, 7, 1 do
        SetVehicleTyreBurst(vehicle,  i,  true,  1000)
      end

    end

  end

end)

AddEventHandler('esx_firejob:hasExitedEntityZone', function(entity)

  if CurrentAction == 'remove_entity' then
    CurrentAction = nil
  end

end)

RegisterNetEvent('esx_firejob:handcuff')
AddEventHandler('esx_firejob:handcuff', function()

  IsHandcuffed    = not IsHandcuffed;
  local playerPed = GetPlayerPed(-1)

  Citizen.CreateThread(function()

    if IsHandcuffed then

      RequestAnimDict('mp_arresting')

      while not HasAnimDictLoaded('mp_arresting') do
        Wait(100)
      end

      TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
      SetEnableHandcuffs(playerPed, true)
      SetPedCanPlayGestureAnims(playerPed, false)
      FreezeEntityPosition(playerPed,  true)

    else

      ClearPedSecondaryTask(playerPed)
      SetEnableHandcuffs(playerPed, false)
      SetPedCanPlayGestureAnims(playerPed,  true)
      FreezeEntityPosition(playerPed, false)

    end

  end)
end)

RegisterNetEvent('esx_firejob:drag')
AddEventHandler('esx_firejob:drag', function(cop)
  TriggerServerEvent('esx:clientLog', 'starting dragging')
  IsDragged = not IsDragged
  CopPed = tonumber(cop)
end)

Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsHandcuffed then
      if IsDragged then
        local ped = GetPlayerPed(GetPlayerFromServerId(CopPed))
        local myped = GetPlayerPed(-1)
        AttachEntityToEntity(myped, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
      else
        DetachEntity(GetPlayerPed(-1), true, false)
      end
    end
  end
end)

RegisterNetEvent('esx_firejob:putInVehicle')
AddEventHandler('esx_firejob:putInVehicle', function()

  local playerPed = GetPlayerPed(-1)
  local coords    = GetEntityCoords(playerPed)

  if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then

    local vehicle = GetClosestVehicle(coords.x,  coords.y,  coords.z,  5.0,  0,  71)

    if DoesEntityExist(vehicle) then

      local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
      local freeSeat = nil

      for i=maxSeats - 1, 0, -1 do
        if IsVehicleSeatFree(vehicle,  i) then
          freeSeat = i
          break
        end
      end

      if freeSeat ~= nil then
        TaskWarpPedIntoVehicle(playerPed,  vehicle,  freeSeat)
      end

    end

  end

end)

RegisterNetEvent('esx_firejob:OutVehicle')
AddEventHandler('esx_firejob:OutVehicle', function(t)
  local ped = GetPlayerPed(t)
  ClearPedTasksImmediately(ped)
  plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
  local xnew = plyPos.x+2
  local ynew = plyPos.y+2

  SetEntityCoords(GetPlayerPed(-1), xnew, ynew, plyPos.z)
end)

RegisterNetEvent('esx_firejob:revive')
AddEventHandler('esx_firejob:revive', function()

  local playerPed = GetPlayerPed(-1)
  local coords    = GetEntityCoords(playerPed)

  Citizen.CreateThread(function()

    DoScreenFadeOut(800)

    while not IsScreenFadedOut() do
      Citizen.Wait(0)
    end

    ESX.SetPlayerData('lastPosition', {
      x = coords.x,
      y = coords.y,
      z = coords.z
    })

    TriggerServerEvent('esx:updateLastPosition', {
      x = coords.x,
      y = coords.y,
      z = coords.z
    })

    RespawnPed(playerPed, {
      x = coords.x,
      y = coords.y,
      z = coords.z
    })

    StopScreenEffect('DeathFailOut')

    DoScreenFadeIn(800)

  end)

end)

-- Handcuff
Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsHandcuffed then
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 30,  true) -- MoveLeftRight
      DisableControlAction(0, 31,  true) -- MoveUpDown
    end
  end
end)

-- Create blips
Citizen.CreateThread(function()

  for k,v in pairs(Config.FireStations) do

    local blip = AddBlipForCoord(v.Blip.Pos.x, v.Blip.Pos.y, v.Blip.Pos.z)

    SetBlipSprite (blip, v.Blip.Sprite)
    SetBlipDisplay(blip, v.Blip.Display)
    SetBlipScale  (blip, v.Blip.Scale)
    SetBlipColour (blip, v.Blip.Colour)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_U('map_blip'))
    EndTextCommandSetBlipName(blip)

  end

end)

-- Display markers
Citizen.CreateThread(function()
  while true do

    Wait(0)

    if PlayerData.job ~= nil and PlayerData.job.name == 'fire' then

      local playerPed = GetPlayerPed(-1)
      local coords    = GetEntityCoords(playerPed)

      for k,v in pairs(Config.FireStations) do

        for i=1, #v.Cloakrooms, 1 do
          if GetDistanceBetweenCoords(coords,  v.Cloakrooms[i].x,  v.Cloakrooms[i].y,  v.Cloakrooms[i].z,  true) < Config.DrawDistance then
            DrawMarker(Config.MarkerType, v.Cloakrooms[i].x, v.Cloakrooms[i].y, v.Cloakrooms[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
          end
        end

        for i=1, #v.Armories, 1 do
          if GetDistanceBetweenCoords(coords,  v.Armories[i].x,  v.Armories[i].y,  v.Armories[i].z,  true) < Config.DrawDistance then
            DrawMarker(Config.MarkerType, v.Armories[i].x, v.Armories[i].y, v.Armories[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
          end
        end

        for i=1, #v.Vehicles, 1 do
          if GetDistanceBetweenCoords(coords,  v.Vehicles[i].Spawner.x,  v.Vehicles[i].Spawner.y,  v.Vehicles[i].Spawner.z,  true) < Config.DrawDistance then
            DrawMarker(Config.MarkerType, v.Vehicles[i].Spawner.x, v.Vehicles[i].Spawner.y, v.Vehicles[i].Spawner.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
          end
        end

        for i=1, #v.VehicleDeleters, 1 do
          if GetDistanceBetweenCoords(coords,  v.VehicleDeleters[i].x,  v.VehicleDeleters[i].y,  v.VehicleDeleters[i].z,  true) < Config.DrawDistance then
            DrawMarker(Config.MarkerType, v.VehicleDeleters[i].x, v.VehicleDeleters[i].y, v.VehicleDeleters[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
          end
        end

        if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.name == 'fire' and PlayerData.job.grade_name == 'boss' then

          for i=1, #v.BossActions, 1 do
            if not v.BossActions[i].disabled and GetDistanceBetweenCoords(coords,  v.BossActions[i].x,  v.BossActions[i].y,  v.BossActions[i].z,  true) < Config.DrawDistance then
              DrawMarker(Config.MarkerType, v.BossActions[i].x, v.BossActions[i].y, v.BossActions[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
            end
          end

        end

      end

    end

  end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()

  while true do

    Wait(0)

    if PlayerData.job ~= nil and PlayerData.job.name == 'fire' then

      local playerPed      = GetPlayerPed(-1)
      local coords         = GetEntityCoords(playerPed)
      local isInMarker     = false
      local currentStation = nil
      local currentPart    = nil
      local currentPartNum = nil

      for k,v in pairs(Config.FireStations) do

        for i=1, #v.Cloakrooms, 1 do
          if GetDistanceBetweenCoords(coords,  v.Cloakrooms[i].x,  v.Cloakrooms[i].y,  v.Cloakrooms[i].z,  true) < Config.MarkerSize.x then
            isInMarker     = true
            currentStation = k
            currentPart    = 'Cloakroom'
            currentPartNum = i
          end
        end

        for i=1, #v.Armories, 1 do
          if GetDistanceBetweenCoords(coords,  v.Armories[i].x,  v.Armories[i].y,  v.Armories[i].z,  true) < Config.MarkerSize.x then
            isInMarker     = true
            currentStation = k
            currentPart    = 'Armory'
            currentPartNum = i
          end
        end

        for i=1, #v.Vehicles, 1 do

          if GetDistanceBetweenCoords(coords,  v.Vehicles[i].Spawner.x,  v.Vehicles[i].Spawner.y,  v.Vehicles[i].Spawner.z,  true) < Config.MarkerSize.x then
            isInMarker     = true
            currentStation = k
            currentPart    = 'VehicleSpawner'
            currentPartNum = i
          end

          if GetDistanceBetweenCoords(coords,  v.Vehicles[i].SpawnPoint.x,  v.Vehicles[i].SpawnPoint.y,  v.Vehicles[i].SpawnPoint.z,  true) < Config.MarkerSize.x then
            isInMarker     = true
            currentStation = k
            currentPart    = 'VehicleSpawnPoint'
            currentPartNum = i
          end

        end

        for i=1, #v.Helicopters, 1 do

          if GetDistanceBetweenCoords(coords,  v.Helicopters[i].Spawner.x,  v.Helicopters[i].Spawner.y,  v.Helicopters[i].Spawner.z,  true) < Config.MarkerSize.x then
            isInMarker     = true
            currentStation = k
            currentPart    = 'HelicopterSpawner'
            currentPartNum = i
          end

          if GetDistanceBetweenCoords(coords,  v.Helicopters[i].SpawnPoint.x,  v.Helicopters[i].SpawnPoint.y,  v.Helicopters[i].SpawnPoint.z,  true) < Config.MarkerSize.x then
            isInMarker     = true
            currentStation = k
            currentPart    = 'HelicopterSpawnPoint'
            currentPartNum = i
          end

        end

        for i=1, #v.VehicleDeleters, 1 do
          if GetDistanceBetweenCoords(coords,  v.VehicleDeleters[i].x,  v.VehicleDeleters[i].y,  v.VehicleDeleters[i].z,  true) < Config.MarkerSize.x then
            isInMarker     = true
            currentStation = k
            currentPart    = 'VehicleDeleter'
            currentPartNum = i
          end
        end

        if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.name == 'fire' and PlayerData.job.grade_name == 'boss' then

          for i=1, #v.BossActions, 1 do
            if GetDistanceBetweenCoords(coords,  v.BossActions[i].x,  v.BossActions[i].y,  v.BossActions[i].z,  true) < Config.MarkerSize.x then
              isInMarker     = true
              currentStation = k
              currentPart    = 'BossActions'
              currentPartNum = i
            end
          end

        end

      end

      local hasExited = false

      if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum) ) then

        if
          (LastStation ~= nil and LastPart ~= nil and LastPartNum ~= nil) and
          (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
        then
          TriggerEvent('esx_firejob:hasExitedMarker', LastStation, LastPart, LastPartNum)
          hasExited = true
        end

        HasAlreadyEnteredMarker = true
        LastStation             = currentStation
        LastPart                = currentPart
        LastPartNum             = currentPartNum

        TriggerEvent('esx_firejob:hasEnteredMarker', currentStation, currentPart, currentPartNum)
      end

      if not hasExited and not isInMarker and HasAlreadyEnteredMarker then

        HasAlreadyEnteredMarker = false

        TriggerEvent('esx_firejob:hasExitedMarker', LastStation, LastPart, LastPartNum)
      end

    end

  end
end)

-- Enter / Exit entity zone events
Citizen.CreateThread(function()

  local trackedEntities = {
    'prop_roadcone02a',
    'prop_barrier_work06a',
    'p_ld_stinger_s',
    'prop_boxpile_07d',
    'hei_prop_cash_crate_half_full'
  }

  while true do

    Citizen.Wait(0)

    local playerPed = GetPlayerPed(-1)
    local coords    = GetEntityCoords(playerPed)

    local closestDistance = -1
    local closestEntity   = nil

    for i=1, #trackedEntities, 1 do

      local object = GetClosestObjectOfType(coords.x,  coords.y,  coords.z,  3.0,  GetHashKey(trackedEntities[i]), false, false, false)

      if DoesEntityExist(object) then

        local objCoords = GetEntityCoords(object)
        local distance  = GetDistanceBetweenCoords(coords.x,  coords.y,  coords.z,  objCoords.x,  objCoords.y,  objCoords.z,  true)

        if closestDistance == -1 or closestDistance > distance then
          closestDistance = distance
          closestEntity   = object
        end

      end

    end

    if closestDistance ~= -1 and closestDistance <= 3.0 then

      if LastEntity ~= closestEntity then
        TriggerEvent('esx_firejob:hasEnteredEntityZone', closestEntity)
        LastEntity = closestEntity
      end

    else

      if LastEntity ~= nil then
        TriggerEvent('esx_firejob:hasExitedEntityZone', LastEntity)
        LastEntity = nil
      end

    end

  end
end)

-- Key Controls
Citizen.CreateThread(function()
  while true do

    Citizen.Wait(0)

    if CurrentAction ~= nil then

      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)

      if IsControlPressed(0,  Keys['E']) and PlayerData.job ~= nil and PlayerData.job.name == 'fire' and (GetGameTimer() - GUI.Time) > 150 then

        if CurrentAction == 'menu_cloakroom' then
          OpenCloakroomMenu()
        end

        if CurrentAction == 'menu_armory' then
          OpenArmoryMenu(CurrentActionData.station)
        end

        if CurrentAction == 'menu_vehicle_spawner' then
          OpenVehicleSpawnerMenu(CurrentActionData.station, CurrentActionData.partNum)
        end

        if CurrentAction == 'delete_vehicle' then

          if Config.EnableSocietyOwnedVehicles then

            local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
            TriggerServerEvent('esx_society:putVehicleInGarage', 'fire', vehicleProps)

          else

            if
              GetEntityModel(vehicle) == GetHashKey('fire')  or
              GetEntityModel(vehicle) == GetHashKey('fire2') or
              GetEntityModel(vehicle) == GetHashKey('fire3') or
              GetEntityModel(vehicle) == GetHashKey('fire4') or
              GetEntityModel(vehicle) == GetHashKey('fireb') or
              GetEntityModel(vehicle) == GetHashKey('firet')
            then
              TriggerServerEvent('esx_service:disableService', 'fire')
            end

          end

          ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
        end

        if CurrentAction == 'menu_boss_actions' then

          ESX.UI.Menu.CloseAll()

          TriggerEvent('esx_society:openBossMenu', 'fire', function(data, menu)

            menu.close()

            CurrentAction     = 'menu_boss_actions'
            CurrentActionMsg  = _U('open_bossmenu')
            CurrentActionData = {}

          end)

        end

        if CurrentAction == 'remove_entity' then
          DeleteEntity(CurrentActionData.entity)
        end

        CurrentAction = nil
        GUI.Time      = GetGameTimer()

      end

    end

    if IsControlPressed(0,  Keys['F6']) and PlayerData.job ~= nil and PlayerData.job.name == 'fire' and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'fire_actions') and (GetGameTimer() - GUI.Time) > 150 then
      OpenFireActionsMenu()
      GUI.Time = GetGameTimer()
    end

  end
end)

function openFire()
  if PlayerData.job ~= nil and PlayerData.job.name == 'fire' and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'fire_actions') and (GetGameTimer() - GUI.Time) > 150 then
    OpenFireActionsMenu()
    GUI.Time = GetGameTimer()
  end
end

function getJob()
  if PlayerData.job ~= nil then
    return PlayerData.job.name
  end
end