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
		
		public var player:Player;
		
		/**
		 * Number of frames between two shoots
		 */
		protected var cooldown:int;
		
		/**
		 * Id of last frame this weapon was used
		 */
		protected var lastShot:Number = 0;
		
		public function Weapon(level:Level, player:Player) 
		{
			this.parent = level;
			this.player = player;
		}
		
		/**
		 * 
		 * @return true if cooldown ok.
		 */
		public function isAbleToFire():Boolean
		{
			return (player.frameNumber - lastShot > cooldown);
		}
		
		/**
		 * Use the weapon.
		 * You need to check isAbleToFire() before using this method.
		 * 
		 * @return brightness of the deflagration, from 0 to 20.
		 */
		public function fire():int
		{
			lastShot = player.frameNumber;
			
			return 0;
		}
		
		/**
		 * Throw a bullet in the direction asked for.
		 * 
		 * @param	deltaAngle (rad) offset current rotation with this angle.
		 * @param	limit max px before giving up and considering bullet lost.
		 * @return radius to the last casualty
		 */
		protected function raycast(deltaAngle:Number, limit:int = Main.WIDTH):int
		{
			var theta:Number = player.rotation * Player.TO_RADIANS + deltaAngle;
			var hitmapTest:Function = player.hitmapTest;
			var x:int = player.x;
			var y:int = player.y;
			
			var radius:int = 0;
			var cos:Number = Math.cos(theta);
			var sin:Number = Math.sin(theta);
			do
			{
				var curX:int = x + radius * cos;
				var curY:int = y + radius * sin;
				
				for each(var zombie:Zombie in parent.zombies)
				{
					
					if (zombie.x - Zombie.RADIUS < curX && zombie.x + Zombie.RADIUS > curX && zombie.y - Zombie.RADIUS < curY && zombie.y + Zombie.RADIUS > curY)
					{
						if (shoot(zombie) == false)
						{
							//We shot him, but the bullet should stop on this corpse (shoot() returns false) :
							break;
						}
					}
				}
				
				radius += Zombie.RADIUS;
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