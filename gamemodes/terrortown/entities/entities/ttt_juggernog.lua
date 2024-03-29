-- The vanilla TTT version of the buy menu passive item for juggernog
-- All it does is give the player the perk bottle SWEP on purchase, which handles all the rest
if TTT2 then return end

if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/ic_juggernog.vmt")
    resource.AddFile("materials/vgui/ttt/perks/hud_juggernog.png")
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
    hook.Add("TTTBoughtItem", "TTTJuggernog", function()
        if LocalPlayer():HasEquipmentItem(EQUIP_JUGGERNOG) then
            yCoordinate = getYCoordinate(EQUIP_JUGGERNOG)
        end
    end)

    local material = Material("vgui/ttt/perks/hud_juggernog.png")

    hook.Add("HUDPaint", "TTTJuggernog", function()
        if LocalPlayer():GetNWBool("JuggernogActive", false) and LocalPlayer():HasEquipmentItem(EQUIP_JUGGERNOG) then
            surface.SetMaterial(material)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(20, yCoordinate, 64, 64)
        end
    end)
end

EQUIP_JUGGERNOG = (GenerateNewEquipmentID and GenerateNewEquipmentID()) or 64

local Juggernog = {
    avoidTTT2 = true,
    id = EQUIP_JUGGERNOG,
    loadout = false,
    type = "item_passive",
    material = "vgui/ttt/ic_juggernog",
    name = "Juggernog",
    desc = "Fully heals and increases your health",
    hud = true
}

if GetConVar("ttt_juggernog_traitor"):GetBool() then
    table.insert(EquipmentItems[ROLE_TRAITOR], Juggernog)
end

if GetConVar("ttt_juggernog_detective"):GetBool() then
    table.insert(EquipmentItems[ROLE_DETECTIVE], Juggernog)
end

if SERVER then
    hook.Add("TTTCanOrderEquipment", "TTTJuggernog", function(ply, id, is_item)
        if tonumber(id) == EQUIP_JUGGERNOG and ply:IsDrinking() then return false end
    end)

    local healthCvar = GetConVar("ttt_juggernog_extra_health")

    hook.Add("TTTOrderedEquipment", "TTTJuggernog", function(ply, id, is_item)
        if id == EQUIP_JUGGERNOG then
            ply:Give("ttt_perk_juggernog")

            timer.Simple(0.2, function()
                if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or ply:HasWeapon("ttt_perk_juggernog") then return end
                ply:EmitSound("perks/burp.wav")
                ply:SetHealth(math.max(ply:Health() + healthCvar:GetInt(), ply:GetMaxHealth() + healthCvar:GetInt()))
                ply:SetNWBool("JuggernogActive", true)
            end)
        end
    end)
end

if CLIENT then
    hook.Add("TTTBodySearchEquipment", "JuggernogCorpseIcon", function(search, eq)
        if type(eq) == "table" then
            search.eq_juggernog = table.HasValue(eq, EQUIP_JUGGERNOG)
        else
            search.eq_juggernog = util.BitSet(eq, EQUIP_JUGGERNOG)
        end
    end)

    hook.Add("TTTBodySearchPopulate", "JuggernogCorpseIcon", function(search, raw)
        if not raw.eq_juggernog then return end
        local highest = 0

        for _, v in pairs(search) do
            highest = math.max(highest, v.p)
        end

        search.eq_juggernog = {
            img = "vgui/ttt/ic_juggernog",
            text = "They drunk a Juggernog.",
            p = highest + 1
        }
    end)
end