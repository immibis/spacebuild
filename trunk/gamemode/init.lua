/*------------------------------------------------
	SPACEBUILD 3 GAMEMODE
	
		Based on Spacebuild 2
		Made by the Spacebuild Dev Team

------------------------------------------------*/
require("sb_space")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_sun.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SB_DEBUG = true

local NextUpdateTime

SB_InSpace = 0
SetGlobalInt("InSpace", 0)
TrueSun = {}
SunAngle = nil

GM.Override_PlayerHeatDestroy = 0
GM.Override_EntityHeatDestroy = 0
GM.Override_PressureDamage = 0
GM.PlayerOverride = 0

CreateConVar( "SB_NoClip", "1" )
CreateConVar( "SB_PlanetNoClipOnly", "1" )
CreateConVar( "SB_AdminSpaceNoclip", "1" )
CreateConVar( "SB_SuperAdminSpaceNoclip", "1" )
CreateConVar( "SB_StaticEnvironment", "0" )
local VolCheckIterations = CreateConVar( "SB_VolumeCheckIterations", "11",{ FCVAR_CHEAT, FCVAR_ARCHIVE } )

//Think + Environments
local Environments = {}
local numenv = 0

function GM:GetPlanets()
	local tmp = {}
	if table.Count(Environments) > 0 then
		for k, v in pairs(Environments) do
			if v.IsPlanet and v:IsPlanet() then
				table.insert(tmp, v)
			end
		end
	end
	return tmp
end

function GM:PhysgunPickup(ply , ent)
	local notallowed =  { "base_sb_planet1", "base_sb_planet2", "base_sb_star1", "base_sb_star2", "nature_dev_tree", "sb_environment"}
	if table.HasValue(notallowed, ent:GetClass()) then
		return false
	end
	return self.BaseClass:PhysgunPickup(ply, ent)
end

function GM:GetStars()
	local tmp = {}
	if table.Count(Environments) > 0 then
		for k, v in pairs(Environments) do
			if v.IsStar and v:IsStar() then
				table.insert(tmp, v)
			end
		end
	end
	return tmp
end

function GM:GetArtificialEnvironments() //not 100 sure this is correct
	local tmp = {}
	if table.Count(Environments) > 0 then
		for k, v in pairs(Environments) do
			if v.IsStar and not v:IsStar() and v.IsPlanet and not v:IsPlanet() then
				table.insert(tmp, v)
			end
		end
	end
	return tmp
end

function GM:OnEnvironmentChanged(ent)
	if not ent.oldsbtmpenvironment or ent.oldsbtmpenvironment != ent.environment then
		local tmp = ent.oldsbtmpenvironment
		ent.oldsbtmpenvironment = ent.environment
		if tmp then
			gamemode.Call( "OnEnvironmentChanged", ent, tmp, ent.environment )
		end
	end
end

function GM:AddOverride_PlayerHeatDestroy()
	self.Override_PlayerHeatDestroy = self.Override_PlayerHeatDestroy + 1
end

function GM:RemoveOverride_PlayerHeatDestroy()
	self.Override_PlayerHeatDestroy = self.Override_PlayerHeatDestroy - 1
end

function GM:AddOverride_EntityHeatDestroy()
	self.Override_EntityHeatDestroy = self.Override_EntityHeatDestroy + 1
end

function GM:RemoveOverride_EntityHeatDestroy()
	self.Override_EntityHeatDestroy = self.Override_EntityHeatDestroy - 1
end

function GM:AddOverride_PressureDamage()
	self.Override_PressureDamage = Override_PressureDamage + 1
end

function GM:RemoveOverride_PressureDamage()
	self.Override_PressureDamage = self.Override_PressureDamage - 1
end

function GM:AddPlayerOverride()
	self.PlayerOverride = self.PlayerOverride + 1
end

function GM:RemovePlayerOverride()
	self.PlayerOverride = self.PlayerOverride - 1
end

