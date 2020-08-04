//Updated by PlusIce on September 2015 to add in End Map Vote
Callback_StartGameType()
{
	// Set up variables
	setupVariables();

	// Show lev logo
	showlogo();


	// Start threads
	startThreads();
}

startThreads()
{
	level notify("lev_boot");

	// Bots
	thread addBotClients();

	// Start thread for updating variables from cvars
	thread updateGametypeCvars(false);
		
	// Fix corrupt maprotations
	if(level.awe_fixmaprotation && !level.awe_mapvote)
		fixMapRotation();

	// Do maprotation randomization
	thread randomMapRotation();
}

setupVariables()
{
	// defaults if not defined in level script
	if(!isDefined(game["allies"]))
		game["allies"] = "american";
	if(!isDefined(game["axis"]))
		game["axis"] = "german";

	// Set up the number of available punishments
	level.lev_punishments = 3;

	// Set up number of voices
	level.lev_voices["german"] = 3;
	level.lev_voices["american"] = 7;
	level.lev_voices["russian"] = 6;
	level.lev_voices["british"] = 6;


	// Set up grenade voices
	level.lev_grenadevoices["german"][0]="german_grenade";
	level.lev_grenadevoices["german"][1]="generic_grenadeattack_german_1";
	level.lev_grenadevoices["german"][2]="generic_grenadeattack_german_2";
	level.lev_grenadevoices["german"][3]="generic_grenadeattack_german_3";	

	level.lev_grenadevoices["american"][0]="american_grenade";
	level.lev_grenadevoices["american"][1]="generic_grenadeattack_american_1";
	level.lev_grenadevoices["american"][2]="generic_grenadeattack_american_2";
	level.lev_grenadevoices["american"][3]="generic_grenadeattack_american_3";
	level.lev_grenadevoices["american"][4]="generic_grenadeattack_american_4";
	level.lev_grenadevoices["american"][5]="generic_grenadeattack_american_5";
	level.lev_grenadevoices["american"][6]="generic_grenadeattack_american_6";	

	level.lev_grenadevoices["russian"][0]="russian_grenade";
	level.lev_grenadevoices["russian"][1]="generic_grenadeattack_russian_3";
	level.lev_grenadevoices["russian"][2]="generic_grenadeattack_russian_4";
	level.lev_grenadevoices["russian"][3]="generic_grenadeattack_russian_5";
	level.lev_grenadevoices["russian"][4]="generic_grenadeattack_russian_6";	

	level.lev_grenadevoices["british"][0]="british_grenade";
	level.lev_grenadevoices["british"][1]="generic_grenadeattack_british_1";
	level.lev_grenadevoices["british"][2]="generic_grenadeattack_british_2";
	level.lev_grenadevoices["british"][3]="generic_grenadeattack_british_4";
	level.lev_grenadevoices["british"][4]="generic_grenadeattack_british_5";
	level.lev_grenadevoices["british"][5]="generic_grenadeattack_british_6";	


	// Initialize variables from cvars
	updateGametypeCvars(true);	


	if(isdefined(game["german_soldiervariation"]) && game["german_soldiervariation"] == "winter")
		level.lev_wintermap = true;
	overrideteams();


	// Load effect for bomb explosion (used by antiteamkill,)
	level._effect["bombexplosion"]= loadfx("fx/explosions/pathfinder_explosion.efx");


	if(
		level.lev_secondaryweapon["default"] == "select"	|| level.lev_secondaryweapon["default"] == "selectother"
	  )
	{
		level.lev_secondaryweapontext = &"Select your secondary weapon";
	}

	// Disable minefields?
	if(level.lev_disableminefields)
	{
		minefields = getentarray( "minefield", "targetname" );
		if(minefields.size)
			for(i=0;i< minefields.size;i++)
				if(isdefined(minefields[i]))
					minefields[i] delete();
	}

}
	
showWelcomeMessages()
{
	self endon("lev_spawned");
	self endon("lev_died");

	if(isdefined(self.pers["lev_welcomed"])) return;
	self.pers["lev_welcomed"] = true;

	wait 2;

	count = 0;
	message = cvardef("scr_lev_welcome" + count, "", "", "", "string");
	while(message != "")
	{
		self iprintlnbold(message);
		count++;
		message = cvardef("scr_lev_welcome" + count, "", "", "", "string");
		wait level.lev_welcomedelay;
	}
}

updateGametypeCvars(init)
{
	level endon("lev_boot");

	// Debug
	level.lev_debug = cvardef("scr_lev_debug", 0, 0, 1, "int");

	// Disable minefields
	level.lev_disableminefields = cvardef("scr_lev_disable_minefields", 0, 0, 1, "int");

	// Weapon options
	level.lev_secondaryweapon["default"]= "panzerfaust_mp";
	
	// Map voting	
	level.awe_mapvote = cvardef("awe_map_vote", 0, 0, 1, "int");
	level.awe_mapvotetime = cvardef("awe_map_vote_time", 30, 10, 180, "int");
	level.awe_mapvotereplay = cvardef("awe_map_vote_replay",0,0,1,"int");


	for(;;)
	{

		// Use bots (for debugging)
		level.lev_bots = cvardef("scr_lev_bots", 0, 0, 99, "int");


		// team overriding
		level.lev_teamallies	= cvardef("scr_lev_team_allies","","","","string");

		// welcome message
		level.lev_welcomedelay		= cvardef("scr_lev_welcome_delay", 1, 0.05, 30, "float");


		// Anti Killing and save positions
		level.AntiKill = cvardef("scr_lev_AntiKill", 0, 0, 1, "int"); 
		level.killmax = cvardef("scr_lev_AntiKill_max", 0, 0, 99, "int");
		level.killwarn = cvardef("scr_lev_AntiKill_warn", 0, 0, 99, "int");
		level.savepositions = cvardef("scr_lev_savepositions", 0, 0, 99, "int");


		// Anti teamkilling
		level.lev_teamkillmax = cvardef("scr_lev_teamkill_max", 3, 0, 99, "int");
		level.lev_teamkillwarn = cvardef("scr_lev_teamkill_warn", 1, 0, 99, "int");
		level.lev_teamkillmethod = cvardef("scr_lev_teamkill_method", 0, 0, level.lev_punishments + 1, "int");
		level.lev_teamkillmsg = cvardef("scr_lev_teamkill_msg","^6Good damnit! ^7Learn the difference between ^4friend ^7and ^1foe ^7you bastard!.","","","string");

		// Grenade options
		level.lev_grenadewarning = cvardef("scr_lev_grenade_warning", 0, 0, 99, "int");
		level.lev_grenadewarningrange = 500;
		level.lev_grenadecount = cvardef("scr_lev_grenade_count", 0, 0, 999, "int");
		level.lev_panzercount = cvardef("scr_lev_panzer_count", 0, 0, 999, "int");
		
		// Ammo limiting
		level.lev_ammomin = cvardef("scr_lev_ammo_min",100,0,100,"int");
		level.lev_ammomax = cvardef("scr_lev_ammo_max",100,level.lev_ammomin,100,"int");
		
		// Fix corrupt maprotations
		level.awe_fixmaprotation = cvardef("awe_fix_maprotation", 0, 0, 1, "int");	

		// Use random maprotation?
		level.awe_randommaprotation = cvardef("awe_random_maprotation", 0, 0, 2, "int");	

		// Rotate map if server is empty?
		level.awe_rotateifempty = cvardef("awe_rotate_if_empty", 30, 0, 1440, "int");

		// Hud
		level.lev_showlogo = cvardef("scr_lev_show_logo", 0, 0, 1, "int");	

		// If we are initializing variables, break here
		if(init) break;

		wait 2;
	}
}

