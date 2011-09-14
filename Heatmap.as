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
		/**
		 * To which scale shall we compute the Heatmap ?
		 * The higher the better and the slower.
		 */
		public static const RESOLUTION:int = 10;
		
		/**
		 * If THRESHOLD pixels are blocking, consider this Heatmap pixel as blocked.
		 */
		public const THRESHOLD:Number = 1 / 3;
		
		/**
		 * Max number of computation to do in one given frame
		 */
		public const PER_FRAME:int = 200;
		
		/**
		 * Decay factor for each iteration.
		 */
		public const DECAY:int = 7;
		
		/**
		 * Influence under the player
		 */
		public static const MAX_INFLUENCE:int = Main.WIDTH;
		
		/**
		 * Some constants to deal with pseudo-non-transparent bitmaps.
		 */
		public static const BASE_ALPHA:uint = 0xff000000;
		
		/**
		 * Base heatmap drawn according to the hitmap.
		 * Every computation uses this bitmap as a base.
		 */
		public var baseInfluence:BitmapData;
		
		/**
		 * Current value computation. Not in bitmapdata for now to improve performance.
		 * 
		 * @see fromXY()
		 * @see fromOffset()
		 */
		public var nextInfluence:Vector.<uint>;
		
		/**
		 * Width for the heatmap
		 */
		public var influenceWidth:int;
		
		/**
		 * Height for the heatmap
		 */
		public var influenceHeight:int;
		
		/**
		 * x-position of the player when we launched current computation
		 */
		public var startX:int = -1;
		
		/**
		 * y-position of the player.
		 */
		public var startY:int = -1;
		
		/**
		 * When player is not moving, he is attracting zombies to himself.
		 */
		public var isAttracting:Boolean = true;
		
		/**
		 * Flag used to avoid zombie buggering map.
		 */
		public var hasJustRedrawn:Boolean = false;
		
		/**
		 * List of offsets to compute before drawing heatmap.
		 */
		protected var offsetToCompute:Vector.<int>;
		
		/**
		 * Associated value.
		 */
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
			
			//Compute baseInfluence according to the hitmap.
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
			//Don't forget to clone ! Elsewise, we'll be drawing over and over.
			super(baseInfluence.clone());
			//For debug purpose. If we display the bitmap, it'll print nicely.
			this.scaleX = this.scaleY = RESOLUTION;
			
			recomputeInfluence();
			addEventListener(Event.ENTER_FRAME, updateInfluence);
		}
		
		/**
		 * Restart anew the calculation.
		 */
		public function recomputeInfluence():void
		{
			if (nextInfluence)
			{
				//Draw last pass result.
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
			nextInfluence[startOffset] = startInfluence + 2 * Zombie.REPULSION + 1; // Avoid blinking when zombie reach destination and is alone.
			startX = startNewX;
			startY = startNewY;
		}
		
		/**
		 * Call on each frame, add more computational power.
		 * @param	e
		 */
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
				//Time out.
				if (nbIterations++ > PER_FRAME)
					return;
				
				var currentOffset:int = offsetToCompute.shift();
				var currentX:int = xFromOffset(currentOffset);
				var currentY:int = yFromOffset(currentOffset);
					
				var currentValue:uint = valueToCompute.shift() - DECAY;
				
				for (var i:int = -1; i <= 1; i++)
				{
					for (var j:int = -1; j <= 1; j++)
					{
						if (i == 0 && j == 0)
							continue;
						
						var newOffset:int = fromXY(currentX + i, currentY + j);

						var v:uint = currentValue - Math.abs(i) - Math.abs(j);
						
						//Do we have a better path than the previous one ?
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
		
		/**
		 * nextInfluence manipulation function.
		 * @param	x
		 * @param	y
		 * @return offset
		 */
		public function fromXY(x:int, y:int):int
		{
			return influenceWidth * x + y;
		}
		
		/**
		 * nextInfluence manipulation function.
		 * @param	offset
		 * @return x
		 */
		public function xFromOffset(offset:int):int
		{
			return offset / influenceWidth;
		}
		
		/**
		 * nextInfluence manipulation function.
		 * 
		 * @param	offset
		 * @return y
		 */
		public function yFromOffset(offset:int):int
		{
			return offset % influenceWidth;
		}
	}
}