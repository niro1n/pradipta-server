local ASPECT_RATIO_16_9  = 1.7777777910233   
local MINIMAP_OFFSET_X   = -7.0              
local MINIMAP_OFFSET_Y   = 21.0             

function math.round(value, decimals)
    if decimals then
        local factor = 10 ^ decimals
        return math.floor(value * factor + 0.5) / factor
    end
    return math.floor(value + 0.5)
end

function ConvertResolutionCoordsToScaleformCoords(x, y)
    local w, h = GetActiveScreenResolution()
    return vector2(x / w * 1280, y / h * 720)
end

function ConvertScaleformCoordsToResolutionCoords(x, y)
    local w, h = GetActiveScreenResolution()
    return vector2(x / 1280 * w, y / 720 * h)
end

function ConvertScreenCoordsToScaleformCoords(x, y)
    return vector2(x * 1280, y * 720)
end

function ConvertScaleformCoordsToScreenCoords(x, y)
    return vector2(x / 1280, y / 720)
end

function ConvertResolutionCoordsToScreenCoords(x, y)
    local w, h = GetActualScreenResolution()
    return vector2(x / w, y / h)
end

function ConvertScreenCoordsToResolutionCoords(x, y)
    local w, h = GetActualScreenResolution()
    return vector2(math.floor(x * w + 0.5), math.floor(y * h + 0.5))
end

function ConvertResolutionSizeToScaleformSize(w, h)
    local sw, sh = GetActiveScreenResolution()
    return vector2(w / sw * 1280, h / sh * 720)
end

function ConvertScaleformSizeToResolutionSize(w, h)
    local sw, sh = GetActiveScreenResolution()
    return vector2(w / 1280 * sw, h / 720 * sh)
end

function ConvertScreenSizeToScaleformSize(w, h)
    return vector2(w * 1280, h * 720)
end

function ConvertScaleformSizeToScreenSize(w, h)
    local sw, sh = GetActualScreenResolution()
    return vector2(w / sw, h / sh)
end

function ConvertResolutionSizeToScreenSize(w, h)
    local sw, sh = GetActualScreenResolution()
    return vector2(w / sw, h / sh)
end

function IsSuperWideScreen()
    return GetAspectRatio(true) > ASPECT_RATIO_16_9
end

function GetWideScreen()
    local minRatio  = 1.5
    local activeAspect = GetAspectRatio(false)
    local physW, physH = GetActualScreenResolution()
    if physW / physH <= minRatio then return false end
    return minRatio < activeAspect
end

function AdjustForSuperWidescreen(x, width)
    if not IsSuperWideScreen() then return x, width end
    local ratio   = ASPECT_RATIO_16_9 / GetAspectRatio(false)
    local offsetX = (0.5 - x) * ratio
    return 0.5 - offsetX, width * ratio
end

function GetMinSafeZone(safeZoneOverride, adjustSuperWide)
    local safe   = GetSafeZoneSize()
    local safeSz = GetSafeZoneSize()

    if safeZoneOverride < 1.0 then
        safe = 1.0 - ((1.0 - safe) + (1.0 - safeZoneOverride))
    end

    local physW, physH = GetActualScreenResolution()
    local marginW = physW * safe
    local marginH = physH * safeSz
    local padX    = (physW - marginW) * 0.5
    local padY    = (physH - marginH) * 0.5

    local left   = math.ceil(padX)  / physW
    local top    = math.ceil(padY)  / physH
    local right  = math.floor(physW - padX) / physW
    local bottom = math.floor(physH - padY) / physH

    if adjustSuperWide and IsSuperWideScreen() then
        local ratio       = ASPECT_RATIO_16_9 / GetAspectRatio(true)
        local pillarWidth = physW * ratio
        local pillarPadX  = (physW - pillarWidth) * 0.5 / physW
        left  = left  + pillarPadX
        right = right - pillarPadX
    end

    return left, top, right, bottom