/*
USAGE OF "cvardef"
cvardef replaces the multiple lines of code used repeatedly in the setup areas of the script.
The function requires 5 parameters, and returns the set value of the specified cvar
Parameters:
	varname - The name of the variable, i.e. "scr_teambalance", or "scr_dem_respawn"
		This function will automatically find map-sensitive overrides, i.e. "src_dem_respawn_mp_brecourt"

	vardefault - The default value for the variable.  
		Numbers do not require quotes, but strings do.  i.e.   10, "10", or "wave"

	min - The minimum value if the variable is an "int" or "float" type
		If there is no minimum, use "" as the parameter in the function call

	max - The maximum value if the variable is an "int" or "float" type
		If there is no maximum, use "" as the parameter in the function call

	type - The type of data to be contained in the vairable.
		"int" - integer value: 1, 2, 3, etc.
		"float" - floating point value: 1.0, 2.5, 10.384, etc.
		"string" - a character string: "wave", "player", "none", etc.
*/
cvardef(varname, vardefault, min, max, type)
{
	mapname = getcvar("mapname");		// "mp_dawnville", "mp_rocket", etc.
	gametype = getcvar("g_gametype");	// "tdm", "bel", etc.

//	if(getcvar(varname) == "")		// if the cvar is blank
//		setcvar(varname, vardefault); // set the default

	tempvar = varname + "_" + gametype;	// i.e., scr_teambalance becomes scr_teambalance_tdm
	if(getcvar(tempvar) != "") 		// if the gametype override is being used
		varname = tempvar; 		// use the gametype override instead of the standard variable

	tempvar = varname + "_" + mapname;	// i.e., scr_teambalance becomes scr_teambalance_mp_dawnville
	if(getcvar(tempvar) != "")		// if the map override is being used
		varname = tempvar;		// use the map override instead of the standard variable


	// get the variable's definition
	switch(type)
	{
		case "int":
			if(getcvar(varname) == "")		// if the cvar is blank
				definition = vardefault;	// set the default
			else
				definition = getcvarint(varname);
			break;
		case "float":
			if(getcvar(varname) == "")	// if the cvar is blank
				definition = vardefault;	// set the default
			else
				definition = getcvarfloat(varname);
			break;
		case "string":
		default:
			if(getcvar(varname) == "")		// if the cvar is blank
				definition = vardefault;	// set the default
			else
				definition = getcvar(varname);
			break;
	}

	// if it's a number, with a minimum, that violates the parameter
	if((type == "int" || type == "float") && min != "" && definition < min)
		definition = min;

	// if it's a number, with a maximum, that violates the parameter
	if((type == "int" || type == "float") && max != "" && definition > max)
		definition = max;

	return definition;
}

// sort a list of entities with ".origin" properties in ascending order by their distance from the "startpoint"
// "points" is the array to be sorted
// "startpoint" (or the closest point to it) is the first entity in the returned list
// "maxdist" is the farthest distance allowed in the returned list
// "mindist" is the nearest distance to be allowed in the returned list
sortByDist(points, startpoint, maxdist, mindist)
{
	if(!isdefined(points))
		return undefined;
	if(!isdefineD(startpoint))
		return undefined;

	if(!isdefined(mindist))
		mindist = -1000000;
	if(!isdefined(maxdist))
		maxdist = 1000000; // almost 16 miles, should cover everything.

	sortedpoints = [];

	max = points.size-1;
	for(i = 0; i < max; i++)
	{
		nextdist = 1000000;
		next = undefined;

		for(j = 0; j < points.size; j++)
		{
			thisdist = distance(startpoint.origin, points[j].origin);
			if(thisdist <= nextdist && thisdist <= maxdist && thisdist >= mindist)
			{
				next = j;
				nextdist = thisdist;
			}
		}

		if(!isdefined(next))
			break; // didn't find one that fit the range, stop trying

		sortedpoints[i] = points[next];

		// shorten the list, fewer compares
		points[next] = points[points.size-1]; // replace the closest point with the end of the list
		points[points.size-1] = undefined; // cut off the end of the list
	}

	sortedpoints[sortedpoints.size] = points[0]; // the last point in the list

	return sortedpoints;
}

PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc)
{
	self notify("lev_died");

	self cleanupPlayer1();
	self notify("end_saveposition_threads");

}

teamkill()
{

			if (!level.lev_teamkillmax)
				return;
		
			// Increase value
			self.pers["lev_teamkills"]++;
		
			// Check if it reached or passed the max level
			if (self.pers["lev_teamkills"]>=level.lev_teamkillmax)
			{
				if(level.lev_teamkillmethod)
					iprintln(self.name + " ^7has killed ^1" + self.pers["lev_teamkills"] + " ^7teammate(s) and will be punished.");
		
				self iprintlnbold(level.lev_teamkillmsg);
				self thread punishme(level.lev_teamkillmethod, "teamkilling");
		
			}
			// Check if it reached or passed the warning level
			else if (self.pers["lev_teamkills"]>=level.lev_teamkillwarn)
			{
				if(level.lev_teamkillmethod)
					self iprintlnbold(level.lev_teamkillmax - self.pers["lev_teamkills"] + " ^7more teamkill(s) and you will be ^1punished^7!");
				else 
					self iprintlnbold(level.lev_teamkillmax - self.pers["lev_teamkills"] + " ^7more teamkill(s) and nothing will happen!");
			}


}