/*---------------------------------------------------------
Name: gamemode:PlayerSpawn( )
Desc: Called when a player spawns
GmodFixerupper
Remove once Sandbox/derive system is fixed!
---------------------------------------------------------*/
function GM:PlayerSpawn( pl )
// If the player doesn't have a team in a TeamBased game
// then spawn him as a spectator
if ( self.TeamBased && ( pl:Team() == TEAM_SPECTATOR || pl:Team() == TEAM_UNASSIGNED ) ) then
self:PlayerSpawnAsSpectator( pl )
return
end
// Stop observer mode
pl:UnSpectate()
// Call item loadout function
hook.Call( "PlayerLoadout", GAMEMODE, pl )
// Set player model
hook.Call( "PlayerSetModel", GAMEMODE, pl )
// Set the player's speed
GAMEMODE:SetPlayerSpeed( pl, 250, 500 )
end

local sb_spawned_entities = {}

local function OnEntitySpawn(ent)
	Msg("Spawn: "..tostring(ent).."\n")
	if not table.HasValue(sb_spawned_entities, ent) then
		table.insert( sb_spawned_entities, ent)
	end
end

//Gmod Spawn Hooks

local function SpawnedSent( ply , ent )
	//Msg("Sent Spawned\n")
	OnEntitySpawn(ent)
end

local function SpawnedVehicle( ply , ent)
	//Msg("Vehicle Spawned\n")
	OnEntitySpawn(ent)
end	

local function SpawnedEnt( ply , model , ent )
	//Msg("Prop Spawned\n")
	OnEntitySpawn(ent)
end

local function PlayerSpawn(ply)
	//Msg("Prop Spawned\n")
	OnEntitySpawn(ply)
end

local function NPCSpawn(ply, ent)
	//Msg("Prop Spawned\n")
	OnEntitySpawn(ent)
end
hook.Add( "PlayerSpawnedNPC", "SB NPC Spawn", NPCSpawn )
hook.Add( "PlayerInitialSpawn", "SB PLAYER Spawn", PlayerSpawn )
hook.Add( "PlayerSpawnedProp", "SB PROP Spawn", SpawnedEnt )
hook.Add( "PlayerSpawnedSENT", "SB SENT Spawn", SpawnedSent )
hook.Add( "PlayerSpawnedVehicle", "SB VEHICLE Spawn", SpawnedVehicle )

local oldcreate = ents.Create
ents.Create = function(class)
	local ent = oldcreate(class)
	--Msg(tostring(ent))
	OnEntitySpawn(ent)
	return ent;
end

function GM:Think()
	if (SB_InSpace == 0) then return end
	if CurTime() < (NextUpdateTime or 0) then return end
	self:PerformEnvironmentCheck()
	--[[local ents = ents.FindByClass( "entityflame" )
	for _, ent in ipairs( ents ) do
		ent:Remove()
	end]]
	NextUpdateTime = CurTime() + 1
end

function GM:PerformEnvironmentCheck()
	--local starttime =SysTime();
	--[[for _, class in ipairs( self.affected ) do
		local ents = ents.FindByClass( class )	
		for _, ent in ipairs( ents ) do
			self:PerformEnvironmentCheckOnEnt( ent )
		end
	end]]
	--Msg(tostring(table.Count(sb_spawned_entities)).."\n")
	for k, ent in ipairs( sb_spawned_entities) do
		if ent and ValidEntity(ent) then
			self:PerformEnvironmentCheckOnEnt( ent )
		else
			table.remove(sb_spawned_entities, k)
		end
	end
	--local endtime = SysTime();
	--Msg("End Time: "..tostring(endtime-starttime).."\n");
end

function GM:GetSpace()
	return sb_space.Get()
end

