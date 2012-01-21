package entity
{
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import levels.Level;
	import Utilitaires.geom.Vector;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class Zombie extends Entity 
	{
		/**
		 * Zombie radius.
		 * For drawing, block, and shoot.
		 */
		public static const RADIUS:int = 5;
		
		/**
		 * When a zombie is asked to sleep, how long it should be. (in frames)
		 */
		public static const SLEEP_DURATION:int = 30;
		
		/**
		 * Moving speed (in manhattan-px)
		 */
		public var speed:int = 3;
		
		/**
		 * To get swarming behavior, zombies should push themselves.
		 */
		public static const REPULSION:int = 15;
		
		/**
		 * Number of frames to precompute (for vector length).
		 * Should be greater than SLEEP_DURATION + 10.
		 */
		public static const MAX_DURATION:int = 100;
		
		/**
		 * Angles depending on deltaX.
		 * Given deltaX and deltaY, compute (deltaX + 1) * 4 + (delatY + 1) to get the index.
		 * At this index, you'll find the angle.
		 * 
		 * @note The 4 was chosen to improve compution since it is a power of 2, however it forces the vector to integrate "jump values", never used.
		 * @note deltaX = 0 && deltaY == 0 does not exists (can't compute an angle if no moves are made)
		 */
		public static const ANGLES:Vector.<int> = Vector.<int>([
			/*dX = -1*/ -45 * 3, 180, 45 * 3, /*jump*/-1,
			/*dX =  0*/ -90, -1, 90, /*jump*/-1,
			/*dX =  1*/ -45, 0, 45
		]);
		
		/**
		 * Which zombie should awake in which frame ?
		 */
		public static var frameWaker:Vector.<Vector.<Zombie>> = new Vector.<Vector.<Zombie>>(MAX_DURATION);
		
		/**
		 * Current frame number % MAX_DURATION
		 */
		public static var frameNumber:int = 0;
		
		/**
		 * Don't forget to call this method before instantiating any zombie !
		 * Populate frameWaker.
		 */
		public static function init():void
		{
			Main.stage.addEventListener(Event.ENTER_FRAME, onFrame);
			for (frameNumber = 0; frameNumber < MAX_DURATION; frameNumber++)
			{
				frameWaker[frameNumber] = new Vector.<Zombie>();
			}
			frameNumber = 0;
		}
		
		/**
		 * This static function awake any zombies that registered for a watch on this frame.
		 * @param	e
		 */
		public static function onFrame(e:Event = null):void
		{
			frameNumber = (frameNumber + 1) % MAX_DURATION;
			
			var currentFrame:Vector.<Zombie> = frameWaker[frameNumber];
			while(currentFrame.length > 0)
			{
				currentFrame.pop().move();
			}
		}
		
		/**
		 * Function the zombie uses to move.
		 * Can be replaced, for instance when zombie is dead ;)
		 * Therefore, we don't need to remove him from the frame , when he'll awake, he'll see he's dead.
		 */
		public var move:Function = onMove;
		
		/**
		 * Influence the zombie try to reach
		 */
		public var maxInfluence:int;

		/**
		 * Is the zombie going to hit the player nextFrame ?
		 */
		public var willHit:Boolean = true;

		public function Zombie(parent:Level, x:int, y:int)
		{
			this.x = x;
			this.y = y;
			maxInfluence = Heatmap.MAX_INFLUENCE
			super(parent);
			
			//Zombie graphics
			this.graphics.lineStyle(1, 0xFF0000);
			this.graphics.beginFill(0xF00000);
			this.graphics.drawCircle(0, 0, RADIUS);
			this.graphics.lineStyle(1, 0);
			this.graphics.lineTo(0, 0);
			this.cacheAsBitmap = true;
			
			//Random starting-wake.
			nextWakeIn(30 + SLEEP_DURATION * Math.random());
			
		}
		
		/**
		 * Kill the zombie.
		 */
		public function kill():void
		{
			//Draw the dead zombies on the map
			this.filters = [new BlurFilter(8, 8, 2)];
			(parent as Level).bitmapLevel.bitmapData.draw(this, new Matrix(1.4, 0, 0, 1.4, x, y));
			this.graphics.clear();
			
			//Remove current zombie from global zombies list
			(parent as Level).zombies.splice((parent as Level).zombies.indexOf(this), 1);

			//Avoid null pointer exception, should the zombie awake in some future frame.
			move = function():void { };
			parent.removeChild(this);
		}
		
		public function onMove():void
		{
			var xScaled:int = x / Heatmap.RESOLUTION;
			var yScaled:int = y / Heatmap.RESOLUTION;
			
			var maxI:int = 0;
			var maxJ:int = 0;
			var maxValue:int = heatmap.bitmapData.getPixel(xScaled , yScaled);
			
			//Are we on the heatmap ? If not, just sleep again (more common case).
			if (maxValue == Heatmap.DEFAULT_COLOR)
			{
				//Player ain't near. We may as well go to sleep to save some CPU.
				nextWakeIn(25);
					
				return;
			}
			
			//Are we on the player ? If so, hit him.
			if (maxValue >= maxInfluence)
			{
				if (willHit)
				{
					//Hit the player !
					this.hit();
					willHit = false;
				}
				else
				{
					willHit = true;
				}
				nextWakeIn(10);
				
				return;
			}
			
			//Find the highest potential around the zombie
			for (var i:int = -1; i <= 1; i++)
			{
				for (var j:int = -1; j <= 1; j++)
				{
					//Identity move is not interesting ;)
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
					//Do not undo-repulsion if a redraw has just occured, else we get flickering behavior.
					heatmap.bitmapData.setPixel(xScaled, yScaled, heatmap.bitmapData.getPixel(xScaled , yScaled) + REPULSION);
				}
				
				//Move toward higher potential
				x += speed * maxI;
				y += speed * maxJ;
				rotation = ANGLES[(maxI + 1) * 4 + (maxJ + 1)];
				
				//Store repulsion
				xScaled = x / Heatmap.RESOLUTION;
				yScaled = y / Heatmap.RESOLUTION;
				heatmap.bitmapData.setPixel(xScaled, yScaled, Math.max(0, heatmap.bitmapData.getPixel(xScaled, yScaled) - REPULSION));
				
				nextWakeIn(1);
			}
			else
			{
				//No move : some other zombies are probably blocking us.
				//Wait a little to let everything boil down.
				nextWakeIn(10 + SLEEP_DURATION * Math.random());
			}
		}
		
		public function hit():void
		{
			(parent as Level).player.hit(this);
		}
		
		/**
		 * Register current zombie for future awakening.
		 * @param	duration (frame)
		 */
		public function nextWakeIn(duration:int):void
		{
			frameWaker[(frameNumber + duration) % MAX_DURATION].push(this);
		}
	}
	
}