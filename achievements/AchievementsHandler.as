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
		 * Each row respects the following structure :
		 * [achievement:Achievement, ...params]
		 * 
		 * where achievement is a Class (and not an object)
		 * params is the params to use for the achievements
		 */
		public var achievementsList:Array = new Array(
		/* 1 - 10*/
			[RangeAchievement, Handgun, 250],
			[CapacityAchievement, Handgun, 2],
			[UnlockAchievement, Shotgun],
			[SubconcsiousVisionAchievement, 5],
			[JungleAchievement, Handgun, true],
			[RangeAchievement, Shotgun, 200],
			[RangeAchievement, Handgun, 3000],
			[LifeAchievement, 75],
			[RangeAchievement, Shotgun, 300],
			[ConvalescenceAchievement, 2],
		/* 11 - 20 */
			[CooldownAchievement, Handgun, 20],
			[CapacityAchievement, Handgun, 10],
			[CooldownAchievement, Handgun, 15],
			[UnlockAchievement, Railgun],
			[VisionAchievement, 60],
			[CapacityAchievement, Shotgun, 2],
			[CapacityAchievement, Handgun, 16],
			[ReloadAchievement, Handgun, 30],
			[RangeAchievement, Shotgun, 3000],
			[AutomaticAchievement, Handgun, true],
		/* 21 - 30 */
			[ConvalescenceAchievement, 1],
			[RangeAchievement, Railgun, 3000],
			[CooldownAchievement, Shotgun, 30],
			[CapacityAchievement, Shotgun, 6],
			[CooldownAchievement, Railgun, 30],
			[UnlockAchievement, Uzi],
			[SubconcsiousVisionAchievement, 10],
			[ReloadAchievement, Shotgun, 40],
			[CooldownAchievement, Shotgun, 20],
			[RangeAchievement, Uzi, 150],
		/* 31 - 40 */
			[CooldownAchievement, Railgun, 20],
			[LifeAchievement, 100],
			[CapacityAchievement, Uzi, 25],
			[AutomaticAchievement, Shotgun, true],
			[RangeAchievement, Uzi, 200],
			[JungleAchievement, Uzi, true],
			[AmplitudeAchievement, Shotgun, 14],
			[BloodrushAchievement, true],
			[CapacityAchievement, Uzi, 30],
			[CooldownAchievement, Uzi, 2],
		/* 41 - 50 */
			[ReloadAchievement, Uzi, 15],
			[AmplitudeAchievement, Shotgun, 16],
			[RangeAchievement, Uzi, 3000],
			[SubconcsiousVisionAchievement, 15],
			[AutomaticAchievement, Uzi, true],
		/* 50+ */
			[Infinity, Achievement, 0] /* final achievement, unreachable. */
		);
		
		/**
		 * Number of zombies to kill between achievement n and n+1
		 * 
		 * @see https://docs.google.com/spreadsheet/ccc?key=0ApZXXCCC0GsvdHpFR1pLWUpSblVRbnBKZlEtQ1VBdEE
		 */
		public var achievementsDelta:Vector.<int> = Vector.<int>([1, 2, 3, 4, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 30, 35, 40, 50, 60, 80, 100, 120, 140, 160, 200]);
		
		/**
		 * Achievement to start at
		 * (for test or going back to a saved game)
		 */
		public var startAtAchievement:int = 0;
		
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
				achievementsDelta.shift();
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
			while (achievementsDelta[0] <= zombiesKilledSinceLastAchievement)
			{
				achievementsDelta.shift();
				//Apply current achievement
				applyAchievement(achievementsList.shift());
				
				//Back to zero.
				zombiesKilledSinceLastAchievement = 0;
			}
		}
		
		protected function applyAchievement(datas:Array):String
		{
			var currentAchievement:Achievement = new datas[0]();
			currentAchievement.setGame(game);
			currentAchievement.setParams(datas.slice(1));

			currentAchievement.apply();
			trace(currentAchievement, datas.slice(1), achievementsDelta[0]);
			
			return 'Applied';
		}
	}

}