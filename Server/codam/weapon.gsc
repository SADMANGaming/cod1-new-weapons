
///////////////////////////////////////////////////////////////////////////////
// PROJECT: CoDaM/GameTypes
// PURPOSE: Game log functions
// UPDATE HISTORY
//	12/1/2003	-- Hammer: started
///////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////
// PROJECT: NW_MP ; NEW WEAPONS MP
//  7/6/2024  :: Sadman

//
///////////////////////////////////////////////////////////////////////////////
main( phase, register )
{
	codam\utils::debug( 0, "======== weapon/main:: |", phase, "|",
								register, "|" );

	switch ( phase )
	{
	  case "init":		_init( register );	break;
	  case "load":		_load();		break;
	  case "start":	  	_start();		break;
	}

	return;
}

//
_init( register )
{
	codam\utils::debug( 0, "======== weapon/_init:: |", register, "|" );

	[[ register ]](  "precacheWeapons", ::precacheWeapons );
	[[ register ]](  "isWeaponAllowed", ::isWeaponAllowed );
	[[ register ]](     "assignWeapon", ::assignWeapon );
	[[ register ]](   "weaponClipSize", ::weaponClipSize );
	[[ register ]](    "weaponMaxAmmo", ::weaponMaxAmmo );
	[[ register ]]( "assignWeaponSlot", ::assignWeaponSlot );
	[[ register ]](  "allowDropWeapon", ::allowDropWeapon );
	[[ register ]](     "grenadeLimit", ::grenadeLimit );
	[[ register ]](       "givePistol", ::givePistol );
	[[ register ]](      "giveGrenade", ::giveGrenade );

	level._weap_unavail = &"^3*** ^1Weapon Not Available!^3 ***";
	level._weap_disabled = &"^3*** ^1Weapon Has Been Disabled!^3 ***";

	return;
}

//
_load()
{
	codam\utils::debug( 0, "======== weapon/_load" );

	if( !isdefined( game[ "gamestarted" ] ) )
	{
		precacheString( level._weap_unavail );
		precacheString( level._weap_disabled );
		precacheModel( "xmodel/weapon_fg42" );
		precacheModel( "xmodel/viewmodel_fg42" );
		precacheModel( "xmodel/weapon_panzerfaust_ammo" );
		precacheModel( "xmodel/weapon_panzerfaust_rocket" );
		precacheModel( "xmodel/viewmodel_panzerfaust" );

		[[ level.gtd_call ]]( "precacheWeapons" );
	}

	[[ level.gtd_call ]]( "initWeapons" );

	// Retrieve weapon list
	_initWeapons();
	return;
}

//
_start()
{
	codam\utils::debug( 0, "======== weapon/_start" );

	[[ level.gtd_call ]]( "restrictPlacedWeapons" );
	thread [[ level.gtd_call ]]( "updateWeapons" );
	return;
}

///////////////////////////////////////////////////////////////////////////////
//

precacheWeapons( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	// Special weapons
	precacheItem( "fg42_mp" );
	precacheItem( "panzerfaust_mp" );

	// Nades
	precacheItem("fraggrenade_mp");
	precacheItem("stielhandgranate_mp");
	precacheItem("rgd-33russianfrag_mp");
	precacheItem("mk1britishfrag_mp");

	// Pistols
	precacheItem("colt_mp");
	precacheItem("luger_mp");
	precacheItem("tt33_mp");
	precacheItem("webley_mp");


	precacheItem("m1carbine_mp");
    precacheItem("gewehr43_mp");
	precacheItem("m1garand_mp");
	precacheItem("enfield_mp");
	precacheItem("mosin_nagant_mp");
	precacheItem("kar98k_mp");
	precacheItem("svt40_mp");


	precacheItem("thompson_mp");
	precacheItem("sten_mp");
	precacheItem("ppsh_mp");
	precacheItem("mp40_mp");
	precacheItem("stens_mp");
	precacheItem("ppsh43_mp");



	precacheItem("bar_mp");
	precacheItem("bren_mp");
	precacheItem("mp44_mp");

	precacheItem("springfield_mp");
	precacheItem("mosin_nagant_sniper_mp");
	precacheItem("kar98k_sniper_mp");
	precacheItem("enfieldscoped_mp");



	return;
}

//
///////////////////////////////////////////////////////////////////////////////
_initWeapons( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	thread _initWeaponDrop();
	thread _initWeaponAmmo();
	thread _initWeaponAssign();
	thread _initGrenadeAssign();
	thread _initWeaponMaps();
	return;
}

