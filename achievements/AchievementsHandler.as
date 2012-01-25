package achievements 
{
	import achievements.player.*;
	import achievements.weapon.*;
	import flash.events.Event;
	import weapon.*;
	/**
	 * Handle the list of unlocks.
	 * 
	 * @author Neamar
	 */
	public class AchievementsHandler 
	{
		/**
		 * List of all the available achievements.
		 * 
		 * Each rwo respects the following structure :
		 * [delta_zombie:int, achievement:Achievement, ...params]
		 * 
		 * delta_zombie is the number of zombie to kill since last achievement.
		 * params is the params to use for the achievements
		 */
		public var achievementsList:Array = new Array(
		[1, RangeAchievement, Handgun, 250],
		[0, CapacityAchievement, Handgun, 6],
		[0, UnlockAchievement, Shotgun],
		[1, SubconcsiousVisionAchievement, 5],
		[Infinity, Achievement, 0] /* final achievement, unreachable. */
		);
		
		/**
		 * Game associated with those achievements
		 */
		public var game:Game;
		
		/**
		 * Total number of zombies killed
		 */
		public var zombiesKilled:int = 0;
		
		/**
		 * Number of zombies killed since last achievement was unlocked
		 */
		public var zombiesKilledSinceLastAchievement:int = 0;
		
		public function AchievementsHandler(game:Game) 
		{
			this.game = game;
		}
		
		/**
		 * A zombie was killed.
		 * Test if an accomplishment was unlocked.
		 */
		public function onZombieKilled(e:Event = null):void
		{
			zombiesKilled++;
			zombiesKilledSinceLastAchievement++;
			
			//While loop is required for "0 based" achievements (unlocking multiple achievement at the same time)
			while (achievementsList[0][0] <= zombiesKilledSinceLastAchievement)
			{
				//Apply current achievement
				var currentRow:Array = achievementsList.shift();
				var currentAchievement:Achievement = new currentRow[1]();
				currentAchievement.setGame(game);
				currentAchievement.setParams(currentRow.slice(2));

				currentAchievement.apply();
				trace(currentAchievement, currentRow.slice(2));
				
				//Back to zero.
				zombiesKilledSinceLastAchievement = 0;
			}
		}
	}

}