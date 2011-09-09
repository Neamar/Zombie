package 
{
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class Zombie extends Entity 
	{
		public static const RADIUS:int = 5;
		public const SPEED:int = 3;
		public const REPULSION:int = 15;
		
		public var sleeping:int = 50;
		
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
		
		public function kill():void
		{
			this.filters = [new BlurFilter(8, 8, 2)];
			(parent as Level).bitmapLevel.bitmapData.draw(this, new Matrix(1, 0, 0, 1, x, y));
			(parent as Level).zombies.splice((parent as Level).zombies.indexOf(this), 1);
			removeEventListener(Event.ENTER_FRAME, onFrame);
			parent.removeChild(this);
			this.graphics.clear();

		}
		
		public function onFrame(e:Event):void
		{
			if (sleeping > 0)
			{
				sleeping--;
				return;
			}
			
			var xScaled:int = x / Heatmap.RESOLUTION;
			var yScaled:int = y / Heatmap.RESOLUTION;
			
			var maxI:int = 0;
			var maxJ:int = 0;
			var maxValue:int = heatmap.bitmapData.getPixel(xScaled , yScaled);
			
			for (var i:int = -1; i <= 1; i++)
			{
				for (var j:int = -1; j <= 1; j++)
				{
					if ( i == 0 && j == 0)
						continue;
					
					if (heatmap.bitmapData.getPixel(xScaled + i, yScaled + j) > maxValue)
					{
						maxValue = heatmap.bitmapData.getPixel(xScaled + i, yScaled + j);
						maxI = i;
						maxJ = j;
					}
				}
			}
			
			if (maxI != 0 || maxJ != 0)
			{
				heatmap.bitmapData.setPixel(xScaled, yScaled, heatmap.bitmapData.getPixel(xScaled , yScaled) - REPULSION);

				x += SPEED * maxI;
				y += SPEED * maxJ;
				
				heatmap.bitmapData.setPixel(x / Heatmap.RESOLUTION, y / Heatmap.RESOLUTION, heatmap.bitmapData.getPixel(xScaled , yScaled) + REPULSION);
			}
			else if(maxValue == 255)
			{
				sleeping = 30;
			}
			else
			{
				sleeping = 5;
			}

		}
	}
	
}