if SERVER then
    AddCSLuaFile("shared.lua")
    util.AddNetworkString("DrinkingtheStaminup")
    util.AddNetworkString("StaminBlurHUD")
    resource.AddFile("sound/perks/buy_stam.wav")
    resource.AddFile("materials/models/perk_bottle/c_perk_bottle_stamin.vmt")
end

SWEP.Author = "Gamefreak"
SWEP.Instructions = "Oh yeah, drink it baby."
SWEP.Category = "CoD Zombies"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Base = "weapon_tttbase"
SWEP.Kind = EQUIP_PERKBOTTLE
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
SWEP.PrintName = "Stamin-Up"
SWEP.Slot = 9
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFlip = false
SWEP.DeploySpeed = 4
SWEP.UseHands = true

hook.Add("TTTPrepareRound", "TTTStaminupReset", function()
    for k, v in pairs(player.GetAll()) do
        v:SetNWBool("StaminUpActive", false)
        timer.Remove("TTTStaminup" .. v:EntIndex())
    end
end)

hook.Add("DoPlayerDeath", "TTTStaminupReset", function(ply)
    local equip_id = TTT2 and "item_ttt_staminup" or EQUIP_STAMINUP

    if ply:HasEquipmentItem(equip_id) then
        ply:SetNWBool("StaminUpActive", false)
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

function SWEP:OnDrop()
    if IsValid(self) then
        self:Remove()
    end
end

if CLIENT then
    net.Receive("DrinkingtheStaminup", function()
        surface.PlaySound("perks/buy_stam.wav")
    end)

    net.Receive("StaminBlurHUD", function()
        hook.Add("HUDPaint", "StaminBlurHUD", function()
            if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "ttt_perk_staminup" then
                DrawMotionBlur(0.4, 0.8, 0.01)
            end
        end)

        timer.Simple(0.7, function()
            hook.Remove("HUDPaint", "StaminBlurHUD")
        end)
    end)
end

hook.Add("TTTPlayerSpeedModifier", "StaminUpSpeed", function(ply)
    local equip_id = TTT2 and "item_ttt_staminup" or EQUIP_STAMINUP
    if ply:HasEquipmentItem(equip_id) and ply:GetNWBool("StaminUpActive", false) then return 1.5 end
end)

function SWEP:Initialize()
    timer.Simple(0.1, function()
        local equip_id = TTT2 and "item_ttt_staminup" or EQUIP_STAMINUP
        if (not IsValid(self)) or (not IsValid(self:GetOwner())) then return end

        if not self:GetOwner():HasEquipmentItem(equip_id) then
            if CLIENT then
                hook.Run("TTTBoughtItem", equip_id, equip_id)
            else
                self:GetOwner():GiveEquipmentItem(equip_id)
            end
        end

        if SERVER then
            self:GetOwner():SelectWeapon(self:GetClass())
            net.Start("DrinkingtheStaminup")
            net.Send(self:GetOwner())

            timer.Simple(0.5, function()
                if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():IsTerror() then
                    self:EmitSound("perks/open.wav")
                    self:GetOwner():ChatPrint("PERK BOTTLE EFFECT:\nYou can run really fast!")
                    self:GetOwner():ViewPunch(Angle(-1, 1, 0))

                    timer.Simple(0.8, function()
                        if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():IsTerror() then
                            self:EmitSound("perks/drink.wav")
                            self:GetOwner():ViewPunch(Angle(-2.5, 0, 0))

                            timer.Simple(1, function()
                                if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():IsTerror() then
                                    self:EmitSound("perks/smash.wav")
                                    net.Start("StaminBlurHUD")
                                    net.Send(self:GetOwner())

                                    timer.Create("TTTStaminUp" .. self:GetOwner():EntIndex(), 0.8, 1, function()
                                        if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():IsTerror() then
                                            self:EmitSound("perks/burp.wav")
                                            self:GetOwner():SetRunSpeed(400)
                                            self:GetOwner():SetNWBool("StaminUpActive", true)
                                            self:GetOwner():SetNWBool("StaminUpFix", true)
                                            self:Remove()
                                        end
                                    end)
                                end
                            end)
                        end
                    end)
                end
            end)

            hook.Add("PlayerSpawn", "StaminupResetFix", function(ply, transition)
                if ply:GetNWBool("StaminUpFix") then
                    ply:SetRunSpeed(ply:GetWalkSpeed())
                    ply:SetNWBool("StaminUpFix", false)
                end
            end)

            hook.Add("PostPlayerDeath", "StaminupResetFix", function(ply)
                if ply:GetNWBool("StaminUpFix") then
                    ply:SetRunSpeed(ply:GetWalkSpeed())
                    ply:SetNWBool("StaminUpFix", false)
                end
            end)
        end

        if CLIENT then
            if self:GetOwner() == LocalPlayer() and LocalPlayer().GetViewModel then
                local vm = LocalPlayer():GetViewModel()
                local mat = "models/perk_bottle/c_perk_bottle_stamin" --perk_materials[self:GetPerk()]
                oldmat = vm:GetMaterial() or ""
                vm:SetMaterial(mat)
            end
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