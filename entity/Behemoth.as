package entity 
{
	import levels.Level;
	
	/**
	 * A behemoth is a slow but very strong zombie
	 * 
	 * "Take your time to aim"
	 * @author Neamar
	 */
	public final class Behemoth extends Zombie 
	{
		/**
		 * Max behemoth life
		 */
		public const MAX_HEALTHPOINTS:int = 8;
		
		/**
		 * Current health of the behemoth.
		 * If damagesTaken > MAX_HEALTHPOINTS, he dies
		 */
		public var damagesTaken:int = 0;
		
		public function Behemoth(parent:Level, x:int, y:int) 
		{
			radius = radius * 2;
			super(parent, x, y);
		
			speed--;
			strengthBlow = 40;
			
			//Behemoth graphics
			this.graphics.clear();
			this.graphics.lineStyle(1, 0xFF0000);
			this.graphics.beginFill(0x00F000);
			this.graphics.drawCircle(0, 0, radius);
			this.graphics.lineStyle(1, 0);
			this.graphics.lineTo(0, 0);
			this.cacheAsBitmap = true;
		}
		
		/**
		 * A behemoth does not die instantly
		 */
		public override function kill():void
		{
			damagesTaken++;
			
			if (damagesTaken >= MAX_HEALTHPOINTS)
			{
				super.kill();
			}
		}
		
	}

}