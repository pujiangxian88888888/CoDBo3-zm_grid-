#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_power;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_melee_weapon;
#using scripts\zm\_zm_perks;

#using scripts\zm\_zm_powerup_nuke;

#using scripts\shared\ai\systems\gib;

#insert scripts\zm\_zm_perk_dying_wish.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "material", DYING_WISH_SHADER ); 

#namespace dying_wish;

REGISTER_SYSTEM( "dying_wish", &__init__, undefined )


//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	enable_custom_perk_for_level();
}

function enable_custom_perk_for_level()
{	
	zm_perks::register_perk_basic_info( DYING_WISH_SPECIALTY, "customperk", DYING_WISH_COST, "Hold ^3[{+activate}]^7 for Dying Wish [Cost: &&1] \n Effect: " + PERK_DYING_WISH_DSEC, GetWeapon( DYING_WISH_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( DYING_WISH_SPECIALTY, &custom_perk_precache );
	zm_perks::register_perk_clientfields( DYING_WISH_SPECIALTY, &custom_perk_register_clientfield, &custom_perk_set_clientfield );
	zm_perks::register_perk_machine( DYING_WISH_SPECIALTY, &custom_perk_machine_setup );
	zm_perks::register_perk_threads( DYING_WISH_SPECIALTY, &give_custom_perk, &take_custom_perk );
	zm_perks::register_perk_host_migration_params( DYING_WISH_SPECIALTY, PERK_DYING_WISH_NAME, DYING_WISH_MACHINE_LIGHT_FX );

	//register double buy
	level thread register_db_perk(DYING_WISH_SPECIALTY, PERK_DYING_WISH_DSEC_DB, DYING_WISH_DB_COST, PERK_DYING_WISH_NAME);
	
	if ( !isdefined( level.reap_custom_perk_array ) )
		level.reap_custom_perk_array = [];	
	level.reap_custom_perk_array[DYING_WISH_SPECIALTY] = true;	

	//callbacks here
	level thread dying_wish_overides();
	zm_spawner::register_zombie_damage_callback( &dying_wish_zombie_damage_response );
}

function custom_perk_precache()
{
	// PRECACHE SHIT HERE
	level.machine_assets[DYING_WISH_SPECIALTY] = SpawnStruct();
	level.machine_assets[DYING_WISH_SPECIALTY].weapon = GetWeapon( DYING_WISH_BOTTLE_WEAPON );
	level.machine_assets[DYING_WISH_SPECIALTY].off_model = DYING_WISH_MACHINE_DISABLED_MODEL;
	level.machine_assets[DYING_WISH_SPECIALTY].on_model = DYING_WISH_MACHINE_ACTIVE_MODEL;	
	
	//add fx here if neccicary
	
}

function custom_perk_register_clientfield()
{
	clientfield::register( "clientuimodel", PERK_CLIENTFIELD_DYING_WISH, VERSION_SHIP, 2, "int" );
}

function custom_perk_set_clientfield( state )
{
	self clientfield::set_player_uimodel( PERK_CLIENTFIELD_DYING_WISH, state );
}

function register_db_perk(perk, desc, cost, name)
{
	if ( !isdefined( level.db_perks_registered ) )
		level.db_perks_registered = [];	
	db_perk = SpawnStruct();
	db_perk.desc = desc;
	db_perk.cost = cost;			
	db_perk.name = name;			
	level.db_perks_registered[ perk ] = db_perk;
}

function custom_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = "";
	use_trigger.script_string = DYING_WISH_SPECIALTY;
	use_trigger.script_label = "";
	use_trigger.target = PERK_DYING_WISH_NAME;
	perk_machine.script_string = DYING_WISH_SPECIALTY;
	perk_machine.targetname = PERK_DYING_WISH_NAME;
	if(IsDefined(bump_trigger))
	{
		bump_trigger.script_string = DYING_WISH_SPECIALTY;
	}
}

function give_custom_perk()
{
	if(!isdefined(self.disabled_perks))
		self.disabled_perks = [];
	self.disabled_perks[ DYING_WISH_SPECIALTY ] = true;
	if(!isdefined(self.player_cz_perks))
		self.player_cz_perks = [];
	if(!isdefined(self.player_cz_perks_db))
		self.player_cz_perks_db = [];
	self.player_cz_perks[DYING_WISH_SPECIALTY] = true;
}

function take_custom_perk( b_pause, str_perk, str_result )
{
	self.disabled_perks[ DYING_WISH_SPECIALTY ] = false;
	self.player_cz_perks[DYING_WISH_SPECIALTY] = undefined;
	self.player_cz_perks_db[DYING_WISH_SPECIALTY] = undefined;
}


function reap_create_hud_icon(aligX, aligY, horzAlin, vertAlin, x, y, alp, icon, icon_x, icon_y, color)
{
	hud = undefined;
	if(self == level)
		hud = newHudElem();
	else
		hud = NewClientHudElem( self );
	hud.alignX = aligX; 
	hud.alignY = aligY;
	hud.horzAlign = horzAlin; 
	hud.vertAlign = vertAlin;
	hud.x = x;
	hud.y = y;
	hud.alpha = alp;
	hud.color = color;
	hud SetShader( icon, icon_x, icon_y );
	
	return hud;
}

function HasPerkNew(perk)
{
	if(!isdefined(self.player_cz_perks))
		return false;
	if(isdefined(self.player_cz_perks) && isdefined(self.player_cz_perks[perk]))
		return true;
	return false;
}

function HasDbPerkNew(perk)
{
	if(!isdefined(self.player_cz_perks_db))
		return false;
	if(isdefined(self.player_cz_perks_db) && isdefined(self.player_cz_perks_db[perk]))
		return true;
	return false;
}


function dying_wish_overides()
{
	level waittill("intro_hud_done");
	level.prevent_player_damage		= &player_prevent_damage;
	level.callbackPlayerDamage 		= &Callback_PlayerDamage;
}

function Callback_PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, vDamageOrigin, psOffsetTime, boneIndex, vSurfaceNormal )
{
	if(isdefined(level.w_widows_wine_grenade) && weapon != level.w_widows_wine_grenade || !isdefined(level.w_widows_wine_grenade))	//widow nades can trigger dying wish
	{
		can_dyingwish = true;
		if(self HasPerkNew("specialty_slider"))
		{
			
			if(sMeansOfDeath == "MOD_ELECTOCUTED" ||
			sMeansOfDeath == "MOD_EXPLOSIVE" ||
			sMeansOfDeath == "MOD_EXPLOSIVE_SPLASH" ||
			sMeansOfDeath == "MOD_FALLING" ||
			sMeansOfDeath == "MOD_GRENADE" ||
			sMeansOfDeath == "MOD_PROJECTILE" ||
			sMeansOfDeath == "MOD_PROJECTILE_SPLASH" ||
			sMeansOfDeath == "MOD_GRENADE_SPLASH" ||
			sMeansOfDeath == "MOD_SUICIDE" ||
			sMeansOfDeath == "MOD_IMPACT" )
				can_dyingwish = false;
		}
		if(self HasPerkNew(DYING_WISH_SPECIALTY) && !isdefined(self.dying_wish_charge) && isdefined(iDamage) && self.health <= iDamage && can_dyingwish)
		{
			self.health = 1;
			self thread dying_wish_activate();
			return;
		}
	}
	
	startedInLastStand = 0;
	if ( isPlayer(self)  )
		startedInLastStand = self laststand::player_is_in_laststand();
	
	if ( isdefined( eAttacker ) && isPlayer( eAttacker ) && (eAttacker.sessionteam == self.sessionteam) && !eAttacker HasPerk( "specialty_playeriszombie" ) && !IS_TRUE( self.is_zombie ) )
	{
		self zm::process_friendly_fire_callbacks( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime, boneIndex );
		if ( self != eAttacker )
			return;
		else if ( sMeansOfDeath != "MOD_GRENADE_SPLASH"
				&& sMeansOfDeath != "MOD_GRENADE"
				&& sMeansOfDeath != "MOD_EXPLOSIVE"
				&& sMeansOfDeath != "MOD_PROJECTILE"
				&& sMeansOfDeath != "MOD_PROJECTILE_SPLASH"
				&& sMeansOfDeath != "MOD_BURNED"
				&& sMeansOfDeath != "MOD_SUICIDE" )
			return;
	}

	if( IsDefined( self.overridePlayerDamage ) )
		iDamage = self [[self.overridePlayerDamage]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime );
	else if( IsDefined( level.overridePlayerDamage ) )
		iDamage = self [[level.overridePlayerDamage]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime );

	Assert(IsDefined(iDamage), "You must return a value from a damage override function.");

	if (IS_TRUE(self.magic_bullet_shield))
	{
		maxHealth = self.maxHealth;
		self.health += iDamage;
		self.maxHealth = maxHealth;
	}
	if( isdefined( self.divetoprone ) && self.divetoprone == 1 )
	{
		if( sMeansOfDeath == "MOD_GRENADE_SPLASH" )
		{
			dist = Distance2d(vPoint, self.origin);
			if( dist > 32 )
			{
				dot_product = vectordot( AnglesToForward( self.angles ), vDir ); 
				if( dot_product > 0 )
				{
					iDamage = int( iDamage * 0.5 ); // halves damage
				}
			}
		}
	}
	if ( isdefined( level.prevent_player_damage ) )
		if ( self [[ level.prevent_player_damage ]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime ) )
			return;	

	iDFlags = iDFlags | level.iDFLAGS_NO_KNOCKBACK;
	
	if( iDamage > 0 && sHitLoc == "riotshield" )
		sHitLoc = "torso_upper";

	wasDowned = 0;
	if ( isPlayer(self))
		wasDowned = !startedInLastStand && self laststand::player_is_in_laststand();

	self zm::finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, vDamageOrigin, psOffsetTime, boneIndex, vSurfaceNormal );
}

