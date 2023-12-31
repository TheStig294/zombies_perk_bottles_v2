-- The TTT2 version of the buy menu passive item for speed cola
-- All it does is give the player the perk bottle SWEP on purchase, which handles all the rest
if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_speedcola.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_speedcola.png")
end

ITEM.hud = Material("vgui/ttt/perks/hud_speedcola_ttt2.png")

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "Speed Cola",
    desc = "Increases reload speed of ordinary guns",
}

ITEM.credits = 1
ITEM.material = "vgui/ttt/ic_speedcola"
ITEM.CanBuy = {}

if not ConVarExists("ttt_speedcola_traitor") then
    include("autorun/sh_zpb_convars.lua")
end

if GetConVar("ttt_speedcola_traitor"):GetBool() then
    table.insert(ITEM.CanBuy, ROLE_TRAITOR)
end

if GetConVar("ttt_speedcola_detective"):GetBool() then
    table.insert(ITEM.CanBuy, ROLE_DETECTIVE)
end

if SERVER then
    function ITEM:Bought(ply)
        ply:Give("ttt_perk_speedcola")

        timer.Simple(0.2, function()
            if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or ply:HasWeapon("ttt_perk_speedcola") then return end
            ply:EmitSound("perks/burp.wav")
            ply:SetNWBool("SpeedColaActive", true)
        end)
    end

    hook.Add("TTTCanOrderEquipment", "TTTSpeed2", function(ply, id)
        if id == "item_ttt_speedcola" and ply:IsDrinking() then return false end
    end)
end