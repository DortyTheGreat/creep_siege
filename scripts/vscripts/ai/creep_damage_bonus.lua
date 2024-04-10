creep_damage_bonus_lua = class({})
modifier_creep_damage_bonus_lua=class({})
LinkLuaModifier("modifier_creep_damage_bonus_lua", "ai/creep_damage_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_creep_damage_bonus", "ai/creep_damage_bonus.lua", LUA_MODIFIER_MOTION_NONE)


function creep_damage_bonus_lua:GetIntrinsicModifierName() 
    return "modifier_creep_damage_bonus_lua" 
end
function modifier_creep_damage_bonus_lua:IsHidden() return true end

function modifier_creep_damage_bonus_lua:DeclareFunctions() 
    return 
    {   
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
    } 
end

function modifier_creep_damage_bonus_lua:GetModifierProcAttack_Feedback(keys)
	
	if keys.attacker and keys.target and not (keys.attacker:IsNull() or keys.target:IsNull() or keys.attacker:GetTeam() == keys.target:GetTeam()) then
		keys.attacker:AddNewModifier(keys.attacker, self:GetAbility(), "modifier_creep_damage_bonus", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	end
	
end


modifier_creep_damage_bonus = class({})
function modifier_creep_damage_bonus:IsHidden() return false end
function modifier_creep_damage_bonus:IsDebuff() return false end
function modifier_creep_damage_bonus:RemoveOnDeath() return true end

function modifier_creep_damage_bonus:DeclareFunctions() 
    return 
    {   
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    } 
end


function modifier_creep_damage_bonus:GetModifierDamageOutgoing_Percentage( params )
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("creep_damage_bonus")
end

function modifier_creep_damage_bonus:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("creep_damage_bonus"))
	end
end


function modifier_creep_damage_bonus:OnRefresh()
	if IsServer() then
		self:SetStackCount(self:GetStackCount() + self:GetAbility():GetSpecialValueFor("creep_damage_bonus")) 
	end
end
