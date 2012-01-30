package entity
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import levels.Level;
	
	/**
	 * A simple zombie
	 * 
	 * "One I can manage, a thousand..."
	 * @author Neamar
	 */
	public class Zombie extends Entity 
	{
		/**
		 * Embed objects
		 */
		[Embed(source = "../assets/sprite/zombie/zombie_0.png")]
		public static const spritesClass:Class;
		public static const spritesData:BitmapData = (new Zombie.spritesClass()).bitmapData;
		
		[Embed(source = "../assets/sprite/zombie/splatter.png")]
		public static const splatterClass:Class;
		public static const splatter:Bitmap = new Zombie.splatterClass();

		/**
		 * Events
		 */
		public static const ZOMBIE_DEAD:String = "zombieDead";

		
		/**
		 * Zombie radius.
		 * For drawing, block, and shoot.
		 */
		public var radius:int = 5;
		
		/**
		 * When a zombie is asked to sleep, how long it should be. (in frames)
		 */
		public const SLEEP_DURATION:int = 30;
		
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
		public const REPULSION:int = 15;
		
		/**
		 * Angles depending on deltaX.
		 * Given deltaX and deltaY, compute (deltaX + 1) * 4 + (delatY + 1) to get the index.
		 * At this index, you'll find the angle.
		 * 
		 * @note The 4 was chosen to improve compution since it is a power of 2, however it forces the vector to integrate "jump values", never used.
		 * @note deltaX = 0 && deltaY == 0 does not exists (can't compute an angle if no moves are made)
		 */
		public const ANGLES:Vector.<int> = Vector.<int>([
			/*dX = -1*/ 2,  1, 0, /*jump*/-1,
			/*dX =  0*/ 3, -1, 7, /*jump*/-1,
			/*dX =  1*/ 4, 5, 6
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
		 * The level the zombies live on
		 */
		public var level:Level;
		
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
		 * The first time the zombie meets the player, we store the current frameNumber in this variable.
		 * The next time we're near the player, we check this value.
		 * - If too much time passed since last encounter, he should "prepare" himself again (and thus not strike for this frame)
		 * - If the last encounter was in our last waking phase, the player forgot (or was unable) to move : hit him.
		 * 
		 * In other words, this variable allos for a "prepare before strike" time.
		 */
		public var lastEncounter:int = -1;
		
		/**
		 * Shortcut to heatmap.bitmapData
		 */
		public var influenceMap:BitmapData;
		
		/**
		 * States of a zombie.
		 * @see setState()
		 */
		public const STATE_IDLE:int = 0;
		public const STATE_WALKING:int = 1;
		public const STATE_HITTING:int = 2;
		public const STATE_HITTING2:int = 3;
		public const STATE_BLOCK:int = 4;
		public const STATE_DIE:int = 5;
		public const STATE_DIE2:int = 6;
		
		/**
		 * Offset and length to use regarding the sprites bitmap
		 * Offset is the first picture to use,
		 * Length is the length of the states
		 * Index corresponds to the associated STATE_ value, e.g. index 2 is STATE_HITTING.
		 */
		public static const statesOffset:Vector.<int> = Vector.<int>([0, 4,	12, 16,	20,	22,	28]);
		public static const statesLength:Vector.<int> = Vector.<int>([4, 8,	 4,  4,  2,  6,  8]);
		
		/**
		 * Store zombie current rotation (from 0 to 7)
		 */
		public var currentRotation:int;
		
		/**
		 * Store zombie current state
		 */
		protected var currentState:int;
		
		/**
		 * Store the offset and the length to use for the current state
		 */
		protected var currentStateOffset:int;
		protected var currentStateLength:int;
		
		/**
		 * Store the current image used
		 */
		protected var currentStateOffsetPosition:int;
		
		/**
		 * All sprites for all states.
		 * Wille be masked using scrollRect
		 */
		protected var sprites:Bitmap;
		
		/**
		 * Rectangle to use for scrollRect (to clip the sprite)
		 */
		protected var spritesRect:Rectangle = new Rectangle( 0, 0, 64, 64);
		
		/**
		 * Determine which animation to use : hit or bite ?
		 * (no ingame changes)
		 */
		protected var isBiter:int = 2 * Math.random();
		protected var isExplodingOnDeath:int = 2 * Math.random();
		
		public function Zombie(parent:Level, x:int, y:int)
		{
			this.x = x;
			this.y = y;
			this.level = parent;
			maxInfluence = Heatmap.MAX_INFLUENCE
			super(parent);
			influenceMap = heatmap.bitmapData;
			
			//Zombie graphics
			sprites = new Bitmap(Zombie.spritesData);
			sprites.scrollRect = spritesRect;
			sprites.y = -32;
			sprites.x = -32;
			addChild(sprites);
			setState(STATE_IDLE);
		}
		
		/**
		 * Kill the zombie.
		 */
		public function kill():void
		{
			//Remove current zombie from global zombies list
			(parent as Level).zombies.splice((parent as Level).zombies.indexOf(this), 1);

			//Add splatters
			var matrix:Matrix = new Matrix(1, 0, 0, 1, x - splatter.width / 2, y - splatter.height / 2);
			(parent as Level).bitmapLevel.bitmapData.draw(splatter, matrix, null, null, null, true);
			
			//Start death animation. When the animation completes, the zombie will be removed from everywhere
			move = onMoveDead;

			//Inform the level we're dead :
			parent.dispatchEvent(new Event(ZOMBIE_DEAD));
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
				//Animation
				if (currentState != STATE_IDLE)
					setState(STATE_IDLE);
					
				//Player ain't near. We may as well go to sleep to save some CPU.
				return 25;
			}
			
			if (maxValue >= MAX_INFLUENCE)
			{
				//We are "on" the player : let's fight !
				
				if (lastEncounter + 10 == level.frameNumber)
				{
					//Hit the player !
					this.hit();
					
					//Prepare ourselves to hit the player again in two wakes :
					lastEncounter = level.frameNumber + 10;
				}
				else
				{
					lastEncounter = level.frameNumber;
				}

				//Animation
				if (currentState != STATE_HITTING + isBiter)
				{
					setState(STATE_HITTING + isBiter);
					//Animation is long and the player may die before we finish hitting him, so start at offset 3
					currentStateOffsetPosition = 3;
				}
				currentStateOffsetPosition = (currentStateOffsetPosition + 1) % currentStateLength;
				spritesRect.x = 64 * (currentStateOffsetPosition + currentStateOffset);
				sprites.scrollRect = spritesRect;
				
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
				
				//Animation
				if (currentState != STATE_WALKING)
					setState(STATE_WALKING);
				
				currentRotation = ANGLES[(maxI + 1) * 4 + (maxJ + 1)];
				currentStateOffsetPosition = (currentStateOffsetPosition + 1) % (4 * currentStateLength);
				spritesRect.x = 64 * ((currentStateOffsetPosition >> 3) + currentStateOffset);
				spritesRect.y = 64 * currentRotation;
				sprites.scrollRect = spritesRect;
				
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
<<<<<<< HEAD
		 * Animation for dying
		 * @return 8 (number of frames before next part of the animation)
		 */
		public function onMoveDead():int
		{
			if (currentState != STATE_DIE + isExplodingOnDeath)
				setState(STATE_DIE + isExplodingOnDeath);
			
			currentStateOffsetPosition = currentStateOffsetPosition + 1;
			if (currentStateOffsetPosition == currentStateLength)
			{
				//He's dead, and has been on the floor for a time long enough.
				//Draw the dead zombies on the map
				this.filters = [new BevelFilter(.5)];
				this.graphics.beginFill(0xFF0000);
				this.graphics.drawCircle(0, 0, 5);
				(parent as Level).bitmapLevel.bitmapData.draw(this, new Matrix(1, 0, 0, 1, x, y));
				parent.removeChild(this);
				
				return 0;
			}
			
			spritesRect.x = 64 * (currentStateOffsetPosition + currentStateOffset);
			sprites.scrollRect = spritesRect;

			return 4;
		}
		
		/**
		 * Define the state to use
		 * Must be a STATE_ constant.
		 * 
		 * @param	newState the state to enter
		 */
		public function setState(newState:int):void
		{
			currentState = newState;
			currentStateOffsetPosition = 0;
			currentStateOffset = statesOffset[currentState];
			currentStateLength = statesLength[currentState];
			
			//Offset to first sprite
			spritesRect.x = 64 * currentStateOffset;
			sprites.scrollRect = spritesRect;
		}
		
		/**
		 * Hit the player !
		 */
		public function hit():void
		{
			level.player.hit(this, strengthBlow);
		}
	}
}