end

function GetMinSafeZoneForScaleformMovies(safeZoneOverride)
    local left, top, right, bottom = GetMinSafeZone(safeZoneOverride)
    local diff = GetDifferenceFrom_16_9_ToCurrentAspectRatio()
    return left + diff, top, right - diff, bottom
end

function GetDifferenceFrom_16_9_ToCurrentAspectRatio()
    if IsSuperWideScreen() then return 0.0 end

    local physW, physH = GetActualScreenResolution()
    local physAspect   = physW / physH
    local safeMargin   = (1.0 - GetSafeZoneSize()) * 0.5

    local targetWidth  = safeMargin * ASPECT_RATIO_16_9 - physAspect
    local normalised   = 1.0 - (physAspect / ASPECT_RATIO_16_9)
    return normalised - targetWidth * 0.5
end

function GetFormatFromString(align)
    local s = align and align:upper() or ""
    if s == "C" then return "C"
    elseif s == "R" then return "R"
    else return "L" end
end

function AdjustNormalized16_9ValuesForCurrentAspectRatio(align, x, y, w, h)
    local activeAspect = GetAspectRatio(false)
    if IsSuperWideScreen() then activeAspect = ASPECT_RATIO_16_9 end

    local ratio = ASPECT_RATIO_16_9 / activeAspect
    local delta = 1.0 - ratio
    if math.abs(delta) < 0.001 then delta = 0.0 end

    w = w * ratio

    if align == "C" then
        x = x * ratio + delta * 0.5
    elseif align == "R" then
        x = x * ratio + delta
    else 
        x = x * ratio
    end

    x, h = AdjustForSuperWidescreen(x, h)
    return vector2(x, y), vector2(w, h)
end

function CalculateHudPosition(offset, size, alignH, alignV)
    local left, top, right, bottom = GetMinSafeZone(1.0)
    local safeMin = vector2(left,  top)
    local safeMax = vector2(right, bottom)
    local pos     = vector2(0.0, 0.0)

    if alignH == "L" then
        pos = vector2(safeMin.x, pos.y)
    elseif alignH == "R" then
        pos = vector2(safeMax.x - size.x, pos.y)
    elseif alignH == "C" then
        pos = vector2((safeMin.x + safeMax.x - size.x) * 0.5, pos.y)
    end

    if alignV == "T" then
        pos = vector2(pos.x, safeMin.y)
    elseif alignV == "B" then
        pos = vector2(pos.x, safeMax.y - size.y)
    elseif alignV == "C" then
        pos = vector2(pos.x, (safeMin.y + safeMax.y - size.y) * 0.5)
    end

    return pos + offset
end

function GetAnchorScreenCoords(alignH, alignV, x, y, w, h)
    local pos, size = AdjustNormalized16_9ValuesForCurrentAspectRatio(alignH, x, y, w, h)
    local topLeft   = CalculateHudPosition(pos, size, alignH, alignV)

    local rect = {
        Width   = size.x,
        Height  = size.y,
        LeftX   = topLeft.x,
        TopY    = topLeft.y,
        RightX  = topLeft.x + size.x,
        BottomY = topLeft.y + size.y,
        CenterX = topLeft.x + size.x * 0.5,
        CenterY = topLeft.y + size.y * 0.5,
        x       = topLeft.x,
        y       = topLeft.y,
    }
    return rect
end

function GetAnchorResolutionCoords(alignH, alignV, xPx, yPx, wPx, hPx)
    local screenPos  = ConvertResolutionCoordsToScreenCoords(xPx, yPx)
    local screenSize = ConvertResolutionSizeToScreenSize(wPx, hPx)
    return GetAnchorScreenCoords(alignH, alignV, screenPos.x, screenPos.y, screenSize.x, screenSize.y)
end

