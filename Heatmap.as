package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class Heatmap extends Bitmap
	{
		public const RESOLUTION:int = 10;
		public const THRESHOLD:Number = 1 / 3;
		public const PER_FRAME:int = 200;
		public const DECAY_FACTOR:int = 5;
		public const MAX_INFLUENCE:int = DECAY_FACTOR * Main.WIDTH / 2;
		public const BASE_ALPHA:uint = 0xff000000;
		
		public var baseInfluence:BitmapData;
		public var nextInfluence:Vector.<uint>;
		public var influenceWidth:int;
		public var influenceHeight:int;
		
		protected var offsetToCompute:Vector.<int>;
		protected var valueToCompute:Vector.<int>;
		
		
		public function Heatmap(hitmap:BitmapData)
		{
			influenceWidth = hitmap.width / RESOLUTION;
			influenceHeight = hitmap.height / RESOLUTION
			baseInfluence = new BitmapData(influenceWidth, influenceHeight, false, 255);
			baseInfluence.lock();
			var rect:Rectangle = new Rectangle();
			rect.width = RESOLUTION;
			rect.height = RESOLUTION;
			
			for (var i:int = 0; i < baseInfluence.width; i++)
			{
				for (var j:int = 0; j < baseInfluence.height; j++)
				{
					rect.x= j * RESOLUTION;
					rect.y = i * RESOLUTION;
					var pixels:Vector.<uint> = hitmap.getVector(rect);
					var thresholdCount:int = 0;
					for each(var pixel:uint in pixels)
					{
						if (pixel != 0)
							thresholdCount++;
					}

					if (thresholdCount > pixels.length * THRESHOLD)
					{
						baseInfluence.setPixel32(j, i, 0);
					}
				}
			}
			
			
			baseInfluence.unlock();
			super(baseInfluence.clone());
			this.scaleX = this.scaleY = RESOLUTION;
			
			recomputeInfluence();
			addEventListener(Event.ENTER_FRAME, updateInfluence);
		}
		
		public function recomputeInfluence():void
		{
			if (nextInfluence)
			{
				bitmapData.setVector(bitmapData.rect, nextInfluence);
				bitmapData.unlock();
			}

			nextInfluence = baseInfluence.getVector(baseInfluence.rect);
			offsetToCompute = new Vector.<int>();
			valueToCompute = new Vector.<int>();
			offsetToCompute.push(fromXY(Level.level.player.y / RESOLUTION, Level.level.player.x / RESOLUTION));
			valueToCompute.push(BASE_ALPHA + MAX_INFLUENCE);
		}
		
		public function updateInfluence(e:Event = null):void
		{
			var nbIterations:int = 0;
			while (offsetToCompute.length > 0)
			{
				if (nbIterations++ > PER_FRAME)
				{
					trace(offsetToCompute.length);
					return;
				}
					
				var currentOffset:int = offsetToCompute.shift();
				var currentX:int = xFromOffset(currentOffset);
				var currentY:int = yFromOffset(currentOffset);
				
				if (currentX < 2 || currentX > influenceWidth - 2 || currentY < 2 ||currentY > influenceHeight - 2)
					continue;
					
				var currentValue:uint = valueToCompute.shift() - DECAY_FACTOR;
				
				for (var i:int = -1; i <= 1; i++)
				{
					for (var j:int = -1; j <= 1; j++)
					{
						if (i == 0 && j == 0)
							continue;
						
						var newOffset:int = fromXY(currentX + i, currentY + j);

						if (nextInfluence[newOffset] != BASE_ALPHA && nextInfluence[newOffset] < currentValue)
						{
							nextInfluence[newOffset] = currentValue;
							offsetToCompute.push(newOffset);
							valueToCompute.push(currentValue);
						}
					}
				}
			}
			
			recomputeInfluence();
		}
		
		public function fromXY(x:int, y:int):int
		{
			return influenceWidth * x + y;
		}
		
		public function xFromOffset(offset:int):int
		{
			return Math.floor(offset / influenceWidth);
		}
		
		public function yFromOffset(offset:int):int
		{
			return offset % influenceWidth;
		}
	}
}