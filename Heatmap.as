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
		public static const RESOLUTION:int = 10;
		public const THRESHOLD:Number = 1 / 3;
		public const PER_FRAME:int = 200;
		public static const MAX_INFLUENCE:int = Main.WIDTH;
		public static const BASE_ALPHA:uint = 0xff000000;
		
		public var baseInfluence:BitmapData;
		public var nextInfluence:Vector.<uint>;
		public var influenceWidth:int;
		public var influenceHeight:int;
		public var startX:int = -1;
		public var startY:int = -1;
		public var isAttracting:Boolean = true;
		public var hasJustRedrawn:Boolean = false;
		protected var offsetToCompute:Vector.<int>;
		protected var valueToCompute:Vector.<int>;
		protected var level:Level;
		
		public function Heatmap(level:Level)
		{
			this.level = level;
			
			influenceWidth = level.hitmap.width / RESOLUTION;
			influenceHeight = level.hitmap.height / RESOLUTION;
			baseInfluence = new BitmapData(influenceWidth, influenceHeight, false, 255);
			baseInfluence.lock();
			var rect:Rectangle = new Rectangle();
			rect.width = RESOLUTION;
			rect.height = RESOLUTION;
			
			for (var i:int = 0; i < influenceWidth; i++)
			{
				for (var j:int = 0; j < influenceHeight; j++)
				{
					rect.x = i * RESOLUTION;
					rect.y = j * RESOLUTION;
					var pixels:Vector.<uint> = level.hitmap.bitmapData.getVector(rect);
					var thresholdCount:int = 0;
					for each(var pixel:uint in pixels)
					{
						if (pixel != 0)
							thresholdCount++;
					}

					if (thresholdCount > pixels.length * THRESHOLD)
					{
						baseInfluence.setPixel32(i, j, 0);
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
				hasJustRedrawn = true;
			}

			nextInfluence = baseInfluence.getVector(baseInfluence.rect);
			offsetToCompute = new Vector.<int>();
			valueToCompute = new Vector.<int>();
			
			var startNewX:int = level.player.x / RESOLUTION;
			var startNewY:int = level.player.y / RESOLUTION;
			var startOffset:int = fromXY(startNewY, startNewX)
			offsetToCompute.push(startOffset);
			
			//If player is not moving to zombies, then zombies will be moving to player !
			var startInfluence:int = BASE_ALPHA + MAX_INFLUENCE;
			if (startNewX == startX && startNewY == startY)
			{
				startInfluence = BASE_ALPHA + 1.5 * MAX_INFLUENCE;
				isAttracting = true;
			}
			else
			{
				isAttracting = false;
			}
			valueToCompute.push(startInfluence);
			nextInfluence[startOffset] = startInfluence + 31; // Avoid blinking when zombie reach destination and is alone.
			startX = startNewX;
			startY = startNewY;
		}
		
		public function updateInfluence(e:Event = null):void
		{
			hasJustRedrawn = false;
			
			if (isAttracting && (Math.floor(level.player.x / RESOLUTION) != startX || Math.floor(level.player.y / RESOLUTION)  != startY))
			{
				//We were calling zombie cause the player was still. However, he moved, so now we revert to standard computing
				//Else, the game lags and zombie keeps swarming around the previous computed spot.
				recomputeInfluence();
				return;
			}
			
			var nbIterations:int = 0;
			while (offsetToCompute.length > 0)
			{
				if (nbIterations++ > PER_FRAME)
					return;
					
				var currentOffset:int = offsetToCompute.shift();
				var currentX:int = xFromOffset(currentOffset);
				var currentY:int = yFromOffset(currentOffset);
					
				var currentValue:uint = valueToCompute.shift() - 7;
				
				for (var i:int = -1; i <= 1; i++)
				{
					for (var j:int = -1; j <= 1; j++)
					{
						if (i == 0 && j == 0)
							continue;
						
						var newOffset:int = fromXY(currentX + i, currentY + j);

						var v:uint = currentValue - Math.abs(i) - Math.abs(j);
						if (nextInfluence[newOffset] != BASE_ALPHA && nextInfluence[newOffset] < v)
						{
							nextInfluence[newOffset] = v;
							offsetToCompute.push(newOffset);
							valueToCompute.push(v);
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