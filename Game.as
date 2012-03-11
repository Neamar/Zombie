package
{
	import achievements.AchievementsHandler;
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
			var screen:Sprite = achievementHandler.getAchievementsScreen();
			addChild(screen);
			return;
			//Load current level
			loader = new LevelLoader(levelName);
			addChild(loader);
			
			loader.addEventListener(Event.COMPLETE, addLevel);
		}
		
		/**
		 * Call when a new level is ready for play
		 * @param	e
		 */
		protected function addLevel(e:Event = null):void
		{
			if (contains(loader))
			{
				loader.removeEventListener(Event.COMPLETE, addLevel);
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