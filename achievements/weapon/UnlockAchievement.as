package achievements.weapon
{
	import achievements.Achievement;
	import entity.Player;
	import flash.events.Event;
	
	/**
	 * Unlock a new weapon by adding it to the player arsenal
	 *
	 * @author Neamar
	 */
	public final class UnlockAchievement extends Achievement
	{
		protected var weapon:Class;
		
		public override function setParams(params:Array):void
		{
			weapon = params[0];
		}
		
		public override function apply():void
		{
			player.availableWeapons.push(new weapon(level, player));
			player.currentWeapon = player.availableWeapons[player.availableWeapons.length - 1];
			
			//Update the HUD
			player.dispatchEvent(new Event(Player.WEAPON_CHANGED));
		}
	}

}