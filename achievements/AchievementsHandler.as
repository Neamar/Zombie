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
		/* 1 - 10 */
			[1, RangeAchievement, Handgun, 250],
			[0, CapacityAchievement, Handgun, 2],
			[0, UnlockAchievement, Shotgun],
			[1, SubconcsiousVisionAchievement, 5],
			[1, JungleAchievement, Handgun, true],
			[1, RangeAchievement, Shotgun, 200],
			[1, RangeAchievement, Handgun, 3000],
			[1, LifeAchievement, 75],
			[1, RangeAchievement, Shotgun, 300],
			[1, ConvalescenceAchievement, 2],
		/* 11 - 20 */
			[1, CooldownAchievement, Handgun, 20],
			[1, CapacityAchievement, Handgun, 10],
			[1, CooldownAchievement, Handgun, 15],
			[1, UnlockAchievement, Railgun],
			[1, VisionAchievement, 60],
			[1, CapacityAchievement, Shotgun, 2],
			[1, CapacityAchievement, Handgun, 16],
			[1, ReloadAchievement, Handgun, 30],
			[1, RangeAchievement, Shotgun, 3000],
			[1, AutomaticAchievement, Handgun, true],
		/* 21 - 30 */
			[1, ConvalescenceAchievement, 1],
			[1, RangeAchievement, Railgun, 3000],
			[1, CooldownAchievement, Shotgun, 30],
			[1, CapacityAchievement, Shotgun, 6],
			[1, CooldownAchievement, Railgun, 30],
			[1, UnlockAchievement, Uzi],
			[1, SubconcsiousVisionAchievement, 10],
			[1, ReloadAchievement, Shotgun, 40],
			[1, CooldownAchievement, Shotgun, 20],
			[1, RangeAchievement, Uzi, 150],
		/* 31 - 40 */
			[1, CooldownAchievement, Railgun, 20],
			[1, LifeAchievement, 100],
			[1, CapacityAchievement, Uzi, 25],
			[1, AutomaticAchievement, Shotgun, true],
			[1, RangeAchievement, Uzi, 200],
			[1, JungleAchievement, Uzi, true],
			[1, AmplitudeAchievement, Shotgun, 14],
			[1, BloodrushAchievement, true],
			[1, CapacityAchievement, Uzi, 30],
			[1, CooldownAchievement, Uzi, 2],
		/* 41 - 50 */
			[1, ReloadAchievement, Uzi, 15],
			[1, AmplitudeAchievement, Shotgun, 16],
			[1, RangeAchievement, Uzi, 3000],
			[1, SubconcsiousVisionAchievement, 15],
			[1, AutomaticAchievement, Uzi, true],
		/* 50+ */
		[Infinity, Achievement, 0] /* final achievement, unreachable. */
		);
		
		/**
		 * Achievement to start at
		 * (for test or going back to a saved game)
		 */
		public var startAtAchievement:int =40;
		
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
		 * Apply achievement precedenlty recorded (another game, or to cheat)
		 */
		public function applyDefaultsAchievements():void
		{
			while(startAtAchievement > 0)
			{
				startAtAchievement--;
				applyAchievement(achievementsList.shift());
			}
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
				applyAchievement(achievementsList.shift());
				
				//Back to zero.
				zombiesKilledSinceLastAchievement = 0;
			}
		}
		
		protected function applyAchievement(datas:Array):String
		{
			var currentAchievement:Achievement = new datas[1]();
			currentAchievement.setGame(game);
			currentAchievement.setParams(datas.slice(2));

			currentAchievement.apply();
			trace(currentAchievement, datas.slice(2));
			
			return 'Applied';
		}
	}

}