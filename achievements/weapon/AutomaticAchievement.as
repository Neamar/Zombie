package achievements.weapon
{
	
	/**
	 * Automatically reload magazine of a given weapon
	 *
	 * @author Neamar
	 */
	public final class AutomaticAchievement extends WeaponAchievement
	{
		public override function apply():void
		{
			weapon.automaticReload = true;
		}
	}

}