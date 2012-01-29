package achievements.weapon 
{
	/**
	 * Improve the reload time of a given weapon
	 * 
	 * @author Neamar
	 */
	public final class ReloadAchievement extends WeaponAchievement 
	{
		public override function apply():void
		{
			weapon.reloadTime = value;
		}
	}

}