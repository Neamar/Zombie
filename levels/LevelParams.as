package levels 
{
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
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
		 * Texture for the level
		 */
		public var bitmap:Bitmap;
		
		/**
		 * Spawn area for the zombies
		 * @see zombieDensity
		 */
		public var zombiesLocation:Vector.<Rectangle> = new Vector.<Rectangle>();
		
		/**
		 * Density of zombies for each area.
		 * @see zombiesLocation
		 */
		public var zombiesDensity:Vector.<int> = new Vector.<int>();
		
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
		 * Name of the level following this one (to be loaded once this one is completed)
		 */
		public var nextLevelName:String;
		
		/////////////////////////////////////
		// SPECIAL PARAMETERS : AccessingAreaLevel
		/////////////////////////////////////
		
		/**
		 * Area to reach to win the level
		 */
		public var successArea:Rectangle
	}

}