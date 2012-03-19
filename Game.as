package
{
	import achievements.AchievementsHandler;
	import achievements.display.AchievementsScreen;
	import entity.Player;
	import entity.Zombie;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import levels.Level;
	import levels.LevelLoader;
	
	/**
	 * There is one game per session.
	 * This class embeds the levels and remember the unlocked achievements from level to level.
	 * It also contains the HUD to display information
	 * 
	 * Workflow to load new level:
	 * - loadLevelInfos: start loading the level and display the achievements tree;
	 * - onAchievementsPicked: display the loader if level is still not loading
	 * - displayWaiter: once the level is loaded and the achievements are picked, display a screen waiting for user confirmation to start level
	 * - startLevel: actually start the level!
	 * - PLAY!
	 * 		- onLevelFailed: level failed; show waiter again
	 * 		- onLevelSuccess: level win; load next level
	 * 
	 * @author Neamar
	 */
	public final class Game extends Sprite
	{
		/**
		 * Name of the first level to load.
		 * Levels are stored in src/assets/levels/{level_name}
		 */
		public static const FIRST_LEVEL:String = "killAll_Intro";
		
		/**
		 * Level currently displayed
		 */
		public var level:Level;
		
		/**
		 * Loader used to generate current level.
		 * We need to keep a reference to generate a new level if the current one is lost -- e.g., played died.
		 */
		public var loader:LevelLoader;
		
		/**
		 * Screen with all the achievements; null when not displayed.
		 * Is is GC during the level.
		 */
		public var achievementsScreen:AchievementsScreen = null;
		
		/**
		 * Handler for all the achievements.
		 * Unique for all the game.
		 */
		public var achievementHandler:AchievementsHandler;
		
		/**
		 * Name of the next level to load.
		 */
		public var nextLevelName:String;
		
		/**
		 * HUD displayed.
		 * Unique for all the game.
		 */
		public var hud:Hud;
		
		/**
		 * ID of the level currently in play
		 */
		public var levelNumber:int = 0;
		
		/**
		 * Special constants
		 */
		public static const DEBUG:int = 10;
		public static const FORCE_WIN:int = 11;
		public static const FULLSCREEN:int = 12;
		public static const PAUSE:int = 13;
		
		/**
		 * Key-binding for the game.
		 */
		public var bindings:Object = {
			/*f		key */70: FULLSCREEN, //TODO: allow fullscreen toggle while viewing achievement
			/*t		key */84: DEBUG,
			/*w		key */87: FORCE_WIN,
			/*p		key */80: PAUSE
		};
		
		/**
		 * Var initialisation + load first level
		 */
		public function Game() 
		{
			achievementHandler = new AchievementsHandler(this);
			
			hud = new Hud();
			addChild(hud);
			
			//Load first level
			loadLevelInfos(FIRST_LEVEL);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function onAddedToStage(e:Event):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			//Clean the event
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/**
		 * Game-level key bindings: fullscreen, pause...
		 * @param	e
		 */
		public function onKeyDown(e:KeyboardEvent):void
		{
			var action:int = bindings[e.keyCode];
			
			if (action == DEBUG && level != null)
			{
				level.toggleDebugMode();
			}
			else if (action == FORCE_WIN && level != null)
			{
				e.stopImmediatePropagation();
				level.dispatchWin();
			}
			else if (action == PAUSE && level != null)
			{
				if (level.hasEventListener(Event.ENTER_FRAME))
					level.removeEventListener(Event.ENTER_FRAME, level.onFrame);
				else
					level.addEventListener(Event.ENTER_FRAME, level.onFrame);
			}
			else if (action == FULLSCREEN)
			{
				if(stage.displayState == StageDisplayState.NORMAL)
					stage.displayState = StageDisplayState.FULL_SCREEN;
				else
					stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		/**
		 * The level says it failed, retry.
		 * @param	e
		 */
		protected function onLevelFailed(e:Event):void
		{
			destroyCurrentLevel();
			
			addChild(loader);
			displayWaiter();
		}
		
		/**
		 * Called when the WIN event is dispatched.
		 * Load the next level
		 */
		protected function onLevelSuccess(e:Event):void
		{
			destroyCurrentLevel();
			
			levelNumber++;
			
			loadLevelInfos(nextLevelName);
		}
		
		/**
		 * Clean up the level currently displayed.
		 * This function should render the level eligible for GC.
		 */
		protected function destroyCurrentLevel():void
		{
			level.destroy();
			removeChild(level);
			removeListeners(level);
			level = null;
		}
		
		/**
		 * Called when a new level should be loaded
		 * @param	levelName name of the level to load
		 */
		protected function loadLevelInfos(levelName:String):void
		{		
			//Start loading next level
			//Note: for now, we do this in the background, since the player may be picking some achievements	
			loader = new LevelLoader(levelName);
			loader.addEventListener(Event.COMPLETE, displayWaiter);
			
			if (levelNumber == 0)
			{
				//Display the loader : no achievement to pick for first level
				addChild(loader);
			}
			else
			{
				//Pick some achievements
				achievementsScreen = achievementHandler.getAchievementsScreen(levelNumber);
				achievementsScreen.addEventListener(Event.COMPLETE, onAchievementsPicked);
				removeChild(hud);
				addChild(achievementsScreen);
			}
		}
		
		/**
		 * Called when the player has picked all the achievements
		 * @param	e
		 */
		protected function onAchievementsPicked(e:Event):void
		{
			removeChild(achievementsScreen);
			addChild(hud);
			addChild(loader);
			achievementsScreen.removeEventListener(Event.COMPLETE, onAchievementsPicked);
			achievementsScreen.destroy();
			achievementsScreen = null;
		}
		
		/**
		 * Call when a new level is ready for play.
		 * Will wait for a click to begin
		 * @param	e
		 */
		protected function displayWaiter(e:Event = null):void
		{
			loader.removeEventListener(Event.COMPLETE, displayWaiter);
			loader.addEventListener(MouseEvent.CLICK,  startLevel);
		}
		
		/**
		 * Start the level after click on the loader
		 * @param	e
		 */
		protected function startLevel(e:Event):void
		{
			loader.removeEventListener(MouseEvent.CLICK, startLevel);
			removeChild(loader);
			
			//Store next level name
			nextLevelName = loader.params.nextLevelName;
			
			//Create the level and add it :
			level = loader.getLevel()
			addListeners(level);
			addChild(level);
			setChildIndex(hud, numChildren - 1);
			
			//Get ready  to play !
			achievementHandler.applyDefaultsAchievements();
			hud.updateWeapon(null, level.player);
		}
		
		/**
		 * Add all the listeners on the level
		 * @param	level
		 */
		private function addListeners(level:Level):void
		{
			//Failure and success
			level.addEventListener(Level.WIN, onLevelSuccess);
			level.addEventListener(Level.LOST, onLevelFailed);
			
			//HUD
			//Weapon display
			level.player.addEventListener(Player.WEAPON_CHANGED, hud.updateWeapon);
			level.player.addEventListener(Player.WEAPON_SHOT, hud.updateBullets);
			//Score
			level.player.addEventListener(Player.WEAPON_SHOT, hud.updateScoreShot);
			level.addEventListener(Zombie.ZOMBIE_DEAD, hud.updateScoreKill);
		}
		
		/**
		 * Remove all listeners added by addListeners
		 * @see addListeners
		 * @param	level
		 */
		private function removeListeners(level:Level):void
		{
			level.removeEventListener(Level.WIN, onLevelSuccess);
			level.removeEventListener(Level.LOST, onLevelFailed);
			level.player.removeEventListener(Player.WEAPON_CHANGED, hud.updateWeapon);
			level.player.removeEventListener(Player.WEAPON_SHOT, hud.updateBullets);
			level.player.removeEventListener(Player.WEAPON_SHOT, hud.updateScoreShot);
			level.removeEventListener(Zombie.ZOMBIE_DEAD, hud.updateScoreKill);
		}
	}
}