punishme(iMethod, sReason)
{
	self endon("lev_spawned");
	self endon("lev_died");

	if(iMethod == 1)
		iMethod = 2 + randomInt(level.lev_punishments);

	switch (iMethod)
	{
		case 2:
			self suicide();
			sMethodname = "killed";
			break;

		case 3:
			wait 0.5;
			// explode 
			playfx(level._effect["bombexplosion"], self.origin);
			wait .05;
			self suicide();
			sMethodname = "blown up";
			break;
		
		case 4:
			// Drop weapon and get 15 seconds of spanking
			time = 15;

			self thread punishtimer(time,(0,1,0));

			self shellshock("default",time);
			self thread spankme(time);

			sMethodname = "spanked";
			break;

		default:
			break;
	}
	if(iMethod)
		iprintln(self.name + "^7 is being " + sMethodname + " ^7for " + sReason + "^7.");
}

punishtimer(time,color)
{
	// Remove timer if it exists
	if(isdefined(self.lev_punishtimer))
		self.lev_punishtimer destroy();

	// Set up timer
	self.lev_punishtimer = newClientHudElem(self);
	self.lev_punishtimer.archived = true;
	self.lev_punishtimer.x = 420;
	self.lev_punishtimer.y = 460;
	self.lev_punishtimer.alignX = "center";
	self.lev_punishtimer.alignY = "middle";
	self.lev_punishtimer.alpha = 1;
	self.lev_punishtimer.sort = -3;
	self.lev_punishtimer.font = "bigfixed";
	self.lev_punishtimer.color = color;
	self.lev_punishtimer setTimer(time - 1);

	// Wait
	wait time;

	// Remove timer
	if(isdefined(self.lev_punishtimer))
		self.lev_punishtimer destroy();
}

spankme(time)
{
	self notify("lev_spankme");
	self endon("lev_spankme");
	self endon("lev_spawned");	
	self endon("lev_died");	

	for(i=0;i<(time*5);i++)
	{
		self setClientCvar("cl_stance", "2");
		self dropItem(self getcurrentweapon());
		wait 0.2;
	}
}

// Done on death/spawn and disconnect
cleanupPlayer1()
{
	// Destroy hud elements
	if(isdefined(self.lev_weaponselectmsg))	self.lev_weaponselectmsg destroy();
	if(isdefined(self.lev_punishtimer))		self.lev_punishtimer destroy();

	// Remove compass objective if present
	if(isdefined(self.lev_objnum))
	{
		objective_delete(self.lev_objnum);
		self.lev_objnum = undefined;
	}

	if(isdefined(self.lev_anchor))
		self.lev_anchor delete();

	// Remove spine marker if present
	if(isdefined(self.lev_spinemarker))
	{
		self.lev_spinemarker unlink();
		self.lev_spinemarker delete();
	}
}

spawnPlayer()
{
	self notify("lev_spawned");
	self notify("end_saveposition_threads");
	
	if(!isdefined(self.pers["jumpkills"]))
		self.pers["jumpkills"] = 0;
	if(level.savepositions)


	if(!isdefined(self.pers["lev_teamkills"]))
		self.pers["lev_teamkills"] = 0;

	if(!isdefined(self.lev_pace))
		self.lev_pace = 0;

	self.lev_killspree = 0;

	// Reset flags
	self.lev_disableprimaryb = undefined;
	self.lev_invulnerable = undefined;
	self.lev_warnnade = undefined;
	self.lev_invulnerable = undefined;
	self cleanupPlayer1();

	// Force weapons
	if(!isdefined(level.lev_classbased))
		self forceWeapons(game[self.pers["team"]]);
	
	// Limit/Randomize ammo
	self ammoLimiting();

	self thread monitorme();
	if(level.lev_grenadewarning)
		self thread warning();

	
	self thread meleeblockon();


	if(getcvar("scr_lev_welcome0") != "")
		self thread showWelcomeMessages();

}

limitAmmo(slot)
{
	if(level.lev_ammomin == 100)
		return;

	if(self getWeaponSlotWeapon(slot) == "panzerfaust_mp")
		return;

	if(!level.lev_ammomax)
		ammopc = 0;
	else if(level.lev_ammomin == level.lev_ammomax)
		ammopc = level.lev_ammomin;
	else
		ammopc = level.lev_ammomin + randomInt(level.lev_ammomax - level.lev_ammomin + 1);

	iAmmo = self getWeaponSlotAmmo(slot) + self getWeaponSlotClipAmmo(slot);
	iAmmo = (int)(iAmmo * ammopc/100 + 0.5);
	
	// If no ammo, remove weapon
	if(!iAmmo)
		self setWeaponSlotWeapon(slot, "none");
	else
	{
		self setWeaponSlotClipAmmo(slot,iAmmo);
		iAmmo = iAmmo - self getWeaponSlotClipAmmo(slot);
		if(iAmmo < 0) iAmmo = 0;	// this should never happen
		self setWeaponSlotAmmo(slot, iAmmo);
	}
}

ammoLimiting()
{
	self limitAmmo("primary");
	self limitAmmo("primaryb");
	self limitAmmo("pistol");

	// Set weapon based grenade count
	if(!isdefined(level.lev_classbased))
	{
		if(level.lev_grenadecount)
			grenadecount = level.lev_grenadecount;
		else
		{
			if(isdefined(self.lev_grenadeforced))
				grenadecount = maps\mp\gametypes\_teams::getWeaponBasedGrenadeCount(self getWeaponSlotWeapon("primary"));
			else
			{
				grenadecount = self getWeaponSlotClipAmmo("grenade");
//				self iprintln("Grenade:" + grenadecount);
			}
		}
	}
	else
	{
		grenadecount = self getWeaponSlotClipAmmo("grenade");
	}


	// If no grenades, remove weapon
	if(!grenadecount)
		self setWeaponSlotWeapon("grenade", "none");
	else
		self setWeaponSlotClipAmmo("grenade", grenadecount);
}


forceWeapons(team)
{

	// Force secondary

		weapon = level.lev_secondaryweapon["default"];
	if(level.lev_panzercount)
	{
		switch(weapon)
		{
			case "disable":
				self.lev_disableprimaryb = false;
				weapon = "panzerfaust_mp";
				break;
			default:
				break;
		}
		self forceWeapon("primaryb", weapon);
	}
}	

forceWeapon(slot, weapon)
{


		 	self setWeaponSlotWeapon(slot, weapon);

//				self setWeaponSlotAmmo(slot, 999);
				self setWeaponSlotClipAmmo(slot, level.lev_panzercount);

			// Print message to player
			self iprintln("You have been equipped with a " + "Panzerfaust 60.");


}