function GM:PerformEnvironmentCheckOnEnt(ent)
	if not ent then return end
	if not ent:IsPlayer() or self.PlayerOverride == 0 then
		if ent.environment != sb_space.Get() then
			ent.environment = sb_space.Get() //restore to default before doing the Environment checks
		end
		for k, v in ipairs(Environments) do
			if v and v:IsValid() then
				v:OnEnvironment(ent)
			else
				table.remove(Environments, k)
			end
		end
		self:OnEnvironmentChanged(ent)
		ent.environment:UpdateGravity(ent)
		ent.environment:UpdatePressure(ent)
	end
	if ent:IsPlayer() then
		if SB_InSpace == 1 and (ent.environment == sb_space.Get()  or (not ent.environment:IsPlanet() and ent.environment.environment and ent.environment.environment == sb_space.Get())) then
			if not ent:InVehicle() or not SinglePlayer() then
				if not self:AllowAdminNoclip(ent) then
					if ent:GetMoveType() == MOVETYPE_NOCLIP then
						ent:SetMoveType(MOVETYPE_WALK)
					end
				end
			end
		end
		if self.PlayerOverride == 0 and self.Override_PlayerHeatDestroy == 0 then
			if ent.environment:GetTemperature(ent) > 10000 then
				ent:SilentKill()
			end
		end
	else
		if ent.environment:GetTemperature(ent) > 10000 and ((not (ent.IsEnvironment and ent:IsEnvironment())) or (ent.IsEnvironment and ent:IsEnvironment() and not ent:IsPlanet() and not ent:IsStar() and ent:GetVolume() == 0 ))  then
			ent:Remove()
		end
	end
end

function GM:AddEnvironment(env)
	if not env or not env.GetEnvClass or env:GetEnvClass() != "SB ENVIRONMENT" then return 0 end
	if not table.HasValue(Environments, env) then
		table.insert(Environments, env)
		numenv = numenv + 1
		env:SetEnvironmentID(numenv)
		return numenv
	else
		return env:GetEnvironmentID()
	end
end

function GM:RemoveEnvironment(env)
	if not env or not env.GetEnvClass or env:GetEnvClass() != "SB ENVIRONMENT" then return end
	for k, v in pairs(Environments) do
		if env == v then
			table.remove(Environments, k)
		end
	end
end

function GM:GetEnvironments()
	return table.Copy(Environments)
end

function GM:AllowAdminNoclip(ply)
	if (ply:IsAdmin() or ply:IsSuperAdmin()) and server_settings.Bool( "SB_AdminSpaceNoclip" ) then return true end
	if ply:IsSuperAdmin() and server_settings.Bool( "SB_SuperAdminSpaceNoclip" ) then return true end
	return false
end

//Init

function GM:InitPostEntity()
	self:Register_Sun()
	self:Register_Environments()
	self:AddSentsToList()
end

function GM:AddSentsToList()
	local SEntList = scripted_ents.GetList()
	for _, item in pairs( SEntList ) do
		local name =  item.t.Classname
		if not table.HasValue(self.affected, name) then
			table.insert(self.affected, name) 
		end
	end
	table.insert(self.affected, "player")
end

function GM:SB_SentCheck(ply, ent)
	if not (ent and ent:IsValid()) then return end
	local c = ent:GetClass()
	if table.HasValue(self.affected, c) then return end
	table.insert(self.affected, c)
end
hook.Add( "PlayerSpawnedSENT", "SBSpawnedSent", GM.SB_SentCheck)

function GM:Register_Sun()
	Msg("Registering Sun\n")
	local suns = ents.FindByClass( "env_sun" )
	for _, ent in ipairs( suns ) do
		if ent:IsValid() then
			local values = ent:GetKeyValues()
			for key, value in pairs(values) do
				if ((key == "target") and (string.len(value) > 0)) then
					local targets = ents.FindByName( "sun_target" )
					for _, target in pairs( targets ) do
						SunAngle = (target:GetPos() - ent:GetPos()):Normalize()
						return //Sunangle set, all that was needed
					end
				end
			end
			//Sun angle still not set, but sun found
		    local ang = ent:GetAngles()
			ang.p = ang.p - 180
			ang.y = ang.y - 180
		    --get within acceptable angle values no matter what...
			ang.p = math.NormalizeAngle( ang.p )
			ang.y = math.NormalizeAngle( ang.y )
			ang.r = math.NormalizeAngle( ang.r )
			SunAngle = ang:Forward()
			return
		end
	end
	//no sun found, so just set a default angle
	if not SunAngle then SunAngle = Vector(0,0,-1) end	
end

