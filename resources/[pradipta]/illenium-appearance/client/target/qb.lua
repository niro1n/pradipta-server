if not Config.UseTarget then return end

if not Target.IsPRADIPTA() then return end

function Target.RemoveZone(zone)
    exports["pradipta-target"]:RemoveZone(zone)
end

function Target.AddTargetEntity(entity, parameters)
    exports["pradipta-target"]:AddTargetEntity(entity, parameters)
end

function Target.AddBoxZone(name, coords, size, parameters)
    exports["pradipta-target"]:AddBoxZone(name, coords, size.x, size.y, {
        name = name,
        debugPoly = Config.Debug,
        minZ = coords.z - 2,
        maxZ = coords.z + 2,
        heading = coords.w
    }, parameters)
end

function Target.AddPolyZone(name, points, parameters)
    exports["pradipta-target"]:AddPolyZone(name, points, {
        name = name,
        debugPoly = Config.Debug,
        minZ = points[1].z - 2,
        maxZ = points[1].z + 2
    }, parameters)
end

function Target.IsTargetStarted()
    return GetResourceState("pradipta-target") == "started"
end
