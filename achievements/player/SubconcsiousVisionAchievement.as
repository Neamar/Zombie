package achievements.player 
{
	/**
	 * Improve the subconscious vision of the player
	 * 
	 * @author Neamar
	 */
	public final class SubconcsiousVisionAchievement extends PlayerAchievement
	{
		public override function apply():void
		{
			player.subconsciousVision = value / 100;
		}
	}

}