monitorme()
{
	self endon("lev_spawned");
	self endon("lev_died");

	{
	self notify("end_saveposition_threads");
		self thread maps\mp\gametypes\_saveposition::main();
		self thread maps\mp\gametypes\_saveposition::_MeleeKey();
		self thread maps\mp\gametypes\_saveposition::_UseKey();
	}
	count = 0;
	funcount=0;

	if(isdefined(self.lev_spinemarker))
	{
		self.lev_spinemarker unlink();
		self.lev_spinemarker delete();
	}

	wait .05;

	self.lev_spinemarker = spawn("script_origin",(0,0,0));
	self.lev_spinemarker linkto (self, "bip01 spine2",(0,0,0),(0,0,0));	

	while( isPlayer(self) && isAlive(self) && self.sessionstate=="playing" )
	{

		// Disable primaryb?		
		if(isdefined(self.lev_disableprimaryb))
		{
			primaryb = self getWeaponSlotWeapon("primaryb");
			if (primaryb != "none")
			{
				//player picked up a weapon
				primary = self getWeaponSlotWeapon("primary");
				if (primary != "none")
				{
					//drop primary weapon if he's carrying one already
					self dropItem(primary);
				}	

				//remove the weapon from the primary b slot
				self setWeaponSlotWeapon("primaryb", "none");
				self.pers["weapon2"] = undefined;

				//put the picked up weapon in primary slot
				self setWeaponSlotWeapon("primary", primaryb);
				self.pers["weapon1"] = primaryb;
				self switchToWeapon(primaryb);
			} 
		}

		// Calculate current speed
		oldpos = self.origin;
		wait 1;				// Wait 2 seconds
		newpos = self.origin;
		speed = distance(oldpos,newpos);

		if (speed > 20)
			self.lev_pace = 1;
		else
			self.lev_pace = 0;

	}
	if(isdefined(self.lev_spinemarker))
	{
		self.lev_spinemarker unlink();
		self.lev_spinemarker delete();
	}
}

PlayerDisconnect()
{
	self notify("lev_died");
	self notify("lev_spawned");

	self cleanupPlayer1();

}

overrideteams()
{
	if(isdefined(level.lev_classbased))
		return;

	// It it's the same map and gametype, use old values to avoid non precached models
	if( getcvar("mapname") == getcvar("lev_oldmap") && getcvar("g_gametype") == getcvar("lev_oldgt") )
	{
		game["allies"] = getcvar("lev_allies");
		game[game["allies"] + "_soldiertype"] 	= getcvar("lev_soldiertype");
		game[game["allies"] + "_soldiervariation"]= getcvar("lev_soldiervariation");
		if(game["allies"] == "american" && game[game["allies"] + "_soldiervariation"] == "winter")
		{
			game["german_soldiertype"] = "wehrmacht";
			game["german_soldiervariation"] = "winter";
		}
		return;
	}

	// Override allies team
	switch(level.lev_teamallies)
	{
		case "american":
		case "british":
		case "german":
		case "russian":
			game["allies"] = level.lev_teamallies;
			break;

		case "random":
			allies = [];
			oldteam = getcvar("lev_allies");
			if(oldteam != "american")	allies[allies.size] = "american";
			if(oldteam != "british")	allies[allies.size] = "british";
			if(oldteam != "russian")	allies[allies.size] = "russian";
			game["allies"] = allies[randomInt(allies.size)];
			break;

		default:
			break;
	}

	if(!isdefined(game[ game["allies"] + "_soldiertype" ]))
	{
		switch(game["allies"])
		{
			case "american":
				if(isdefined(level.lev_wintermap))
				{
					game["american_soldiertype"] = "airborne";
					game["american_soldiervariation"] = "winter";
					game["german_soldiertype"] = "wehrmacht";
					game["german_soldiervariation"] = "winter";
				}
				else	
				{
					game["american_soldiertype"] = "airborne";
					game["american_soldiervariation"] = "normal";
				}
				break;

			case "british":
				if(isdefined(level.lev_wintermap))
				{
					game["british_soldiertype"] = "commando";
					game["british_soldiervariation"] = "winter";
				}
				else
				{
					switch(randomInt(2))
					{
						case 0:
							game["british_soldiertype"] = "airborne";
							game["british_soldiervariation"] = "normal";
							break;
	
						default:
							game["british_soldiertype"] = "commando";
							game["british_soldiervariation"] = "normal";
							break;
					}
				}
				break;

			case "russian":
				if(isdefined(level.lev_wintermap))
				{
					switch(randomInt(2))
					{
						case 0:
							game["russian_soldiertype"] = "conscript";
							game["russian_soldiervariation"] = "winter";
							break;

						default:
							game["russian_soldiertype"] = "veteran";
							game["russian_soldiervariation"] = "winter";
							break;
					}
				}
				else
				{
					switch(randomInt(2))
					{
						case 0:
							game["russian_soldiertype"] = "conscript";
							game["russian_soldiervariation"] = "normal";
							break;


						default:
							game["russian_soldiertype"] = "veteran";
							game["russian_soldiervariation"] = "normal";
							break;

					}
				}
				break;
		}
	}

	// Save stuff for reinitializing in roundbased gametypes
	setcvar("lev_oldgt",	getcvar("g_gametype") );
	setcvar("lev_oldmap",	getcvar("mapname") );
	setcvar("lev_allies",			game["allies"] );
	setcvar("lev_soldiertype", 		game[game["allies"] + "_soldiertype"] );
	setcvar("lev_soldiervariation",	game[game["allies"] + "_soldiervariation"] );
}

showlogo()
{

logotext = &"^7A^2k^1k ^3v1.5 ^2enabled";


	if (level.AntiKill && level.lev_showlogo) //Show Logo
	{
		if(isdefined(level.logo))
			level.logo destroy();

		level.logo = newHudElem();	
		level.logo.x = 631;
		level.logo.y = 475;
		level.logo.alignX = "right";
		level.logo.alignY = "middle";
		level.logo.sort = -3;
		level.logo.alpha = 1;
		level.logo.fontScale = 0.6;
		level.logo.archived = true;
		level.logo setText(logotext);
	}
}

addBotClients()
{
	level endon("lev_boot");

	wait 5;
	
	while(!level.lev_bots) wait 1;
	
	for(i = 0; i < level.lev_bots; i++)
	{
		ent[i] = addtestclient();
		wait 0.5;

		if(isPlayer(ent[i]))
		{
			if(i & 1)
			{
				ent[i] notify("menuresponse", game["menu_team"], "axis");
				wait 0.5;
				ent[i] notify("menuresponse", game["menu_weapon_axis"], "kar98k_mp");
			}
			else
			{
				ent[i] notify("menuresponse", game["menu_team"], "allies");
				wait 0.5;
				if(game["allies"] == "russian")
					ent[i] notify("menuresponse", game["menu_weapon_allies"], "mosin_nagant_mp");
				else
					ent[i] notify("menuresponse", game["menu_weapon_allies"], "springfield_mp");
			}
		}
	}
}

