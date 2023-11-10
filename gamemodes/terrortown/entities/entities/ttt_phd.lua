-- The vanilla TTT version of the buy menu passive item for phd flopper
-- All it does is give the player the perk bottle SWEP on purchase, which handles all the rest
if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_phd.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_phd.png")
end

if CLIENT then
    -- feel for to use this function for your own perk, but please credit Zaratusa
    -- your perk needs a "hud = true" in the table, to work properly
    local defaultY = ScrH() / 2 + 20

    local function getYCoordinate(currentPerkID)
        local amount, i, perk = 0, 1

        while i < currentPerkID do
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

            if istable(perk) and perk.hud and LocalPlayer():HasEquipmentItem(perk.id) then
                amount = amount + 1
            end

            i = i * 2
        end

        return defaultY - 80 * amount
    end

    local yCoordinate = defaultY

    -- best performance, but the has about 0.5 seconds delay to the HasEquipmentItem() function
    hook.Add("TTTBoughtItem", "TTTPHD", function()
        if LocalPlayer():HasEquipmentItem(EQUIP_PHD) then
            yCoordinate = getYCoordinate(EQUIP_PHD)
        end
    end)

    local material = Material("vgui/ttt/perks/hud_phd.png")

    hook.Add("HUDPaint", "TTTPHD", function()
        if LocalPlayer():GetNWBool("PHDActive", false) and LocalPlayer():HasEquipmentItem(EQUIP_PHD) then
            surface.SetMaterial(material)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(20, yCoordinate, 64, 64)
        end
    end)
end

EQUIP_PHD = (GenerateNewEquipmentID and GenerateNewEquipmentID()) or 128

local PHD = {
    avoidTTT2 = true,
    id = EQUIP_PHD,
    loadout = false,
    type = "item_passive",
    material = "vgui/ttt/ic_phd",
    name = "PHD Flopper",
    desc = "Instead of taking fall damage, cause a high-damage explosion where you land. \n\nGrants immunity to explosions",
    hud = true
}

if GetConVar("ttt_phd_traitor"):GetBool() then
    table.insert(EquipmentItems[ROLE_TRAITOR], PHD)
end

if GetConVar("ttt_phd_detective"):GetBool() then
    table.insert(EquipmentItems[ROLE_DETECTIVE], PHD)
end

if SERVER then
    hook.Add("TTTCanOrderEquipment", "TTTPHD", function(ply, id, is_item)
        if tonumber(id) == EQUIP_PHD and ply:IsDrinking() then return false end
    end)

    hook.Add("TTTOrderedEquipment", "TTTPHD", function(ply, id, is_item)
        if id == EQUIP_PHD then
            ply:Give("ttt_perk_phd")

            timer.Simple(0.2, function()
                if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or ply:HasWeapon("ttt_perk_phd") then return end
                ply:EmitSound("perks/burp.wav")
                ply:SetNWBool("PHDActive", true)
            end)
        end
    end)
end

if CLIENT then
    hook.Add("TTTBodySearchEquipment", "PHDCorpseIcon", function(search, eq)
        search.eq_phd = util.BitSet(eq, EQUIP_PHD)
    end)

    hook.Add("TTTBodySearchPopulate", "PHDCorpseIcon", function(search, raw)
        if not raw.eq_phd then return end
        local highest = 0

        for _, v in pairs(search) do
            highest = math.max(highest, v.p)
        end

        search.eq_phd = {
            img = "vgui/ttt/ic_phd",
            text = "They drunk a PHD Flopper.",
            p = highest + 1
        }
    end)
end