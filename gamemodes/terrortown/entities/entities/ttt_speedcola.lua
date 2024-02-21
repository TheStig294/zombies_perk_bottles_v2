-- The vanilla TTT version of the buy menu passive item for speed cola
-- All it does is give the player the perk bottle SWEP on purchase, which handles all the rest
if TTT2 then return end

if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_speedcola.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_speedcola.png")
end

if CLIENT then
    -- feel for to use this function for your own perk, but please credit Zaratusa
    -- your perk needs a "hud = true" in the table, to work properly
    local defaultY = ScrH() / 2 + 20
    local client

    local function getYCoordinate(currentPerkID)
        local amount, i, perk = 0, 1
        client = client or LocalPlayer()

        while i < currentPerkID do
            local role = client:GetRole()
            perk = GetEquipmentItem(role, i)

            if not perk then
                perk = GetEquipmentItem(ROLE_TRAITOR, i)

                if not perk then
                    perk = GetEquipmentItem(ROLE_DETECTIVE, i)
                end
            end

            if istable(perk) and perk.hud and client:HasEquipmentItem(perk.id) then
                amount = amount + 1
            end

            if CRVersion and CRVersion("2.1.2") then
                i = i + 1
            else
                i = i * 2
            end
        end

        return defaultY - 80 * amount
    end

    local yCoordinate = defaultY

    -- best performance, but the has about 0.5 seconds delay to the HasEquipmentItem() function
    hook.Add("TTTBoughtItem", "TTTSpeedCola", function()
        if LocalPlayer():HasEquipmentItem(EQUIP_SPEEDCOLA) then
            yCoordinate = getYCoordinate(EQUIP_SPEEDCOLA)
        end
    end)

    local material = Material("vgui/ttt/perks/hud_speedcola.png")

    hook.Add("HUDPaint", "TTTSpeedCola", function()
        if LocalPlayer():GetNWBool("SpeedColaActive", false) and LocalPlayer():HasEquipmentItem(EQUIP_SPEEDCOLA) then
            surface.SetMaterial(material)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(20, yCoordinate, 64, 64)
        end
    end)
end

EQUIP_SPEEDCOLA = (GenerateNewEquipmentID and GenerateNewEquipmentID()) or 512

local SpeedCola = {
    avoidTTT2 = true,
    id = EQUIP_SPEEDCOLA,
    loadout = false,
    type = "item_passive",
    material = "vgui/ttt/ic_speedcola",
    name = "Speed Cola",
    desc = "Increases reload speed of ordinary guns",
    hud = true
}

if GetConVar("ttt_speedcola_traitor"):GetBool() then
    table.insert(EquipmentItems[ROLE_TRAITOR], SpeedCola)
end

if GetConVar("ttt_speedcola_detective"):GetBool() then
    table.insert(EquipmentItems[ROLE_DETECTIVE], SpeedCola)
end

if SERVER then
    hook.Add("TTTCanOrderEquipment", "TTTSpeedCola", function(ply, id, is_item)
        if tonumber(id) == EQUIP_SPEEDCOLA and ply:IsDrinking() then return false end
    end)

    hook.Add("TTTOrderedEquipment", "TTTSpeedCola", function(ply, id, is_item)
        if id == EQUIP_SPEEDCOLA then
            ply:Give("ttt_perk_speedcola")

            timer.Simple(0.2, function()
                if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or ply:HasWeapon("ttt_perk_speedcola") then return end
                ply:EmitSound("perks/burp.wav")
                ply:SetNWBool("SpeedColaActive", true)
            end)
        end
    end)
end

if CLIENT then
    hook.Add("TTTBodySearchEquipment", "SpeedColaCorpseIcon", function(search, eq)
        if type(eq) == "table" then
            search.eq_speedcola = table.HasValue(eq, EQUIP_SPEEDCOLA)
        else
            search.eq_speedcola = util.BitSet(eq, EQUIP_SPEEDCOLA)
        end
    end)

    hook.Add("TTTBodySearchPopulate", "SpeedColaCorpseIcon", function(search, raw)
        if not raw.eq_speedcola then return end
        local highest = 0

        for _, v in pairs(search) do
            highest = math.max(highest, v.p)
        end

        search.eq_speedcola = {
            img = "vgui/ttt/ic_speedcola",
            text = "They drunk a Speed Cola.",
            p = highest + 1
        }
    end)
end