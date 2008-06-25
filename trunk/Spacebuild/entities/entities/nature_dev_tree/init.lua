AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	//Add setmodel
	//Add health adds
end

function ENT:Destruct()
	if LS_Destruct then
		LS_Destruct( self.Entity, true )
	end
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:OnRemove()
 //nothing
end

function ENT:Think()
	self.BaseClass.Think(self)
	if self.environment then
		self.environment:Convert(1, 0, 5)
	end
	self:NextThink( CurTime() +  1 )
	return true
end
