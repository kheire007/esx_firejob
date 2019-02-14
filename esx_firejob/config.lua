Config                            = {}
Config.DrawDistance               = 100.0
Config.MarkerType                 = 1
Config.MarkerSize                 = { x = 1.5, y = 1.5, z = 1.0 }
Config.MarkerColor                = { r = 50, g = 50, b = 204 }
Config.EnablePlayerManagement     = true
Config.EnableArmoryManagement     = false
Config.EnableESXIdentity          = true -- only turn this on if you are using esx_identity
Config.EnableNonFreemodePeds      = true -- turn this on if you want custom peds
Config.EnableSocietyOwnedVehicles = false
Config.EnableLicenses             = true
Config.MaxInService               = -1
Config.Locale                     = 'fr'

Config.FireStations = {

  LSFD = {
    Blip = {
      Pos = { x = 1202.7244873047, y = -1463.0455322266, z = 34.849590301514 },
      Sprite  = 436,
      Display = 4,
      Scale   = 1.2,
      Colour  = 1,
    },

    AuthorizedWeapons = {
      {name = 'WEAPON_FLASHLIGHT',       price = 80},
      {name = 'WEAPON_FIREEXTINGUISHER', price = 120},
	  {name = 'WEAPON_FLARE',            price = 60 },
      {name = 'WEAPON_FLAREGUN',         price = 60},
    },

    AuthorizedVehicles = {
	  { name = 'ambulance', label = 'Ambulance' },
	  { name = 'firetruk', label = 'Fire Truck' },
	  { name = 'emscar', label = 'EMS Car' },	  
	  { name = 'emscar2', label = 'EMS Car' },	  
	  { name = 'emsvan', label = 'EMS Van' },	  
	  { name = 'emssuv', label = 'EMS SUV' },	  
	  { name = 'ambulance2', label = 'Ambulance 2' },	  
    },

    Cloakrooms = {
      { x = 1192.637, y = -1474.431, z = 33.893 }
    },

    Armories = {
      { x = 1194.7569580078, y = -1478.9689941406, z = 33.859531402588 },
    },

    Vehicles = {
      {
        Spawner    = { x = 1196.3173828125, y = -1462.1235351563, z = 33.822658538818 },
        SpawnPoint = { x = 1200.7666015625, y = -1456.6851806641, z = 34.93176651001 },
        Heading    = 359.68
      }
    },

    Helicopters = {
      {
        Spawner    = {x = 466.477, y = -982.819, z = 42.691},
        SpawnPoint = {x = 450.04, y = -981.14, z = 42.691},
        Heading    = 0.0
      }
    },

    VehicleDeleters = {
      { x = 1221.260, y = -1518.321, z = 33.692 },
    },

    BossActions = {
      { x = 1209.4600830078, y = -1480.7308349609, z = 33.859531402588 },
    }
  }
}