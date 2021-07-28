if SERVER then
    AddCSLuaFile()
    resource.AddFile("sound/perks/open.wav")
    resource.AddFile("sound/perks/smash.wav")
    resource.AddFile("sound/perks/drink.wav")
    resource.AddFile("sound/perks/burp.wav")
    util.AddNetworkString("ZPBResetMaterials")
end

local Perks = {"PHD", "StaminUp", "Juggernog", "Speed", "DoubleTap"}

local plymeta = FindMetaTable("Player")
EQUIP_PERKBOTTLE = (GenerateNewEquipmentID and GenerateNewEquipmentID()) or 256

function plymeta:IsDrinking()
    for _, perk in pairs(Perks) do
        perk = "ttt_perk_" .. string.lower(perk)

        if IsValid(self:GetActiveWeapon()) then
            if perk == self:GetActiveWeapon():GetClass() then return true end
        else
            return false
        end
    end

    return false
end

hook.Add("TTTPrepareRound", "ZPBResetMaterial", function()
    if SERVER then
        net.Start("ZPBResetMaterials")
        net.Broadcast()
    end
end)

hook.Add("PlayerSpawn", "ZPBResetMaterial", function(ply)
    if IsValid(ply) then
        net.Start("ZPBResetMaterials")
        net.Send(ply)
    end
end)

hook.Add("TTTOrderedEquipment", "PerksStripCig", function(ply, equipment, is_item)
    if ply:HasWeapon("weapon_cigarro") and is_item and (equipment == EQUIP_DOUBLETAP or equipment == EQUIP_JUGGERNOG or equipment == EQUIP_PHD or equipment == EQUIP_SPEEDCOLA or equipment == EQUIP_STAMINUP) then
        ply:StripWeapon("weapon_cigarro")

        timer.Simple(4, function()
            ply:Give("weapon_cigarro")
        end)
    end
end)

net.Receive("ZPBResetMaterials", function()
    if CLIENT and IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetViewModel()) then
        local vm = LocalPlayer():GetViewModel()

        if oldmat then
            vm:SetMaterial(oldmat)
            oldmat = nil
        else
            vm:SetMaterial("")
        end
    end
end)

CreateConVar("ttt_doubletap_detective", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether a detective can buy Doubletap", 0, 1)

CreateConVar("ttt_doubletap_traitor", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether a traitor can buy Doubletap", 0, 1)

CreateConVar("ttt_juggernog_detective", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether a detective can buy Juggernog", 0, 1)

CreateConVar("ttt_juggernog_traitor", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether a traitor can buy Juggernog", 0, 1)

CreateConVar("ttt_phd_detective", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether a detective can buy PHD Flopper", 0, 1)

CreateConVar("ttt_phd_traitor", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether a traitor can buy PHD Flopper", 0, 1)

CreateConVar("ttt_speedcola_detective", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether a detective can buy Speed Cola", 0, 1)

CreateConVar("ttt_speedcola_traitor", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether a traitor can buy Speed Cola", 0, 1)

CreateConVar("ttt_staminup_detective", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether a detective can buy Staminup", 0, 1)

CreateConVar("ttt_staminup_traitor", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether a traitor can buy Staminup", 0, 1)