function player_prevent_damage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if( isdefined( self.dying_wish_active ) && self.dying_wish_active )
		return true;
	if( !isdefined( eInflictor ) || !isdefined( eAttacker ) )
		return false;
	if ( eInflictor == self || eAttacker == self )
		return false;

	if ( isdefined( eInflictor ) && isdefined( eInflictor.team ) )
	{
		if (!IS_TRUE(eInflictor.damage_own_team))
			if ( eInflictor.team == self.team )
			{
				return true;
			}
	}

	return false;
}

function dying_wish_activate()
{
	self.dying_wish_active = true;
	visionset_mgr::activate( "overlay", DYING_WISH_VISION, self, 2 );
	visionset_mgr::activate( "visionset", DYING_WISH_VISION, self, 2 );
	
	if(isdefined(self.dying_wish_bar))
		self.dying_wish_bar Destroy();
	if(isdefined(self.dying_wish_bar_back))
		self.dying_wish_bar_back Destroy();
	
	time = 0;
	time_to_kill = DYING_WISH_ACTIVE_TIME;
	self.dying_wish_bar_back = self reap_create_hud_icon("right", "bottom", "right", "bottom", -180, -51, .2, "white", 100, 8, (1,1,1));
	self.dying_wish_bar = self reap_create_hud_icon("right", "bottom", "right", "bottom", -180, -51, .5, "white", 5, 8, (.3,.3,1));
	while(time < time_to_kill && self HasPerkNew(DYING_WISH_SPECIALTY))
	{
		time +=.1;
		self.dying_wish_bar scaleOverTime(.1, 100-int(time/time_to_kill*100), 8);
		wait .1;
	}
	if(isdefined(self.dying_wish_bar))
		self.dying_wish_bar Destroy();
	if(isdefined(self.dying_wish_bar_back))
		self.dying_wish_bar_back Destroy();

	visionset_mgr::deactivate( "overlay", DYING_WISH_VISION, self );
	visionset_mgr::deactivate( "visionset", DYING_WISH_VISION, self );
	self.dying_wish_active = undefined;
	self thread dying_wish_cooldown();
	if(self HasDbPerkNew(DYING_WISH_SPECIALTY))
		self.health = self.maxHealth;
	else
		self.health = 1;
}

