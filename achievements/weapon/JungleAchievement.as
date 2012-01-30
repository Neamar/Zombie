package achievements.weapon
{
	import weapon.JungleStyleWeapon;
	
	/**
	 * Improve the capacity of a magazine for a given weapon
	 *
	 * @author Neamar
	 */
	public final class JungleAchievement extends WeaponAchievement
	{
		public override function apply():void
		{
			(weapon as JungleStyleWeapon).isJungleStyle = true;
		}
	}

}