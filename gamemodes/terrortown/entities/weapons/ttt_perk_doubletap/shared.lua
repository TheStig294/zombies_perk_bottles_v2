-- The doubletap perk bottle itself,
-- given by items/item_ttt_doubletap if TTT2 is installed,
-- or by entities/ttt_doubletap.lua otherwise
if SERVER then
    AddCSLuaFile("shared.lua")
    util.AddNetworkString("DoubleTapBlurHUD")
    util.AddNetworkString("DoubletapApply")
    util.AddNetworkString("DrinkingtheDoubleTap")
    resource.AddFile("sound/perks/buy_doubletap.wav")
    resource.AddFile("models/weapons/c_perk_bottle.mdl")
    resource.AddFile("materials/models/perk_bottle/c_perk_bottle_doubletap.vmt")
end

SWEP.Author = "Gamefreak"
SWEP.Instructions = "Oh yeah, drink it baby."
SWEP.Category = "CoD Zombies"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Base = "weapon_tttbase"
SWEP.Kind = 115
SWEP.AmmoEnt = ""
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true
SWEP.AllowDrop = false
SWEP.IsSilent = false
SWEP.NoSights = false
SWEP.AutoSpawnable = false
SWEP.ViewModel = "models/weapons/c_perk_bottle.mdl"
SWEP.WorldModel = ""
SWEP.HoldType = "camera"
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
SWEP.PrintName = "DoubleTap Root Beer"
SWEP.Slot = 9
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFlip = false
SWEP.DeploySpeed = 4
SWEP.UseHands = true
local firerateCvar = GetConVar("ttt_doubletap_firerate_multiplier")

function ApplyDoubleTap(wep)
    if (wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL) and isnumber(wep.Primary.Delay) then
        wep.OldDelay = wep.Primary.Delay
        wep.OldOnDrop = wep.OnDrop

        wep.OnDrop = function(self, ...)
            if IsValid(self) then
                self.Primary.Delay = self.OldDelay
                self.OnDrop = self.OldOnDrop
            end
        end

        -- This is where the magic happens...
        wep.Primary.Delay = math.Round(wep.Primary.Delay / firerateCvar:GetFloat(), 3)
        net.Start("DoubletapApply")
        net.WriteBool(true)
        net.WriteEntity(wep)
        net.WriteFloat(wep.Primary.Delay)
        net.WriteFloat(wep.OldDelay)
        net.Send(wep.Owner)
    end
end

function RemoveDoubleTap(wep)
    if (wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL) and isnumber(wep.Primary.Delay) then
        wep.Primary.Delay = wep.OldDelay or wep.Primary.Delay
        wep.OnDrop = wep.OldOnDrop or wep.OnDrop
        net.Start("DoubletapApply")
        net.WriteBool(false)
        net.WriteEntity(wep)
        net.WriteFloat(wep.Primary.Delay)
        net.Send(wep.Owner)
    end
end

function SWEP:OnDrop()
    if IsValid(self) then
        self:Remove()
    end
end

hook.Add("PlayerSwitchWeapon", "TTTDoubleTapEnable", function(ply, old, new)
    local equip_id = TTT2 and "item_ttt_doubletap" or EQUIP_DOUBLETAP

    if SERVER and (ply:GetNWBool("DoubleTapActive", false) and ply:HasEquipmentItem(equip_id)) and (new.Kind == WEAPON_HEAVY or new.Kind == WEAPON_PISTOL) then
        ApplyDoubleTap(new)
    end

    if SERVER and (ply:GetNWBool("DoubleTapActive", false) and ply:HasEquipmentItem(equip_id)) and (old.Kind == WEAPON_HEAVY or old.Kind == WEAPON_PISTOL) then
        RemoveDoubleTap(old)
    end
end)

hook.Add("TTTPrepareRound", "TTTDoubleTapReset", function()
    for k, v in pairs(player.GetAll()) do
        v:SetNWBool("DoubleTapActive", false)
        timer.Remove("TTTDoubleTap" .. v:EntIndex())
    end
end)

hook.Add("DoPlayerDeath", "TTTDoubleTapReset", function(ply)
    local equip_id = TTT2 and "item_ttt_doubletap" or EQUIP_DOUBLETAP

    if ply:HasEquipmentItem(equip_id) then
        ply:SetNWBool("DoubleTapActive", false)
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

function SWEP:ShouldDropOnDie()
    return false
end

if CLIENT then
    net.Receive("DrinkingtheDoubleTap", function()
        surface.PlaySound("perks/buy_doubletap.wav")
    end)

    net.Receive("DoubleTapBlurHUD", function()
        local client = LocalPlayer()

        hook.Add("HUDPaint", "DoubleTapBlurHUD", function()
            if IsValid(client) and IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "ttt_perk_doubletap" then
                DrawMotionBlur(0.4, 0.8, 0.01)
            end
        end)

        timer.Simple(0.7, function()
            hook.Remove("HUDPaint", "DoubleTapBlurHUD")
        end)
    end)
end

local function SWEPRemoved(wep, owner)
    if IsValid(wep) then
        return false
    else
        if GetRoundState() == ROUND_ACTIVE then
            owner:EmitSound("perks/burp.wav")
            owner:SetNWBool("DoubleTapActive", true)
        end

        return true
    end
end

function SWEP:Initialize()
    timer.Simple(0.1, function()
        local equip_id = TTT2 and "item_ttt_doubletap" or EQUIP_DOUBLETAP
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
            owner:ChatPrint("DOUBLETAP:\nShooting speed increased!")
            net.Start("DrinkingtheDoubleTap")
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
                                    net.Start("DoubleTapBlurHUD")
                                    net.Send(owner)

                                    timer.Create("TTTDoubleTap" .. owner:EntIndex(), 0.8, 1, function()
                                        if IsValid(owner) and owner:IsTerror() then
                                            if SWEPRemoved(self, owner) then return end
                                            self:EmitSound("perks/burp.wav")
                                            owner:SetNWBool("DoubleTapActive", true)
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
                local mat = "models/perk_bottle/c_perk_bottle_doubletap"
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

if CLIENT then
    net.Receive("DoubletapApply", function()
        local apply = net.ReadBool()
        local wep = net.ReadEntity()
        if not IsValid(wep) then return end
        wep.Primary.Delay = net.ReadFloat()

        if apply then
            wep.OldOnDrop = wep.OnDrop

            wep.OnDrop = function(self, ...)
                if IsValid(self) then
                    self.Primary.Delay = net.ReadFloat()
                    self.OnDrop = self.OldOnDrop
                end
            end
        else
            wep.OnDrop = wep.OldOnDrop
        end
    end)
end