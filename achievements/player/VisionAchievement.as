package achievements.player 
{
	/**
	 * Improve the subconscious vision of the player
	 * 
	 * @author Neamar
	 */
	public final class VisionAchievement extends PlayerAchievement
	{
		public override function apply():void
		{
			player.halfAngularVisibility = value;
		}
	}

}