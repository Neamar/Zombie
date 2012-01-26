package achievements.player 
{
	import achievements.Achievement;
	/**
	 * Base class for all player-based achievements
	 * 
	 * @author Neamar
	 */
	public class PlayerAchievement extends Achievement
	{
		protected var value:int;
		
		public override function setParams(params:Array):void
		{
			value = params[0];
		}
	}

}