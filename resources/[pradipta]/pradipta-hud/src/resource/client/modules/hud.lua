local NUI_ACTIONS = (BabloHud and BabloHud.Constants and BabloHud.Constants.NUI_ACTIONS) or {}

local VALID_COMPONENTS = {
    status        = true,
    speedometer   = true,
    playerInfo    = true,
    minimap       = true,
    voice         = true,
    notifications = true,
    progressBar   = true,
    controlHints  = true,
}

Bablo = Bablo or {}

Bablo.Hud = {
    suppressed        = false,
    hiddenComponents  = {},
}

function SyncMinimapHiddenGlobal()
    local hidden = Bablo.Hud.suppressed or (Bablo.Hud.hiddenComponents.minimap == true)
    _G.BabloHudMinimapHidden = hidden or nil

    if _G.BabloHudRecomputeRadar then
        _G.BabloHudRecomputeRadar()
    end
end

function SendHudSuppressedState()
    SendNUIMessage({
        action = NUI_ACTIONS.SET_HUD_SUPPRESSED or "setHudSuppressed",
        data   = Bablo.Hud.suppressed,
    })
end

function SendComponentVisibility(component, visible)
    SendNUIMessage({
        action = NUI_ACTIONS.SET_COMPONENT_VISIBLE or "setComponentVisible",
        data   = { component = component, visible = visible and true or false },
    })
end

function Bablo.Hud:SetVisible(visible)
    local newSuppressed = not visible
    if newSuppressed == self.suppressed then return end

    self.suppressed            = newSuppressed
    _G.BabloHudSuppressed      = self.suppressed

    SendHudSuppressedState()
    SyncMinimapHiddenGlobal()
end

function Bablo.Hud:Toggle()
    self:SetVisible(self.suppressed)   
end

function Bablo.Hud:IsVisible()
    return not self.suppressed
end

function Bablo.Hud:SetComponentVisible(component, visible)
    if type(component) ~= "string" or not VALID_COMPONENTS[component] then
        return false
    end

    self.hiddenComponents[component] = (not visible) or nil
    SendComponentVisibility(component, visible)

    if component == "minimap" then
        SyncMinimapHiddenGlobal()
    end

    return true
end

function Bablo.Hud:IsComponentVisible(component)
    if type(component) ~= "string" or not VALID_COMPONENTS[component] then
        return false
    end

    if self.hiddenComponents[component] == true then return false end

    if BabloHud and BabloHud.Settings and type(BabloHud.Settings.isComponentEnabled) == "function" then
        if BabloHud.Settings.isComponentEnabled(component) == false then
            return false
        end
    end

    return true
end

exports("ShowHud", function()
    Bablo.Hud:SetVisible(true)
end)

exports("HideHud", function()
    Bablo.Hud:SetVisible(false)
end)

exports("ToggleHud", function()
    Bablo.Hud:Toggle()
end)

exports("IsHudVisible", function()
    return Bablo.Hud:IsVisible()
end)

exports("SetComponentVisible", function(component, visible)
    return Bablo.Hud:SetComponentVisible(component, visible)
end)

exports("IsComponentVisible", function(component)
    return Bablo.Hud:IsComponentVisible(component)
end)

