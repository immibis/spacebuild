

ENT.Type 			= "anim"
ENT.Base 			= "base_rd_entity"

ENT.PrintName		= "Powered Thruster"
ENT.Author			= "Syncaidius"
ENT.Contact			= ""
ENT.Purpose			= "To move your contraption and eat your resources."
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

function ENT:GetOverlayText()
	local txt = ""
	local force = self.Entity:GetNetworkedInt( 3 )
	local resource = self.Entity:GetNetworkedString( 2 )
	local consumption = math.floor( self.Entity:GetNetworkedInt( 1 ) )
	
	if (self.OOOActive == 1) then
		txt = self.PrintName.." (ON)\nForce: " .. force .. "\nResource: " .. resource .. "\nConsumption: " .. consumption.."/sec"
	else
		txt =  self.PrintName.." (OFF)\nForce: " .. force .. "\nResource: " .. resource .. "\nConsumption: " .. consumption.."/sec"
	end
	
	local PlayerName = self:GetPlayerName()
	if ( !SinglePlayer() and PlayerName != "") then
		txt = txt .. "\n- " .. PlayerName .. " -"
	end
	
	return txt
end

function ENT:SetEffect( name )
	self.Entity:SetNetworkedString( "Effect", name )
end
function ENT:GetEffect( name )
	return self.Entity:GetNetworkedString( "Effect" )
end

function ENT:SetOn( boolon )
	self.Entity:SetNetworkedBool( "On", boolon, true )
end
function ENT:IsOn( name )
	return self.Entity:GetNetworkedBool( "On" )
end

function ENT:SetOffset( v )
	self.Entity:SetNetworkedVector( "Offset", v, true )
end
function ENT:GetOffset( name )
	return self.Entity:GetNetworkedVector( "Offset" )
end

function ENT:NetSetForce( force )
	self.Entity:SetNetworkedInt(4, math.floor(force*100))
end
function ENT:NetGetForce()
	return self.Entity:GetNetworkedInt(4)/100
end

local Limit = .1
local LastTime = 0
local LastTimeA = 0
function ENT:NetSetMul( mul )
	if (CurTime() < LastTimeA + .05) then
		LastTimeA = CurTime()
		return
	end
	LastTimeA = CurTime()
	
	if (CurTime() > LastTime + Limit) then
		self.Entity:SetNetworkedInt(5, math.floor(mul*100))
		LastTime = CurTime()
	end
end

function ENT:NetGetMul()
	return self.Entity:GetNetworkedInt(5)/100
end