function CalculateRawHudRect(alignH, alignV, xScreen, yScreen, wScreen, hScreen)
    local size    = vector2(wScreen, hScreen)
    local pos     = CalculateHudPosition(vector2(xScreen, yScreen), size, alignH, alignV)
    return {
        LeftX   = pos.x,
        TopY    = pos.y,
        Width   = wScreen,
        Height  = hScreen,
        RightX  = pos.x + wScreen,
        BottomY = pos.y + hScreen,
    }
end

local MINIMAP_STYLES = {
    square = {
        main = { x = 0.0,   y = -0.047, w = 0.1638, h = 0.183 },
        mask = { x = 0.0,   y =  0.0,   w = 0.128,  h = 0.2   },
        blur = { x = -0.01, y =  0.025, w = 0.262,  h = 0.3   },
    },
    circle = {
        main = { x = 0.0,   y = -0.047, w = 0.1638, h = 0.183 },
        mask = { x = 0.0,   y = -0.047, w = 0.1638, h = 0.183 },
        blur = { x = -0.01, y =  0.025, w = 0.262,  h = 0.3   },
    },
    
    wide = {
        main = { x = 0.0,   y = -0.047, w = 0.364,  h = 0.460416666 },
        mask = { x = 0.0,   y =  0.0,   w = 0.176,  h = 0.395       },
        blur = { x = -0.01, y =  0.025, w = 0.262,  h = 0.464       },
    },
}

local STYLE_TEXTURE_DICT = {
    circle = "circlemap",
    square = "squaremap",
}

Minimap = {
    offsetX             = MINIMAP_OFFSET_X,
    offsetY             = MINIMAP_OFFSET_Y,
    isInitialized       = false,
    overlayHideLockStarted = false,
    currentStyle        = "square",
    reapplyPending      = false,
    scaleform           = nil,
}

function GetMinimapStyleData(styleName)
    return MINIMAP_STYLES[styleName or "square"] or MINIMAP_STYLES.square
end

function GetStyleTextureName(styleName)
    return STYLE_TEXTURE_DICT[styleName or "square"] or STYLE_TEXTURE_DICT.square
end

function GetWidescreenMinimapXCorrection()
    local RATIO_16_9 = 1.7777777777777777
    local activeAspect = GetAspectRatio(false)
    if RATIO_16_9 >= activeAspect then return 0.0 end

    local w, h = GetActiveScreenResolution()
    local physAspect = w / h
    if RATIO_16_9 < physAspect then
        return (RATIO_16_9 - physAspect) / 3.6 - 0.008
    end
    return 0.0
end

function GetMinimapConfig()
    return Config and Config.DefaultSettings and Config.DefaultSettings.minimap or nil
end

function GetMinimapScale()
    if type(_G.BabloHudMinimapSize) == "number" and _G.BabloHudMinimapSize > 0 then
        return _G.BabloHudMinimapSize
    end
    local cfg = GetMinimapConfig()
    if cfg then
        local size = tonumber(cfg.size)
        if size and size > 0 then return size end
    end
    return 1.0
end

function ApplyNorthIndicatorVisibility()
    local blip = GetNorthRadarBlip()
    if not blip or not DoesBlipExist(blip) then return end

    local cfg   = GetMinimapConfig()
    local alpha = (cfg and cfg.showNorthIndicator) and 255 or 0
    SetBlipAlpha(blip, alpha)
end

local savedBlipAlphas = {}

function HideAllBlips()
    for blipType = 0, 826 do
        local blip = GetFirstBlipInfoId(blipType)
        while DoesBlipExist(blip) do
            if savedBlipAlphas[blip] == nil then
                savedBlipAlphas[blip] = GetBlipAlpha(blip)
            end
            SetBlipAlpha(blip, 0)
            blip = GetNextBlipInfoId(blipType)
        end
    end

    local playerBlip = GetMainPlayerBlipId()
    if playerBlip and DoesBlipExist(playerBlip) then
        SetBlipAlpha(playerBlip, 0)
    end

    local northBlip = GetNorthRadarBlip()
    if northBlip and DoesBlipExist(northBlip) then
        SetBlipAlpha(northBlip, 0)
    end
