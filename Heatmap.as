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
		public var layers:Dictionary = new Dictionary();
		public var rect:Rectangle;
		
		public function Heatmap()
		{
			super(new BitmapData(Main.LEVEL_WIDTH, Main.LEVEL_HEIGHT, true));
			rect = bitmapData.rect;
		}
		
		public function apply():void
		{
			bitmapData.fillRect(rect, 0xFFFFFFFF);
			for each(var layer:* in layers)
			{
				bitmapData.draw(layer);
			}
		}
		
		public function addNewLayer(name:String):BitmapData
		{
			var newLayer:BitmapData = new BitmapData(Main.LEVEL_WIDTH, Main.LEVEL_HEIGHT, true, 0x00FFFFFF);
			addLayer(name, newLayer);
			return newLayer;
		}
		
		public function addLayer(name:String, bd:BitmapData):void
		{
			layers[name] = bd;
			apply();
		}
	}
	
}