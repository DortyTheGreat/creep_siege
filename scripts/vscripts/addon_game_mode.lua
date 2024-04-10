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

	XP_PER_LEVEL_TABLE = {}
	XP_PER_LEVEL_TABLE[0] = 0
	XP_PER_LEVEL_TABLE[1] = 250
	for i=1,MAX_LEVEL do
		XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1]+ (i ^ 1.6)
	end
	mode = GameRules:GetGameModeEntity()
	mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
	mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	
	GameRules:LockCustomGameSetupTeamAssignment( true )
	
	GameRules:SetPreGameTime(15.0)
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 ) --5 это количество игроков для команд сил света
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 ) --0 это количество игроков для команд сил тьмы (0 - команда вообще не доступна)
	
	GameRules:LockCustomGameSetupTeamAssignment( true )
    GameRules:EnableCustomGameSetupAutoLaunch( true )
	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
	mode:SetFogOfWarDisabled(true)
	mode:SetFreeCourierModeEnabled( true )
	
	
end

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end


local spawns = 0

local power = 0

creep_list = {"npc_dota_creature_gnoll_assassin", "rnd_lion"}

function _G.Spawn_creep(rosh, creepwave)	
	spawns = spawns + 1
	
	power = power + spawns
	
	print("here2")
	spawnpoint1 = Entities:FindByName( nil, "creep_spawner" ):GetAbsOrigin()
	--print("aaa" .. spawnpoint1)
	
	local diff = 400
	
	maxlvl = 1
	
	if power >= 600 then
		maxlvl = 2
	end
	
	selectedlvl = RandomInt(1,maxlvl)
	
	if selectedlvl == 2 then
		power = power - 600
	end
	
	
	local creep = CreateUnitByName( creep_list[selectedlvl]	, spawnpoint1 + RandomVector( RandomFloat( diff, diff )), true, nil, nil, DOTA_TEAM_BADGUYS )
	
	local mult_damage = 1 + spawns * 0.01
	local mult_hp = 1 + spawns * 0.01
	local mult_armor = 1 + spawns * 0.003
	local mult_xp = 1 + spawns * 0.01
	
	
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