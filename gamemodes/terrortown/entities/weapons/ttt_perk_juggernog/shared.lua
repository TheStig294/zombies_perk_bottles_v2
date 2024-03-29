if SERVER then
    AddCSLuaFile("shared.lua")
    util.AddNetworkString("JuggerBlurHUD")
    util.AddNetworkString("DrinkingtheJuggernog")
    resource.AddFile("sound/perks/buy_jug.wav")
    resource.AddFile("materials/models/perk_bottle/c_perk_bottle_jugg.vmt")
end

SWEP.Author = "Gamefreak"
SWEP.Instructions = "Reach for Juggernog tonight!"
SWEP.Base = "weapon_tttbase"
SWEP.Kind = 115
SWEP.AmmoEnt = ""
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true
SWEP.AllowDrop = false
SWEP.IsSilent = false
SWEP.NoSights = true
SWEP.AutoSpawnable = false
SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.HoldType = "camera"
SWEP.ViewModel = "models/weapons/c_perk_bottle.mdl"
SWEP.WorldModel = ""
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.PrintName = "Juggernog"
SWEP.Slot = 9
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.DeploySpeed = 4
SWEP.UseHands = true

hook.Add("TTTPrepareRound", "TTTJuggernogResettin", function()
    for k, v in pairs(player.GetAll()) do
        v:SetNWBool("JuggernogActive", false)
        timer.Remove("TTTJuggernog" .. v:EntIndex())
    end
end)

hook.Add("DoPlayerDeath", "TTTJuggernogReset", function(pl)
    local equip_id = TTT2 and "item_ttt_juggernog" or EQUIP_JUGGERNOG

    if pl:HasEquipmentItem(equip_id) then
        pl:SetNWBool("JuggernogActive", false)
    end
end)

function SWEP:OnRemove()
    if SERVER then return end
    local client = LocalPlayer()

    if IsValid(self:GetOwner()) and self:GetOwner() == client and self:GetOwner():Alive() then
        RunConsoleCommand("lastinv")
    end

    if self:GetOwner() == client and client.GetViewModel then
        local vm = client:GetViewModel()
        vm:SetMaterial(PERK_BOTTLE_OLD_MATERIAL)
        PERK_BOTTLE_OLD_MATERIAL = nil
    end
end

function SWEP:Holster()
    return false
end

function SWEP:PrimaryAttack()
end

function SWEP:OnDrop()
    if IsValid(self) then
        self:Remove()
    end
end

function SWEP:ShouldDropOnDie()
    return false
end

if CLIENT then
    net.Receive("DrinkingtheJuggernog", function()
        surface.PlaySound("perks/buy_jug.wav")
    end)

    net.Receive("JuggerBlurHUD", function()
        local client = LocalPlayer()

        hook.Add("HUDPaint", "JuggerBlurHUD", function()
            if IsValid(client) and IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "ttt_perk_juggernog" then
                DrawMotionBlur(0.4, 0.8, 0.01)
            end
        end)

        timer.Simple(0.7, function()
            hook.Remove("HUDPaint", "JuggerBlurHUD")
        end)
    end)
end

local healthCvar = GetConVar("ttt_juggernog_extra_health")

local function SWEPRemoved(wep, owner)
    if IsValid(wep) then
        return false
    else
        if GetRoundState() == ROUND_ACTIVE then
            owner:EmitSound("perks/burp.wav")
            owner:SetHealth(math.max(owner:Health() + healthCvar:GetInt(), owner:GetMaxHealth() + healthCvar:GetInt()))
            owner:SetNWBool("JuggernogActive", true)
        end

        return true
    end
end

function SWEP:Initialize()
    timer.Simple(0.1, function()
        local equip_id = TTT2 and "item_ttt_juggernog" or EQUIP_JUGGERNOG
        if not IsValid(self) then return end
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        if not owner:HasEquipmentItem(equip_id) then
            if CLIENT then
                hook.Run("TTTBoughtItem", equip_id, equip_id)
            else
                owner:GiveEquipmentItem(equip_id)
            end
        end

        if SERVER then
            owner:SelectWeapon(self:GetClass())
            owner:ChatPrint("JUGGERNOG:\nFull heal + extra health!")
            net.Start("DrinkingtheJuggernog")
            net.Send(owner)

            timer.Simple(0.5, function()
                if IsValid(owner) and owner:IsTerror() then
                    if SWEPRemoved(self, owner) then return end
                    self:EmitSound("perks/open.wav")
                    owner:ViewPunch(Angle(-1, 1, 0))

                    timer.Simple(0.8, function()
                        if IsValid(owner) and owner:IsTerror() then
                            if SWEPRemoved(self, owner) then return end
                            self:EmitSound("perks/drink.wav")
                            owner:ViewPunch(Angle(-2.5, 0, 0))

                            timer.Simple(1, function()
                                if IsValid(owner) and owner:IsTerror() then
                                    if SWEPRemoved(self, owner) then return end
                                    self:EmitSound("perks/smash.wav")
                                    net.Start("JuggerBlurHUD")
                                    net.Send(owner)

                                    timer.Create("TTTJuggernog" .. owner:EntIndex(), 0.8, 1, function()
                                        if IsValid(owner) and owner:IsTerror() then
                                            if SWEPRemoved(self, owner) then return end
                                            self:EmitSound("perks/burp.wav")
                                            owner:SetHealth(math.max(owner:Health() + healthCvar:GetInt(), owner:GetMaxHealth() + healthCvar:GetInt()))
                                            owner:SetNWBool("JuggernogActive", true)
                                            self:Remove()
                                        end
                                    end)
                                end
                            end)
                        end
                    end)
                end
            end)
        end

        if CLIENT then
            local client = LocalPlayer()

            if owner == client and client.GetViewModel then
                local vm = client:GetViewModel()
                local mat = "models/perk_bottle/c_perk_bottle_jugg"
                PERK_BOTTLE_OLD_MATERIAL = vm:GetMaterial() or ""
                vm:SetMaterial(mat)
            end
        end
    end)

    return self.BaseClass.Initialize(self)
end

function SWEP:GetViewModelPosition(pos, ang)
    local client = LocalPlayer()
    local newpos = client:EyePos()
    local newang = client:EyeAngles()
    local up = newang:Up()
    newpos = newpos + client:GetAimVector() * 3 - up * 65

    return newpos, newang
end