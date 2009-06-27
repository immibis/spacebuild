
/*---------------------------------------------------------

  SB3 Dummy Gamemode

---------------------------------------------------------*/

include( 'shared.lua' )

function GM:Think()
	if not CAF or not CAF.GetAddon("Spacebuild") then
		LocalPlayer():ChatPrint("Install the Spacebuild Addon");
	end
end