function GM:Register_Environments()
	Msg("Registering planets\n")
	local Blooms = {}
	local Colors = {}
	local Planets = {}
	local Planetscolor = {}
	local Planetsbloom = {}
	//Load the planets/stars/bloom/color
	local entities = ents.FindByClass( "logic_case" )
	for _, ent in ipairs( entities ) do
		local values = ent:GetKeyValues()
		for key, value in pairs(values) do
   			if key == "Case01" then
				if value == "planet" then
					SB_InSpace = 1
					SetGlobalInt("InSpace", 1)
					if table.Count(TrueSun) == 0 or not table.HasValue(TrueSun, ent:GetPos()) then
						local radius
						local gravity
						local atmosphere
						local stemperature
						local ltemperature
						local ColorID
						local BloomID
						local flags 
						for key2, value2 in pairs(values) do
							if (key2 == "Case02") then radius = tonumber(value2)
							elseif (key2 == "Case03") then gravity = tonumber(value2)
							elseif (key2 == "Case04") then atmosphere = tonumber(value2)
							elseif (key2 == "Case05") then stemperature = tonumber(value2)
							elseif (key2 == "Case06") then ltemperature = tonumber(value2)
							elseif (key2 == "Case07") then
								if (string.len(value2) > 0) then
									ColorID = value2
								end
							elseif (key2 == "Case08") then
								if (string.len(value2) > 0) then
									BloomID = value2
								end
							elseif (key2 == "Case16") then flags = tonumber(value2) end
						end
						local planet = ents.Create( "base_sb_planet1" )
						planet:SetModel("models/props_lab/huladoll.mdl")
						planet:SetAngles( ent:GetAngles() )
						planet:SetPos( ent:GetPos() )
						planet:Spawn()
						planet:CreateEnvironment(ent, radius, gravity, atmosphere, stemperature, ltemperature, flags)
						if ColorID then
							Planetscolor[ColorID] = planet
						end
						if BloomID then
							Planetsbloom[BloomID] = planet
						end
						table.insert(Planets, planet)
						Msg("Registered New Planet\n")
					end
				elseif value == "planet2" then
					SB_InSpace = 1
					SetGlobalInt("InSpace", 1)
					if table.Count(TrueSun) == 0 or not table.HasValue(TrueSun, ent:GetPos()) then
						local radius
						local gravity
						local atmosphere
						local pressure
						local stemperature
						local ltemperature
						local o2
						local co2
						local n
						local h
						local ColorID
						local BloomID
						local flags
						local name
						for key2, value2 in pairs(values) do
							if (key2 == "Case02") then radius = tonumber(value2)
							elseif (key2 == "Case03") then gravity = tonumber(value2)
							elseif (key2 == "Case04") then atmosphere = tonumber(value2)
							elseif (key2 == "Case05") then pressure = tonumber(value2)
							elseif (key2 == "Case06") then stemperature = tonumber(value2)
							elseif (key2 == "Case07") then ltemperature = tonumber(value2)
							elseif (key2 == "Case08") then flags = tonumber(value2)
							elseif (key2 == "Case09") then o2 = tonumber(value2)
							elseif (key2 == "Case10") then co2 = tonumber(value2)
							elseif (key2 == "Case11") then n = tonumber(value2)
							elseif (key2 == "Case12") then h = tonumber(value2)
							elseif (key2 == "Case13") then name = tostring(value2)
							elseif (key2 == "Case15") then
								if (string.len(value2) > 0) then
									ColorID = value2
								end
							elseif (key2 == "Case16") then
								if (string.len(value2) > 0) then
									BloomID = value2
								end
							end
						end
						local planet = ents.Create( "base_sb_planet2" )
						planet:SetModel("models/props_lab/huladoll.mdl")
						planet:SetAngles( ent:GetAngles() )
						planet:SetPos( ent:GetPos() )
						planet:Spawn()
						if name == "" then
							name = "Planet " .. tostring(planet:GetEnvironmentID())
						end
						planet:CreateEnvironment(ent, radius, gravity, atmosphere, pressure, stemperature, ltemperature,  o2, co2, n, h, flags, name)
						if ColorID then
							Planetscolor[ColorID] = planet
						end
						if BloomID then
							Planetsbloom[BloomID] = planet
						end
						table.insert(Planets, planet)
						Msg("Registered New Planet\n")
					end
				elseif value == "sb_dev_tree" then
					local rate
					for key2, value2 in pairs(values) do
						if (key2 == "Case02") then rate = tonumber(value2) end
					end
					local tree = ents.Create( "nature_dev_tree" )
					tree:SetRate(rate, true)
					tree:SetAngles( ent:GetAngles() )
					tree:SetPos( ent:GetPos() )
					tree:Spawn()
					Msg("Registered New SB Tree\n")
				elseif value == "planet_color" then
					local hash = {}
					local ColorID
					for key2, value2 in pairs(values) do
						if (key2 == "Case02") then
							hash.AddColor_r = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							hash.AddColor_g = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							hash.AddColor_b = tonumber(value2)
						end
						if (key2 == "Case03") then
							hash.MulColor_r = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							hash.MulColor_g = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							hash.MulColor_b = tonumber(value2)
						end
						if (key2 == "Case04") then hash.Brightness = tonumber(value2) end
						if (key2 == "Case05") then hash.Contrast = tonumber(value2) end
						if (key2 == "Case06") then hash.Color = tonumber(value2) end
						if (key2 == "Case16") then ColorID = value2 end
					end
					Colors[ColorID] = hash
					Msg("Registered New Planet Color\n")
				elseif value == "planet_bloom" then
					local hash = {}
					local BloomID
					for key2, value2 in pairs(values) do
						if (key2 == "Case02") then
							hash.Col_r = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							hash.Col_g = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							hash.Col_b = tonumber(value2)
						end
						if (key2 == "Case03") then
							hash.SizeX = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							hash.SizeY = tonumber(value2)
						end
						if (key2 == "Case04") then hash.Passes = tonumber(value2) end
						if (key2 == "Case05") then hash.Darken = tonumber(value2) end
						if (key2 == "Case06") then hash.Multiply = tonumber(value2) end
						if (key2 == "Case07") then hash.Color = tonumber(value2) end
						if (key2 == "Case16") then BloomID = value2 end
					end
					Blooms[BloomID] = hash
					Msg("Registered New Planet Bloom\n")
				elseif value == "star" then
					SB_InSpace = 1
					SetGlobalInt("InSpace", 1)
					if table.Count(TrueSun) == 0 or not table.HasValue(TrueSun, ent:GetPos()) then
						local radius
						for key2, value2 in pairs(values) do
							if (key2 == "Case02") then radius = tonumber(value2) end
						end
						local planet = ents.Create( "base_sb_star1" )
						planet:SetModel("models/props_lab/huladoll.mdl")
						planet:SetAngles( ent:GetAngles() )
						planet:SetPos( ent:GetPos() )
						planet:Spawn()
						planet:CreateEnvironment(ent, radius)
						table.insert(TrueSun, ent:GetPos())
						Msg("Registered New Star\n")
					end
				elseif value == "star2" then
					SB_InSpace = 1
					SetGlobalInt("InSpace", 1)
					if table.Count(TrueSun) == 0 or not table.HasValue(TrueSun, ent:GetPos()) then
						local radius
						local temp1
						local temp2
						local temp3
						local name
						for key2, value2 in pairs(values) do
							if (key2 == "Case02") then radius = tonumber(value2)
							elseif (key2 == "Case03") then temp1 = tonumber(value2)
							elseif (key2 == "Case04") then temp2 = tonumber(value2)
							elseif (key2 == "Case05") then temp3 = tonumber(value2)
							elseif (key2 == "Case06") then name = tostring(value2) end
						end
						if name =="" then
							name = "Star"
						end
						local planet = ents.Create( "base_sb_star2" )
						planet:SetModel("models/props_lab/huladoll.mdl")
						planet:SetAngles( ent:GetAngles() )
						planet:SetPos( ent:GetPos() )
						planet:Spawn()
						planet:CreateEnvironment(ent, radius, temp1, temp2, temp3, name)
						table.insert(TrueSun, ent:GetPos())
						Msg("Registered New Star\n")
					end
				end
			end
		end
	end
	for k, v in pairs(Blooms) do
		if Planetsbloom[k] then
			Planetsbloom[k]:BloomEffect(v.Col_r, v.Col_g, v.Col_b, v.SizeX, v.SizeY, v.Passes, v.Darken, v.Multiply, v.Color)
		end
	end
	for k, v in pairs(Colors) do
		if Planetscolor[k] then
			Planetscolor[k]:ColorEffect(v.AddColor_r, v.AddColor_g, v.AddColor_b, v.MulColor_r, v.MulColor_g, v.MulColor_b, v.Brightness, v.Contrast, v.Color)
		end
	end
