function IsResourceActive(resourceName)
    local state = GetResourceState(resourceName)
    return state == "started" or state == "starting"
end

function DetectFramework()
    if Config.Framework and Config.Framework ~= "auto" then return end

    if IsResourceActive("pradipta-core") then
        Config.Framework = "qbcore"
    elseif IsResourceActive("qbx_core") then
        Config.Framework = "qbox"
    elseif IsResourceActive("qb-core") then
        Config.Framework = "qbcore"
    elseif IsResourceActive("es_extended") then
        Config.Framework = "esx"
    else
        Config.Framework = "qbcore"  
    end
end

DetectFramework()