PlayerinRange(range)
{
	if(!range)
		return true;

	// Get all players and pick out the ones that are playing
	allplayers = getentarray("player", "classname");
	players = [];
	for(i = 0; i < allplayers.size; i++)
	{
		if(allplayers[i].sessionstate == "playing")
			players[players.size] = allplayers[i];
	}

	// Get the players that are in range
	sortedplayers = sortByDist(players, self);

	// Need at least 2 players (myself + one team mate)
	if(sortedplayers.size<2)
		return false;

	// First player will be myself so check against second player
	distance = distance(self.origin, sortedplayers[1].origin);
	if( distance <= range )
		return true;
	else
		return false;
}

isGrenade(weapon)
{
	switch(weapon)
	{
		case "fraggrenade_mp":
		case "mk1britishfrag_mp":
		case "rgd-33russianfrag_mp":
		case "stielhandgranate_mp":
//		case "smokegrenade_mp":
			return true;
			break;

		default:
			return false;
			break;
	}
}

warning()
{
	self endon("lev_spawned");
	self endon("lev_died");

	// Loop
	while (isAlive(self) && self.sessionstate == "playing")
	{
		// Wait
		wait .05;

		// get current weapon
		cw = self getCurrentWeapon();
		attackButton = self attackButtonPressed();

		// Is the current weapon a grenade?
		if(attackButton && isGrenade(cw))
			self thread warningyell();


			self thread meleeblock();
	}
}

meleeblockon()
{
	self endon("lev_spawned");
	self endon("lev_died");

	// Loop
	while (isAlive(self) && self.sessionstate == "playing")
	{
			wait .05;
			self thread meleeblock();
	}
}

meleeblock()
{
	if (level.AntiKill)
	{
	self endon("lev_spawned");
	self endon("lev_died");


		if(self PlayerinRange(100))
			{
				if(isdefined(self.pers["lev_notified"])) return;
				self.pers["lev_notified"] = true;
					wait(0.25);
				self.lev_invulnerable = true;
			}
		else
			{
			self.lev_invulnerable = undefined;
			self.pers["lev_notified"] = undefined;
			}
	}
}

warningyell()
{
	if(isdefined(self.lev_warnnade)) return;
	self.lev_warnnade = true;

	self endon("lev_spawned");
	self endon("lev_died");

 
		while(self attackButtonPressed() && isGrenade( self getCurrentWeapon() ) && isAlive(self) && self.sessionstate == "playing")
			wait .05;

	// Thrown a grenade?
	if(isGrenade(self getCurrentWeapon()) && !self attackButtonPressed() && level.lev_grenadewarning && isAlive(self) && self.sessionstate == "playing")
	{
		if( (level.lev_grenadewarning) && self PlayerinRange(level.lev_grenadewarningrange) )
		{
			// Yell "Grenade!"
			soundalias = level.lev_grenadevoices[ game[ self.pers["team"] ] ][randomInt(level.lev_grenadevoices[ game[ self.pers["team"] ] ].size)];
			self playsound(soundalias);
		}
	}
	self.lev_warnnade = undefined;
}

Antikill()
{

	if (level.killmax)
	{

	if(!isdefined(self.pers["jumpkills"]))
		self.pers["jumpkills"] = 0;

		self.pers["jumpkills"]++;


			if (self.pers["jumpkills"]>=level.killmax)
				{
				iprintln(self.name + " ^7has killed" + "^1 " + self.pers["jumpkills"] +"^7 jumper(s) and will be ^1kicked.");
				self iprintlnbold("^3[^2B^7y^2e ^7b^2y^7e^3]");
				wait 1;
				self setClientCvar("name", "I_am_a_pathetic_jumper_killer!");

				}


			else if (self.pers["jumpkills"]>=level.killwarn)
				{
				self iprintlnbold(self.name);
				self iprintlnbold(level.killmax - self.pers["jumpkills"]);
				self iprintlnbold("^7more kill(s) and you will be ^1kicked^7!");

				}
	}
}
//-----------------------------------------------------------------------------
// Maprotation Vote added
//-----------------------------------------------------------------------------
endMap()
{
	if (isDefined(level.lev_debug) && level.lev_debug) {
		iprintln("^2DEBUG: Starting _lev endMap().");
		wait 3;
	}

	// Temporarily disabled by Kraken
	// if(level.awe_disable)
	// 	return;

	if (isDefined(level.awe_gametype))
	{
		setcvar("g_gametype",level.awe_gametype);		// Restore gametype in case we are pretending
	}


	if (isDefined(level.lev_debug) && level.lev_debug) {
		iprintln("^2DEBUG: Finished setting g_gametype.");
		wait 1;
	}

	maps\mp\gametypes\_awe_mapvote::Initialise();

	if (isDefined(level.lev_debug) && level.lev_debug) {
		iprintln("^2DEBUG: Finished Initialise().");
		wait 1;
	}
}
fixMapRotation()
{
	x = GetPlainMapRotation();
	if(isdefined(x))
	{
		if(isdefined(x.maps))
			maps = x.maps;
		x delete();
	}

	if(!isdefined(maps) || !maps.size)
		return;

	// Built new maprotation string
	newmaprotation = "";
	newmaprotationcurrent = "";
	for(i = 0; i < maps.size; i++)
	{
		if(!isdefined(maps[i]["exec"]))
			exec = "";
		else
			exec = " exec " + maps[i]["exec"];

		if(!isdefined(maps[i]["jeep"]))
			jeep = "";
		else
			jeep = " allow_jeeps " + maps[i]["jeep"];

		if(!isdefined(maps[i]["tank"]))
			tank = "";
		else
			tank = " allow_tanks " + maps[i]["tank"];

		if(!isdefined(maps[i]["gametype"]))
			gametype = "";
		else
			gametype = " gametype " + maps[i]["gametype"];

		newmaprotation += exec + jeep + tank + gametype + " map " + maps[i]["map"];

		if(i>0)
			newmaprotationcurrent += exec + jeep + tank + gametype + " map " + maps[i]["map"];
	}

	// Set the new rotation
	setCvar("sv_maprotation", strip(newmaprotation));

	// Set the new rotationcurrent
	setCvar("sv_maprotationcurrent", newmaprotationcurrent);

	// Set awe_fix_maprotation to "0" to indicate that initial fixing has been done
	setCvar("awe_fix_maprotation", "0");
}
	
