package entity
{
	import flash.display.Sprite;
	import levels.Level;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class Entity extends Sprite 
	{	
		/**
		 * Can we go through a given pixel?
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