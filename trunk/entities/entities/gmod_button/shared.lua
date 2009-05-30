

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""


function ENT:SetKey( key )
	self.Entity:SetVar( "NumpadKey", key )
end
function ENT:GetKey()
	return self.Entity:GetVar( "NumpadKey" )
end


function ENT:SetOn( bOn )
	self.Entity:SetNetworkedBool( "OnOff", bOn, true )
end
function ENT:IsOn()
	return self.Entity:GetNetworkedBool( "OnOff" )
end


function ENT:SetLabel( text )

	text = string.gsub( text, "\\", "" )
	text = string.sub( text, 0, 20 )
	
	if ( text != "" ) then
	
		text = "\""..text.."\""
	
	end
	
	self:SetOverlayText( text )
	
end
function ENT:GetLabel()
	self.Entity:GetVar( "Label", "" )
end


function ENT:GetPlayer()
	return self.Entity:GetVar( "Founder", NULL )
end
function ENT:GetPlayerIndex()
	return self.Entity:GetVar( "FounderIndex", 0 )
end
