package entity 
{
	import levels.Level;
	
	/**
	 * A satanus is a very fast zombie.
	 * @author Neamar
	 */
	public final class Satanus extends Zombie 
	{		
		public function Satanus(parent:Level, x:int, y:int) 
		{		
			super(parent, x, y);
		
			speed += 2;
			strengthBlow = 15;
			
			//Behemoth graphics
			this.graphics.clear();
			this.graphics.lineStyle(1, 0xFF0000);
			this.graphics.beginFill(0x0000F0);
			this.graphics.drawCircle(0, 0, RADIUS * .5);
			this.graphics.lineStyle(1, 0);
			this.graphics.lineTo(0, 0);
			this.cacheAsBitmap = true;
		}
	}

}