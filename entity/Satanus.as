package entity
{
	import levels.Level;
	
	/**
	 * A satanus is a very fast zombie.
	 *
	 * "Kill him or get killed"
	 * @author Neamar
	 */
	public final class Satanus extends Zombie
	{
		public function Satanus(parent:Level, x:int, y:int)
		{
			radius = radius * 1.75;
			super(parent, x, y);
			
			speed += 2;
			strengthBlow = 25;
			
			//Behemoth graphics
			this.graphics.clear();
			this.graphics.lineStyle(1, 0xFF0000);
			this.graphics.beginFill(0x0000F0);
			this.graphics.drawCircle(0, 0, radius);
			this.graphics.lineStyle(1, 0);
			this.graphics.lineTo(0, 0);
			this.cacheAsBitmap = true;
		}
		
		public override function onMove():int
		{
			//A satanus always hit : it does not need time to prepare the strike.
			lastEncounter = level.frameNumber - 10;
			
			return super.onMove();
		}
	}

}