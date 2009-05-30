
local pQT = nil

local cl_quicktool = CreateClientConVar( "cl_quicktool", 
												"0", 
												true /*Should Save*/, 
												false /*Accessible by server*/ )

//
// See list module on how to add to these without overriding this file!
//
list.Set( "16x16Icons", "wrench", 		"gui/silkicons/wrench" )
list.Set( "16x16Icons", "add", 			"gui/silkicons/add" )
list.Set( "16x16Icons", "cascade", 		"gui/silkicons/application_cascade" )
list.Set( "16x16Icons", "smile", 		"gui/silkicons/emoticon_smile" )
list.Set( "16x16Icons", "exclamation", 	"gui/silkicons/exclamation" )
list.Set( "16x16Icons", "user", 		"gui/silkicons/user" )
list.Set( "16x16Icons", "heart", 		"gui/silkicons/heart" )
list.Set( "16x16Icons", "palette", 		"gui/silkicons/palette" )
list.Set( "16x16Icons", "star", 		"gui/silkicons/star" )

local function GetQT()

	if ( cl_quicktool:GetInt() == 0 ) then return end
	if ( pQT ) then return pQT end

	pQT = vgui.Create( "ToolQuickSelect" )

end

hook.Add( "Initialize", "QuickToolInit", GetQT )



local function QuickToolIn()

	local pQT = GetQT()
	if ( !pQT ) then return end 
	pQT:SetIn( true )

end

hook.Add( "OnContextMenuOpen", "QuickToolIn", QuickToolIn )
hook.Add( "OnSpawnMenuOpen", "QuickToolIn", QuickToolIn )


local function QuickToolOut()

	local pQT = GetQT()
	if ( !pQT ) then return end 
	pQT:SetIn( false )

end

hook.Add( "OnContextMenuClose", "QuickToolOut", QuickToolOut )
hook.Add( "OnSpawnMenuClose", "QuickToolOut", QuickToolOut )
