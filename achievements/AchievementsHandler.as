package achievements 
{
	import achievements.player.*;
	import achievements.weapon.*;
	import flash.events.Event;
	import weapon.*;
	/**
	 * Handle the list of unlocks.
	 * 
	 * TODO : remove event zombie dead
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
		public var achievementsList:Vector.<Array> = Vector.<Array>([
		
		//Handgun achievement tree
		[
			[0, "Handgun unlocked. Now default weapon", UnlockAchievement, Shotgun],
			[0, "Increased range for the handgun", RangeAchievement, Handgun, 250],
			[1, "Infinite range for the handgun", RangeAchievement, Handgun, 3000],
			[0, "Higher capacity for the handgun: 6 bullets", CapacityAchievement, Handgun, 6],
			[3, "Higher capacity for the handgun: 10 bullets", CapacityAchievement, Handgun, 10],
			[4, "Higher capacity for the handgun : 16 bullets", CapacityAchievement, Handgun, 16],
			[0, "Jungle-style reload for the handgun", JungleAchievement, Handgun, true],
			[0, "Faster cooldown for the handgun", CooldownAchievement, Handgun, 20],
			[7, "Faster cooldown for the handgun", CooldownAchievement, Handgun, 15],
			[0, "Faster reload for the handgun", ReloadAchievement, Handgun, 30],			
			[0, "Automatic reload for the handgun", AutomaticAchievement, Handgun, true],
		]
		]);
			
		/*	["Increased range for the shotgun", RangeAchievement, Shotgun, 200],
			["Increased subconscious vision (10%)", SubconcsiousVisionAchievement, 10],
			[-1, "Shotgun unlocked. Now default weapon", UnlockAchievement, Shotgun],
			["More life for the player", LifeAchievement, 75],
			["Increased range for the shotgun", RangeAchievement, Shotgun, 300],
			["Faster recuperation for the player", ConvalescenceAchievement, 2],
			["Railgun unlocked. Now default weapon", UnlockAchievement, Railgun],
			["Wider vision for the player", VisionAchievement, 60],
			["Higher capacity for the shotgun : 2 bullets", CapacityAchievement, Shotgun, 2],
			["Infinite range for the shotgun", RangeAchievement, Shotgun, 3000],
			["Faster recuperation for the player", ConvalescenceAchievement, 1],
			["Infinite range for the railgun", RangeAchievement, Railgun, 3000],
			["Faster cooldown for the shotgun", CooldownAchievement, Shotgun, 30],
			["Higher capacity for the shotgun : 6 bullets", CapacityAchievement, Shotgun, 6],
			["Uzi unlocked. Now default weapon", UnlockAchievement, Uzi],
			["Increased subconscious vision (15%)", SubconcsiousVisionAchievement, 15],
			["Faster reload for the shotgun", ReloadAchievement, Shotgun, 40],
			["Faster cooldown for the shotgun", CooldownAchievement, Shotgun, 20],
			["Increased range for the railgun", RangeAchievement, Uzi, 150],
			["Faster cooldown for the handgun", CooldownAchievement, Railgun, 30],
			["Faster cooldown for the railgun", CooldownAchievement, Railgun, 20],
			["More life for the player", LifeAchievement, 100],
			["Higher capacity for the uzi : 25 bullets", CapacityAchievement, Uzi, 25],
			["Automatic reload for the shotgun", AutomaticAchievement, Shotgun, true],
			["Increased range for the uzi", RangeAchievement, Uzi, 200],
			["Jungle-style reload for the uzi", JungleAchievement, Uzi, true],
			["Wider shot for the shotgun", AmplitudeAchievement, Shotgun, 14],
			["Tamed bloodrush", BloodrushAchievement, true],
			["Higher capacity for the uzi : 30 bullets", CapacityAchievement, Uzi, 30],
			["Faster cooldown for the uzi", CooldownAchievement, Uzi, 2],
			["Faster reload for the uzi", ReloadAchievement, Uzi, 15],
			["Wider shot for the shotgun", AmplitudeAchievement, Shotgun, 16],
			["Infinite range for the uzi", RangeAchievement, Uzi, 3000],
			["Increased subconscious vision (20%)", SubconcsiousVisionAchievement, 20],
			["Automatic reload for the uzi", AutomaticAchievement, Uzi, true],*/
		
		
		/**
		 * Game associated with those achievements
		 */
		public var game:Game;

		
		/**
		 * Creates the handler.
		 * @param	game to operate on
		 * @param	startAtAchievement whether or not to directly unlock some achievement (to restore previous session for instance)
		 */
		public function AchievementsHandler(game:Game, startAtAchievement:int = 0) 
		{
			this.game = game;
		}
		
		/**
		 * Apply achievement precedently recorded (from another game, or another level)
		 */
		public function applyDefaultsAchievements():void
		{
			//TODO
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