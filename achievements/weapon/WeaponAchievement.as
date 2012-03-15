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
		protected var weaponClass:Class
		/**
		 * The new value to use
		 */
		protected var value:int;
		
		/**
		 * Find the weapon in the list
		 */
		public function get weapon():Weapon
		{
			for each (var w:weapon.Weapon in player.availableWeapons)
			{
				if (w is weaponClass)
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
			weaponClass = params[0];
			value = params[1];
		}
	}

}