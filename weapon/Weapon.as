package weapon 
{
	import flash.filters.BlurFilter;
	/**
	 * ...
	 * @author Neamar
	 */
	public class Weapon
	{
		public var parent:Level;
		
		protected var cooldown:int;
		protected var lastShot:Date;
		
		public function Weapon(level:Level) 
		{
			this.parent = level;
		}
		
		public function isAbleToFire():Boolean
		{
			return true;
		}
		
		public function fire():void
		{
			throw new Error("Méthode abstraite : fire().");
		}
		
		public function raycast(deltaAngle:Number, limit:int = Main.WIDTH):int
		{
			var theta:Number = parent.player.rotation * Player.TO_RADIANS + deltaAngle;
			var hitmapTest:Function = parent.player.hitmapTest;
			var x:int = parent.player.x;
			var y:int = parent.player.y;
			
			var radius:int = 0;
			
			do
			{
				var curX:int = x + radius * Math.cos(theta);
				var curY:int = y + radius * Math.sin(theta);
				
				for each(var zombie:Zombie in parent.zombies)
				{
					
					if (zombie.x - Zombie.RADIUS < curX && zombie.x + Zombie.RADIUS > curX && zombie.y - Zombie.RADIUS < curY && zombie.y + Zombie.RADIUS > curY)
					{
						if (shoot(zombie) == false)
						{
							//We shot him, but the bullet should stop on this corpse (shoot return false) :
							return radius;
						}
					}
				}
				
				radius++;
				if (radius >= limit)
				{
					break;
				}
			}
			while (hitmapTest(curX, curY) == 0)
			
			return radius;
		}
		
		public function shoot(zombie:Zombie):Boolean
		{
			zombie.kill();
			
			return false;
		}
	}

}