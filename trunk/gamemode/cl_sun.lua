// draw sun effects
local stars = {}
local function DrawSunEffects( )
	// no pixel shaders? no sun effects!
	if( !render.SupportsPixelShaders_2_0() ) then return; end
	// render each star.
	for ent, Sun in pairs( stars ) do
		// calculate brightness.
		local entpos = Sun.Position //Sun.ent:LocalToWorld( Vector(0,0,0) )
		local dot = math.Clamp( EyeAngles():Forward():DotProduct( Vector( entpos - EyePos() ):Normalize() ), 0, 1 );
		local dist = Vector( entpos - EyePos() ):Length();
		// draw sunbeams.
		local sunpos = EyePos() + Vector( entpos - EyePos() ):Normalize() * ( dist * 0.5 );
		local scrpos = sunpos:ToScreen();
		if( dist <= Sun.BeamRadius && dot > 0 ) then
			local frac = ( 1 - ( ( 1 / ( Sun.BeamRadius ) ) * dist ) ) * dot;
			// draw sun.
			//DrawSunbeams( darken, multiply, sunsize, sunx, suny )
			DrawSunbeams(
				0.95,
				frac,
				0.255,
				scrpos.x / ScrW(),
				scrpos.y / ScrH()
			);
		end
		// can the sun see us?
		local trace = {
			start = entpos,
			endpos = EyePos(),
			filter = LocalPlayer(),
		};
		local tr = util.TraceLine( trace );
		// draw!
		if( dist <= Sun.Radius && dot > 0 && tr.Fraction >= 1 ) then
			// calculate brightness.
			local frac = ( 1 - ( ( 1 / Sun.Radius ) * dist ) ) * dot;
			// draw bloom.
			/*DrawBloom(
				0.428, 
				3 * frac, 
				15 * frac, 15 * frac, 
				5, 
				0, 
				1, 
				1, 
				1
			);*/
			DrawBloom(
				0, 
				0.75 * frac, 
				3 * frac, 3 * frac, 
				2, 
				3, 
				1, 
				1, 
				1
			);
			// draw color.
			local tab = {
				['$pp_colour_addr']		= 0.35 * frac,
				['$pp_colour_addg']		= 0.15 * frac,
				['$pp_colour_addb']		= 0.05 * frac,
				['$pp_colour_brightness']	= 0.8 * frac,
				['$pp_colour_contrast']		= 1 + ( 0.15 * frac ),
				['$pp_colour_colour']		= 1,
				['$pp_colour_mulr']		= 0,
				['$pp_colour_mulg']		= 0,
				['$pp_colour_mulb']		= 0,
			};
			// draw colormod.
			DrawColorModify( tab );
		end
	end

end
hook.Add( "RenderScreenspaceEffects", "SunEffects", DrawSunEffects );


// receive sun information
local function recvSun( msg )
	local ent = msg:ReadShort()
	local position = msg:ReadVector()
	Msg("Added star at angle: "..tostring(position).."\n")
	local radius = msg:ReadFloat()/4
	stars[ ent] = {
		Ent = ents.GetByIndex(ent),
		Position = position,
		Radius = radius * 2,
		BeamRadius = radius * 3,
	}
end
usermessage.Hook( "AddStar", recvSun );

