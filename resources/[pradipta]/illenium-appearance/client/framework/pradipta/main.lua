if not Framework.PradiptaCore() then return end

local client = client

local PradiptaCore = exports["pradipta-core"]:GetCoreObject()

local PlayerData = PradiptaCore.Functions.GetPlayerData()

local function getRankInputValues(rankList)
    local rankValues = {}
    for k, v in pairs(rankList) do
        rankValues[#rankValues + 1] = {
            label = v.name,
            value = k
        }
    end
    return rankValues
end

local function setClientParams()
    client.job = PlayerData.job
    client.gang = PlayerData.gang
    client.citizenid = PlayerData.citizenid
end

function Framework.GetPlayerGender()
    if PlayerData.charinfo.gender == 1 then
        return "Female"
    end
    return "Male"
end

function Framework.UpdatePlayerData()
    PlayerData = PradiptaCore.Functions.GetPlayerData()
    setClientParams()
end

function Framework.HasTracker()
    return PradiptaCore.Functions.GetPlayerData().metadata["tracker"]
end

function Framework.CheckPlayerMeta()
    return PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"] or PlayerData.metadata["ishandcuffed"]
end

function Framework.IsPlayerAllowed(citizenid)
    return citizenid == PlayerData.citizenid
end

function Framework.GetRankInputValues(type)
    local grades = PradiptaCore.Shared.Jobs[client.job.name].grades
    if type == "gang" then
        grades = PradiptaCore.Shared.Gangs[client.gang.name].grades
    end
    return getRankInputValues(grades)
end

function Framework.GetJobGrade()
    return client.job.grade.level
end

function Framework.GetGangGrade()
    return client.gang.grade.level
end

RegisterNetEvent("PradiptaCore:Client:OnJobUpdate", function(JobInfo)
    PlayerData.job = JobInfo
    client.job = JobInfo
    ResetBlips()
end)

RegisterNetEvent("PradiptaCore:Client:OnGangUpdate", function(GangInfo)
    PlayerData.gang = GangInfo
    client.gang = GangInfo
    ResetBlips()
end)

RegisterNetEvent("PradiptaCore:Client:SetDuty", function(duty)
    if PlayerData and PlayerData.job then
        PlayerData.job.onduty = duty
        client.job = PlayerData.job
    end
end)

RegisterNetEvent("PradiptaCore:Client:OnPlayerLoaded", function()
    InitAppearance()
end)

RegisterNetEvent("pradipta-clothes:client:CreateFirstCharacter", function()
    PradiptaCore.Functions.GetPlayerData(function(pd)
        PlayerData = pd
        setClientParams()
        InitializeCharacter(Framework.GetGender(true))
    end)
end)

function Framework.CachePed()
    return nil
end

function Framework.RestorePlayerArmour()
    Framework.UpdatePlayerData()
    if PlayerData and PlayerData.metadata then
        Wait(1000)
        SetPedArmour(cache.ped, PlayerData.metadata["armor"])
    end
end