end

function GM:PlayerNoClip( ply, on )
	if SB_InSpace == 1 and not SinglePlayer() and server_settings.Bool("SB_NoClip") and not self:AllowAdminNoclip(ply) and server_settings.Bool( "SB_PlanetNoClipOnly" ) and ply.environment and ply.environment:IsSpace() then return false end
	return server_settings.Bool( "sbox_noclip" )
end

local function SendColorAndBloom(ent, ply)
		umsg.Start( "AddPlanet", ply )
			umsg.Short( ent:EntIndex())
			umsg.String(ent:GetEnvironmentName())
			umsg.Vector( ent:GetPos() )
			umsg.Float( ent.sbenvironment.size )
			if ent.sbenvironment.color and table.Count(ent.sbenvironment.color) > 0 then
				umsg.Bool( true )
				umsg.Short( ent.sbenvironment.color.AddColor_r )
				umsg.Short( ent.sbenvironment.color.AddColor_g )
				umsg.Short( ent.sbenvironment.color.AddColor_b )
				umsg.Short( ent.sbenvironment.color.MulColor_r )
				umsg.Short( ent.sbenvironment.color.MulColor_g )
				umsg.Short( ent.sbenvironment.color.MulColor_b )
				umsg.Float( ent.sbenvironment.color.Brightness )
				umsg.Float( ent.sbenvironment.color.Contrast )
				umsg.Float( ent.sbenvironment.color.Color )
			else
				umsg.Bool(false)
			end
			if ent.sbenvironment.bloom and table.Count(ent.sbenvironment.bloom) > 0 then
				umsg.Bool(true)
				umsg.Short( ent.sbenvironment.bloom.Col_r )
				umsg.Short( ent.sbenvironment.bloom.Col_g )
				umsg.Short( ent.sbenvironment.bloom.Col_b )
				umsg.Float( ent.sbenvironment.bloom.SizeX )
				umsg.Float( ent.sbenvironment.bloom.SizeY )
				umsg.Float( ent.sbenvironment.bloom.Passes )
				umsg.Float( ent.sbenvironment.bloom.Darken )
				umsg.Float( ent.sbenvironment.bloom.Multiply )
				umsg.Float( ent.sbenvironment.bloom.Color )
			else
				umsg.Bool(false)
			end
		umsg.End()
