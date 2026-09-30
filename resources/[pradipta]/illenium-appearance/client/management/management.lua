if not Config.BossManagedOutfits then return end

Management = {}

Management.ItemIDs = {
    Gang = nil,
    Boss = nil
}

function Management.IsPRADIPTA()
    local resName = "pradipta-management"
    if GetResourceState(resName) ~= "missing" then
        Management.ResourceName = resName
        return true
    end
    return false
end

function Management.IsPRADIPTAX()
    local resName = "pradiptax_management"
    if GetResourceState(resName) ~= "missing" then
        Management.ResourceName = resName
        return true
    end
    return false
end
