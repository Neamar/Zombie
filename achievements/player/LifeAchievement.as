package achievements.player
{
	
	/**
	 * Improve player life
	 *
	 * @author Neamar
	 */
	public final class LifeAchievement extends PlayerAchievement
	{
		public override function apply():void
		{
			player.maxHealthPoints = value;
		}
	}

}