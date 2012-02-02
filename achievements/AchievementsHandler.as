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
			["First blood ! Increased range for the handgun", RangeAchievement, Handgun, 250],
			["Shotgun unlocked. Now default weapon", UnlockAchievement, Shotgun],
			["Higher capacity for the handgun: 6 bullets", CapacityAchievement, Handgun, 6],
			["Increased subconscious vision (10%)", SubconcsiousVisionAchievement, 10],
			["Jungle-style reload for the handgun", JungleAchievement, Handgun, true],
			["Increased range for the shotgun", RangeAchievement, Shotgun, 200],
			["Infinite range for the handgun", RangeAchievement, Handgun, 3000],
			["More life for the player", LifeAchievement, 75],
			["Increased range for the shotgun", RangeAchievement, Shotgun, 300],
			["Faster recuperation for the player", ConvalescenceAchievement, 2],
		/* 11 - 20 */
			["Faster fire for the handgun", CooldownAchievement, Handgun, 20],
			["Higher capacity for the handgun: 10 bullets", CapacityAchievement, Handgun, 10],
			["Faster cooldown for the handgun", CooldownAchievement, Handgun, 15],
			["Railgun unlocked. Now default weapon", UnlockAchievement, Railgun],
			["Wider vision for the player", VisionAchievement, 60],
			["Higher capacity for the shotgun : 2 bullets", CapacityAchievement, Shotgun, 2],
			["Higher capacity for the handgun : 16 bullets", CapacityAchievement, Handgun, 16],
			["Faster reload for the handgun", ReloadAchievement, Handgun, 30],
			["Infinite range for the shotgun", RangeAchievement, Shotgun, 3000],
			["Automatic reload for the handgun", AutomaticAchievement, Handgun, true],
		/* 21 - 30 */
			["Faster recuperation for the player", ConvalescenceAchievement, 1],
			["Infinite range for the railgun", RangeAchievement, Railgun, 3000],
			["Faster cooldown for the shotgun", CooldownAchievement, Shotgun, 30],
			["Higher capacity for the shotgun : 6 bullets", CapacityAchievement, Shotgun, 6],
			["Faster cooldown for the handgun", CooldownAchievement, Railgun, 30],
			["Uzi unlocked. Now default weapon", UnlockAchievement, Uzi],
			["Increased subconscious vision (15%)", SubconcsiousVisionAchievement, 15],
			["Faster reload for the shotgun", ReloadAchievement, Shotgun, 40],
			["Faster cooldown for the shotgun", CooldownAchievement, Shotgun, 20],
			["Increased range for the railgun", RangeAchievement, Uzi, 150],
		/* 31 - 40 */
			["Faster cooldown for the railgun", CooldownAchievement, Railgun, 20],
			["More life for the player", LifeAchievement, 100],
			["Higher capacity for the uzi : 25 bullets", CapacityAchievement, Uzi, 25],
			["Automatic reload for the handgun", AutomaticAchievement, Shotgun, true],
			["Increased range for the uzi", RangeAchievement, Uzi, 200],
			["Jungle-style reload for the uzi", JungleAchievement, Uzi, true],
			["Wider shot for the shotgun", AmplitudeAchievement, Shotgun, 14],
			["Tamed bloodrush", BloodrushAchievement, true],
			["Higher capacity for the uzi : 30 bullets", CapacityAchievement, Uzi, 30],
			["Faster cooldown for the uzi", CooldownAchievement, Uzi, 2],
		/* 41 - 50 */
			["Faster reload for the uzi", ReloadAchievement, Uzi, 15],
			["Wider shot for the shotgun", AmplitudeAchievement, Shotgun, 16],
			["Infinite range for the uzi", RangeAchievement, Uzi, 3000],
			["Increased subconscious vision (20%)", SubconcsiousVisionAchievement, 20],
			["Automatic reload for the uzi", AutomaticAchievement, Uzi, true],
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