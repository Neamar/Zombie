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
		
		public function Entity()
		{
			mouseEnabled = false;
		}
		
		/**
		 * Init the entity on the level.
		 * Don't forget to call this as soon as the Entity gets a reference to the level.
		 * 
		 * @param	parent
		 */
		protected function init(parent:Level):void
		{
			hitmapTest = parent.hitmap.bitmapData.getPixel32;
			heatmap = parent.heatmap;
		}
	}
}