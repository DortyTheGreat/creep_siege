require( 'timers' )


-- Generated from template

-- GameRules Variables
ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = true             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = false       -- Should we let people select the same hero as each other



HERO_SELECTION_TIME = 60.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 10.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

MAX_LEVEL = 100


creep_spawn_interval = 5

function ini()
	GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
	GameRules:GetGameModeEntity():SetMaximumAttackSpeed( 600 ) 
	GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
	GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
	GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
	GameRules:SetPreGameTime( PRE_GAME_TIME)
	GameRules:SetPostGameTime( POST_GAME_TIME )
	GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
	GameRules:SetUseCustomHeroXPValues ( true )
	GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
	
	GameRules:SetStrategyTime(15)
	GameRules:SetShowcaseTime(1)
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)
	
	XP_PER_LEVEL_TABLE = {}
	XP_PER_LEVEL_TABLE[0] = 0
	XP_PER_LEVEL_TABLE[1] = 250
	for i=1,MAX_LEVEL do
		XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1]+ (i ^ 1.6)
	end
	mode = GameRules:GetGameModeEntity()
	
	--mode:SetUseCustomHeroLevels ( true )
	--mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
	--mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	
	GameRules:LockCustomGameSetupTeamAssignment( true )
	
	GameRules:SetPreGameTime(15.0)
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 6 ) --5 это количество игроков для команд сил света
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 ) --0 это количество игроков для команд сил тьмы (0 - команда вообще не доступна)
	
	GameRules:LockCustomGameSetupTeamAssignment( true )
    GameRules:EnableCustomGameSetupAutoLaunch( true )
	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
	
	mode:SetFogOfWarDisabled(true)
	mode:SetFreeCourierModeEnabled( true )
	mode:SetFixedRespawnTime( 10 ) 
	
	mode:SetAllowNeutralItemDrops( true )
	mode:SetNeutralStashEnabled ( true )
	
end

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end

function CAddonTemplateGameMode:CaptureGameMode()
	if mode == nil then
		-- Set GameMode parameters
		mode = GameRules:GetGameModeEntity()


		--mode:SetUseCustomHeroLevels ( true )
		--mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
		--mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
		mode:SetFixedRespawnTime( 10 ) 
		--mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
		mode:SetTowerBackdoorProtectionEnabled( false )
		mode:SetAllowNeutralItemDrops( true )
		mode:SetNeutralStashEnabled ( true )

		self:OnFirstPlayerLoaded()
		
	end
end


local spawns = 0

local power = 0

creep_list = {"npc_dota_creature_gnoll_assassin", "rnd_lion"}

creep_list = {
	-- name                           cost chance
	{"creep_ursa", 0, 1},
	{"creep_sniper", 500, 0.05},
	{"creep_lion", 1200, 0.4},
	{"creep_chaos", 1400, 0.3},
	{"creep_antimage", 1500, 0.1},
	{"creep_bara", 2000, 0.05},
	{"creep_zeus", 2500, 0.1},
	
	{"creep_razor", 5000, 0.03},
	{"creep_krot", 5000, 0.03},
	{"creep_bristle", 5000, 0.03},
	
	{"creep_shaman", 10000, 0.01},
	{"creep_legion", 13000, 0.01},
	--{"creep_tide",   15000, 0.01},
}

function _G.Spawn_creep(rosh, creepwave)	
	spawns = spawns + 1
	
	power = power + spawns
	
	spawnpoint1 = Entities:FindByName( nil, "creep_spawner" ):GetAbsOrigin()
	
	
	local diff = 400
	
	listing = {}
	
	for i = 1, #creep_list do
		if math.random() <=  creep_list[i][3] and creep_list[i][2] <= power then
			table.insert(listing, creep_list[i][1])
		end
	end
	
	selected_creep = listing[RandomInt(1,#listing)]
	
	for i = 1, #creep_list do
		if selected_creep ==  creep_list[i][1] then
			power = power - creep_list[i][2]
		end
	end
	
	print("creep selected" .. selected_creep)
	local creep = CreateUnitByName( selected_creep	, spawnpoint1 + RandomVector( RandomFloat( diff, diff )), true, nil, nil, DOTA_TEAM_BADGUYS )
	
	local mult_damage = 1 + spawns * 0.01
	local mult_hp = 1 + spawns * 0.01
	local mult_armor = 1 + spawns * 0.001
	local mult_xp = 1 + spawns * 0.004
	
	
	creep:SetBaseDamageMin(creep:GetBaseDamageMin() * mult_damage)
	creep:SetBaseDamageMax(creep:GetBaseDamageMax() * mult_damage)
	
	creep:SetPhysicalArmorBaseValue(creep:GetPhysicalArmorBaseValue() * mult_armor)
	--creep:SetBaseMagicalResistanceValue(50)
	
	creep:SetMaxHealth(creep:GetMaxHealth() * mult_hp)
	creep:SetBaseMaxHealth(creep:GetBaseMaxHealth() * mult_hp)
	creep:SetHealth(creep:GetBaseMaxHealth())	
	
	creep:SetDeathXP(creep:GetDeathXP() * mult_xp)
	

	
	
	
end

function CAddonTemplateGameMode:OnGameInProgress()

	Spawn_creep(1)
	print("here3")
	
	-- spwn = Entities:FindByName( nil, "creep_spawner" ):GetAbsOrigin()
	
	--CreateUnitByName( "barrack2", spwn + Vector(3000,1000), true, nil, nil, DOTA_TEAM_BADGUYS )
	
	Timers:CreateTimer(creep_spawn_interval, function()
			Spawn_creep()
		return creep_spawn_interval

	end)

end





function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
	ini()
end

function CAddonTemplateGameMode:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	
	ListenToGameEvent('entity_killed', Dynamic_Wrap(CAddonTemplateGameMode, 'OnEntityKilled'), self)
	
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function CAddonTemplateGameMode:OnEntityKilled( keys )
	
	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- The Killing entity
	local killerEntity = nil

	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end

	-- Put code here to handle when an entity gets killed
	local killedUnit = EntIndexToHScript(keys.entindex_killed)
	local killer = EntIndexToHScript(keys.entindex_attacker)
	
	if killedUnit:GetUnitName() == "basetower" then
		--SentStuffPostMatch("LOSE")
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		--request:savewave() 
		return
	end
	
	if killedUnit:GetUnitName() == "enemytower2" then
		--SentStuffPostMatch("LOSE")
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		--request:savewave() 
		return
	end
	
	if string.starts(killedUnit:GetUnitName(), "creep") then
		local players = 0
		for index=0 ,10 do
			if PlayerResource:HasSelectedHero(index) then
				players = players + 1
			end
		end
		
		for index=0 ,10 do
			if PlayerResource:HasSelectedHero(index) then
				local player = PlayerResource:GetPlayer(index)
				local hero = PlayerResource:GetSelectedHeroEntity(index)
				
				
				---
				
				--hero:AddNewModifier (hero, nil, "modifier_wave_damage_bonus", {duration = -1})
				--hero:AddNewModifier (hero, nil, "modifier_wave_speed_bonus", {duration = -1})
				--hero:AddNewModifier (hero, nil, "modifier_gold_extra_storage", {duration = -1})
				
				local hero = PlayerResource:GetSelectedHeroEntity(index)
				local currentGold = PlayerResource:GetGold(index)
				hero:SpendGold( -1 * killedUnit:GetGoldBounty() / players / 2 , 0) -- 0 is an idk reason -_- (Dorty 10.04.2024)
				
				
				
				
				--print("5 done ")
			end
		end
	end
end

-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
		Spawn_creep()
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end