randomMapRotation()
{
	level endon("awe_boot");

	// Do random maprotation?
	if(!level.awe_randommaprotation || level.awe_mapvote)
		return;

	// Randomize maps of maprotationcurrent is empty or on a fresh start
	if( strip(getcvar("sv_maprotationcurrent")) == "" || level.awe_randommaprotation == 1)
	{
		x = GetRandomMapRotation();
		if(isdefined(x))
		{
			if(isdefined(x.maps))
				maps = x.maps;
			x delete();
		}

		if(!isdefined(maps) || !maps.size)
			return;

		lastexec = "";
		lastjeep = "";
		lasttank = "";
		lastgt = "";

		// Built new maprotation string
		newmaprotation = "";
		for(i = 0; i < maps.size; i++)
		{
			if(!isdefined(maps[i]["exec"]) || lastexec == maps[i]["exec"])
				exec = "";
			else
			{
				lastexec = maps[i]["exec"];
				exec = " exec " + maps[i]["exec"];
			}

			if(!isdefined(maps[i]["jeep"]) || lastjeep == maps[i]["jeep"])
				jeep = "";
			else
			{
				lastjeep = maps[i]["jeep"];
				jeep = " allow_jeeps " + maps[i]["jeep"];
			}

			if(!isdefined(maps[i]["tank"]) || lasttank == maps[i]["tank"])
				tank = "";
			else
			{
				lasttank = maps[i]["tank"];
				tank = " allow_tanks " + maps[i]["tank"];	
			}

			if(!isdefined(maps[i]["gametype"]) || lastgt == maps[i]["gametype"])
				gametype = "";
			else
			{
				lastgt = maps[i]["gametype"];
				gametype = " gametype " + maps[i]["gametype"];	
			}

			newmaprotation += exec + jeep + tank + gametype + " map " + maps[i]["map"];
		}

		// Set the new rotation
		setCvar("sv_maprotationcurrent", newmaprotation);

		// Set awe_random_maprotation to "2" to indicate that initial randomizing is done
		setCvar("awe_random_maprotation", "2");
	}
}

randomizeArray(arr)
{
	if(arr.size)
	{
		// Shuffle the array 10 times
		for(k = 0; k < 10; k++)
		{
			for(i = 0; i < arr.size; i++)
			{
				j = randomInt(arr.size);
				element = arr[i];
				arr[i] = arr[j];
				arr[j] = element;
			}
		}
	}
	return arr;
}
serverMessages()
{
	level endon("awe_boot");
	if(level.awe_messageindividual)
	{
		// Check if thread has allready been called.
		if(isdefined(self.pers["awe_serverMessages"]))
			return;

		self endon("awe_spawned");
		self endon("awe_died");
	}
	else
	{
		// Check if thread has allready been called.
		if(isdefined(game["serverMessages"]))
			return;
	}

	wait level.awe_messagedelay;

	for(;;)
	{
		if( !level.awe_mapvote && level.awe_messagenextmap && !(level.awe_messageindividual && isdefined(self.pers["awe_messagecount"])) )
		{
			x = GetCurrentMapRotation(1);
			if(isdefined(x))
			{
				if(isdefined(x.maps))
					maps = x.maps;
				x delete();
			}

			if(isdefined(maps) && maps.size)
			{
				// Get next map
				if(isdefined(maps[0]["gametype"]))
					nextgt=maps[0]["gametype"];
				else
					nextgt=level.awe_gametype;

				nextmap=maps[0]["map"];

				if(level.awe_messagenextmap == 4)
				{
					if(level.awe_randommaprotation)
					{
						if(level.awe_messageindividual)
							self iprintln("^3This server uses ^5random ^3maprotation.");
						else
							iprintln("^3This server uses ^5random ^3maprotation.");
					}
					else
					{
						if(level.awe_messageindividual)
							self iprintln("^3This server uses ^5normal ^3maprotation.");
						else
							iprintln("^3This server uses ^5normal ^3maprotation.");
					}	
				
					wait 1;
				}

				if(level.awe_messagenextmap > 2)
				{
					if(level.awe_messageindividual)
						self iprintln("^3Next gametype: ^5" + getGametypeName(nextgt) );
					else
						iprintln("^3Next gametype: ^5" + getGametypeName(nextgt) );
					wait 1;
				}

				if(level.awe_messagenextmap > 2 || level.awe_messagenextmap == 1)
				{
					if(level.awe_messageindividual)
						self iprintln("^3Next map: ^5" + getMapName(nextmap) );
					else
						iprintln("^3Next map: ^5" + getMapName(nextmap) );
				}

				if(level.awe_messagenextmap == 2)
				{
					if(level.awe_messageindividual)
						self iprintln("^3Next: ^5" + getMapName(nextmap) + "^3/^5" + getGametypeName(nextgt) );
					else
						iprintln("^3Next: ^5" + getMapName(nextmap) + "^3/^5" + getGametypeName(nextgt) );
					wait 1;
				}

				// Set next message
				if(level.awe_messageindividual)
					self.pers["awe_messagecount"] = 0;

				wait level.awe_messagedelay;
			}
		}
	
		// Get first message
		if(level.awe_messageindividual && isdefined(self.pers["awe_messagecount"]))
			count = self.pers["awe_messagecount"];
		else
			count = 0;

		message = cvardef("awe_message" + count, "", "", "", "string");

		// Avoid infinite loop
		if(message == "" && !(isdefined(maps) && maps.size))
			wait level.awe_messagedelay;

		// Announce messages
		while(message != "")
		{
			if(level.awe_messageindividual)
				self iprintln(message);
			else
				iprintln(message);
			count++;
			// Set next message
			if(level.awe_messageindividual)
				self.pers["awe_messagecount"] = count;

			wait level.awe_messagedelay;

			message = cvardef("awe_message" + count, "", "", "", "string");
		}

		if(level.awe_messageindividual)
			self.pers["awe_messagecount"] = undefined;

		// Loop?
		if(!level.awe_messageloop)
			break;
	}
	// Set flag to indicate that this thread has been called and run all through once
	if(level.awe_messageindividual)
		self.pers["awe_serverMessages"] = true;
	else
		game["serverMessages"] = true;
}

getGametypeName(gt)
{
	switch(gt)
	{
		case "dm":
		case "mc_dm":
			gtname = "Deathmatch";
			break;
		
		case "tdm":
		case "mc_tdm":
			gtname = "Team Deathmatch";
			break;

		case "sd":
		case "mc_sd":
			gtname = "Search & Destroy";
			break;

		case "re":
		case "mc_re":
			gtname = "Retrieval";
			break;

		case "hq":
		case "mc_hq":
			gtname = "Headquarters";
			break;

		case "bel":
		case "mc_bel":
			gtname = "Behind Enemy Lines";
			break;
		
		case "cnq":
		case "mc_cnq":
			gtname = "Conquest TDM";
			break;

		case "lts":
		case "mc_lts":
			gtname = "Last Team Standing";
			break;

		case "ctf":
		case "mc_ctf":
			gtname = "Capture The Flag";
			break;

		case "dom":
		case "mc_dom":
			gtname = "Domination";
			break;

		case "ad":
		case "mc_ad":
			gtname = "Attack and Defend";
			break;

		case "bas":
		case "mc_bas":
			gtname = "Base assault";
			break;

		case "actf":
		case "mc_actf":
			gtname = "AWE Capture The Flag";
			break;

		case "htf":
		case "mc_htf":
			gtname = "Hold The Flag";
			break;

		case "ter":
		case "mc_ter":
			gtname = "Territory";
			break;

		case "asn":
		case "mc_asn":
			gtname = "Assassin";
			break;

		case "mc_tdom":
			gtname = "Team Domination";
			break;
		
		default:
			gtname = gt;
			break;
	}

	return gtname;
}

