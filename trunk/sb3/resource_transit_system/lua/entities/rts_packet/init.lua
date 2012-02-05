-- Author: Solthar
-- Thanks to: Sassafrass
-- Entity: Mass Driver Packet 
-- Purpose: transports goods over large distances
-- and provides a nice gcombat weapon :-P
-- Uses: Resource Distribution 2, Life Support 2, GCombat, Wire


AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

util.PrecacheSound( "AlyxEMP.Discharge" )

function ENT:Initialize()   
	self.model = "models/props/de_train/Processor_NoBase.mdl"
	self.damagemultiplier = 1						--Resource type affects damage, and weight

	self.Entity:SetModel( self.model ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   	
	self.Entity:SetSolid( SOLID_VPHYSICS ) 

	local RD = CAF.GetAddon("Resource Distribution")
	RD.RegisterNonStorageDevice(self)
	
	--local phys = self.Entity:GetPhysicsObject()  	
	--if (phys:IsValid()) then  		
		--phys:Wake()  
		--phys:ApplyForceCenter( self.Entity:GetUp() * 10000 )
	--end 
end   

function ENT:TransferResources( restype, resamount )
	self.resourceamount = resamount
	self.resourcetype = restype
	
	if (restype == "oxygen") then --air
		self.Entity:SetColor(0,165,255,255)
    	local trail = util.SpriteTrail(self.Entity, 0, Color(0,165,255), true, 80, 0, 2, 1/(60+0)*0.5,"trails/plasma.vmt")
    	self.damagemultiplier = 0.5
    elseif (restype == "nitrogen") then --coolant
		self.Entity:SetColor(1,255,107,255)
    	local trail = util.SpriteTrail(self.Entity, 0, Color(1,255,107), true, 80, 0, 2, 1/(60+0)*0.5,"trails/plasma.vmt")
    	self.damagemultiplier = 1
    elseif (restype == "water") then --water
		self.Entity:SetColor(0,0,255,255)
    	local trail = util.SpriteTrail(self.Entity, 0, Color(0,0,255), true, 80, 0, 2, 1/(60+0)*0.5,"trails/plasma.vmt")
    	self.damagemultiplier = 2
    elseif (restype == "heavywater") then --heavy water
		self.Entity:SetColor(101,34,44,255)
    	local trail = util.SpriteTrail(self.Entity, 0, Color(101,34,44), true, 80, 0, 2, 1/(60+0)*0.5,"trails/plasma.vmt")
    	self.damagemultiplier = 4
    elseif (restype == "darkmatter") then --The unseen stuff of the universe
		self.Entity:SetColor(255,255,255,125)
    	local trail = util.SpriteTrail(self.Entity, 0, Color(255,255,255), true, 80, 0, 2, 1/(60+0)*0.5,"trails/plasma.vmt")
    	self.damagemultiplier = 25
    elseif (restype == "ammo_basic") then --CDS Ammo
		self.Entity:SetColor(125,255,55,255)
    	local trail = util.SpriteTrail(self.Entity, 0, Color(125,255,55), true, 80, 0, 2, 1/(60+0)*0.5,"trails/plasma.vmt")
    	self.damagemultiplier = 5
    elseif (restype == "ammo_explosion") then --CDS Ammo
		self.Entity:SetColor(125,255,55,255)
    	local trail = util.SpriteTrail(self.Entity, 0, Color(125,255,55), true, 80, 0, 2, 1/(60+0)*0.5,"trails/plasma.vmt")
    	self.damagemultiplier = 10
    elseif (restype == "ammo_fuel") then --CDS Ammo
		self.Entity:SetColor(125,255,55,255)
    	local trail = util.SpriteTrail(self.Entity, 0, Color(125,255,55), true, 80, 0, 2, 1/(60+0)*0.5,"trails/plasma.vmt")
    	self.damagemultiplier = 8
    elseif (restype == "ammo_pierce") then --CDS Ammo
		self.Entity:SetColor(125,255,55,255)
    	local trail = util.SpriteTrail(self.Entity, 0, Color(125,255,55), true, 80, 0, 2, 1/(60+0)*0.5,"trails/plasma.vmt")
    	self.damagemultiplier = 6
	else --energy, and unknown packet types
		self.Entity:SetColor(255,255,255,255)
    	local trail = util.SpriteTrail(self.Entity, 0, Color(255,255,255), true, 80, 0, 2, 1/(60+0)*0.5,"trails/plasma.vmt")
    	self.damagemultiplier = 0.25
    end
	
	--larger loads are heavier
	local phys = self.Entity:GetPhysicsObject()
	if ( phys:IsValid() ) then 
		phys:SetMass(resamount * self.damagemultiplier)
		phys:Wake()
        self:ShowOutput(value)
	end
end
function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )
end

function ENT:PhysicsCollide(data, physobj )
	local hitent = data.HitEntity
	local class = hitent:GetClass()
	local RD = CAF.GetAddon("Resource Distribution")
	if class and class == "rts_massdriver" then
		RD.SupplyResource(data.HitEntity, self.resourcetype, self.resourceamount)
		self.Entity:EmitSound( "AlyxEMP.Discharge", 100, 100)
		self.Entity:Remove()
	else
		-- EXPLODE! KABLOOIE!
		--rts_Explosion(damage, piercing, area, position, killcredit)
		local RTS = CAF.GetAddon("Resource Transit System")
		RTS.Explosion( self.resourceamount * self.damagemultiplier / 4,(5 + self.damagemultiplier/10) , self.resourceamount * self.damagemultiplier / 2,self.Entity:GetPos()+  self.Entity:GetUp() * 25,self.Activator)

		self.Entity:Remove()
	end
end

function ENT:Think()
 
	local physx = self.Entity:GetPhysicsObject()  	
	if (physx:IsValid()) then  		
		physx:ApplyForceCenter( self.Entity:GetUp() * 10000)  	
	end 
	self.Entity:NextThink( CurTime() )
	return true
 end
 
 
