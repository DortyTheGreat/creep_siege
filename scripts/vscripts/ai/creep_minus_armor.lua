creep_minus_armor_lua = class({})
modifier_creep_minus_armor_lua=class({})
LinkLuaModifier("modifier_creep_minus_armor_lua", "ai/creep_minus_armor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_creep_minus_armor", "ai/creep_minus_armor.lua", LUA_MODIFIER_MOTION_NONE)


function creep_minus_armor_lua:GetIntrinsicModifierName() 
    return "modifier_creep_minus_armor_lua" 
end
function modifier_creep_minus_armor_lua:IsHidden() return true end

function modifier_creep_minus_armor_lua:DeclareFunctions() 
    return 
    {   
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
    } 
end

function modifier_creep_minus_armor_lua:GetModifierProcAttack_Feedback(keys)
	
	if keys.attacker and keys.target and not (keys.attacker:IsNull() or keys.target:IsNull() or keys.attacker:GetTeam() == keys.target:GetTeam()) then
		keys.target:AddNewModifier(keys.attacker, self:GetAbility(), "modifier_creep_minus_armor", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	end
	
end


modifier_creep_minus_armor=class({})
function modifier_creep_minus_armor:IsHidden() return false end
function modifier_creep_minus_armor:IsPurgable() return true end
function modifier_creep_minus_armor:IsDebuff() return true end
function modifier_creep_minus_armor:RemoveOnDeath() return true end

function modifier_creep_minus_armor:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end

function modifier_creep_minus_armor:GetModifierPhysicalArmorBonus(params)
	return self:GetParent():GetPhysicalArmorBaseValue() * self:GetStackCount() * self:GetAbility():GetSpecialValueFor("percent") * -0.01
end

function modifier_creep_minus_armor:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("stacks"))
	end
end


function modifier_creep_minus_armor:OnRefresh()
	if IsServer() then
		self:SetStackCount(self:GetStackCount() + self:GetAbility():GetSpecialValueFor("stacks")) 
	end
end