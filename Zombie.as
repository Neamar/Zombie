package 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class Zombie extends Entity 
	{
		public const RADIUS:int = 5;
		public const SPEED:int = 3;
		
		public function Zombie(parent:Level, x:int, y:int)
		{
			this.x = x;
			this.y = y;
			super(parent);
			
			this.graphics.lineStyle(1, 0xFF0000);
			this.graphics.beginFill(0xF00000);
			this.graphics.drawCircle(0, 0, RADIUS);
			this.graphics.moveTo(0, 0);
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		public function onFrame(e:Event):void
		{
			var xScaled:int = x / Heatmap.RESOLUTION;
			var yScaled:int = y / Heatmap.RESOLUTION;
			
			var minI:int = 0;
			var minJ:int = 0;
			var minValue:int = heatmap.bitmapData.getPixel(xScaled , yScaled);
			
			for (var i:int = -1; i <= 1; i++)
			{
				for (var j:int = -1; j <= 1; j++)
				{
					if ( i == 0 && j == 0)
						continue;
					
					if (heatmap.bitmapData.getPixel(xScaled + i, yScaled + j) > minValue)
					{
						minValue = heatmap.bitmapData.getPixel(xScaled + i, yScaled + j);
						minI = i;
						minJ = j;
					}
				}
			}
			
			heatmap.bitmapData.setPixel(xScaled, yScaled, heatmap.bitmapData.getPixel(xScaled , yScaled) - 15);

			x += SPEED * minI;
			y += SPEED * minJ;
			
			heatmap.bitmapData.setPixel(x / Heatmap.RESOLUTION, y / Heatmap.RESOLUTION, heatmap.bitmapData.getPixel(xScaled , yScaled) + 15);

		}
	}
	
}