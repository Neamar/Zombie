package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
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
			bitmapData.lock();
			//Clean
			bitmapData.fillRect(rect, 0xFFFFFFFF);
			
			//Redraw
			for each(var layer:Object in layers)
			{
				var ibd:IBitmapDrawable = layer.ibd;
				var matrix:Matrix = layer.matrix;
				bitmapData.draw(ibd, matrix);
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
			setLayer(name, newLayer);
			return newLayer;
		}
		
		/**
		 * Add existing bitmap data as layer.
		 * @param	name
		 * @param	ibd
		 */
		public function setLayer(name:String, ibd:IBitmapDrawable, matrix:Matrix = null):void
		{
			layers[name] = {ibd:ibd, matrix:matrix};
			apply();
		}
		
		/**
		 * Retrieve layer by name
		 * @param	name
		 * @return layer & matrix (or undefined)
		 */
		public function getLayer(name:String):Object
		{
			return layers[name];
		}
	}
	
}