end

function RestoreAllBlips()
    for blipType = 0, 826 do
        local blip = GetFirstBlipInfoId(blipType)
        while DoesBlipExist(blip) do
            local saved = savedBlipAlphas[blip]
            SetBlipAlpha(blip, saved ~= nil and saved or 255)
            blip = GetNextBlipInfoId(blipType)
        end
    end

    local playerBlip = GetMainPlayerBlipId()
    if playerBlip and DoesBlipExist(playerBlip) then
        SetBlipAlpha(playerBlip, 255)
    end

    savedBlipAlphas = {}
end

local editModeActive = false

RegisterNUICallback("setEditMode", function(data, cb)
    local requestedActive = (data and data.active == true)

    if requestedActive == editModeActive then
        cb({ success = true })
        return
    end

    editModeActive = requestedActive

    if editModeActive then
        CreateThread(function()
            while editModeActive do
                HideAllBlips()
                Wait(400)
            end
            RestoreAllBlips()
            ApplyNorthIndicatorVisibility()
        end)
    end

    cb({ success = true })
end)

function Minimap:setOffset(x, y)
    self.offsetX = x or 0.0
    self.offsetY = y or 0.0
end

function Minimap:resetOffset()
    self.offsetX = MINIMAP_OFFSET_X
    self.offsetY = MINIMAP_OFFSET_Y
end

function Minimap:getOffset()
    return self.offsetX, self.offsetY
end

function Minimap:getAnchor()
    local style      = GetMinimapStyleData(self.currentStyle)
    local main       = style.main
    local widthScale = (GetMinimapConfig() and GetMinimapConfig().widthScale) or 0.88
    local offsetPx   = ConvertResolutionCoordsToScreenCoords(self.offsetX, self.offsetY)
    local xCorrect   = GetWidescreenMinimapXCorrection()
    local scale      = GetMinimapScale()

    local x = (main.x + xCorrect + offsetPx.x) * scale
    local y = (main.y - offsetPx.y) * scale
    local w = main.w * scale * widthScale
    local h = main.h * scale

    local rect     = GetAnchorScreenCoords("L", "B", x, y, w, h)
    local topLeft  = ConvertScreenCoordsToResolutionCoords(rect.x, rect.y)
    local botRight = ConvertScreenCoordsToResolutionCoords(rect.RightX, rect.BottomY)

    local widthPx  = math.max(0, botRight.x - topLeft.x)
    local heightPx = math.max(0, botRight.y - topLeft.y)
    local leftPx   = math.max(0, topLeft.x)
    local topPx    = math.max(0, topLeft.y)

    return {
        x         = rect.x,
        y         = rect.y,
        width     = rect.Width,
        height    = rect.Height,
        xPct      = rect.x       * 100,
        yPct      = rect.y       * 100,
        widthPct  = rect.Width   * 100,
        heightPct = rect.Height  * 100,
        leftPx    = leftPx,
        topPx     = topPx,
        widthPx   = widthPx,
        heightPx  = heightPx,
        bottomPx  = topPx + heightPx,
        rawX      = rect.x,
        rawY      = rect.y,
        offsetX   = self.offsetX,
        offsetY   = self.offsetY,
    }
end

function Minimap:applyClipType()
    SetMinimapClipType(self.currentStyle == "circle" and 1 or 0)
end

function Minimap:enforceHiddenOverlays()
    if not self.scaleform or not HasScaleformMovieLoaded(self.scaleform) then return end

    BeginScaleformMovieMethod(self.scaleform, "SETUP_HEALTH_ARMOUR")
    ScaleformMovieMethodAddParamInt(3)
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(self.scaleform, "HIDE_SATNAV")
    EndScaleformMovieMethod()
