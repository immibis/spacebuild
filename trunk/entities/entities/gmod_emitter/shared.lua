

ENT.Type 				= "anim"
ENT.Base 				= "base_gmodentity"

ENT.PrintName			= ""
ENT.Author				= ""
ENT.Contact				= ""
ENT.Purpose				= ""
ENT.Instructions		= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false


/*---------------------------------------------------------
   Effect
---------------------------------------------------------*/
function ENT:SetEffect( name )
	self.Entity:SetNetworkedString( "Effect", name )
end
function ENT:GetEffect()
	return self.Entity:GetNetworkedString( "Effect" )
end



/*---------------------------------------------------------
   Delay
---------------------------------------------------------*/
function ENT:SetDelay( f )
	self.Entity:SetNetworkedFloat( "Delay", f )
end
function ENT:GetDelay()
	return self.Entity:GetNetworkedFloat( "Delay" )
end


/*---------------------------------------------------------
   Delay
---------------------------------------------------------*/
function ENT:SetToggle( b )
	self.Entity:SetNetworkedBool( "Toggle", b )
end
function ENT:GetToggle()
	return self.Entity:GetNetworkedBool( "Toggle" )
end


/*---------------------------------------------------------
   On
---------------------------------------------------------*/
function ENT:SetOn( b )
	self.Entity:SetNetworkedBool( "On", b, true ) // True means send it right now instead of waiting!
end
function ENT:GetOn()
	return self.Entity:GetNetworkedBool( "On" )
end



/*---------------------------------------------------------
   Effect registration
---------------------------------------------------------*/

ENT.Effects				= {}

function ENT:AddEffect( name, func, nicename )

	self.Effects[ name ] = func
	
	if (CLIENT) then
	
		// Maintain a global reference for these effects
		ComboBox_Emitter_Options = ENT.Effects
		language.Add( "emitter_"..name, nicename )
		
	end

end


/*---------------------------------------------------------
   Modular effect adding.. stuff
---------------------------------------------------------*/
local effects = file.FindInLua( "entities/gmod_emitter/fx_*.lua" )
for key, val in pairs( effects ) do

	AddCSLuaFile( val )
	
	if ( CLIENT ) then
		include( val )
	end
	
end