//
_initWeaponDrop()
{
	level.noWeaponDrop = [];

	noweapdrop = codam\utils::getVar( "scr", "noweapondrop", "string",
								1|2, "" );

	resettimeout();

	weapList = codam\utils::splitArray( noweapdrop, " ", "", true );
	for ( i = 0; i < weapList.size; i++ )
	{
		weapClass = weapList[ i ];

		level.noWeaponDrop[ weapClass ] = true;

		codam\utils::debug( 91, "noWeaponDrop = |", weapClass, "|" );
	}

	return;
}

//
_initWeaponAmmo()
{
	level.weaponAmmo = [];

	defWeaponAmmo = "m1carbine,15,400 m1garand,8,240 thompson,30,360 bar,20,300 springfield,5,200 enfield,10,160 gewehr43,10,200 svt40.10,200 stens,32,320 enfieldscoped,10,200 ppsh43,30,210 tt33,7,56 webley,6,48 sten,32,320 bren,30,300 mosin_nagant,5,150 ppsh,71,355 mosin_nagant_sniper,5,150 kar98k,5,125 mp40,32,320 mp44,30,240 kar98k_sniper,5,150 colt,7,56 luger,8,64 fraggrenade,1,3 mk1britishfrag,1,3 rgd-33russianfrag,1,3 stielhandgranate,1,3 fg42,20,320 panzerfaust,1,1";
	weaponAmmo = codam\utils::getVar( "scr", "weapon_ammo", "string",
							1|2, defWeaponAmmo );

	resettimeout();

	weapList = codam\utils::splitArray( weaponAmmo, " ,", "", true );
	for ( i = 0; i < weapList.size; i++ )
	{
		weapEntry = weapList[ i ][ "fields" ];
		weapName  = weapEntry[ 0 ];
		clipSize  = weapEntry[ 1 ];
		maxAmmo   = weapEntry[ 2 ];

		_tmpa = [];
		_tmpa[ "clip" ] = (int) clipSize;
		_tmpa[ "max" ] = (int) maxAmmo;
		level.weaponAmmo[ weapName + "_mp" ] = _tmpa;
		codam\utils::debug( 91, "weaponAmmo = |", weapName, "|",
						clipSize, "|", maxAmmo, "|" );
	}

	return;
}

//
_initWeaponAssign()
{
	level.weaponClass = [];
	level.teamWeaponByType = [];

	defWeaponAssign = "default=100%,american=m1carbine,british=sten,russian=ppsh,german=mp40 rifle=100%,american=m1garand,british=enfield,russian=mosin_nagant,german=kar98k smg=100%,american=thompson,british=sten,russian=ppsh,german=mp40 smgxd=100%,british=stens,russian=ppsh43 mg=100%,american=bar,british=bren,german=mp44 rifle=100%,german=gewehr43,russian=svt40 sniper=100%,american=springfield,british=springfield,russian=mosin_nagant_sniper,german=kar98k_sniper sniperxd=100%,british=enfieldscoped pistol=100%,american=colt,british=webley,russian=tt33,german=luger grenade=100%,american=fraggrenade,british=mk1britishfrag,russian=rgd-33russianfrag,german=stielhandgranate";

	weaponAssign = codam\utils::getVar( "scr", "weapon_assign", "string",
							1|2, defWeaponAssign );

	resettimeout();

	weapList = codam\utils::splitArray( weaponAssign, " ,=", "", true );
	for ( i = 0; i < weapList.size; i++ )
	{
		weapEntry = weapList[ i ][ "fields" ];  // 2nd index

		// The first element should always be the class
		weapClass = weapEntry[ 0 ][ "fields" ][ 0 ];
		weapMax   = weapEntry[ 0 ][ "fields" ][ 1 ];
		if ( weapMax[ weapMax.size - 1 ] == "%" )
		{
			// Adjust entered ratio for later ...

			s = "";
			for ( x = 0; x < weapMax.size - 1; x++ )
				s += weapMax[ x ];
			weapMax = (float) s;
			if ( weapMax > 100 )
				weapMax = 100;
			if ( weapMax < 0 )
				weapMax = 0;
			weapMax /= -100.0;	// YES, negative!
		}
		else
		{
			weapMax = (int) weapMax;
			if ( weapMax < 0 )
				weapMax = 0;
		}

		for ( j = 1; j < weapEntry.size; j++ )
		{
			entry = weapEntry[ j ][ "fields" ]; // 3rd index
			team = entry[ 0 ];
			weap = entry[ 1 ];

			switch ( weap )
			{
			  case "kar98k_sniper":
				_cvar = "kar98ksniper";		break;
			  case "mosin_nagant":
				_cvar = "nagant";		break;
			  case "mosin_nagant_sniper":
				_cvar = "nagantsniper";		break;
			  default:
				_cvar = weap;			break;
			}

			// If weapon has been globally restricted, remove it!
			if ( !codam\utils::getVar( "scr", "allow_" + _cvar,
							"bool", 0, true ) )
				continue;

			weap += "_mp";

			level.weaponClass[ weap ] = weapClass;

			_tmpa = [];
			_tmpa[ "weapon" ] = weap;
			_tmpa[ "max" ] = weapMax;
			level.teamWeaponByType[ team ][ weapClass ] = _tmpa;
			codam\utils::debug( 91, "weaponClass = |",
						weapClass, "|", team, "|",
						weap, "|", weapMax, "|" );
		}
	}

	return;
}

