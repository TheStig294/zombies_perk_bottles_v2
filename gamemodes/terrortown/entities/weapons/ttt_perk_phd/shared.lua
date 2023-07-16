if SERVER then
    AddCSLuaFile("shared.lua")
    resource.AddFile("sound/perks/buy_phd.wav")
    util.AddNetworkString("DrinkingthePHD")
    util.AddNetworkString("PHDBlurHUD")
    resource.AddFile("materials/models/perk_bottle/c_perk_bottle_phd.vmt")
end

SWEP.Author = "Gamefreak"
SWEP.Instructions = "Damn straight."
SWEP.Category = "CoD Zombies"
SWEP.Base = "weapon_tttbase"
SWEP.Kind = 115
SWEP.AmmoEnt = ""
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true
SWEP.AllowDrop = false
SWEP.IsSilent = false
SWEP.NoSights = false
SWEP.AutoSpawnable = false
SWEP.Spawnable = true
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
SWEP.ViewModelFOV = 70
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.PrintName = "PHD Flopper"
SWEP.Slot = 9
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFlip = false
SWEP.DeploySpeed = 4
SWEP.UseHands = true

local function PHDRemoveFallDamage(target, dmginfo)
    if not target:IsPlayer() then return end
    if not target:GetNWBool("PHDActive", false) then return end
    local equip_id = TTT2 and "item_ttt_phd" or EQUIP_PHD
    if not target:HasEquipmentItem(equip_id) then return end

    if dmginfo:IsFallDamage() and target:GetNWBool("StigDisablePHD") == false then
        local explode = ents.Create("env_explosion")
        explode:SetPos(target:GetPos())
        explode:SetOwner(target)
        explode:Spawn()
        explode:SetKeyValue("iMagnitude", "100")
        explode:SetKeyValue("iRadiusOverride", "256")
        explode:Fire("Explode", 0, 0)
        explode:EmitSound("weapon_AWP.Single", 400, 400)

        return true
    elseif dmginfo:IsExplosionDamage() then
        return true
    end
end

hook.Add("EntityTakeDamage", "TTTPHDRemoveFallDamage", PHDRemoveFallDamage)

hook.Add("TTTPrepareRound", "TTTPHDReset", function()
    for k, v in pairs(player.GetAll()) do
        v:SetNWBool("PHDActive", false)
        timer.Remove("TTTPHD" .. v:EntIndex())
    end
end)

hook.Add("DoPlayerDeath", "TTTPHDReset", function(pl)
    local equip_id = TTT2 and "item_ttt_phd" or EQUIP_PHD

    if pl:HasEquipmentItem(equip_id) then
        pl:SetNWBool("PHDActive", false)
    end
end)

function SWEP:OnRemove()
    if CLIENT and IsValid(self:GetOwner()) and self:GetOwner() == LocalPlayer() and self:GetOwner():Alive() then
        RunConsoleCommand("lastinv")
    end

    if CLIENT then
        if self:GetOwner() == LocalPlayer() and LocalPlayer().GetViewModel then
            local vm = LocalPlayer():GetViewModel()
            vm:SetMaterial(oldmat)
            oldmat = nil
        end
    end
end

function SWEP:Holster()
    return false
end

function SWEP:PrimaryAttack()
end

function SWEP:ShouldDropOnDie()
    return false
end

if CLIENT then
    net.Receive("DrinkingthePHD", function()
        surface.PlaySound("perks/buy_phd.wav")
    end)

    net.Receive("PHDBlurHUD", function()
        hook.Add("HUDPaint", "PHDBlurPaint", function()
            if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "ttt_perk_phd" then
                DrawMotionBlur(0.4, 0.8, 0.01)
            end
        end)

        timer.Simple(0.7, function()
            hook.Remove("HUDPaint", "PHDBlurPaint")
        end)
    end)
end

local function SWEPRemoved(wep, owner)
    if IsValid(wep) then
        return false
    else
        if GetRoundState() == ROUND_ACTIVE then
            owner:EmitSound("perks/burp.wav")
            owner:SetNWBool("PHDActive", true)
        end

        return true
    end
end

function SWEP:Initialize()
    timer.Simple(0.1, function()
        local equip_id = TTT2 and "item_ttt_phd" or EQUIP_PHD
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
            owner:ChatPrint("PHD FLOPPER:\nExplosion immunity, instead of taking fall damage, you create an explosion around you!")
            net.Start("DrinkingthePHD")
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
                                    net.Start("PHDBlurHUD")
                                    net.Send(owner)

                                    timer.Create("TTTPHD" .. owner:EntIndex(), 0.8, 1, function()
                                        if IsValid(owner) and owner:IsTerror() then
                                            if SWEPRemoved(self, owner) then return end
                                            self:EmitSound("perks/burp.wav")
                                            owner:SetNWBool("PHDActive", true)
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

        if CLIENT and owner == LocalPlayer() and LocalPlayer().GetViewModel then
            local vm = LocalPlayer():GetViewModel()
            local mat = "models/perk_bottle/c_perk_bottle_phd"
            oldmat = vm:GetMaterial() or ""
            vm:SetMaterial(mat)
        end
    end)

    return self.BaseClass.Initialize(self)
end

function SWEP:GetViewModelPosition(pos, ang)
    local newpos = LocalPlayer():EyePos()
    local newang = LocalPlayer():EyeAngles()
    local up = newang:Up()
    newpos = newpos + LocalPlayer():GetAimVector() * 3 - up * 65

    return newpos, newang
end

function SWEP:OnDrop()
    if IsValid(self) then
        self:Remove()
    end
end