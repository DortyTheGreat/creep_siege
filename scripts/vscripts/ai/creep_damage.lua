creep_damage_lua = class({})
modifier_damage_creep_lua=class({})
LinkLuaModifier("modifier_damage_creep_lua", "ai/creep_damage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damage_creep", "ai/creep_damage.lua", LUA_MODIFIER_MOTION_NONE)


function creep_damage_lua:GetIntrinsicModifierName() 
    return "modifier_damage_creep_lua" 
end
function modifier_damage_creep_lua:IsHidden() return true end
function modifier_damage_creep_lua:DeclareFunctions() 
    return 
    {   
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
    } 
end

function modifier_damage_creep_lua:GetModifierProcAttack_Feedback(keys)

	if keys.attacker and keys.target and not (keys.attacker:IsNull() or keys.target:IsNull() or keys.attacker:GetTeam() == keys.target:GetTeam()) then
		keys.target:AddNewModifier(keys.attacker, self:GetAbility(), "modifier_damage_creep", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	end
end

modifier_damage_creep=class({})
function modifier_damage_creep:IsHidden() return false end
function modifier_damage_creep:IsPurgable() return true end
function modifier_damage_creep:IsDebuff() return true end
function modifier_damage_creep:RemoveOnDeath() return true end

function modifier_damage_creep:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end

function modifier_damage_creep:GetModifierIncomingDamage_Percentage() return self:GetStackCount() end

function modifier_damage_creep:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("creep_damage"))
	end
end

function modifier_damage_creep:OnRefresh()
	if IsServer() then
		self:SetStackCount(self:GetStackCount() + self:GetAbility():GetSpecialValueFor("creep_damage")) 
	end
end