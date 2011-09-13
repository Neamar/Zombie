package 
{
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import Utilitaires.geom.Vector;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class Zombie extends Entity 
	{
		public static const RADIUS:int = 5;
		public const SLEEP_DURATION:int = 30;
		public const SPEED:int = 3;
		public const REPULSION:int = 15;
		
		public static var frameWaker:Vector.<Vector.<Zombie>> = new Vector.<Vector.<Zombie>>(100);
		public static var frameNumber:int = 0;
		
		public static function init():void
		{
			
			Main.stage.addEventListener(Event.ENTER_FRAME, onFrame);
			for (frameNumber = 0; frameNumber < frameWaker.length; frameNumber++)
			{
				frameWaker[frameNumber] = new Vector.<Zombie>();
			}
			frameNumber = 0;
		}
		
		public static function onFrame(e:Event = null):void
		{
			frameNumber = (frameNumber + 1) % frameWaker.length;
			
			var currentFrame:Vector.<Zombie> = frameWaker[frameNumber];
			while(currentFrame.length > 0)
			{
				currentFrame.pop().move();
			}
		}
		
		public var move:Function = onMove;
		
		public function Zombie(parent:Level, x:int, y:int)
		{
			this.x = x;
			this.y = y;
			super(parent);
			
			this.graphics.lineStyle(1, 0xFF0000);
			this.graphics.beginFill(0xF00000);
			this.graphics.drawCircle(0, 0, RADIUS);
			this.graphics.moveTo(0, 0);
			
			nextWakeIn(30 + SLEEP_DURATION * Math.random());
			
		}
		
		public function kill():void
		{
			this.filters = [new BlurFilter(8, 8, 2)];
			(parent as Level).bitmapLevel.bitmapData.draw(this, new Matrix(1.4, 0, 0, 1.4, x, y));
			(parent as Level).zombies.splice((parent as Level).zombies.indexOf(this), 1);
			removeEventListener(Event.ENTER_FRAME, onFrame);
			parent.removeChild(this);
			this.graphics.clear();
			move = function():void { };

		}
		
		public function onMove():void
		{
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
				if (!(parent as Level).heatmap.hasJustRedrawn)
				{
					heatmap.bitmapData.setPixel(xScaled, yScaled, heatmap.bitmapData.getPixel(xScaled , yScaled) + REPULSION);
				}
				
				x += SPEED * maxI;
				y += SPEED * maxJ;
				
				xScaled = x / Heatmap.RESOLUTION;
				yScaled = y / Heatmap.RESOLUTION;
				heatmap.bitmapData.setPixel(xScaled, yScaled, Math.max(0, heatmap.bitmapData.getPixel(xScaled, yScaled) - REPULSION));
				
				nextWakeIn(1);
			}
			else
			{
				nextWakeIn(10 + SLEEP_DURATION * Math.random());
			}

			
		}
		
		public function nextWakeIn(duration:int):void
		{
			frameWaker[(frameNumber + duration) % frameWaker.length].push(this);
		}
	}
	
}