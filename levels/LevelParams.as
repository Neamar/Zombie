package levels
{
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	
	/**
	 * Parameters for a level
	 *
	 * No class taking a LevelParams as a parameter should store it for further use. It is a temporary holder for the XML information.
	 * @author Neamar
	 */
	public final class LevelParams
	{
		/**
		 * Class to use to instantiate the Level.
		 * Can be any subclass of Level.
		 */
		public var LevelClass:Class = Level;
		
		/**
		 * Shall we display help messages along the way ?
		 */
		public var displayHelp:Boolean = false;
		
		/**
		 * Texture for the level
		 */
		public var bitmap:Bitmap;
		
		/**
		 * Initial Spawn datas for the zombies
		 */
		public var initialSpawns:Vector.<LevelSpawn> = new Vector.<LevelSpawn>();
		
		/**
		 * Hitmap for the level
		 */
		public var hitmap:Bitmap;
		
		/**
		 * Player start position on the x-axis
		 */
		public var playerStartX:int;
		
		/**
		 * Player start position on the x-axis
		 */
		public var playerStartY:int;
		
		/**
		 * Player resolution (precision for the lamplight raycasting).
		 * Redefined for tight levels.
		 */
		public var playerStartResolution:int = 12;
		
		/**
		 * Number of magazines for each weapon
		 */
		public var playerMagazines:Object = { handgun:0, shotgun:0, uzi:0 };
		
		/**
		 * Name of the level following this one (to be loaded once this one is completed)
		 */
		public var nextLevelName:String;
		
		/**
		 * Sound to play in the background
		 */
		public var ambientSound:Sound;
		
		/////////////////////////////////////
		// SPECIAL PARAMETERS : AccessingAreaLevel
		/////////////////////////////////////
		
		/**
		 * Area to reach to win the level
		 */
		public var successArea:Rectangle
		
		/////////////////////////////////////
		// SPECIAL PARAMETERS : WavesLevel
		/////////////////////////////////////
		/**
		 * Maximum number of zombies displayed on the stage.
		 * If a wave spawns more zombies than this limit, the level is lost.
		 */
		public var wavesMaxNumberOfZombies:int;
		
		/**
		 * Delay between each wave.
		 * The first value is the delay between the level start and the first wave
		 */
		public var wavesDelay:Vector.<int> = new Vector.<int>();
		
		/**
		 * Datas for the waves.
		 */
		public var wavesDatas:Vector.<Vector.<LevelSpawn>> = new Vector.<Vector.<LevelSpawn>>();
	}

}