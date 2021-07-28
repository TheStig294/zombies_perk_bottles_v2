if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_staminup.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_staminup.png")
end

ITEM.hud = Material("vgui/ttt/perks/hud_staminup_ttt2.png")

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "Stamin-Up",
    desc = "Stamin-Up Perk.\nAutomatically drinks perk to greatly increase\nwalk speed!",
}

ITEM.credits = 1
ITEM.material = "vgui/ttt/ic_staminup"

if GetConVar("ttt_staminup_detective"):GetBool() and GetConVar("ttt_staminup_traitor"):GetBool() then
    ITEM.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}
end

if GetConVar("ttt_staminup_detective"):GetBool() == false and GetConVar("ttt_staminup_traitor"):GetBool() then
    ITEM.CanBuy = {ROLE_TRAITOR}
end

if GetConVar("ttt_staminup_detective"):GetBool() and GetConVar("ttt_staminup_traitor"):GetBool() == false then
    ITEM.CanBuy = {ROLE_DETECTIVE}
end

if SERVER then
    function ITEM:Bought(ply)
        ply:Give("ttt_perk_staminup")
    end

    hook.Add("TTTCanOrderEquipment", "TTTStaminup2", function(ply, id)
        if id == "item_ttt_staminup" and ply:IsDrinking() then return false end
    end)
end