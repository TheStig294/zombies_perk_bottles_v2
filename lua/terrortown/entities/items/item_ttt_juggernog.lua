-- The TTT2 version of the buy menu passive item for juggernog
-- All it does is give the player the perk bottle SWEP on purchase, which handles all the rest
if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_juggernog.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_juggernog.png")
end

ITEM.hud = Material("vgui/ttt/perks/hud_juggernog_ttt2.png")

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "Juggernog",
    desc = "Fully heals and increases your health",
}

ITEM.credits = 1
ITEM.material = "vgui/ttt/ic_juggernog"
ITEM.CanBuy = {}

if not ConVarExists("ttt_juggernog_traitor") then
    include("autorun/sh_zpb_convars.lua")
end

if GetConVar("ttt_juggernog_traitor"):GetBool() then
    table.insert(ITEM.CanBuy, ROLE_TRAITOR)
end

if GetConVar("ttt_juggernog_detective"):GetBool() then
    table.insert(ITEM.CanBuy, ROLE_DETECTIVE)
end

if SERVER then
    local healthCvar = GetConVar("ttt_juggernog_extra_health")

    function ITEM:Bought(ply)
        ply:Give("ttt_perk_juggernog")

        timer.Simple(0.2, function()
            if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or ply:HasWeapon("ttt_perk_juggernog") then return end
            ply:EmitSound("perks/burp.wav")
            ply:SetHealth(math.max(ply:Health() + healthCvar:GetInt(), ply:GetMaxHealth() + healthCvar:GetInt()))
            ply:SetNWBool("JuggernogActive", true)
        end)
    end

    hook.Add("TTTCanOrderEquipment", "TTTJuggernog2", function(ply, id)
        if id == "item_ttt_juggernog" and ply:IsDrinking() then return false end
    end)
end