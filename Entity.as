package 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class Entity extends Sprite 
	{	
		/**
		 * Function to use to know if we may go through a given pixel.
		 */
		public var hitmapTest:Function;
		
		/**
		 * Shortcut to the level heatmap.
		 */
		public var heatmap:Heatmap;
		
		public function Entity(parent:Level)
		{
			hitmapTest = parent.hitmap.bitmapData.getPixel32;
			heatmap = parent.heatmap;
		}
	}
}