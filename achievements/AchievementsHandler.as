package achievements 
{
	import achievements.weapon.*;
	import weapon.*;
	/**
	 * ...
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
		public var achievements = Array(
		[0, UnlockAchievement, Handgun],
		[1, RangeAchievement, Handgun, 200]
		);
		
		public function AchievementsHandler() 
		{
			
		}
		
	}

}