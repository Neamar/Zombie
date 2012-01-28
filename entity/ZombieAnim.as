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
		 * States of a zombie
		 */
		public const STATE_IDLE:int = 0;
		public const STATE_WALKING:int = 1;
		public const STATE_HITTING:int = 2;
		public const STATE_HITTING2:int = 3;
		public const STATE_BLOCK:int = 4;
		public const STATE_DIE:int = 5;
		public const STATE_DIE2:int = 6;
		
		public const statesOffset:Vector.<int> = Vector.<int>([
			0,
			4,
			12,
			16,
			20,
			22,
			28
		]);
		
		public const statesLength:Vector.<int> = Vector.<int>([
			4,
			8,
			4,
			4,
			2,
			6,
			8
		]);
		
		protected var currentState:int;
		protected var currentStateOffset:int;
		protected var currentStateLength:int;
		protected var currentStateOffsetPosition:int;
		
		protected var sprites:Bitmap;
		
		public function ZombieAnim()
		{
			setState(STATE_IDLE);
			
			//Zombie graphics
			sprites = new Bitmap(Zombie.spritesData);
			scrollRect = new Rectangle(-16, -16, 32, 32);
			sprites.x = - 21;
			sprites.y = -12;
			
			this.graphics.lineStyle(1, 0xFF0000);
			this.graphics.drawRect(-16, -16, 32, 32);
			this.graphics.lineStyle(1, 0x990000);
			this.graphics.moveTo(0, -12);
			this.graphics.lineTo(0, 24);
			addChild(sprites);
		}
		
		public function onMove(e:Event):void
		{
			//rotation = ANGLES[(maxI + 1) * 4 + (maxJ + 1)];
			currentStateOffsetPosition = (currentStateOffsetPosition + 1) % currentStateLength;
			sprites.x = -16 - 32 * (currentStateOffsetPosition + currentStateOffset);
		}
		
		public function setState(newState:int):void
		{
			currentState = newState;
			currentStateOffsetPosition = 0;
			currentStateOffset = statesOffset[currentState];
			currentStateLength = statesLength[currentState];
		}
	}
	
}