function dying_wish_cooldown()
{
	wait .1;
	if(isdefined(self.dying_wish_bar))
		self.dying_wish_bar Destroy();
	if(isdefined(self.dying_wish_bar_back))
		self.dying_wish_bar_back Destroy();
	self.dying_wish_charge = 0;
	max = DYING_WISH_COOLDOWN;
	self.dying_wish_bar_back = self reap_create_hud_icon("right", "bottom", "right", "bottom", -180, -51, .2, "white", 100, 8, (1,1,1));
	self.dying_wish_bar = self reap_create_hud_icon("right", "bottom", "right", "bottom", -180, -51, .5, "white", 5, 8, (.3,.3,1));
	while(self.dying_wish_charge < max && self HasPerkNew(DYING_WISH_SPECIALTY))
	{
		self.dying_wish_charge +=1;
		self.dying_wish_bar scaleOverTime(1, int(self.dying_wish_charge/max*100), 8);
		wait 1;
	}
	if(isdefined(self.dying_wish_bar))
		self.dying_wish_bar Destroy();
	if(isdefined(self.dying_wish_bar_back))
		self.dying_wish_bar_back Destroy();
	self.dying_wish_charge = undefined;
}

function dying_wish_zombie_damage_response( str_mod, str_hit_location, v_hit_origin, e_player, n_amount, w_weapon, direction_vec, tagName, modelName, partName, dFlags, inflictor, chargeLevel )
{
	if ( IS_EQUAL(str_mod,"MOD_MELEE") && IsDefined(e_player) && IsPlayer(e_player) && e_player HasPerkNew(DYING_WISH_SPECIALTY) && isdefined(e_player.dying_wish_activee) )
	{
		self DoDamage( self.health+666, self.origin, e_player, self, "MOD_MELEE" );
	}
	return false;
}
