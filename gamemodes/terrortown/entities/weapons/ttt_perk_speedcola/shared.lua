if SERVER then
    AddCSLuaFile("shared.lua")
    util.AddNetworkString("DrinkingtheSpeedCola")
    util.AddNetworkString("SpeedColaBlurHUD")
    resource.AddFile("sound/perks/buy_speed.wav")
    resource.AddFile("models/weapons/c_perk_bottle.mdl")
    resource.AddFile("materials/models/perk_bottle/c_perk_bottle_speedcola.vmt")
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
SWEP.PrintName = "Speed Cola"
SWEP.Slot = 9
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFlip = false
SWEP.DeploySpeed = 4
SWEP.UseHands = true

function SWEP:OnDrop()
    if IsValid(self) then
        self:Remove()
    end
end

local speedMultCvar = GetConVar("ttt_speedcola_speed_multiplier")

function ApplySpeed(wep)
    local speedMult = speedMultCvar:GetFloat()

    if wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL then
        wep:SetDeploySpeed(speedMult)

        if wep.AmmoEnt ~= "item_box_buckshot_ttt" then
            wep.OldReload = wep.Reload

            wep.Reload = function(self, ...)
                if (self:Clip1() == self.Primary.ClipSize or self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0) or self.Reloading then return end
                if not IsFirstTimePredicted() then return end
                timer.Remove("SpeedReload" .. self:EntIndex())
                local ct = CurTime()
                self.Reloading = true
                self:SendWeaponAnim(ACT_VM_RELOAD)
                local sequencetime = self:SequenceDuration()
                diff = sequencetime / speedMult + ct
                self.reloadtimer = diff
                self:SetPlaybackRate(speedMult)
                self:GetOwner():GetViewModel():SetPlaybackRate(speedMult)
                self:SetNextPrimaryFire(diff)
                self:SetNextSecondaryFire(diff)
                self:GetOwner():SetFOV(0, 0.2)

                if IsValid(self) and self.SetIronsights then
                    self:SetIronsights(false)
                end
            end

            wep.OldThink = wep.Think

            wep.Think = function(self, ...)
                if IsValid(self) and self.Reloading and IsFirstTimePredicted() and self.reloadtimer and self.reloadtimer <= CurTime() and IsValid(self:GetOwner()) and self:GetOwner():IsTerror() and IsValid(self:GetOwner():GetActiveWeapon()) and self:GetOwner():GetActiveWeapon() == self then
                    local maxclip = self.Primary.ClipSize
                    local curclip = self:Clip1()
                    local amounttoreplace = math.min(maxclip - curclip, self:GetOwner():GetAmmoCount(self.Primary.Ammo))
                    self:SetClip1(curclip + amounttoreplace)
                    self:GetOwner():RemoveAmmo(amounttoreplace, self.Primary.Ammo)
                    self.Reloading = false
                end
            end

            wep.OldOnDrop = wep.OnDrop

            wep.OnDrop = function(self, ...)
                if IsValid(self) then
                    self:SetDeploySpeed(1)
                    self.Reloading = false
                    self.Reload = self.OldReload
                    self.Think = self.OldThink
                    self.OnDrop = self.OldOnDrop
                    self.OldReload = nil
                    self.OldOnDrop = nil
                    self.OldThink = nil
                end
            end
        elseif wep.AmmoEnt == "item_box_buckshot_ttt" then
            wep.OldStartReload = wep.StartReload
            wep.OldPerformReload = wep.PerformReload
            wep.OldFinishReload = wep.FinishReload

            if wep.SetReloading then
                wep.StartReload = function(self, ...)
                    if self:GetReloading() then return false end
                    self:SetIronsights(false)
                    if not IsFirstTimePredicted() then return false end
                    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
                    local ply = self:GetOwner()
                    if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then return false end
                    if self:Clip1() >= self.Primary.ClipSize then return false end
                    self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
                    self:SetPlaybackRate(speedMult)
                    self:GetOwner():GetViewModel():SetPlaybackRate(speedMult)
                    self.reloadtimer = CurTime() + self:SequenceDuration() / speedMult
                    self:SetReloading(true)

                    return true
                end

                wep.PerformReload = function(self, ...)
                    local ply = self:GetOwner()
                    -- prevent normal shooting in between reloads
                    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
                    if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
                    if self:Clip1() >= self.Primary.ClipSize then return end
                    self:GetOwner():RemoveAmmo(1, self.Primary.Ammo, false)
                    self:SetClip1(self:Clip1() + 1)
                    self:SendWeaponAnim(ACT_VM_RELOAD)
                    self:SetPlaybackRate(speedMult)
                    self:GetOwner():GetViewModel():SetPlaybackRate(speedMult)
                    self:SetReloadTimer(CurTime() + self:SequenceDuration() / speedMult)
                end

                wep.FinishReload = function(self, ...)
                    self:SetReloading(false)
                    self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
                    self:SetPlaybackRate(speedMult)
                    self:GetOwner():GetViewModel():SetPlaybackRate(speedMult)
                    self:SetReloadTimer(CurTime() + self:SequenceDuration() / speedMult)
                end

                wep.OldOnDrop = wep.OnDrop

                wep.OnDrop = function(self, ...)
                    self:SetReloading(false)
                    self:SetDeploySpeed(1)
                    self.StartReload = self.OldStartReload
                    self.PerformReload = self.OldPerformReload
                    self.FinishReload = self.OldFinishReload
                    self.OnDrop = self.OldOnDrop
                    self.OldStartReload = nil
                    self.OldPerformReload = nil
                    self.OldFinishReload = nil
                    self.OldOnDrop = nil
                end
            else
                wep.StartReload = function(self, ...)
                    if self.dt.reloading then return false end
                    self:SetIronsights(false)
                    if not IsFirstTimePredicted() then return false end
                    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
                    local ply = self:GetOwner()
                    if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then return false end
                    if self:Clip1() >= self.Primary.ClipSize then return false end
                    self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
                    self:SetPlaybackRate(speedMult)
                    self:GetOwner():GetViewModel():SetPlaybackRate(speedMult)
                    self.reloadtimer = CurTime() + self:SequenceDuration() / speedMult
                    self.dt.reloading = true

                    return true
                end

                wep.PerformReload = function(self, ...)
                    local ply = self:GetOwner()
                    -- prevent normal shooting in between reloads
                    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
                    if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
                    if self:Clip1() >= self.Primary.ClipSize then return end
                    self:GetOwner():RemoveAmmo(1, self.Primary.Ammo, false)
                    self:SetClip1(self:Clip1() + 1)
                    self:SendWeaponAnim(ACT_VM_RELOAD)
                    self:SetPlaybackRate(speedMult)
                    self:GetOwner():GetViewModel():SetPlaybackRate(speedMult)
                    self.reloadtimer = CurTime() + self:SequenceDuration() / speedMult
                end

                wep.FinishReload = function(self, ...)
                    self.dt.reloading = false
                    self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
                    self:SetPlaybackRate(speedMult)
                    self:GetOwner():GetViewModel():SetPlaybackRate(speedMult)
                    self.reloadtimer = CurTime() + self:SequenceDuration() / speedMult
                end

                wep.OldOnDrop = wep.OnDrop

                wep.OnDrop = function(self, ...)
                    self.Reloading = false
                    self:SetDeploySpeed(1)
                    self.StartReload = self.OldStartReload
                    self.PerformReload = self.OldPerformReload
                    self.FinishReload = self.OldFinishReload
                    self.OnDrop = self.OldOnDrop
                    self.OldStartReload = nil
                    self.OldPerformReload = nil
                    self.OldFinishReload = nil
                    self.OldOnDrop = nil
                end
            end
        end
    end
