package 
{
	import entity.Player;
	import entity.Zombie;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import levels.Level;
	
	/**
	 * Heatmap (other names : influence map, potential fields)
	 * 
	 * @see http://aigamedev.com/open/tutorials/potential-fields/
	 * @author Neamar
	 */
	public final class Heatmap extends Bitmap
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
		 * Decay value for each iteration.
		 */
		public const DECAY:int = 7;
		
		/**
		 * Influence under the player.
		 * @note Should be a multiple of RESOLUTION.
		 */
		public static const MAX_INFLUENCE:int = Main.WIDTH + 20;
		
		/**
		 * Width and height of the influence bitmap, storing the influence for each pixels around the player up to MAX_INFLUENCE width.
		 */
		public static const MAX_INFLUENCE_WIDTH:int = (MAX_INFLUENCE / RESOLUTION) + 4;
		
		/**
		 * Halved width.
		 */
		public static const MAX_INFLUENCE_WIDTH2:int = MAX_INFLUENCE_WIDTH / 2;
		
		/**
		 * Some constants to deal with pseudo-non-transparent bitmaps.
		 */
		public static const BASE_ALPHA:uint = 0xff000000;
		
		/**
		 * Default color (when no heatmap)
		 */
		public static const DEFAULT_COLOR:int = 255;
		
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
		 * Flag used to avoid zombie buggering map.
		 */
		public var hasJustRedrawn:Boolean = false;
		
		/**
		 * List of offsets to compute before drawing heatmap.
		 */
		protected var offsetToCompute:Vector.<int> = new Vector.<int>();;
		
		/**
		 * Associated values.
		 */
		protected var valueToCompute:Vector.<int> = new Vector.<int>();;
		
		/**
		 * Parent level
		 */
		protected var level:Level;
		
		/**
		 * Rectangle currently computed
		 * @see http://webr3.org/blog/haxe/bitmapdata-vectors-bytearrays-and-optimization/
		 */
		public var currentRect:Rectangle = new Rectangle(0, 0, MAX_INFLUENCE_WIDTH, MAX_INFLUENCE_WIDTH);
		
		public function Heatmap(level:Level)
		{			
			this.level = level;
			
			influenceWidth = level.hitmap.width / RESOLUTION;
			influenceHeight = level.hitmap.height / RESOLUTION;
			baseInfluence = new BitmapData(influenceWidth, influenceHeight, false, DEFAULT_COLOR);
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
			//For debug purpose. If we display the bitmap, it'll fit nicely with the landscape.
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
				bitmapData.setVector(currentRect, nextInfluence);
				//Add lamplight repulsion
				var player:Player = level.player;
				if (player.lamplightIsRepulsive)
				{
					var lightMask:Shape = player.lightMask;
					bitmapData.draw(lightMask, new Matrix(1 / 5, 0, 0, 1 / 5, -player.x / RESOLUTION, -player.y / RESOLUTION), null, null );
					//Force the central pixel color value
					bitmapData.setPixel(player.x / RESOLUTION, player.y / RESOLUTION, BASE_ALPHA + MAX_INFLUENCE + 31);
				}
				//TODO : what for ?
				bitmapData.unlock();
				hasJustRedrawn = true;
			}

			//Update currentRect for new computation
			currentRect.x = Math.round(Math.min(influenceWidth - currentRect.width, Math.max(0, level.player.x / RESOLUTION - MAX_INFLUENCE_WIDTH2)));
			currentRect.y = Math.round(Math.max(0, level.player.y / RESOLUTION - MAX_INFLUENCE_WIDTH2));
			nextInfluence = baseInfluence.getVector(currentRect);
			nextInfluence.fixed = true;

			//Empty everything
			offsetToCompute.length = 0;
			valueToCompute.length = 0;
			
			var startNewX:int = level.player.x / RESOLUTION - currentRect.x;
			var startNewY:int = level.player.y / RESOLUTION - currentRect.y;
			var startOffset:int = fromXY(startNewY, startNewX);
			offsetToCompute.push(startOffset);
			
			var startInfluence:int = BASE_ALPHA + MAX_INFLUENCE;
			valueToCompute.push(startInfluence);
			nextInfluence[startOffset] = startInfluence + 31; // Avoid blinking when zombie reach destination and is alone.
		}
		
		/**
		 * Called on each frame, add more computational power.
		 * @param	e
		 */
		public function updateInfluence(e:Event = null):void
		{
			hasJustRedrawn = false;
			
			var nbIterations:int = 0;
			while (offsetToCompute.length > 0)
			{
				//Time out.
				if (nbIterations++ > PER_FRAME)
				{
					return;
				}
				
				var currentOffset:int = offsetToCompute.shift();
				var currentX:int = xFromOffset(currentOffset);
				var currentY:int = yFromOffset(currentOffset);
					
				var currentValue:uint = valueToCompute.shift() - DECAY;
				
				var absI:int, absJ:int;
				for (var i:int = -1; i <= 1; i++)
				{
					for (var j:int = -1; j <= 1; j++)
					{
						//Faster than using Math.abs
						absI = i < 0 ? -i:i;
						absJ = j < 0 ? -j:j;
						if (i == 0 && j == 0 || (absI == absJ && absI == 1))
							continue;
						
						var newOffset:int = fromXY(currentX + i, currentY + j);

						var v:uint = currentValue - absI - absJ;
						
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
			return MAX_INFLUENCE_WIDTH * x + y;
		}
		
		/**
		 * nextInfluence manipulation function.
		 * @param	offset
		 * @return x
		 */
		public function xFromOffset(offset:int):int
		{
			return offset / MAX_INFLUENCE_WIDTH;
		}
		
		/**
		 * nextInfluence manipulation function.
		 * 
		 * @param	offset
		 * @return y
		 */
		public function yFromOffset(offset:int):int
		{
			return offset % MAX_INFLUENCE_WIDTH;
		}
	}
}