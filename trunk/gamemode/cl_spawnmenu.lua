
include( 'spawnmenu/spawnmenu.lua' )


/*---------------------------------------------------------
	If false is returned then the spawn menu is never created.
	This saves load times if your mod doesn't actually use the
	spawn menu for any reason.
---------------------------------------------------------*/
function GM:SpawnMenuEnabled()
	return true	
end


/*---------------------------------------------------------
  Called when spawnmenu is trying to be opened. 
   Return false to dissallow it.
---------------------------------------------------------*/
function GM:SpawnMenuOpen()

	GAMEMODE:SuppressHint( "OpeningMenu" )
	GAMEMODE:AddHint( "OpeningContext", 20 )
	return true	
	
end

/*---------------------------------------------------------
  Called when context menu is trying to be opened. 
   Return false to dissallow it.
---------------------------------------------------------*/
function GM:ContextMenuOpen()

	GAMEMODE:SuppressHint( "OpeningContext" )
	GAMEMODE:AddHint( "ContextClick", 20 )

	return true	
end


/*---------------------------------------------------------
  Backwards compatibility. Do Not Use!!!
---------------------------------------------------------*/
function GM:GetSpawnmenuTools( name )	
	return spawnmenu.GetToolMenu( name )
end


/*---------------------------------------------------------
  Backwards compatibility. Do Not Use!!!
---------------------------------------------------------*/
function GM:AddSTOOL( category, itemname, text, command, controls, cpanelfunction )
	self:AddToolmenuOption( "Main", category, itemname, text, command, controls, cpanelfunction )
end


/*---------------------------------------------------------
	Don't hook or override this function. 
	Hook AddToolMenuTabs instead!
---------------------------------------------------------*/
function GM:AddGamemodeToolMenuTabs( )
	
	spawnmenu.AddToolTab( "Main", 			"#Tools", "gui/silkicons/wrench" )
	spawnmenu.AddToolTab( "PostProcessing", "#Post_Processing", "gui/silkicons/picture_edit" )
	spawnmenu.AddToolTab( "Utilities", 		"#Utilities", "gui/silkicons/page_white_wrench" )
	spawnmenu.AddToolTab( "Options", 		"#Options", "gui/silkicons/table_edit" )

end

/*---------------------------------------------------------
	Add your custom tabs here.
---------------------------------------------------------*/
function GM:AddToolMenuTabs()

	// Hook me!

end

/*---------------------------------------------------------
	Add categories to your tabs
---------------------------------------------------------*/
function GM:AddGamemodeToolMenuCategories()

	spawnmenu.AddToolCategory( "Main", 	"Constraints", 	"#Constraints" )
	spawnmenu.AddToolCategory( "Main", 	"Construction", "#Construction" )
	spawnmenu.AddToolCategory( "Main", 	"Poser", 		"#Poser" )
	spawnmenu.AddToolCategory( "Main", 	"Render", 		"#Render" )

end	


/*---------------------------------------------------------
	Add categories to your tabs
---------------------------------------------------------*/
function GM:AddToolMenuCategories()

	// Hook this function to add custom stuff

end	

/*---------------------------------------------------------
	Add categories to your tabs
---------------------------------------------------------*/
function GM:PopulatePropMenu()

	// This function makes the engine load the spawn menu text files.
	// We call it here so that any gamemodes not using the default 
	// spawn menu can totally not call it.
	spawnmenu.PopulateFromEngineTextFiles()

end	



/*

	All of this model search stuff is due for an update to speed it up
	So don't rely on any of this code still being here.
	
*/

local ModelIndex = {}
local ModelIndexTimer = CurTime()

local function BuildModelIndex( dir )

	// Add models from this folder
	local files = file.Find( "../" .. dir .. "*" )
	for k, v in pairs( files ) do
		
		if ( v:sub( -4, -1 ) == ".mdl" ) then
		
			// Filter out some of the un-usable crap
			if ( !v:find( "_gestures" ) && 
				!v:find( "_anim" ) && 
				!v:find( "_gst" ) && 
				!v:find( "_pst" ) && 
				!v:find( "_shd" ) && 
				!v:find( "_ss" ) && 
				!v:find( "cs_fix" ) &&
				!v:find( "_anm" ) ) then
			
				table.insert( ModelIndex, (dir .. v):lower() )
			
			end
			
		elseif ( v:sub( -4, -4 ) != '.' ) then
		
			//BuildModelIndex( dir..v.."/" )
			
			// Stagger the loading so we don't block.
			// This means that the data is inconsistent at first
			// but it's better than adding 5 seconds onto loadtime
			// or pausing for 5 seconds on the first search
			// or dumping all this to a text file and loading it
			ModelIndexTimer = ModelIndexTimer + 0.02
			timer.Simple( ModelIndexTimer - CurTime(), BuildModelIndex, ( dir..v.."/" ) )
			
		end
		
	end
	
end



/*---------------------------------------------------------
  Called by the toolgun to add a STOOL
---------------------------------------------------------*/
function GM:DoModelSearch( str )

	local ret = {}
	
	if ( #ModelIndex == 0 ) then
		ModelIndexTimer = CurTime()
		BuildModelIndex( "models/" )
	end

	if ( str:len() < 3 ) then
			
		table.insert( ret, "Enter at least 3 characters" )
	
	else

		str = str:lower()
		
		for k, v in pairs( ModelIndex ) do
		
			if ( v:find( str ) ) then
		
				table.insert( ret, v )
			
			end
		
		end
		
	end

	return ret

end
