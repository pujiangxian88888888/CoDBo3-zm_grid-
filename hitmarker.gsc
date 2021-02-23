/*
原作者：M.A.K.E C E N T S，

将以下内容添加到你的地图gsc脚本头文件
#using scripts\zm\hitmarker;

将以下内容添加到你的地图zone文件
scriptparsetree,scripts/zm/hitmarker.gsc
*/

#using scripts\shared\callbacks_shared;

#namespace hitmark;

function autoexec init()
{
	level.hitmarkersound = "mpl_hit_alert";
	level.hitmarkershader = "damage_feedback";
	level.mc_hitmarkers = true;
	callback::on_ai_spawned(&TrackDamage);
}

function playHitSound(alert)
{
	self endon ("disconnect");
	
	if (self.hitSoundTracker)
	{
		self.hitSoundTracker = false;
		
		self playlocalsound(alert);

		wait .05;	// waitframe
		self.hitSoundTracker = true;
	}
}	

function TrackDamage()
{
	while(IsAlive(self))
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type, tagName, modelName, partName, weapon, dFlags, inflictor, chargeLevel );
		if(IsPlayer(attacker))
		{
			attacker thread playHitSound ( level.hitmarkersound);
			attacker.hud_damagefeedback setShader( level.hitmarkershader, 24, 48 );
			attacker.hud_damagefeedback.alpha = 1;
			attacker.hud_damagefeedback fadeOverTime(1);
			attacker.hud_damagefeedback.alpha = 0;
		}
	}
}