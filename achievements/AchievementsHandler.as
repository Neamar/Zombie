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
			["First blood ! Handgun range increased", RangeAchievement, Handgun, 250],
			["Shotgun unlocked. Now default weapon", UnlockAchievement, Shotgun],
			["New handgun capacity : 2 bullets", CapacityAchievement, Handgun, 6],
			["Increased subconscious vision", SubconcsiousVisionAchievement, 5],
			["Jungle-style reload for the handgun", JungleAchievement, Handgun, true],
			["Shotgun range increased", RangeAchievement, Shotgun, 200],
			["Handgun range increased", RangeAchievement, Handgun, 3000],
			["Player got more life", LifeAchievement, 75],
			["Shotgun range increased", RangeAchievement, Shotgun, 300],
			["Player healing faster", ConvalescenceAchievement, 2],
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
			["You'll never unlock this one", Infinity, Achievement, 0] /* final achievement, unreachable. */
		);
		
		/**
		 * Number of zombies to kill between achievement n and n+1
		 * 
		 * @see https://docs.google.com/spreadsheet/ccc?key=0ApZXXCCC0GsvdHpFR1pLWUpSblVRbnBKZlEtQ1VBdEE
		 */
		public var achievementsDelta:Vector.<int> = Vector.<int>([1,2,3,4,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,16,17,18,19,20,21,22,23,25,30,35,40,50,60,80,100,120,140,160,200,Infinity]);
		
		/**
		 * Number of achievement unlocked.
		 */
		public var achievementsUnlocked:int;
		
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
		
		/**
		 * Creates the handler.
		 * @param	game to operate on
		 * @param	startAtAchievement whether or not to directly unlock some achievement (to restore previous session for instance)
		 */
		public function AchievementsHandler(game:Game, startAtAchievement:int = 0) 
		{
			this.game = game;
			achievementsUnlocked = startAtAchievement;
		}
		
		/**
		 * Apply achievement precedently recorded (from another game, or another level)
		 */
		public function applyDefaultsAchievements():void
		{
			for (var i:int = 0; i < achievementsUnlocked; i++)
			{
				applyAchievement(achievementsList[i]);
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
			while (achievementsDelta[achievementsUnlocked] <= zombiesKilledSinceLastAchievement)
			{
				//Apply current achievement
				var msg:String = applyAchievement(achievementsList[achievementsUnlocked]);
				game.hud.displayMessage(msg);
				
				//Get ready for next turn !
				achievementsUnlocked++;
				zombiesKilledSinceLastAchievement = 0;
			}
		}
		
		/**
		 * Apply the achievement.
		 * 
		 * @param	datas an array, respecting the row-structure of achievementsList
		 * @return achievement string (to be displayed)
		 */
		protected function applyAchievement(datas:Array):String
		{
			var currentAchievement:Achievement = new datas[1]();
			currentAchievement.setGame(game);
			currentAchievement.setParams(datas.slice(2));

			currentAchievement.apply();
			
			return datas[0];
		}
	}

}