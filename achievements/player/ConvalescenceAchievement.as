package achievements.player 
{
	/**
	 * Improve player recuperation
	 * 
	 * @author Neamar
	 */
	public final class ConvalescenceAchievement extends PlayerAchievement
	{
		public override function apply():void
		{
			player.recuperationSpeed = value;
		}
	}

}