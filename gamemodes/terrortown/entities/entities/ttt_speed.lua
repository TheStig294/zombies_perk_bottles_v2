--if TTT2 then return end
if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_speed.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_speed.png")
end

if CLIENT then
    -- feel for to use this function for your own perk, but please credit Zaratusa
    -- your perk needs a "hud = true" in the table, to work properly
    local defaultY = ScrH() / 2 + 20

    local function getYCoordinate(currentPerkID)
        local amount, i, perk = 0, 1

        while (i < currentPerkID) do
            local role = LocalPlayer():GetRole()

            --he gets it in a special way
            if role == ROLE_INNOCENT then
                if GetEquipmentItem(ROLE_TRAITOR, i) then
                    role = ROLE_TRAITOR -- Temp fix what if a perk is just for Detective
                elseif GetEquipmentItem(ROLE_DETECTIVE, i) then
                    role = ROLE_DETECTIVE
                end
            end

            perk = GetEquipmentItem(role, i)

            if (istable(perk) and perk.hud and LocalPlayer():HasEquipmentItem(perk.id)) then
                amount = amount + 1
            end

            i = i * 2
        end

        return defaultY - 80 * amount
    end

    local yCoordinate = defaultY

    -- best performance, but the has about 0.5 seconds delay to the HasEquipmentItem() function
    hook.Add("TTTBoughtItem", "TTTSpeed", function()
        if (LocalPlayer():HasEquipmentItem(EQUIP_SPEEDCOLA)) then
            yCoordinate = getYCoordinate(EQUIP_SPEEDCOLA)
        end
    end)

    local material = Material("vgui/ttt/perks/hud_speed.png")

    hook.Add("HUDPaint", "TTTSpeed", function()
        if LocalPlayer():GetNWBool("SpeedActive", false) and LocalPlayer():HasEquipmentItem(EQUIP_SPEEDCOLA) then
            surface.SetMaterial(material)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(20, yCoordinate, 64, 64)
        end
    end)

    LANG.AddToLanguage("english", "item_speed_name", "Speed Cola")
    LANG.AddToLanguage("english", "item_speed_desc", "Doubles your reload speed of ordinary guns.")
end

EQUIP_SPEEDCOLA = (GenerateNewEquipmentID and GenerateNewEquipmentID()) or 512

local SpeedCola = {
    avoidTTT2 = true,
    id = EQUIP_SPEEDCOLA,
    loadout = false,
    type = "item_passive",
    material = "vgui/ttt/ic_speed",
    name = "Speed Cola",
    desc = "Doubles your reload speed of ordinary guns.",
    hud = true
}

if GetConVar("ttt_speedcola_detective"):GetBool() and GetConVar("ttt_speedcola_traitor"):GetBool() then
    table.insert(EquipmentItems[ROLE_DETECTIVE], SpeedCola)
    table.insert(EquipmentItems[ROLE_TRAITOR], SpeedCola)
end

if GetConVar("ttt_speedcola_detective"):GetBool() == false and GetConVar("ttt_speedcola_traitor"):GetBool() then
    table.insert(EquipmentItems[ROLE_TRAITOR], SpeedCola)
end

if GetConVar("ttt_speedcola_detective"):GetBool() and GetConVar("ttt_speedcola_traitor"):GetBool() == false then
    table.insert(EquipmentItems[ROLE_DETECTIVE], SpeedCola)
end

if SERVER then
    hook.Add("TTTCanOrderEquipment", "TTTSpeed", function(ply, id, is_item)
        if tonumber(id) == EQUIP_SPEEDCOLA and ply:IsDrinking() then return false end
    end)

    hook.Add("TTTOrderedEquipment", "TTTSpeed", function(ply, id, is_item)
        if id == EQUIP_SPEEDCOLA then
            ply:Give("ttt_perk_speed")
        end
    end)
end

if CLIENT then
    hook.Add("TTTBodySearchEquipment", "SpeedCorpseIcon", function(search, eq)
        search.eq_speed = util.BitSet(eq, EQUIP_SPEEDCOLA)
    end)

    hook.Add("TTTBodySearchPopulate", "SpeedCorpseIcon", function(search, raw)
        if (not raw.eq_speed) then return end
        local highest = 0

        for _, v in pairs(search) do
            highest = math.max(highest, v.p)
        end

        search.eq_speed = {
            img = "vgui/ttt/ic_speed",
            text = "They drunk a Speed Cola.",
            p = highest + 1
        }
    end)
end