-- The TTT2 version of the buy menu passive item for phd flopper
-- All it does is give the player the perk bottle SWEP on purchase, which handles all the rest
if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_phd.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_phd.png")
end

ITEM.hud = Material("vgui/ttt/perks/hud_phd_ttt2.png")

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "PHD Flopper",
    desc = "Instead of taking fall damage, cause a high-damage explosion where you land. \n\nGrants immunity to explosions",
}

ITEM.credits = 1
ITEM.material = "vgui/ttt/ic_phd"
ITEM.CanBuy = {}

if GetConVar("ttt_phd_traitor"):GetBool() then
    table.insert(ITEM.CanBuy, ROLE_TRAITOR)
end

if GetConVar("ttt_phd_detective"):GetBool() then
    table.insert(ITEM.CanBuy, ROLE_DETECTIVE)
end

if SERVER then
    function ITEM:Bought(ply)
        ply:Give("ttt_perk_phd")

        timer.Simple(0.2, function()
            if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or ply:HasWeapon("ttt_perk_phd") then return end
            ply:EmitSound("perks/burp.wav")
            ply:SetNWBool("PHDActive", true)
        end)
    end

    hook.Add("TTTCanOrderEquipment", "TTTPHD2", function(ply, id)
        if id == "item_ttt_phd" and ply:IsDrinking() then return false end
    end)
end