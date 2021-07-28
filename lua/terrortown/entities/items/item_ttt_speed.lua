if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_speed.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_speed.png")
end

ITEM.hud = Material("vgui/ttt/perks/hud_speed_ttt2.png")

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "Speed Cola",
    desc = "Speed Cola Perk.\nAutomatically drinks perk to get \ndouble the reload speed.",
}

ITEM.credits = 1
ITEM.material = "vgui/ttt/ic_speed"

if GetConVar("ttt_speedcola_detective"):GetBool() and GetConVar("ttt_speedcola_traitor"):GetBool() then
    ITEM.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}
end

if GetConVar("ttt_speedcola_detective"):GetBool() == false and GetConVar("ttt_speedcola_traitor"):GetBool() then
    ITEM.CanBuy = {ROLE_TRAITOR}
end

if GetConVar("ttt_speedcola_detective"):GetBool() and GetConVar("ttt_speedcola_traitor"):GetBool() == false then
    ITEM.CanBuy = {ROLE_DETECTIVE}
end

if SERVER then
    function ITEM:Bought(ply)
        ply:Give("ttt_perk_speed")
    end

    hook.Add("TTTCanOrderEquipment", "TTTSpeed2", function(ply, id)
        if id == "item_ttt_speed" and ply:IsDrinking() then return false end
    end)
end