end

local function SendSunBeam(ent, ply)
		umsg.Start( "AddStar", ply )
			umsg.Short( ent:EntIndex())
			umsg.String(ent:GetName())
			umsg.Vector( ent:GetPos() )
			umsg.Float( ent.sbenvironment.size )
		umsg.End()
end

function GM:PlayerInitialSpawn(ply) //Send the player info about the Stars and Planets for Effects
	self.BaseClass:PlayerInitialSpawn(ply)
	if Environments and table.Count(Environments) > 0 then
		for k, v in pairs(Environments) do
			if v.IsPlanet and v:IsPlanet() then
				SendColorAndBloom(v, ply)
			elseif v.IsStar and v:IsStar() then
				SendSunBeam(v, ply)
			end
		end
	end
end

function GM:PlayerSay( ply, txt )
	txt = self.BaseClass:PlayerSay( ply, txt )
	if not ply:IsAdmin() then return end
	if (string.sub(txt, 1, 10 ) == "!freespace") then
		self:RemoveSBProps()
	elseif (string.sub(txt, 1, 10 ) == "!freeworld") then
		self:RemoveSBProps(true)
	end
	if not txt then txt = "" end
	return tostring(txt)
end

function GM:RemoveSBProps(world)
	for _, class in ipairs( self.affected ) do
		local stuff = ents.FindByClass( class )
		for _, ent in ipairs( stuff ) do
			if world and ent.environment and ent.environment:IsPlanet() then
				if not (ent:IsPlayer() or (ent.IsPlanet and ent:IsPlanet()) or (ent.IsStar and ent:IsStar())) then
					ent:Remove()
				end
			elseif not world and (not ent.environment or ent.environment:IsSpace()) then
				if not (ent:IsPlayer() or (ent.IsPlanet and ent:IsPlanet()) or (ent.IsStar and ent:IsStar())) then
					ent:Remove()
				end
			end
		end
	end
