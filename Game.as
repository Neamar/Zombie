package
{
	import achievements.AchievementsHandler;
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
		public static const FIRST_LEVEL:String = "0-intro";
		
		public var level:Level;
		
		public var achievementHandler:AchievementsHandler;
		
		public function Game()
		{
			//Load first level
			prepareLevel(FIRST_LEVEL);
			
			achievementHandler = new AchievementsHandler(this);
		}
		
		/**
		 * Call when the WIN event is dispatched
		 */
		protected function gotoNextLevel(e:Event):void
		{
			level.destroy();
			removeChild(level);
			level.removeEventListener(Level.WIN, gotoNextLevel);
			level.removeEventListener(Zombie.ZOMBIE_DEAD, achievementHandler.onZombieKilled);
			
			prepareLevel(level.nextLevelName);
		}
		
		/**
		 * Call when a new level should be loaded
		 * @param	levelName
		 */
		protected function prepareLevel(levelName:String):void
		{
			//Load current level
			var loader:LevelLoader = new LevelLoader(levelName);
			loader.addEventListener(Event.COMPLETE, addLevel);
		}
		
		/**
		 * Call when a new level is ready for play
		 * @param	e
		 */
		protected function addLevel(e:Event):void
		{
			var loader:LevelLoader = e.target as LevelLoader;
			loader.removeEventListener(Event.COMPLETE, addLevel);
			
			level = loader.getLevel()
			level.addEventListener(Level.WIN, gotoNextLevel);
			level.addEventListener(Zombie.ZOMBIE_DEAD, achievementHandler.onZombieKilled);
			
			achievementHandler.applyDefaultsAchievements();
			addChild(level);
		}
	}
}