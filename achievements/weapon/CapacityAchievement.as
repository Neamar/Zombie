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
			var deltaCapacity:int = value - weapon.magazineCapacity;
			
			weapon.magazineCapacity = value;
			weapon.ammoInCurrentMagazine += deltaCapacity;
		}
	}

}