end

function GM:PlayerDeathSound()
	return true
end

function GM:SB_Ragdoll(ply)
	if ply:GetRagdollEntity() and ply:GetRagdollEntity():IsValid() then
		ply:GetRagdollEntity():SetGravity(0)
	else
		ply:CreateRagdoll()
		ply:GetRagdollEntity():SetGravity(0)
	end
end
hook.Add("PlayerKilled","SBRagdoll",GM.SB_Ragdoll)

local volumes = {}
/**
* @param name
* @return Volume(table) or nil
*
*/
function GM:GetVolume(name)
	return volumes[name]
end

/**
* @param name
* @param radius
* @return Volume(table) or ( false + errormessage)
*
* Notes: If the volume name already exists, that volume is returned! 
*
*/
function GM:CreateVolume(name, radius)
	return self:FindVolume(name, radius)
end

/**
* @param name
* @param radius
* @return Volume(table) or ( false + errormessage)
*
* Notes: If the volume name already exists, that volume is returned! 
*
*/
function GM:FindVolume(name, radius)
	if not name then return false, "No Name Entered!" end
	if not radius or radius < 0 then radius = 0 end
	if not volumes[name] then
		volumes[name] = {}
		volumes[name].radius = radius
		volumes[name].pos = Vector(0, 0 ,0 )
		local tries = VolCheckIterations:GetInt()
		local found = 0
		while ( ( found == 0 ) and ( tries > 0 ) ) do
			tries = tries - 1
			pos = VectorRand()*16384
			if (util.IsInWorld( pos ) == true) then
				found = 1
				for k, v in pairs(volumes) do
					--if v and v.pos and (v.pos == pos or v.pos:Distance(pos) < v.radius) then -- Hur hur. This is why i had planetary collisions.
					if v and v.pos and (v.pos == pos or v.pos:Distance(pos) < v.radius+radius) then
						found = 0
					end
				end
				if found == 1 then
					for k, v in pairs(Environments) do
						if v and ValidEntity(v) and ((v.IsPlanet and v.IsPlanet()) or (v.IsStar and v.IsStar())) and (v:GetPos() == pos or v:GetPos():Distance(pos) < v:GetSize()) then
							found = 0
						end
					end
				end
				if (found == 1) and radius > 0 then
					local edges = {
						pos+(Vector(1, 0, 0)*radius),
						pos+(Vector(0, 1, 0)*radius),
						pos+(Vector(0, 0, 1)*radius),
						pos+(Vector(-1, 0, 0)*radius),
						pos+(Vector(0, -1, 0)*radius),
						pos+(Vector(0, 0, -1)*radius)
					}
					local trace = {}
					trace.start = pos
					for _, edge in pairs( edges ) do
						trace.endpos = edge
						trace.filter = { }
						local tr = util.TraceLine( trace )
						if (tr.Hit) then
							found = 0
							break
						end
					end
				end
				if (found == 0) then Msg( "Rejected Volume.\n" ) end
			end
			if (found == 1) then
				volumes[name].pos = pos
			elseif tries <= 0 then
				volumes[name] = nil
			end
		end
	end
	return volumes[name]
end

/**
* @param name
* @return nil
*
*/
function GM:DestroyVolume(name)
	self:RemoveVolume(name);
end

/**
* @param name
* @return nil
*
*/
function GM:RemoveVolume(name)
	if name and volumes[name] then volumes[name] = nil end
end

/**
* @param name
* @param pos
* @param radius
* @return nil
*
* Note: this is meant for people who spawn their props in space using a custom Spawner (like the Stargate Spawner)
*/
function GM:AddCustomVolume(name, pos, radius)
	if not name or not radius or not pos then return false, "Invalid Parameters" end
	if volumes[name] then return false, "this volume already exists!" end
	volumes[name] = {}
	volumes[name].pos = pos
	volumes[name].radius = radius
end
