AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

if not (WireAddon == nil) then
    ENT.WireDebugName = "Large Propane Tank"
end

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/canister_propane01a.mdl")
    self.BaseClass.Initialize(self)
    self.Entity:SetColor(85, 0, 0, 255)
    
	self.damaged = 0
    self.maxhealth = 500
    self.health = self.maxhealth
    
    LS_RegisterEnt(self.Entity, "Storage")
    RD_AddResource(self.Entity, "propane", 8000)

	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "Propane", "Max Propane" }) end
	
    local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(90)
	end
end


function ENT:OnRemove()
    self.BaseClass.OnRemove(self)
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
end

function ENT:Repair()
	self.Entity:SetColor(85, 0, 0, 255)
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:Destruct()
	local resource=RD_GetResourceAmount( self, "propane" )
	
	if (resource==0) then 
		resource=1 
	end
	if (resource>8000) then
		resource=8000
	end
	
	local magnit=math.floor(resource/80)
	local radius=math.floor(resource/110)
	local expl=ents.Create("env_explosion")
	
	expl:SetPos(self.Entity:GetPos())
	expl:SetName("Missile")
	expl:SetParent(self.Entity)
	expl:SetOwner(self.Entity:GetOwner())
	expl:SetKeyValue("iMagnitude", magnit)
	expl:SetKeyValue("iRadiusOverride", radius)
	expl:SetKeyValue("spawnflags", 64)
	expl:Spawn()
	expl:Activate()
	expl:Fire("explode", "", 0)
	expl:Fire("kill","",0)
	self.Exploded = true
	
	local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetMagnitude(2)
		effectdata:SetScale(0.4)
	util.Effect( "Propane_Explode", effectdata )	 -- self made effect 
	
	util.PrecacheSound("ambient/explosions/explode_8.wav")
	self.Entity:EmitSound("ambient/explosions/explode_8.wav", 100, 100)
	
	local Ambient = ents.Create("ambient_generic")
	Ambient:SetPos(self.Entity:GetPos())
	Ambient:SetKeyValue("message", "ambient/explosions/explode_8.wav")
	Ambient:SetKeyValue("health", 10)
	Ambient:SetKeyValue("preset", 0)
	Ambient:SetKeyValue("radius", radius*10)
	Ambient:Spawn()
	Ambient:Activate()
	Ambient:Fire("PlaySound", "", 0)
	Ambient:Fire("kill", "", 4)
	
	self.shakeeffect = ents.Create("env_shake") -- Shake from the explosion
	self.shakeeffect:SetKeyValue("amplitude", 16)
	self.shakeeffect:SetKeyValue("spawnflags", 4 + 8 + 16)
	self.shakeeffect:SetKeyValue("frequency", 200.0)
	self.shakeeffect:SetKeyValue("duration", 2)
	self.shakeeffect:SetKeyValue("radius", 2000)
	self.shakeeffect:SetPos(self.Entity:GetPos())
	self.shakeeffect:Fire("StartShake","",0)
	self.shakeeffect:Fire("Kill","",4)
	
	self.splasheffect = ents.Create("env_splash")
	self.splasheffect:SetKeyValue("scale", 500)
	self.splasheffect:SetKeyValue("spawnflags", 2)
	
	self.light = ents.Create("light")
	self.light:SetKeyValue("_light", 255 + 255 + 255)
	self.light:SetKeyValue("style", 0)
	
	local physExplo = ents.Create( "env_physexplosion" )
	physExplo:SetOwner( self.Owner )
	physExplo:SetPos( self.Entity:GetPos() )
	physExplo:SetKeyValue( "Magnitude", magnit )	-- Power of the Physicsexplosion
	physExplo:SetKeyValue( "radius", radius )	-- Radius of the explosion
	physExplo:SetKeyValue( "spawnflags", 2 + 16 )
	physExplo:Spawn()
	physExplo:Fire( "Explode", "", 0 )
	physExplo:Fire( "Kill", "", 0 )

	for k, v in pairs ( ents.FindInSphere( self.Entity:GetPos(), 350 ) ) do
		if not (v:IsPlayer()) then
			--v:Ignite( 10, 0 )
		end
	end
	
	self.Entity:Remove()
end

function ENT:Output()
	return 1
end

function ENT:UpdateWireOutputs()
    if not (WireAddon == nil) then
        Wire_TriggerOutput(self.Entity, "Propane", RD_GetResourceAmount( self, "propane" ))
        Wire_TriggerOutput(self.Entity, "Max Propane", RD_GetNetworkCapacity( self, "propane" ))
    end
end

function ENT:Think()
    self.BaseClass.Think(self)
    
    self:UpdateWireOutputs()
    
	self.Entity:NextThink( CurTime() + 1 )
	return true
end

function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
	end
end

function ENT:PreEntityCopy()
    self.BaseClass.PreEntityCopy(self)
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
    self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities )
end
