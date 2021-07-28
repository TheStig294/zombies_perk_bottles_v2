if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_juggernog.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_juggernog.png")
end

ITEM.hud = Material("vgui/ttt/perks/hud_juggernog_ttt2.png")

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "Juggernog",
    desc = "Juggernog Perk.\nAutomatically drinks perk to get \nthe maximum health avaible!",
}

ITEM.credits = 1
ITEM.material = "vgui/ttt/ic_juggernog"

if GetConVar("ttt_juggernog_detective"):GetBool() and GetConVar("ttt_juggernog_traitor"):GetBool() then
    ITEM.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}
end

if GetConVar("ttt_juggernog_detective"):GetBool() == false and GetConVar("ttt_juggernog_traitor"):GetBool() then
    ITEM.CanBuy = {ROLE_TRAITOR}
end

if GetConVar("ttt_juggernog_detective"):GetBool() and GetConVar("ttt_juggernog_traitor"):GetBool() == false then
    ITEM.CanBuy = {ROLE_DETECTIVE}
end

if SERVER then
    function ITEM:Bought(ply)
        ply:Give("ttt_perk_juggernog")
    end

    hook.Add("TTTCanOrderEquipment", "TTTJuggernog2", function(ply, id)
        if id == "item_ttt_juggernog" and ply:IsDrinking() then return false end
    end)
end