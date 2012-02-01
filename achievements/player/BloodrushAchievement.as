package achievements.player
{
	
	/**
	 * Improve the vision when the player is hurt by disminishing the bloodrush.
	 *
	 * @author Neamar
	 */
	public final class BloodrushAchievement extends PlayerAchievement
	{
		public override function apply():void
		{
			player.tamedBloodrush = true;
			
			//Refresh the bloodrush
			player.drawBloodrush();
		}
	}

}