//
_initGrenadeAssign()
{
	level.nadeAssign = [];

	defNadeAssign = "default=3 rifle=3 smg=2 mg=2 sniper=1";
	nadeAssign = codam\utils::getVar( "scr", "grenade_assign", "string",
							1|2, defNadeAssign );

	resettimeout();

	nadeList = codam\utils::splitArray( nadeAssign, " =", "", true );
	for ( i = 0; i < nadeList.size; i++ )
	{
		nadeEntry = nadeList[ i ][ "fields" ];
		class  = nadeEntry[ 0 ];
		limit  = nadeEntry[ 1 ];

		level.nadeAssign[ class ] = (int) limit;
		codam\utils::debug( 91, "nadeAssign = |", class, "|",
								limit, "|" );
	}

	return;
}

//
_initWeaponMaps()
{
	level.weaponMap = [];

	defWeaponMap = "";
	weaponMap = codam\utils::getVar( "scr", "weapon_map", "string",
							1|2, defWeaponMap );

	resettimeout();

	mapList = codam\utils::splitArray( weaponMap, " =", "", true );
	for ( i = 0; i < mapList.size; i++ )
	{
		mapEntry = mapList[ i ][ "fields" ];
		weap   = mapEntry[ 0 ] + "_mp";
		alias  = mapEntry[ 1 ] + "_mp";

		level.weaponMap[ weap ] = alias;
		codam\utils::debug( 91, "weaponMap = |", weap, "|",
								alias, "|" );
	}

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
allowDropWeapon( weapon, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isdefined( weapon ) || ( weapon == "" ) )
		return ( false );

	class = level.weaponClass[ weapon ];
	if ( !isdefined( class ) )
		return ( true );

	return ( !isdefined( level.noWeaponDrop[ class ] ) );
}

//
///////////////////////////////////////////////////////////////////////////////
isWeaponAllowed( weapon, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isdefined( weapon ) || ( weapon == "" ) )
		return ( false );

	_x = isdefined( level.weaponClass[ weapon ] );
	if ( !_x )
		self thread [[ level.gtd_call ]]( "client_hud_announce",
							level._weap_disabled,
							320, 40, true );

	return ( _x );
}

//
///////////////////////////////////////////////////////////////////////////////
assignWeapon( weapon, useDefault, forceTeam, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) )
		return ( undefined );

	if ( isdefined( forceTeam ) && ( forceTeam != "" ) )
		_team = forceTeam;
	else
	{
		_team = self.pers[ "team" ];
		if ( !isdefined( _team ) )
			return ( undefined );
	}

	team = game[ _team ];

	codam\utils::debug( 90, "assignWeapon:: |", team, "|", weapon, "|",
					useDefault, "|", forceTeam, "|" );

	if ( !isdefined( team ) || ( team == "" ) ||
	     !isdefined( level.teamWeaponByType[ team ] ) )
		return ( undefined );

	// First determine the weapon's class ...
	if ( isdefined( weapon ) )
		weapClass = level.weaponClass[ weapon ];
	else
		weapClass = undefined;

	if ( !isdefined( weapClass ) )
	{
		if ( !isdefined( useDefault ) )
			return ( undefined );

		weapClass = "default";
	}

	// If the weapon does not belong to the team, use team default
	_weap = level.teamWeaponByType[ team ][ weapClass ];
	if ( !isdefined( _weap ) )
		_weap = level.teamWeaponByType[ team ][ "default" ];

	weapon = _weap[ "weapon" ];
	weapMax = _weap[ "max" ];

	// If the weapon is limited, determine how many are being used.
	// Simple algorithm, find all players in the team and count
	// the weapons in use.
	teamCount = 1;	// Count me in!
	weapCount = 0;
	players = getentarray( "player", "classname" );
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		if ( player == self )
			continue;	// My weapon has already been counted!

		pteam = player.sessionteam;
		if ( !isdefined( pteam ) || ( pteam == "none" ) )
			pteam = player.pers[ "team" ];

		if ( isdefined( pteam ) && ( pteam == _team ) )
		{
			teamCount++;

			if ( isdefined( player.pers[ "weapon" ] ) &&
			     ( player.pers[ "weapon" ] == weapon ) )
				weapCount++;
		}
	}

	codam\utils::debug( 90, "assignWeapon = |", team, "|", teamCount, "|",
				weapon, "|", weapMax, "|", weapCount, "|" );

	// A negative weapMax indicates ratio!!!
	if ( weapMax < 0 )
	{
		// Limiting factor entered as a ratio ... adjust max
		// based on existing number of players in team.
		weapMax = 0 - ( weapMax * ( (float) teamCount ) );
		if ( weapMax < 1 )
			weapMax = 1;	// Always allow at least one
		weapMax = (int) weapMax;
	}

	if ( weapCount >= weapMax )
	{
		self thread [[ level.gtd_call ]]( "client_hud_announce",
							level._weap_unavail,
							320, 40, true );
		return ( undefined );
	}

	return ( weapon );
}