end

function MoveMinimapComponent(alignH, alignV, deltaX, deltaY, scale, refreshBigmap)
    local miniStyle  = GetMinimapStyleData(Minimap.currentStyle)
    local wideStyle  = MINIMAP_STYLES.wide
    local xCorrect   = GetWidescreenMinimapXCorrection()
    local widthScale = (GetMinimapConfig() and GetMinimapConfig().widthScale) or 0.88

    local function PlaceLayer(component, layer, xOff)
        local cx = (layer.x + xOff + deltaX) * scale
        local cy = (layer.y + deltaY) * scale
        local cw = layer.w * scale * (widthScale or 1.0)
        local ch = layer.h * scale
        
        if component == "bigmap" or component == "bigmap_mask" or component == "bigmap_blur" then
            cw = layer.w * scale
        end
        SetMinimapComponentPosition(component, alignH, alignV, cx, cy, cw, ch)
    end

    PlaceLayer("minimap",      miniStyle.main, xCorrect)
    PlaceLayer("minimap_mask", miniStyle.mask, xCorrect)
    PlaceLayer("minimap_blur", miniStyle.blur, xCorrect)
    PlaceLayer("bigmap",      wideStyle.main, xCorrect)
    PlaceLayer("bigmap_mask", wideStyle.mask, xCorrect)
    PlaceLayer("bigmap_blur", wideStyle.blur, xCorrect)

    if refreshBigmap then
        SetBigmapActive(true,  false)
        Wait(50)
        SetBigmapActive(false, false)

        local cfg = GetMinimapConfig()
        if not (cfg and cfg.showLongRangeBlips) then
            
            CreateThread(function()
                for _ = 1, 8 do
                    SetMinimapComponent(2, false, 0)
                    Wait(50)
                end
            end)
        end
    end
end

function Minimap:applyPosition(refreshBigmap)
    ResetScriptGfxAlign()
    local offsetScreen = ConvertResolutionCoordsToScreenCoords(self.offsetX, self.offsetY)
    self:applyClipType()
    MoveMinimapComponent("L", "B", offsetScreen.x, -offsetScreen.y, GetMinimapScale(), refreshBigmap)
    if refreshBigmap then self:applyClipType() end
    self:enforceHiddenOverlays()
end

function Minimap:refresh()
    self:applyPosition(true)
end

function SetRadarVisible(visible)
    DisplayRadar(visible)
end

function LoadTextureDictWithTimeout(dictName)
    if HasStreamedTextureDictLoaded(dictName) then return true end

    RequestStreamedTextureDict(dictName, false)
    for attempt = 0, 159 do
        if HasStreamedTextureDictLoaded(dictName) then return true end
        if attempt % 40 == 0 then
            RequestStreamedTextureDict(dictName, false)
        end
        Wait(50)
    end
    return HasStreamedTextureDictLoaded(dictName)
end

function EnsureCirclemapLoaded()
    if HasStreamedTextureDictLoaded("circlemap") then return true end
    Wait(250)
    RequestStreamedTextureDict("circlemap", false)
    return LoadTextureDictWithTimeout("circlemap")
end

function ApplyMinimapMask(textureDictName)
    local cfg = GetMinimapConfig()
    if cfg and cfg.useCustomMask == false then return end

    local maskTexture = "radarmasksm"
    if textureDictName == "circlemap" and CirclemapTextureName then
        maskTexture = CirclemapTextureName
    end

    RemoveReplaceTexture("platform:/textures/graphics", "radarmasksm")
    RemoveReplaceTexture("platform:/textures/graphics", "radarmask1g")
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", textureDictName, maskTexture)
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g",  textureDictName, maskTexture)

    if textureDictName == "circlemap" then
        Trace("Circlemap mask applied (texture: %s)", maskTexture)
    end
end

