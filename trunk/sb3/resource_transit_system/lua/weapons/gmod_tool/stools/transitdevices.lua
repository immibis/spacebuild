TOOL.Category = '(Resource Transit)'
TOOL.Name = '#Resource Transit Systems'
TOOL.Command = nil
TOOL.ConfigName = ''
if (CLIENT and GetConVarNumber("CAF_UseTab") == 1) then TOOL.Tab = "Custom Addon Framework" end

TOOL.ClientConVar['type'] = 'air_tank'
TOOL.ClientConVar['model'] = 'models/props_vehicles/generatortrailer01.mdl'

if ( CLIENT ) then
	language.Add( 'Tool_transitdevices_name', 'Resource Transit Devices' )
	language.Add( 'Tool_transitdevices_desc', 'Create Transit Devices attached to any surface.' )
	language.Add( 'Tool_transitdevices_0', 'Left-Click: Spawn a Device.  Right-Click: Repair Device.' )

	language.Add( 'Undone_transitdevices', 'Transit Device Undone' )
	language.Add( 'Cleanup_transitdevices', 'LS: Transit Device' )
	language.Add( 'Cleaned_transitdevices', 'Cleaned up all Transit Devices' )
	language.Add( 'SBoxLimit_transitdevices', 'Maximum Transit Devices Reached' )end

if not CAF or not CAF.GetAddon("Resource Distribution") then Error("Please Install Resource Distribution Addon.'" ) return end

if( SERVER ) then
	CreateConVar('sbox_maxtransitdevices', 10)
	
	function Maketransitdevices( ply, ang, pos, gentype, model, frozen )
		if ( not ply:CheckLimit( "transitdevices" ) ) then return nil end
		
		--Create generator
		local ent = ents.Create( gentype )
		
		
		
		-- Set
		ent:SetPos( pos )
		ent:SetAngles( ang )
		
		ent:Spawn()
		ent:Activate()
		
		ent:SetVar('Owner', ply)
		ent:SetPlayer(ply)
		
		--for duplication, call it Class to fake it for old dupe saves but 
		ent.Class = gentype
		
		if (frozen) then
			local phys = ent:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:EnableMotion( false ) 
				ply:AddFrozenPhysicsObject( ent, phys )
			end
		end
		
		ply:AddCount('transitdevices', ent)
		
		return ent
	end
end

local receptacle_models = {
	{"Mass Driver", "models/props_canal/bridge_pillar02.mdl", "rts_massdriver" },
	{"Microwave Transmitter", "models/props_c17/utilityconnecter006c.mdl", "rts_transmitter" },
	{"Microwave Reciever", "models/props_industrial/oil_storage.mdl", "rts_reciever" },
	{"Packaging System", "models/props_lab/teleplatform.mdl", "rts_packagesys" }
	
}

CAF_ToolRegister( TOOL, receptacle_models, Maketransitdevices, "transitdevices" )