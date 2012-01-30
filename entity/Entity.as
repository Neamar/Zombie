package entity
{
	import flash.display.Sprite;
	import levels.Heatmap;
	import levels.Level;
	
	/**
	 * An entity represents anything moving on the map : a zombie, the player, a survivor...
	 * 
	 * TODO : extends Bitmap ?
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