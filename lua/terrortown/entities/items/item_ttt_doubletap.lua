-- The TTT2 version of the buy menu passive item for doubletap
-- All it does is give the player the perk bottle SWEP on purchase, which handles all the rest
if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_doubletap.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_doubletap.png")
end

ITEM.hud = Material("vgui/ttt/perks/hud_doubletap_ttt2.png")

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "Doubletap Root Beer",
    desc = "Makes you shoot faster with any ordinary gun",
}

ITEM.credits = 1
ITEM.material = "vgui/ttt/ic_doubletap"
ITEM.CanBuy = {}

if GetConVar("ttt_doubletap_traitor"):GetBool() then
    table.insert(ITEM.CanBuy, ROLE_TRAITOR)
end

if GetConVar("ttt_doubletap_detective"):GetBool() then
    table.insert(ITEM.CanBuy, ROLE_DETECTIVE)
end

if SERVER then
    function ITEM:Bought(ply)
        ply:Give("ttt_perk_doubletap")

        timer.Simple(0.2, function()
            if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or ply:HasWeapon("ttt_perk_doubletap") then return end
            ply:EmitSound("perks/burp.wav")
            ply:SetNWBool("DoubleTapActive", true)
        end)
    end

    hook.Add("TTTCanOrderEquipment", "TTTDoubleTap2", function(ply, id)
        if id == "item_ttt_doubletap" and ply:IsDrinking() then return false end
    end)
end