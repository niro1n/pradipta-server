local resourcePrefix = ("[%s]"):format(GetCurrentResourceName())

function IsDebugEnabled()
    local config = rawget(_G, "Config")
    if type(config) == "table" and config.DEBUG ~= nil then
        return config.DEBUG == true
    end
    return false
end

function Serialise(value)
    if type(value) == "table" then
        local ok, encoded = pcall(json.encode, value, { indent = true })
        if ok and encoded then return encoded end
    end
    return tostring(value)
end

function FormatMessage(fmt, ...)
    local argCount = select("#", ...)

    if argCount == 0 then
        return Serialise(fmt)
    end

    if type(fmt) ~= "string" then
        local parts = { Serialise(fmt) }
        for i = 1, argCount do
            parts[#parts + 1] = Serialise(select(i, ...))
        end
        return table.concat(parts, " ")
    end

    local args = { ... }
    for i = 1, #args do
        if type(args[i]) == "table" then
            args[i] = Serialise(args[i])
        end
    end

    local ok, result = pcall(string.format, fmt, table.unpack(args))
    if ok then return result end

    local parts = { fmt }
    for i = 1, #args do
        parts[#parts + 1] = Serialise(args[i])
    end
    return table.concat(parts, " ")
end

function EmitLog(level, debugOnly, fmt, ...)
    if debugOnly and not IsDebugEnabled() then return end
    local message = FormatMessage(fmt, ...)
    print(("%s[%s] %s"):format(resourcePrefix, level, message))
end

function Trace(fmt, ...)  EmitLog("TRACE", true,  fmt, ...) end
function Info(fmt, ...)   EmitLog("INFO",  true,  fmt, ...) end
function Warn(fmt, ...)   EmitLog("WARN",  true,  fmt, ...) end
function Error(fmt, ...)  EmitLog("ERROR", true,  fmt, ...) end
function DebugPrint(fmt, ...) Trace(fmt, ...) end