getMapName(map)
{
	switch(map)
	{
		case "mp_arnhem":
			mapname = "Arnhem";
			break;

		case "mp_berlin":
			mapname = "Berlin";
			break;

		case "mp_bocage":
			mapname = "Bocage";
			break;
		
		case "mp_brecourt":
			mapname = "Brecourt";
			break;

		case "mp_carentan":
			mapname = "Carentan";
			break;

		case "mp_uo_carentan":
			mapname = "Carentan(UO)";
			break;
		
		case "mp_cassino":
			mapname = "Cassino";
			break;

		case "mp_chateau":
			mapname = "Chateau";
			break;
		
		case "mp_dawnville":
			mapname = "Dawnville";
			break;

		case "mp_uo_dawnville":
			mapname = "Dawnville(UO)";
			break;
		
		case "mp_depot":
			mapname = "Depot";
			break;
		
		case "mp_uo_depot":
			mapname = "Depot(UO)";
			break;
		
		case "mp_foy":
			mapname = "Foy";
			break;

		case "mp_harbor":
			mapname = "Harbor";
			break;
		
		case "mp_uo_harbor":
			mapname = "Harbor(UO)";
			break;
		
		case "mp_hurtgen":
			mapname = "Hurtgen";
			break;
		
		case "mp_uo_hurtgen":
			mapname = "Hurtgen(UO)";
			break;
		
		case "mp_italy":
			mapname = "Italy";
			break;

		case "mp_kharkov":
			mapname = "Kharkov";
			break;

		case "mp_kursk":
			mapname = "Kursk";
			break;

		case "mp_neuville":
			mapname = "Neuville";
			break;
		
		case "mp_pavlov":
			mapname = "Pavlov";
			break;
		
		case "mp_peaks":
			mapname = "Peaks";
			break;

		case "mp_ponyri":
			mapname = "Ponyri";
			break;

		case "mp_powcamp":
			mapname = "P.O.W Camp";
			break;

		case "mp_uo_powcamp":
			mapname = "P.O.W Camp(UO)";
			break;
		
		case "mp_railyard":
			mapname = "Railyard";
			break;

		case "mp_rhinevalley":
			mapname = "Rhine Valley";
			break;

		case "mp_rocket":
			mapname = "Rocket";
			break;
		
		case "mp_ship":
			mapname = "Ship";
			break;

		case "mp_streets":
			mapname = "Streets";
			break;
		
		case "mp_sicily":
			mapname = "Sicily";
			break;

		case "mp_stalingrad":
			mapname = "Stalingrad";
			break;
		
		case "mp_tigertown":
			mapname = "Tigertown";
			break;

		case "mp_uo_stanjel":
			mapname = "Stanjel(UO)";
			break;

		case "DeGaulle_beta2":
			mapname = "DeGaulle Beta2";
			break;

		case "mp_bellicourt":
			mapname = "Bellicourt";
			break;

		case "mp_offensive":
			mapname = "Offensive";
			break;

		case "mp_rzgarena":
			mapname = "Rezorg Arena";
			break;

		case "mp_venicedock":
			mapname = "Venicedock";
			break;

		case "nuenen":
			mapname = "Nuenen";
			break;

		case "Outlaw_Bridge":
			mapname = "Outlaw Bridge";
			break;

		case "Outlaws_SFrance":
			mapname = "Outlaws France";
			break;

		case "the_hunt":
			mapname = "The Hunt";
			break;

		case "mp_streetwar":
			mapname = "Streetwar";
			break;

		case "mp_subharbor_night":
			mapname = "Subharbor Night";
			break;

		case "mp_subharbor_day":
			mapname = "Subharbor Day";
			break;

		case "mp_landsitz":
			mapname = "Landsitz";
			break;

		case "Hafen_beta":
			mapname = "Hafen";
			break;

		case "mp_hollenberg":
			mapname = "Hollenberg";
			break;

		case "viaduct":
			mapname = "Viaduct";
			break;

		case "mp_oase":
			mapname = "Oase";
			break;

		case "mp_v2_ver3":
			mapname = "V2 Rocket";
			break;

		case "arcville":
			mapname = "Arcville";
			break;

		case "arkov4":
			mapname = "Arkov";
			break;

		case "mp_saint-lo":
			mapname = "Saint-Lo";
			break;

		case "second_coming":
			mapname = "The Second Coming";
			break;

		case "mp_westwall":
			mapname = "Westwall";
			break;

		case "mp_maaloy":
			mapname = "Maaloy";
			break;

		case "dufresne":
			mapname = "Dufresne";
			break;

		case "dufresne_winter":
			mapname = "Dufresne Winter";
			break;

		case "gorges_du_wet":
			mapname = "Les Gorges du Wet";
			break;

		case "d-day+7":
			mapname = "D-Day";
			break;

		case "mp_wolfsquare_final":
			mapname = "Wolfsquare Public";
			break;

		case "the_bridge":
			mapname = "The Bridge";
			break;

		case "mp_amberville":
		case "mc_amberville":
			mapname = "Amberville";
			break;

		case "mp_stanjel":
		case "mc_stanjel":
			mapname = "Stanjel";
			break;

		case "mp_bazolles":
		case "mc_bazolles":
			mapname = "Bazolles";
			break;

		case "townville_beta":
		case "mp_townville":
		case "mc_townville":
			mapname = "Townville";
			break;

		case "german_town":
		case "mp_german_town":
		case "mc_german_town":
			mapname = "German Town";
			break;
		
		case "mp_drumfergus2":
			mapname = "Drum Fergus 2";
			break;
			
		case "mp_uo_vaddhe":
			mapname = "V2 Base";
			break;

		default:
			mapname = map;
			break;
	}

	return mapname;
}
// Get Map Stuff


GetPlainMapRotation(number)
{
	return GetMapRotation(false, false, number);
}

GetRandomMapRotation()
{
	return GetMapRotation(true, false, undefined);
}

GetCurrentMapRotation(number)
{
	return GetMapRotation(false, true, number);
}

