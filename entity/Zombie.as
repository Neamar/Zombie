package entity
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import levels.Level;
	
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
		 * Strength of the blow a zombie gives when hitting the player
		 */
		public var strengthBlow:int = 30;
		
		/**
		 * To get swarming behavior, zombies should push themselves.
		 */
		public static const REPULSION:int = 15;
		
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
		 * To speed everything, we should not access static vars from another class.
		 * Hence, we just duplicate them.
		 * 
		 * @see http://blog.controul.com/2009/04/how-slow-is-static-access-in-as3avm2-exactly/
		 * @see Heatmap
		 */
		public static const RESOLUTION:int = Heatmap.RESOLUTION;
		public static const DEFAULT_COLOR:int = Heatmap.DEFAULT_COLOR;
		public static const MAX_INFLUENCE:int = Heatmap.MAX_INFLUENCE;
		
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
		
		/**
		 * Shortcut to heatmap.bitmapData
		 */
		public var influenceMap:BitmapData;

		public function Zombie(parent:Level, x:int, y:int)
		{
			this.x = x;
			this.y = y;
			maxInfluence = Heatmap.MAX_INFLUENCE
			super(parent);
			influenceMap = heatmap.bitmapData;
			
			//Zombie graphics
			this.graphics.lineStyle(1, 0xFF0000);
			this.graphics.beginFill(0xF00000);
			this.graphics.drawCircle(0, 0, RADIUS);
			this.graphics.lineStyle(1, 0);
			this.graphics.lineTo(0, 0);
			this.cacheAsBitmap = true;
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
		
		public function onMove():int
		{
			var xScaled:int = x / RESOLUTION;
			var yScaled:int = y / RESOLUTION;
			
			var maxI:int = 0;
			var maxJ:int = 0;
			var maxValue:int = influenceMap.getPixel(xScaled , yScaled);
			
			//Are we on the heatmap ? If not, just sleep.
			if (maxValue == DEFAULT_COLOR)
			{
				//Player ain't near. We may as well go to sleep to save some CPU.
				return 25;
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
				return 10;
			}
			
			//We're on the heatmap, and we can't hit the player ? Move toward him
			//Find the highest potential around the zombie
			for (var i:int = -1; i <= 1; i++)
			{
				for (var j:int = -1; j <= 1; j++)
				{
					//Identity move is not interesting ;)
					if ( i == 0 && j == 0)
						continue;
					
					if (influenceMap.getPixel(xScaled + i, yScaled + j) > maxValue)
					{
						maxValue = influenceMap.getPixel(xScaled + i, yScaled + j);
						maxI = i;
						maxJ = j;
					}
				}
			}
			
			if (maxI != 0 || maxJ != 0)
			{
				if (!heatmap.hasJustRedrawn)
				{
					//Do not undo-repulsion if a redraw has just occured, else we get flickering behavior.
					influenceMap.setPixel(xScaled, yScaled, influenceMap.getPixel(xScaled , yScaled) + REPULSION);
				}
				
				//Move toward higher potential
				x += speed * maxI;
				y += speed * maxJ;
				rotation = ANGLES[(maxI + 1) * 4 + (maxJ + 1)];
				
				//Store repulsion
				xScaled = x / RESOLUTION;
				yScaled = y / RESOLUTION;
				influenceMap.setPixel(xScaled, yScaled, Math.max(0, influenceMap.getPixel(xScaled, yScaled) - REPULSION));
				
				return 1;
			}
			
			//No move available : some zombies are probably blocking us.
			//Wait a little to let everything boil down.
			return 10 + SLEEP_DURATION * Math.random();
		}
		
		/**
		 * Hit the player !
		 */
		public function hit():void
		{
			(parent as Level).player.hit(this, strengthBlow);
		}
	}
}