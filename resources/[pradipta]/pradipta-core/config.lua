PradiptaCore = {}
PradiptaCore.Config = {}

PradiptaCore.Config.MaxPlayers = GetConvarInt('sv_maxclients', 48) -- Gets max players from config file, default 48
PradiptaCore.Config.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)
PradiptaCore.Config.UpdateInterval = 5                             -- how often to update player data in minutes
PradiptaCore.Config.StatusInterval = 5000                          -- how often to check hunger/thirst status in milliseconds

PradiptaCore.Config.Money = {}
PradiptaCore.Config.Money.MoneyTypes = { cash = 500, bank = 5000, crypto = 0 } -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!
PradiptaCore.Config.Money.DontAllowMinus = { 'cash', 'crypto' }                -- Money that is not allowed going in minus
PradiptaCore.Config.Money.MinusLimit = -5000                                   -- The maximum amount you can be negative
PradiptaCore.Config.Money.PayCheckTimeOut = 0
PradiptaCore.Config.Money.PayCheckSociety = false

PradiptaCore.Config.Player = {}
PradiptaCore.Config.Player.HungerRate = 0
PradiptaCore.Config.Player.ThirstRate = 0
PradiptaCore.Config.Player.Bloodtypes = {
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
}

PradiptaCore.Config.Player.PlayerDefaults = {
    citizenid = function() return PradiptaCore.Player.CreateCitizenId() end,
    cid = 1,
    money = function()
        local moneyDefaults = {}
        for moneytype, startamount in pairs(PradiptaCore.Config.Money.MoneyTypes) do
            moneyDefaults[moneytype] = startamount
        end
        return moneyDefaults
    end,
    optin = true,
    charinfo = {
        firstname = 'Firstname',
        lastname = 'Lastname',
        birthdate = '00-00-0000',
        gender = 0,
        nationality = 'USA',
        phone = function() return PradiptaCore.Functions.CreatePhoneNumber() end,
        account = function() return PradiptaCore.Functions.CreateAccountNumber() end
    },
    job = {
        name = 'unemployed',
        label = 'Civilian',
        payment = 10,
        type = 'none',
        onduty = false,
        isboss = false,
        grade = {
            name = 'Freelancer',
            level = 0
        }
    },
    gang = {
        name = 'none',
        label = 'No Gang Affiliation',
        isboss = false,
        grade = {
            name = 'none',
            level = 0
        }
    },
    metadata = {
        hunger = 100,
        thirst = 100,
        stress = 0,
        isdead = false,
        inlaststand = false,
        armor = 0,
        ishandcuffed = false,
        tracker = false,
        injail = 0,
        jailitems = {},
        status = {},
        phone = {},
        rep = {},
        currentapartment = nil,
        callsign = 'NO CALLSIGN',
        bloodtype = function() return PradiptaCore.Config.Player.Bloodtypes[math.random(1, #PradiptaCore.Config.Player.Bloodtypes)] end,
        fingerprint = function() return PradiptaCore.Player.CreateFingerId() end,
        walletid = function() return PradiptaCore.Player.CreateWalletId() end,
        criminalrecord = {
            hasRecord = false,
            date = nil
        },
        licences = {
            driver = true,
            business = false,
            weapon = false
        },
        inside = {
            house = nil,
            apartment = {
                apartmentType = nil,
                apartmentId = nil,
            }
        },
        phonedata = {
            SerialNumber = function() return PradiptaCore.Player.CreateSerialNumber() end,
            InstalledApps = {}
        }
    },
    position = PradiptaCore.Config.DefaultSpawn,
    items = {},
}

PradiptaCore.Config.Server = {}                                    -- General server config
PradiptaCore.Config.Server.Closed = false                          -- Set server closed (no one can join except people with ace permission 'pradiptaadmin.join')
PradiptaCore.Config.Server.ClosedReason = 'Server Closed'          -- Reason message to display when people can't join the server
PradiptaCore.Config.Server.Uptime = 0                              -- Time the server has been up.
PradiptaCore.Config.Server.Whitelist = false                       -- Enable or disable whitelist on the server
PradiptaCore.Config.Server.WhitelistPermission = 'admin'           -- Permission that's able to enter the server when the whitelist is on
PradiptaCore.Config.Server.PVP = true                              -- Enable or disable pvp on the server (Ability to shoot other players)
PradiptaCore.Config.Server.Discord = ''                            -- Discord invite link
PradiptaCore.Config.Server.CheckDuplicateLicense = true            -- Check for duplicate rockstar license on join
PradiptaCore.Config.Server.Permissions = { 'god', 'admin', 'mod' } -- Add as many groups as you want here after creating them in your server.cfg

PradiptaCore.Config.Commands = {}                                  -- Command Configuration
PradiptaCore.Config.Commands.OOCColor = { 255, 151, 133 }          -- RGB color code for the OOC command

PradiptaCore.Config.Notify = {}

PradiptaCore.Config.Notify.NotificationStyling = {
    group = false,      -- Allow notifications to stack with a badge instead of repeating
    position = 'right', -- top-left | top-right | bottom-left | bottom-right | top | bottom | left | right | center
    progress = true     -- Display Progress Bar
}

-- These are how you define different notification variants
-- The "color" key is background of the notification
-- The "icon" key is the css-icon code, this project uses `Material Icons` & `Font Awesome`
PradiptaCore.Config.Notify.VariantDefinitions = {
    success = {
        classes = 'success',
        icon = 'check_circle'
    },
    primary = {
        classes = 'primary',
        icon = 'notifications'
    },
    warning = {
        classes = 'warning',
        icon = 'warning'
    },
    error = {
        classes = 'error',
        icon = 'error'
    },
    police = {
        classes = 'police',
        icon = 'local_police'
    },
    ambulance = {
        classes = 'ambulance',
        icon = 'fas fa-ambulance'
    }
}
