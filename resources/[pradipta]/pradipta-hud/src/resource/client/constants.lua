PradiptaHud = PradiptaHud or {}
BabloHud = PradiptaHud
_G.PradiptaHud = PradiptaHud
_G.BabloHud = PradiptaHud
_G.PradiptaHudHostname = nil
_G.BabloHudHostname = nil

if not PradiptaHud.Constants then
    PradiptaHud.Constants = {
        KVP = {
            MINIMAP_POSITION = "pradipta_hud_minimap_position_v2",
            SETTINGS        = "pradipta_hud_settings_v2",
        },
        NUI_ACTIONS = {
            TOGGLE_SETTINGS            = "toggleSettings",
            SAFEZONE_UPDATE            = "safeZone:update",
            SET_MINIMAP_ANCHOR         = "setMinimapAnchor",
            MINIMAP_TRANSITION         = "minimapTransition",
            CONTROL_HINT_SHOW          = "controlHint:show",
            CONTROL_HINT_HIDE          = "controlHint:hide",
            CONTROL_HINT_CLEAR         = "controlHint:clear",
            SET_DEFAULT_MINIMAP_ANCHOR = "setDefaultMinimapAnchor",
            LOAD_LOCALE                = "loadLocale",
            LOAD_SETTINGS              = "loadSettings",
            UPDATE_STATUS              = "updateStatus",
            UPDATE_PLAYER_INFO         = "updatePlayerInfo",
            SET_VEHICLE_STATE          = "setVehicleState",
            UPDATE_VEHICLE_DATA        = "updateVehicleData",
            NOTIFY                     = "notify",
            PROGRESS_START             = "progressBar:start",
            PROGRESS_STOP              = "progressBar:stop",
            PROGRESS_UPDATE            = "progressBar:update",
            SET_HUD_VISIBLE            = "setHudVisible",
            SET_HUD_SUPPRESSED         = "setHudSuppressed",
            SET_PAUSE_MENU_ACTIVE      = "setPauseMenuActive",
            SET_COMPONENT_VISIBLE      = "setComponentVisible",
            SET_CINEMATIC              = "setCinematic",
            UPDATE_COMPASS             = "updateCompass",
            SET_COMPASS_IN_VEHICLE     = "setCompassInVehicle",
            UPDATE_WAYPOINT            = "updateWaypoint",
            PLAY_ALERT_SOUND           = "playAlertSound",
            START_ALARM_SOUND          = "startAlarmSound",
            STOP_ALARM_SOUND           = "stopAlarmSound",
        },
    }
end

function PradiptaHud.GetKvpKey(baseKey)
    local hostname = _G.PradiptaHudHostname or _G.BabloHudHostname
    if not hostname or hostname == "" then
        return baseKey
    end
    return baseKey .. "-" .. hostname
end
BabloHud.GetKvpKey = PradiptaHud.GetKvpKey
