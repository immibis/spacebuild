-- Author: Solthar
-- Thanks to: Sassafrass
-- Entity: Packaging Factory Crate
-- Purpose: holds resources and storage
-- Uses: Resource Distribution 2, Life Support 2


AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

util.PrecacheSound( "AlyxEMP.Discharge" )
local CDSFudgeFix = 100000	-- A huge number so that CDS won't destroy the prop.

function ENT:Initialize()   
	self.model = "models/props_c17/woodbarrel001.mdl"
	local RD = CAF.GetAddon("Resource Distribution")
	RD.RegisterNonStorageDevice(self)
	
	self.Entity:SetModel( self.model ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   	
	self.Entity:SetSolid( SOLID_VPHYSICS )        	
end   

function ENT:SetWeight(restype,resamount)
	self.resourceamount =  resamount
	self.resourcetype = restype
	self.Entity:SetMaterial("models/props_vents/borealis_vent001c")
	
	local RD = CAF.GetAddon("Resource Distribution")
	RD.AddResource   (self.Entity,restype,resamount)
	RD.SupplyResource(self.Entity,restype,resamount)


	if (restype == "oxygen") then --air
		self.Entity:SetColor(0,165,255,255)
    	self.damagemultiplier = 0.5
    	self.volatility = 0
    elseif (restype == "nitrogen") then --coolant
		self.Entity:SetColor(1,255,107,255)
    	self.damagemultiplier = 1
    	self.volatility = 5
    elseif (restype == "water") then --water
		self.Entity:SetColor(0,0,255,255)
    	self.damagemultiplier = 2
    	self.volatility = 0
    elseif (restype == "heavy water") then --heavy water
		self.Entity:SetColor(101,34,44,255)
    	self.damagemultiplier = 4
    	self.volatility = 5
    elseif (restype == "oil") then
		self.Entity:SetColor(255,0,0,255)
    	self.damagemultiplier = 5
    	self.volatility = 10
    elseif (restype == "darkmatter") then --The unseen stuff of the universe
		self.Entity:SetMaterial("models/dog/eyeglass")
    	self.damagemultiplier = 25
    	self.volatility = 75
    elseif (restype == "ammo_basic") then --CDS Ammo
		self.Entity:SetColor(125,255,55,255)
    	self.damagemultiplier = 5
    	self.volatility = 25
    elseif (restype == "ammo_explosion") then --CDS Ammo
		self.Entity:SetColor(125,255,55,255)
    	self.damagemultiplier = 10
    	self.volatility = 45
    elseif (restype == "ammo_fuel") then --CDS Ammo
		self.Entity:SetColor(125,255,55,255)
    	self.damagemultiplier = 8
    	self.volatility = 35
    elseif (restype == "ammo_pierce") then --CDS Ammo
		self.Entity:SetColor(125,255,55,255)
    	self.damagemultiplier = 6
    	self.volatility = 15
    else --energy and unknown types
		self.Entity:SetColor(255,255,255,255)
    	self.damagemultiplier = 0.5
    	self.volatility = 10
    end
    
    -- The more explosive the loads, the more reinforced the crates are, naturally
    self.Entity:SetHealth(self.resourceamount * (self.damagemultiplier / 5))
    self.health = self.resourceamount * (self.damagemultiplier / 5) + CDSFudgeFix
    self.maxhealth = self.resourceamount * (self.damagemultiplier / 5) + CDSFudgeFix
	
	--larger loads are heavier
	local phys = self.Entity:GetPhysicsObject()
	if ( phys:IsValid() ) then 
		phys:SetMass((resamount * self.damagemultiplier)/10)
		phys:Wake()
	end
	
	self.Entity:NextThink( CurTime() + 1)
 	self.Entity:SetNetworkedString("DisplayText1", self.resourcetype)
 	self.Entity:SetNetworkedString("DisplayText2", self.resourceamount.." Units")

end
function ENT:OnTakeDamage( dmginfo )
--	self.Entity:TakePhysicsDamage( dmginfo )

	-- Volatility System, Rather like d20. 
	-- if it rolls less than the volatility, double damage.
	-- if it rolls less than twice, ten times.
	-- if it rolls less than thrice, one hundred times, and double the explosion (aka; ressonant cascade failure :-P).
	-- Should make transporting dangerous goods more exciting.
	
	-- maybe add sounds to each event?
	local DamageMod = 1
	local ExplodeMod = 1
	if (math.Rand(0,100) <= self.volatility) then
		DamageMod = 2
		local effectdata = EffectData()
			effectdata:SetStart	(self.Entity:GetPos())
			effectdata:SetOrigin(dmginfo:GetAttacker():GetPos()+   Vector(math.Rand(-50,50),math.Rand(-50,50),0))
			effectdata:SetEntity(self.Entity)
			effectdata:SetAttachment( 1 )
		util.Effect	( "rts_zap", effectdata ) 
		if (math.Rand(0,100) <= self.volatility) then
			DamageMod = 10
			ExplodeMod = 1.15
			if (math.Rand(0,100) <= self.volatility) then
				DamageMod = 100
				ExplodeMod = 5
			end

		end
	end
	
	self.health = self.health - dmginfo:GetDamage() * DamageMod
	
	--Error((self.health-CDSFudgeFix)..", damage: "..dmginfo:GetDamage()..", mod:"..DamageMod.."\n")
	self:HealthCheck(ExplodeMod)

end

function ENT:HealthCheck(ExplodeMod)
	if self.health <= CDSFudgeFix then
		-- EXPLODE! KABLOOIE!
		--rts_Explosion(damage, piercing, area, position, killcredit)
		local RTS = CAF.GetAddon("Resource Transit System")
		RTS.Explosion( self.resourceamount * self.damagemultiplier / 20 * ExplodeMod,2 + self.damagemultiplier + (ExplodeMod * 10) , self.resourceamount * self.damagemultiplier / 10 * ExplodeMod,self.Entity:GetPos()+  self.Entity:GetUp() * 25,self.Activator)
		self.Entity:Remove()
	end
end


function ENT:Think()
	self:HealthCheck(1)
 	
	self.Entity:NextThink( CurTime() + 1)
	return true
 end
 
 
function Sol_Fade_Percent(starttime,endtime, currenttime)
	local temp = 0
	temp = (currenttime - starttime) / (endtime - starttime)
	return temp
end