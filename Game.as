package
{
	import achievements.AchievementsHandler;
	import achievements.display.AchievementsScreen;
	import entity.Player;
	import entity.Zombie;
	import flash.display.Sprite;
	import flash.events.Event;
	import levels.Level;
	import levels.LevelLoader;
	
	/**
	 * There is one game per session.
	 * This class embeds the levels and remember the unlocked achievements from level to level.
	 *
	 * @author Neamar
	 */
	public final class Game extends Sprite
	{
		/**
		 * Name of the first level to load
		 */
		public static const FIRST_LEVEL:String = "area_Intro";
		
		/**
		 * Level currently displayed
		 */
		public var level:Level;
		
		/**
		 * Loader used to generate current level.
		 */
		public var loader:LevelLoader;
		
		/**
		 * Screen with all the achievements; null when not displayed
		 */
		public var achievementsScreen:AchievementsScreen = null;
		
		/**
		 * Handler for the achievements of the level.
		 */
		public var achievementHandler:AchievementsHandler;
		
		/**
		 * Name of the next level to load
		 */
		public var nextLevelName:String;
		
		/**
		 * Hud to be displayed
		 */
		public var hud:Hud;
		
		/**
		 * Flag set to true when the level finishes to load *before* the achievement are picked.
		 */
		public var hasFinishedLoading:Boolean = false;
		
		/**
		 * Flag set to true when the achievements have been picked
		 */
		public var hasFinishedPickingAchievements:Boolean = false;
		
		public function Game() 
		{
			achievementHandler = new AchievementsHandler(this, 40);
						
			//Load first level
			prepareLevel(FIRST_LEVEL);
			
			hud = new Hud();
			addChild(hud);
		}
		
		/**
		 * The level says it failed, retry.
		 * @param	e
		 */
		protected function onFailure(e:Event):void
		{
			destroyCurrentLevel();
			
			addLevel();
		}
		
		/**
		 * Call when the WIN event is dispatched.
		 * Load the next level
		 */
		protected function onSuccess(e:Event):void
		{
			destroyCurrentLevel();
			
			prepareLevel(nextLevelName);
		}
		
		/**
		 * Clean up the level currently displayed.
		 * It should be eligible for GC.
		 */
		protected function destroyCurrentLevel():void
		{
			//Render the level eligible for GC :
			level.destroy();
			removeChild(level);
			removeListeners(level);
			level = null;
		}
		
		/**
		 * Call when a new level should be loaded
		 * @param	levelName
		 */
		protected function prepareLevel(levelName:String):void
		{
			hasFinishedLoading = hasFinishedPickingAchievements = false;
			
			//Pick some achievements
			achievementsScreen = achievementHandler.getAchievementsScreen();
			achievementsScreen.addEventListener(Event.COMPLETE, achievementsPicked);
			addChild(achievementsScreen);

			//While loading next level in the background :
			loader = new LevelLoader(levelName);
			loader.addEventListener(Event.COMPLETE, addLevel);
		}
		
		protected function achievementsPicked(e:Event):void
		{
			removeChild(achievementsScreen);
			achievementsScreen.removeEventListener(Event.COMPLETE, achievementsPicked);
			achievementsScreen.destroy();
			achievementsScreen = null;
			hasFinishedPickingAchievements = true;
			
			if (!hasFinishedLoading)
			{
				//The level is still loading : display the loader and wait for the COMPLETE event.
				addChild(loader);
			}
			else
			{
				//We spent a lot of time picking the achievements, and we can play straightforward.
				addLevel();
			}
		}
		
		/**
		 * Call when a new level is ready for play
		 * @param	e
		 */
		protected function addLevel(e:Event = null):void
		{
			loader.removeEventListener(Event.COMPLETE, addLevel);
			hasFinishedLoading = true;
			
			//We shall wait for the achievements to be picked before launching new level.
			if (!hasFinishedPickingAchievements)
				return;
				
			if (contains(loader))
			{
				removeChild(loader);
			}
			
			//Store next level name
			nextLevelName = loader.params.nextLevelName;
			
			//Add the level
			level = loader.getLevel()
			addListeners(level);
			addChild(level);
			setChildIndex(hud, numChildren - 1);
			
			//Get ready  to play !
			achievementHandler.applyDefaultsAchievements();
			hud.updateWeapon(null, level.player);
		}
		
		/**
		 * All all the listeners on the level
		 * @param	level
		 */
		private function addListeners(level:Level):void
		{
			//Failure and success
			level.addEventListener(Level.WIN, onSuccess);
			level.addEventListener(Level.LOST, onFailure);
			
			//HUD
			level.player.addEventListener(Player.WEAPON_CHANGED, hud.updateWeapon);
			level.player.addEventListener(Player.WEAPON_SHOT, hud.updateBullets);
		}
		
		/**
		 * Remove all listeners added by addListeners
		 * @see addListeners
		 * @param	level
		 */
		private function removeListeners(level:Level):void
		{
			level.removeEventListener(Level.WIN, onSuccess);
			level.removeEventListener(Level.LOST, onFailure);
			level.player.removeEventListener(Player.WEAPON_CHANGED, hud.updateWeapon);
			level.player.removeEventListener(Player.WEAPON_SHOT, hud.updateBullets);
		}
	}
}