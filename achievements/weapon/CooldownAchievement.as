package achievements.weapon 
{
	import weapon.Handgun;
	
	/**
	 * Improve the coolodown for a given weapon
	 * 
	 * @author Neamar
	 */
	public class CooldownAchievement extends WeaponAchievement
	{
		public override function apply():void
		{
			weapon.cooldown = value;
		}
	}

}