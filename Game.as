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
		public static const FIRST_LEVEL:String = "0-intro";
		
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
			//Load first level
			prepareLevel(FIRST_LEVEL);
			
			achievementHandler = new AchievementsHandler(this);
			
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
			level.removeEventListener(Level.WIN, onSuccess);
			level.removeEventListener(Level.LOST, onFailure);
			level.removeEventListener(Zombie.ZOMBIE_DEAD, achievementHandler.onZombieKilled);
			level = null;
		}
		
		/**
		 * Call when a new level should be loaded
		 * @param	levelName
		 */
		protected function prepareLevel(levelName:String):void
		{
			//Load current level
			loader = new LevelLoader(levelName);
			loader.addEventListener(Event.COMPLETE, addLevel);
		}
		
		/**
		 * Call when a new level is ready for play
		 * @param	e
		 */
		protected function addLevel(e:Event = null):void
		{
			loader.removeEventListener(Event.COMPLETE, addLevel);
			
			//Store next level name
			nextLevelName = loader.params.nextLevelName;
			
			//Add the level
			level = loader.getLevel()
			level.addEventListener(Level.WIN, onSuccess);
			level.addEventListener(Level.LOST, onFailure);
			
			level.addEventListener(Zombie.ZOMBIE_DEAD, achievementHandler.onZombieKilled);
			
			achievementHandler.applyDefaultsAchievements();

			addChild(level);
			setChildIndex(hud, numChildren - 1);
		}
	}
}