function Spawn(entityKeyValues)
	thisEntity:SetContextThink("AIThink", AIThink, 0)
end

function AIThink()
    local main_base = Entities:FindByName(nil, "way2")
	if main_base ~= nil then
		if thisEntity:IsAlive() then
		if not thisEntity:IsChanneling() and thisEntity:GetCurrentActiveAbility() == nil and not thisEntity:IsCommandRestricted() then
				if not thisEntity:IsDisarmed() then
					local attackOrder = {
						UnitIndex = thisEntity:entindex(), 
						OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
						Position = main_base:GetAbsOrigin()
						}
				ExecuteOrderFromTable(attackOrder)
			else 
				local attackOrder = {
					UnitIndex = thisEntity:entindex(), 
					OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
					Position = thisEntity:GetAbsOrigin()
					}
				ExecuteOrderFromTable(attackOrder)
			end
		end
    end
	end
	return 1
end


