if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_doubletap.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_doubletap.png")
end

ITEM.hud = Material("vgui/ttt/perks/hud_doubletap_ttt2.png")

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "DoubleTap Root Beer",
    desc = "DoubleTap Root Beer Perk.\nAutomatically drinks perk to get \na 50% higher fire rate.",
}

ITEM.credits = 1
ITEM.material = "vgui/ttt/ic_doubletap"

if GetConVar("ttt_doubletap_detective"):GetBool() and GetConVar("ttt_doubletap_traitor"):GetBool() then
    ITEM.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}
end

if GetConVar("ttt_doubletap_detective"):GetBool() == false and GetConVar("ttt_doubletap_traitor"):GetBool() then
    ITEM.CanBuy = {ROLE_TRAITOR}
end

if GetConVar("ttt_doubletap_detective"):GetBool() and GetConVar("ttt_doubletap_traitor"):GetBool() == false then
    ITEM.CanBuy = {ROLE_DETECTIVE}
end

if SERVER then
    function ITEM:Bought(ply)
        ply:Give("ttt_perk_doubletap")
    end

    hook.Add("TTTCanOrderEquipment", "TTTDoubleTap2", function(ply, id)
        if id == "item_ttt_doubletap" and ply:IsDrinking() then return false end
    end)
end