GetMapRotation(random, current, number)
{
	maprot = "";

	if(!isdefined(number))
		number = 0;

	// Get current maprotation
	if(current)
		maprot = strip(getcvar("sv_maprotationcurrent"));	

	// Get maprotation if current empty or not the one we want
	if(level.awe_debug) iprintln("(cvar)maprot: " + getcvar("sv_maprotation").size);
	if(maprot == "")
		maprot = strip(getcvar("sv_maprotation"));	
	if(level.awe_debug) iprintln("(var)maprot: " + maprot.size);

	// No map rotation setup!
	if(maprot == "")
		return undefined;
	
	// Explode entries into an array
//	temparr2 = explode(maprot," ");
	j=0;
	temparr2[j] = "";	
	for(i=0;i<maprot.size;i++)
	{
		if(maprot[i]==" ")
		{
			j++;
			temparr2[j] = "";
		}
		else
			temparr2[j] += maprot[i];
	}

	// Remove empty elements (double spaces)
	temparr = [];
	for(i=0;i<temparr2.size;i++)
	{
		element = strip(temparr2[i]);
		if(element != "")
		{
			if(level.awe_debug) iprintln("maprot" + temparr.size + ":" + element);
			temparr[temparr.size] = element;
		}
	}

	// Spawn entity to hold the array
	x = spawn("script_origin",(0,0,0));

	x.maps = [];
	lastexec = undefined;
	lastjeep = undefined;
	lasttank = undefined;
	lastgt = level.awe_gametype;
	for(i=0;i<temparr.size;)
	{
		switch(temparr[i])
		{
			case "allow_jeeps":
				if(isdefined(temparr[i+1]))
					lastjeep = temparr[i+1];
				i += 2;
				break;

			case "allow_tanks":
				if(isdefined(temparr[i+1]))
					lasttank = temparr[i+1];
				i += 2;
				break;
	
			case "exec":
				if(isdefined(temparr[i+1]))
					lastexec = temparr[i+1];
				i += 2;
				break;

			case "gametype":
				if(isdefined(temparr[i+1]))
					lastgt = temparr[i+1];
				i += 2;
				break;

			case "map":
				if(isdefined(temparr[i+1]))
				{
					x.maps[x.maps.size]["exec"]		= lastexec;
					x.maps[x.maps.size-1]["jeep"]	= lastjeep;
					x.maps[x.maps.size-1]["tank"]	= lasttank;
					x.maps[x.maps.size-1]["gametype"]	= lastgt;
					x.maps[x.maps.size-1]["map"]	= temparr[i+1];
				}
				// Only need to save this for random rotations
				if(!random)
				{
					lastexec = undefined;
					lastjeep = undefined;
					lasttank = undefined;
					lastgt = undefined;
				}

				i += 2;
				break;

			// If code get here, then the maprotation is corrupt so we have to fix it
			default:
				iprintlnbold("ERROR IN MAPROTATION!!! Will try to fix.");
	
				if(isGametype(temparr[i]))
					lastgt = temparr[i];
				else if(isConfig(temparr[i]))
					lastexec = temparr[i];
				else
				{
					x.maps[x.maps.size]["exec"]		= lastexec;
					x.maps[x.maps.size-1]["jeep"]	= lastjeep;
					x.maps[x.maps.size-1]["tank"]	= lasttank;
					x.maps[x.maps.size-1]["gametype"]	= lastgt;
					x.maps[x.maps.size-1]["map"]	= temparr[i];
	
					// Only need to save this for random rotations
					if(!random)
					{
						lastexec = undefined;
						lastjeep = undefined;
						lasttank = undefined;
						lastgt = undefined;
					}
				}
					

				i += 1;
				break;
		}
		if(number && x.maps.size >= number)
			break;
	}

	if(random)
	{
		// Shuffle the array 20 times
		for(k = 0; k < 20; k++)
		{
			for(i = 0; i < x.maps.size; i++)
			{
				j = randomInt(x.maps.size);
				element = x.maps[i];
				x.maps[i] = x.maps[j];
				x.maps[j] = element;
			}
		}
	}

	return x;
}
isGametype(gt)
{
	switch(gt)
	{
		case "dm":
		case "tdm":
		case "sd":
		case "re":
		case "hq":
		case "bel":
		case "bas":
		case "dom":
		case "ctf":
		case "ter":
		case "actf":
		case "lts":
		case "cnq":
		case "rsd":
		case "tdom":
		case "ad":
		case "htf":
		case "asn":

		case "mc_dm":
		case "mc_tdm":
		case "mc_sd":
		case "mc_re":
		case "mc_hq":
		case "mc_bel":
		case "mc_bas":
		case "mc_dom":
		case "mc_ctf":
		case "mc_ter":
		case "mc_actf":
		case "mc_lts":
		case "mc_cnq":
		case "mc_rsd":
		case "mc_tdom":
		case "mc_ad":
		case "mc_htf":
		case "mc_asn":

			return true;

		default:
			return false;
	}
}
//------------------------
//Strips
//------------------------
// Strip blanks at start and end of string
strip(s)
{
	if(s=="")
		return "";

	s2="";
	s3="";

	i=0;
	while(i<s.size && s[i]==" ")
		i++;

	// String is just blanks?
	if(i==s.size)
		return "";
	
	for(;i<s.size;i++)
	{
		s2 += s[i];
	}

	i=s2.size-1;
	while(s2[i]==" " && i>0)
		i--;

	for(j=0;j<=i;j++)
	{
		s3 += s2[j];
	}
		
	return s3;
}
//----------------------------
//isConfig dependency for Map Vote
//-----------------------------
isConfig(cfg)
{
	temparr = explode(cfg,".");
	if(temparr.size == 2 && temparr[1] == "cfg")
		return true;
	else
		return false;
}
explode(s,delimiter)
{
	j=0;
	temparr[j] = "";	

	for(i=0;i<s.size;i++)
	{
		if(s[i]==delimiter)
		{
			j++;
			temparr[j] = "";
		}
		else
			temparr[j] += s[i];
	}
	return temparr;
}
//--------------------------------
//Spawn Spectator
//--------------------------------
spawnSpectator(origin, angles)
{
	self notify("spawned");
	self notify("killed");
	self notify("end_respawn");

	resettimeout();

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;

	if(self.pers["team"] == "spectator")
		self.statusicon = "";
	
	if(isDefined(origin) && isDefined(angles))
		self spawn(origin, angles);
	else
	{
         	spawnpointname = level.awe_spawnspectatorname;
		spawnpoints = getentarray(spawnpointname, "classname");
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
	
		if(isDefined(spawnpoint))
			self spawn(spawnpoint.origin, spawnpoint.angles);
		else
			maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	}
}