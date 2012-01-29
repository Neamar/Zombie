package entity
{
	import flash.display.Sprite;
	import levels.Level;
	
	/**
	 * An entity represents anythin moving on the map : a zombie, the player, a survivor...
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
			mouseEnabled = false;
				
			hitmapTest = parent.hitmap.bitmapData.getPixel32;
			heatmap = parent.heatmap;
		}
	}
}