end

function RemoveSpeed(wep)
    if wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL then
        wep:SetDeploySpeed(1)
        wep.Reloading = false

        if wep.AmmoEnt ~= "item_box_buckshot_ttt" then
            wep.Reload = wep.OldReload
            wep.Think = wep.OldThink
            wep.OnDrop = wep.OldOnDrop
            wep.OldReload = nil
            wep.OldOnDrop = nil
            wep.OldThink = nil
        elseif wep.AmmoEnt == "item_box_buckshot_ttt" then
            wep.StartReload = wep.OldStartReload
            wep.PerformReload = wep.OldPerformReload
            wep.FinishReload = wep.OldFinishReload
            wep.OnDrop = wep.OldOnDrop
            wep.OldStartReload = nil
            wep.OldPerformReload = nil
            wep.OldFinishReload = nil
            wep.OldOnDrop = nil
        end
    end
end

hook.Add("PlayerSwitchWeapon", "TTTSpeedEnable", function(ply, old, new)
    local equip_id = TTT2 and "item_ttt_speedcola" or EQUIP_SPEEDCOLA

    if ply:GetNWBool("SpeedColaActive", false) and ply:HasEquipmentItem(equip_id) then
        ApplySpeed(new)
        RemoveSpeed(old)
    end
end)

hook.Add("TTTPrepareRound", "TTTSpeedReset", function()
    for k, v in pairs(player.GetAll()) do
        v:SetNWBool("SpeedColaActive", false)
        timer.Remove("TTTSpeed" .. v:EntIndex())
    end
end)

hook.Add("DoPlayerDeath", "TTTSpeedReset", function(ply)
    local equip_id = TTT2 and "item_ttt_speedcola" or EQUIP_SPEEDCOLA

    if ply:HasEquipmentItem(equip_id) then
        ply:SetNWBool("SpeedColaActive", false)
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
    net.Receive("DrinkingtheSpeedCola", function()
        surface.PlaySound("perks/buy_speed.wav")
    end)

    net.Receive("SpeedColaBlurHUD", function()
        local client = LocalPlayer()

        hook.Add("HUDPaint", "SpeedColaBlurHUD", function()
            if IsValid(client) and IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "ttt_perk_speedcola" then
                DrawMotionBlur(0.4, 0.8, 0.01)
            end
        end)

        timer.Simple(0.7, function()
            hook.Remove("HUDPaint", "SpeedColaBlurHUD")
        end)
    end)
end

local function SWEPRemoved(wep, owner)
    if IsValid(wep) then
        return false
    else
        if GetRoundState() == ROUND_ACTIVE then
            owner:EmitSound("perks/burp.wav")
            owner:SetNWBool("SpeedColaActive", true)
        end

        return true
    end
end

function SWEP:Initialize()
    timer.Simple(0.1, function()
        local equip_id = TTT2 and "item_ttt_speedcola" or EQUIP_SPEEDCOLA
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
            owner:ChatPrint("SPEEDCOLA:\nReload speed increased!")
            net.Start("DrinkingtheSpeedCola")
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
                                    net.Start("SpeedColaBlurHUD")
                                    net.Send(owner)

                                    timer.Create("TTTSpeedCola" .. owner:EntIndex(), 0.8, 1, function()
                                        if IsValid(owner) and owner:IsTerror() then
                                            if SWEPRemoved(self, owner) then return end
                                            self:EmitSound("perks/burp.wav")
                                            owner:SetNWBool("SpeedColaActive", true)
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
                local mat = "models/perk_bottle/c_perk_bottle_speedcola"
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