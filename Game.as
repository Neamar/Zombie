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
	import levels.Level;
	import levels.LevelLoader;
	
	/**
	 * There is one game per session.
	 * This class embeds the levels and remember the unlocked achievements from level to level.
	 * It also contains the HUD to display information
	 * 
	 * Workflow to load new level:
	 * - prepareLevel: start loading the level and display the achievements tree;
	 * - achievementsPicked: display the loader if level is stille not loading
	 * - addLevel: once the level is loaded and the achievements are picked, display the levels
	 * - PLAY!
	 * 		- onFailure: level failed
	 * 		- onSuccess: level win.
	 * 
	 * @author Neamar
	 */
	public final class Game extends Sprite
	{
		/**
		 * Name of the first level to load.
		 * Levels are stored in src/assets/levels/{level_name}
		 */
		public static const FIRST_LEVEL:String = "area_Intro";
		
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
		 * Flag set to true when the level finishes to load *before* the achievement are picked.
		 */
		public var hasFinishedLoading:Boolean = false;
		
		/**
		 * Flag set to true when the achievements have been picked
		 */
		public var hasFinishedPickingAchievements:Boolean = false;
		
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
		
		/**
		 * Key-binding for the game.
		 */
		public var bindings:Object = {
			/*f		key */70: FULLSCREEN, //TODO: allow fullscreen toggle while viewing achievement
			/*t		key */84: DEBUG,
			/*w		key */87: FORCE_WIN
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
			prepareLevel(FIRST_LEVEL);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function onAddedToStage(e:Event):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			//Clean the event
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
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
		protected function onFailure(e:Event):void
		{
			destroyCurrentLevel();
			
			addLevel();
		}
		
		/**
		 * Called when the WIN event is dispatched.
		 * Load the next level
		 */
		protected function onSuccess(e:Event):void
		{
			destroyCurrentLevel();
			
			levelNumber++;
			
			prepareLevel(nextLevelName);
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
		protected function prepareLevel(levelName:String):void
		{
			//Re-set flags
			hasFinishedLoading = hasFinishedPickingAchievements = false;
			
			//Start loading next level
			//Note: for now, we do this in the background, since the player may be picking some achievements	
			loader = new LevelLoader(levelName);
			loader.addEventListener(Event.COMPLETE, addLevel);
			
			if (levelNumber == 0)
			{
				//No achievements to pick for first level
				hasFinishedPickingAchievements = true;
				
				//Display the loader
				addChild(loader);
			}
			else
			{
				//Pick some achievements
				achievementsScreen = achievementHandler.getAchievementsScreen(levelNumber);
				achievementsScreen.addEventListener(Event.COMPLETE, achievementsPicked);
				removeChild(hud);
				addChild(achievementsScreen);
			}
		}
		
		protected function achievementsPicked(e:Event):void
		{
			removeChild(achievementsScreen);
			addChild(hud);
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