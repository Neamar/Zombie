package achievements.weapon
{
	
	/**
	 * Improve the capacity of a magazine for a given weapon
	 *
	 * @author Neamar
	 */
	public final class CapacityAchievement extends WeaponAchievement
	{
		public override function apply():void
		{
			weapon.magazineCapacity = value;
		}
	}

}