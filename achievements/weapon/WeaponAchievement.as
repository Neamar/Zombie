package achievements.weapon
{
	import achievements.Achievement;
	import weapon.Weapon;
	
	/**
	 * Base class for all weapon-based achievements
	 *
	 * @author Neamar
	 */
	public class WeaponAchievement extends Achievement
	{
		/**
		 * The weapon the class applies on
		 */
		protected var weapon:Weapon;
		
		/**
		 * The new value to use
		 */
		protected var value:int;
		
		/**
		 * Get the player's weapon from the class
		 * @param	weapon
		 * @return null if weapon does not exist in player arsenal
		 */
		protected function getWeaponByClass(weapon:Class):Weapon
		{
			for each (var w:weapon.Weapon in player.availableWeapons)
			{
				if (w is weapon)
					return w;
			}
			
			return null;
		}
		
		/**
		 * All weapons achievement uses the same structure : name of the weapon, new value.
		 * @param	params
		 */
		public override function setParams(params:Array):void
		{
			weapon = getWeaponByClass(params[0]);
			value = params[1];
		}
	}

}