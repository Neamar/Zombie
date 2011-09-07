package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class Heatmap extends Bitmap 
	{
		/**
		 * Layers to use to draw the heatmap
		 * @see apply()
		 */
		public var layers:Dictionary = new Dictionary();
		
		/**
		 * Precomputed shortcut for this.bitmapData.rect.
		 */
		public var rect:Rectangle;
		
		public function Heatmap()
		{
			super(new BitmapData(Main.LEVEL_WIDTH, Main.LEVEL_HEIGHT, true));
			rect = bitmapData.rect;
		}
		
		/**
		 * Recompute the heatmap.
		 * !!CPU intensive!!
		 */
		public function apply():void
		{
			//Clean
			bitmapData.fillRect(rect, 0xFFFFFFFF);
			
			//Redraw
			for each(var layer:* in layers)
			{
				bitmapData.draw(layer);
			}
		}
		
		/**
		 * Add new layer to the heatmap.
		 * @param	name to use
		 * @return new layer. Don't forget to apply() once intialised.
		 */
		public function addNewLayer(name:String):BitmapData
		{
			var newLayer:BitmapData = new BitmapData(Main.LEVEL_WIDTH, Main.LEVEL_HEIGHT, true, 0x00FFFFFF);
			addLayer(name, newLayer);
			return newLayer;
		}
		
		/**
		 * Add existing bitmap data as layer.
		 * @param	name
		 * @param	bd
		 */
		public function addLayer(name:String, bd:BitmapData):void
		{
			layers[name] = bd;
			apply();
		}
		
		/**
		 * Retrieve layer by name
		 * @param	name
		 * @return layer (or undefined)
		 */
		public function getLayer(name:String):BitmapData
		{
			return layers[name];
		}
	}
	
}