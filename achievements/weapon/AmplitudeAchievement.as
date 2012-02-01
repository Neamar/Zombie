package achievements.weapon
{
	import weapon.Shotgun;
	
	/**
	 * Improve the amplitude of the shotgun.
	 *
	 * @author Neamar
	 */
	public final class AmplitudeAchievement extends WeaponAchievement
	{
		public override function apply():void
		{
			(weapon as Shotgun).halfAmplitude = value;
		}
	}

}