function LoadStyleTexture(self, requestedStyle, failureMessageFormat)
    local texDict = GetStyleTextureName(requestedStyle)
    local loaded  = false

    if texDict == "circlemap" then
        loaded = EnsureCirclemapLoaded()
    else
        loaded = LoadTextureDictWithTimeout(texDict)
    end

    if not loaded then
        if texDict == "circlemap" then
            Info("Circlemap texture dict 'circlemap' did not load in time; using square. Check stream/circlemap.ytd and that the resource has started.")
        else
            Info(failureMessageFormat, texDict)
        end

        self.currentStyle = "square"
        local fallbackDict = STYLE_TEXTURE_DICT.square
        if not LoadTextureDictWithTimeout(fallbackDict) then
            Info("Failed to load square minimap texture '%s'", fallbackDict)
            return nil
        end
        return fallbackDict
    end

    return texDict
end

function Minimap:LoadMap(styleName)
    self.currentStyle = (styleName == "default") and "square" or (styleName or "square")

    local texDict = LoadStyleTexture(self, self.currentStyle,
        "Failed to load minimap texture '%s', falling back to square")
    if not texDict then return end

    self:applyClipType()
    ApplyMinimapMask(texDict)
    self:applyPosition(true)
    self:applyClipType()
    ApplyNorthIndicatorVisibility()
end

function Minimap:SwitchMap(styleName)
    self.currentStyle = (styleName == "default") and "square" or (styleName or "square")

    local texDict = LoadStyleTexture(self, self.currentStyle,
        "Failed to switch minimap texture '%s', falling back to square")
    if not texDict then return end

    self:applyClipType()
    ApplyMinimapMask(texDict)
    self:applyPosition(true)
    self:applyClipType()
    ApplyNorthIndicatorVisibility()
end

function Minimap:reapply()
    if not self.isInitialized then return false end

    local styleName = self.currentStyle or "square"
    local texDict   = GetStyleTextureName(styleName)
    local loaded    = (texDict == "circlemap") and EnsureCirclemapLoaded()
                                               or LoadTextureDictWithTimeout(texDict)

    if not loaded then
        self.reapplyPending = true
        Info("Minimap reapply: texture dict '%s' not ready, watchdog will retry", texDict)
        return false
    end

    self.reapplyPending = false
    self:applyClipType()
    ApplyMinimapMask(texDict)
    self:applyPosition(true)
    self:applyClipType()
    ApplyNorthIndicatorVisibility()
    return true
end

function Minimap:init()
    Info("starting minimap init")
    self:LoadMap("square")

    RequestStreamedTextureDict("circlemap", false)

    local requestedStyle = _G.BabloHudMapStyle or "square"
    if requestedStyle == "default" then requestedStyle = "square" end
    Trace("loaded startup minimap style: square, requested: %s", requestedStyle)

    ApplyNorthIndicatorVisibility()

    self.scaleform = RequestScaleformMovie("minimap")
    while not HasScaleformMovieLoaded(self.scaleform) do Wait(0) end

    SetRadarBigmapEnabled(false, false)
    DisplayRadar(false)
    self:applyPosition(true)
    self.isInitialized = true

    Trace("starting denna skiten")

    self:enforceHiddenOverlays()

    if IsPauseMenuActive() then
        SetMinimapClipType(0)
    end

    local cfg = GetMinimapConfig()
    if not (cfg and cfg.showLongRangeBlips) then
        SetMinimapComponent(2, false, 0)
    end

    if IsBigmapActive() then
        SetRadarBigmapEnabled(false, false)
    end

    CreateThread(function()
        Wait(300)
        Minimap:applyPosition(true)
    end)

    if requestedStyle ~= "square" then
        CreateThread(function()
            Wait(600)
            Minimap:SwitchMap(requestedStyle)
            if SendMinimapPosition then SendMinimapPosition(true) end
        end)
    end
