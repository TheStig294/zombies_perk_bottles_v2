-- The TTT2 version of the buy menu passive item for staminup
-- All it does is give the player the perk bottle SWEP on purchase, which handles all the rest
if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_staminup.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_staminup.png")
end

ITEM.hud = Material("vgui/ttt/perks/hud_staminup_ttt2.png")

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "Stamin-Up",
    desc = "Increases sprint speed!",
}

ITEM.credits = 1
ITEM.material = "vgui/ttt/ic_staminup"
ITEM.CanBuy = {}

if not ConVarExists("ttt_staminup_traitor") then
    include("autorun/sh_zpb_convars.lua")
end

if GetConVar("ttt_staminup_traitor"):GetBool() then
    table.insert(ITEM.CanBuy, ROLE_TRAITOR)
end

if GetConVar("ttt_staminup_detective"):GetBool() then
    table.insert(ITEM.CanBuy, ROLE_DETECTIVE)
end

if SERVER then
    local speedMultCvar = GetConVar("ttt_staminup_speed_multiplier")

    function ITEM:Bought(ply)
        ply:Give("ttt_perk_staminup")

        timer.Simple(0.2, function()
            if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or ply:HasWeapon("ttt_perk_staminup") then return end
            ply:EmitSound("perks/burp.wav")
            ply:SetRunSpeed(ply:GetRunSpeed() * speedMultCvar:GetFloat())
            ply:SetNWBool("StaminUpActive", true)
        end)
    end

    hook.Add("TTTCanOrderEquipment", "TTTStaminup2", function(ply, id)
        if id == "item_ttt_staminup" and ply:IsDrinking() then return false end
    end)
end