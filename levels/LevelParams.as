package levels 
{
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	/**
	 * Parameters for a level
	 * @author Neamar
	 */
	public class LevelParams 
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
		
		/////////////////////////////////////
		// SPECIAL PARAMETERS : AccessingAreaLevel
		/////////////////////////////////////
		
		/**
		 * Area to reach to win the level
		 */
		public var successArea:Rectangle
	}

}