end

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(100) end
    Wait(500)
    Minimap:init()

    local watchdogCfg     = (Config and Config.MinimapWatchdog) or {}
    local enforceInterval = watchdogCfg.enforceFrameInterval or 300

    if not watchdogCfg.continuous then
        if Bablo and Bablo.Ticker then
            Bablo.Ticker:register(function(frame)
                if frame % enforceInterval == 17 then
                    Minimap:enforceHiddenOverlays()
                end
            end)
        end
    end
end)

CreateThread(function()
    while not (Minimap and Minimap.isInitialized) do Wait(500) end

    local prevW, prevH      = GetActualScreenResolution()
    local prevAspect        = GetAspectRatio(false)
    local prevSafeZone      = GetSafeZoneSize()

    while true do
        Wait(1000)
        local w, h       = GetActualScreenResolution()
        local aspect     = GetAspectRatio(false)
        local safeZone   = GetSafeZoneSize()

        local resChanged  = (w ~= prevW or h ~= prevH)
        local aspectDiff  = math.abs((aspect or 0) - (prevAspect or 0))
        local safeZoneDiff= math.abs((safeZone or 0) - (prevSafeZone or 0))

        if resChanged or aspectDiff > 0.001 or safeZoneDiff > 0.001 then
            prevW, prevH, prevAspect, prevSafeZone = w, h, aspect, safeZone
            Wait(250)
            Minimap:applyPosition(true)
            if SendMinimapPosition then SendMinimapPosition(true) end
            Trace("video mode changed (%dx%d aspect %.3f safezone %.3f) - minimap anchor resent",
                w, h, aspect or 0, safeZone or 0)
        end
    end
end)

CreateThread(function()
    local watchdogCfg = (Config and Config.MinimapWatchdog) or {}
    if watchdogCfg.enabled == false then return end

    local interval   = watchdogCfg.intervalMs or 1000
    local wasInPause = false
    local lastReapplyTime = 0

    while true do
        Wait(interval)
        if Minimap.isInitialized then
            local inPause = IsPauseMenuActive()

            if wasInPause and not inPause then
                Minimap:reapply()
                lastReapplyTime = GetGameTimer()
            end
            wasInPause = inPause

            if GetGameTimer() - lastReapplyTime > 3000 then
                local texDict = GetStyleTextureName(Minimap.currentStyle)
                if Minimap.reapplyPending or not HasStreamedTextureDictLoaded(texDict) then
                    Minimap:reapply()
                    lastReapplyTime = GetGameTimer()
                end
            end

            if _G.BabloHudRecomputeRadar and not IsPauseMenuActive() then
                _G.BabloHudRecomputeRadar()
            end
        end
    end
end)

CreateThread(function()
    local watchdogCfg = (Config and Config.MinimapWatchdog) or {}
    if not watchdogCfg.continuous then return end

    while true do
        Wait(0)
        if Minimap.isInitialized then
            Minimap:applyPosition(false)
        end
    end
end)

CreateThread(function()
    local cfg = GetMinimapConfig()
    if not (cfg and cfg.customMap and cfg.customMap.enabled) then return end

    local customMap = cfg.customMap
    while customMap.enabled do
        SetRadarZoom(customMap.radarZoom or 1100)
        Wait(customMap.refreshRate or 500)
    end
end)

local COMPATIBLE_HUD_RESOURCES = {
    ["qb-hud"]  = true,
    qbx_hud     = true,
    ["qbx-hud"] = true,
}

AddEventHandler("onClientResourceStop", function(resourceName)
    if not COMPATIBLE_HUD_RESOURCES[resourceName] then return end
    CreateThread(function()
        Wait(300)
        Minimap:reapply()
    end)
end)

AddEventHandler("onClientResourceStart", function(resourceName)
    if not COMPATIBLE_HUD_RESOURCES[resourceName] then return end
    CreateThread(function()
        Wait(1500)
        Minimap:reapply()
    end)
end)
