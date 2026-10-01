Locale = Locale or {}

local resourceName  = GetCurrentResourceName()
local FALLBACK_CODE = "en-US"

local activeDictionary  = nil  
local fallbackDictionary = nil  
local activeCode        = FALLBACK_CODE

function LoadLocaleFile(localeCode)
    local path = ("locales/%s.json"):format(localeCode)
    local raw  = LoadResourceFile(resourceName, path)

    if not raw or raw == "" then
        return nil, ("file not found: %s"):format(path)
    end

    local ok, decoded = pcall(json.decode, raw)
    if ok and type(decoded) == "table" then
        return decoded
    end

    return nil, ("invalid JSON in %s: %s"):format(path, tostring(decoded))
end

function LookupKey(dictionary, keyPath)
    if type(dictionary) ~= "table" then return nil end

    local node = dictionary
    for segment in keyPath:gmatch("[^%.]+") do
        if type(node) ~= "table" then return nil end
        node = node[segment]
        if node == nil then return nil end
    end

    return node
end

function InterpolateParams(text, params)
    if type(params) ~= "table" then return text end
    return text:gsub("{(.-)}", function(key)
        local val = params[key]
        if val == nil then return "{" .. key .. "}" end
        return tostring(val)
    end)
end

function Locale.load()
    local enDictionary, err = LoadLocaleFile(FALLBACK_CODE)
    if not enDictionary then
        Error("[locale] failed to load en-US fallback: " .. tostring(err))
        activeDictionary  = {}
        fallbackDictionary = {}
        activeCode        = FALLBACK_CODE
        return
    end

    fallbackDictionary = enDictionary

    local requestedCode = (Config and Config.Locale) or FALLBACK_CODE

    if requestedCode == FALLBACK_CODE then
        activeDictionary = enDictionary
        activeCode       = FALLBACK_CODE
        Info("[locale] using en-US")
        return
    end

    local dict, loadErr = LoadLocaleFile(requestedCode)
    if not dict then
        Warn(("[locale] could not load %s (%s); falling back to en-US"):format(
            requestedCode, tostring(loadErr)))
        activeDictionary = enDictionary
        activeCode       = FALLBACK_CODE
        return
    end

    activeDictionary = dict
    activeCode       = requestedCode
    Info("[locale] using " .. requestedCode)
end

function Locale.t(key, params)
    if type(key) ~= "string" or key == "" then
        return tostring(key)
    end

    local value = LookupKey(activeDictionary, key)
        or LookupKey(fallbackDictionary, key)

    if type(value) ~= "string" then return key end

    return InterpolateParams(value, params)
end

function Locale.getCode()       return activeCode end
function Locale.getDictionary() return activeDictionary end
function Locale.getFallback()   return fallbackDictionary end

Locale.load()