//
///////////////////////////////////////////////////////////////////////////////
weaponClipSize( weapon, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	return ( _weaponAmmo( weapon, "clip" ) );
}

//
weaponMaxAmmo( weapon, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	return ( _weaponAmmo( weapon, "ammo" ) );
}

//
_weaponAmmo( weapon, type )
{
	codam\utils::debug( 90, "_weaponAmmo:: |", weapon, "|", type, "|" );

	if ( !isdefined( weapon ) || ( weapon == "" ) ||
	     !isdefined( type ) || ( type == "" ) )
		return ( 999 );

	_weaponAmmo = level.weaponAmmo[ weapon ];
	if ( !isdefined( _weaponAmmo ) )
		return ( 999 );

	switch ( type )
	{
	  case "clip":	_size = _weaponAmmo[ "clip" ]; break;
	  case "ammo":	_size = _weaponAmmo[ "max" ]; break;
	  default:	_size = 999; break;
	}

	codam\utils::debug( 91, "_weaponAmmo = |", weapon, "|", _size, "|" );
	return ( _size );
}

//
///////////////////////////////////////////////////////////////////////////////
assignWeaponSlot( slot, weapon, limit, noMap, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 90, "assignWeaponSlot:: |", slot, "|", weapon, "|",
								limit, "|" );

	if ( !isdefined( slot ) || ( slot == "" ) ||
	     !isdefined( weapon ) || ( weapon == "" ) )
		return ( undefined );

	clip = _weaponAmmo( weapon, "clip" );
	ammo = _weaponAmmo( weapon, "ammo" );

	if ( isDefined( limit ) && ( ammo > limit ) )
		ammo = limit;

	if ( !isdefined( noMap ) &&
	     isdefined( level.weaponMap[ weapon ] ) )
		weapon = level.weaponMap[ weapon ];

	self setWeaponSlotWeapon( slot, weapon );
	self setWeaponSlotClipAmmo( slot, clip );
	self setWeaponSlotAmmo( slot, ammo );

	return ( weapon );
}

//
///////////////////////////////////////////////////////////////////////////////
grenadeLimit( weapon, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	codam\utils::debug( 90, "grenadeLimit:: |", weapon, "|" );

	if ( !isdefined( weapon ) )
		return ( 999 );

	class = level.weaponClass[ weapon ];
	if ( !isdefined( class ) )
		class = "default";

	limit = level.nadeAssign[ class ];
	if ( !isdefined( limit ) )
		return ( 999 );

	return ( limit );
}

//
///////////////////////////////////////////////////////////////////////////////
givePistol( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) )
		return;

	// Assign correct pistol based on team
	pistol = self [[ level.gtd_call ]]( "assignWeapon", "colt_mp" );
	if ( !isDefined( pistol ) )
		return;

	self [[ level.gtd_call ]]( "assignWeaponSlot", "pistol", pistol );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
giveGrenade( weapon, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) )
		return;

	// Assign correct grenade based on team
	grenade	= self [[ level.gtd_call ]]( "assignWeapon", "fraggrenade_mp" );
	if ( !isDefined( grenade ) )
		return;

	nadelimit = [[ level.gtd_call ]]( "grenadeLimit", weapon );
	self [[ level.gtd_call ]]( "assignWeaponSlot", "grenade", grenade,
								nadelimit );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
