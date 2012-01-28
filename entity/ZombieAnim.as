package entity
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import levels.Level;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class ZombieAnim extends Sprite 
	{
		[Embed(source = "../assets/sprite/zombie/zombie_0.png")]
		public static const spritesClass:Class;
		public static const spritesData:BitmapData = (new Zombie.spritesClass()).bitmapData;
		
		/**
		 * Angles depending on deltaX.
		 * Given deltaX and deltaY, compute (deltaX + 1) * 4 + (delatY + 1) to get the index.
		 * At this index, you'll find the angle.
		 * 
		 * @note The 4 was chosen to improve compution since it is a power of 2, however it forces the vector to integrate "jump values", never used.
		 * @note deltaX = 0 && deltaY == 0 does not exists (can't compute an angle if no moves are made)
		 */
		public const ANGLES:Vector.<int> = Vector.<int>([
			/*dX = -1*/ -45 * 3, 180, 45 * 3, /*jump*/-1,
			/*dX =  0*/ -90, -1, 90, /*jump*/-1,
			/*dX =  1*/ -45, 0, 45
		]);
		
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
		
		public function ZombieAnim()
		{
			//Zombie graphics
			sprites = new Bitmap(Zombie.spritesData);
			scrollRect = new Rectangle( -16, -16, 32, 32);
			sprites.y = -16;
			addChild(sprites);
			setState(STATE_IDLE);
			
			this.graphics.lineStyle(1, 0xFF0000);
			this.graphics.drawRect(-15, -15, 30, 30);
			this.graphics.lineStyle(1, 0x990000);
			this.graphics.moveTo(0, -15);
			this.graphics.lineTo(0, 15);
		}
		
		public function onMove(e:Event):void
		{
			//rotation = ANGLES[(maxI + 1) * 4 + (maxJ + 1)];
			currentStateOffsetPosition = (currentStateOffsetPosition + 1) % currentStateLength;
			sprites.x = -16 - 32 * (currentStateOffsetPosition + currentStateOffset);
			sprites.y = -16 - 32 * currentRotation;
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
			sprites.x = -16 - 32 * currentStateOffset;
		}
	}
	
}