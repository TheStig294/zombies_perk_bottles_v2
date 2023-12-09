-- The vanilla TTT version of the buy menu passive item for doubletap
-- All it does is give the player the perk bottle SWEP on purchase, which handles all the rest
if TTT2 then return end
if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_doubletap.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_doubletap.png")
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
    hook.Add("TTTBoughtItem", "TTTDoubleTap", function()
        if LocalPlayer():HasEquipmentItem(EQUIP_DOUBLETAP) then
            yCoordinate = getYCoordinate(EQUIP_DOUBLETAP)
        end
    end)

    local material = Material("vgui/ttt/perks/hud_doubletap.png")

    hook.Add("HUDPaint", "TTTDoubleTap", function()
        if LocalPlayer():GetNWBool("DoubleTapActive", false) and LocalPlayer():HasEquipmentItem(EQUIP_DOUBLETAP) then
            surface.SetMaterial(material)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(20, yCoordinate, 64, 64)
        end
    end)
end

EQUIP_DOUBLETAP = (GenerateNewEquipmentID and GenerateNewEquipmentID()) or 2048

local DoubleTap = {
    avoidTTT2 = true,
    id = EQUIP_DOUBLETAP,
    loadout = false,
    type = "item_passive",
    material = "vgui/ttt/ic_doubletap",
    name = "Doubletap Root Beer",
    desc = "Makes you shoot faster with any ordinary gun",
    hud = true
}

if GetConVar("ttt_doubletap_traitor"):GetBool() then
    table.insert(EquipmentItems[ROLE_TRAITOR], DoubleTap)
end

if GetConVar("ttt_doubletap_detective"):GetBool() then
    table.insert(EquipmentItems[ROLE_DETECTIVE], DoubleTap)
end

if SERVER then
    hook.Add("TTTCanOrderEquipment", "TTTDoubleTap", function(ply, id, is_item)
        if tonumber(id) == EQUIP_DOUBLETAP and ply:IsDrinking() then return false end
    end)

    hook.Add("TTTOrderedEquipment", "TTTDoubleTap", function(ply, id, is_item)
        if id == EQUIP_DOUBLETAP then
            ply:Give("ttt_perk_doubletap")

            timer.Simple(0.2, function()
                if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or ply:HasWeapon("ttt_perk_doubletap") then return end
                ply:EmitSound("perks/burp.wav")
                ply:SetNWBool("DoubleTapActive", true)
            end)
        end
    end)
end

if CLIENT then
    hook.Add("TTTBodySearchEquipment", "DoubleTapCorpseIcon", function(search, eq)
        search.eq_doubletap = util.BitSet(eq, EQUIP_DOUBLETAP)
    end)

    hook.Add("TTTBodySearchPopulate", "DoubleTapCorpseIcon", function(search, raw)
        if not raw.eq_doubletap then return end
        local highest = 0

        for _, v in pairs(search) do
            highest = math.max(highest, v.p)
        end

        search.eq_doubletap = {
            img = "vgui/ttt/ic_doubletap",
            text = "They drunk a Double Tap Root Beer.",
            p = highest + 1
        }
    end)
end