package weapon 
{
	import entity.Player;
	import entity.Zombie;
	import flash.filters.BlurFilter;
	import levels.Level;
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
		
		protected var magazineCapacity:int;
		
		protected var magazineNumber:int;
		
		protected var ammoInCurrentMagazine:int;
		
		public function Weapon(level:Level, player:Player) 
		{
			this.parent = level;
			this.player = player;
			
			reload();
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
			return 0;
		}
		
		/**
		 * Remove one bullet from current magazine.
		 * 
		 * @return false if the magazine is empty.
		 */
		protected function beforeFiring():Boolean
		{
			if (ammoInCurrentMagazine > 0)
			{
				lastShot = player.frameNumber;
				ammoInCurrentMagazine--;
				
				trace('Shoot !', ammoInCurrentMagazine);
				
				return true;
			}
			
			return false;
		}
		
		public function reload():void
		{
			if (magazineNumber > 0)
			{
				ammoInCurrentMagazine = magazineCapacity;
				magazineNumber--;
			}
			
			trace('Reload !', magazineNumber);
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
							return radius;
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
		
		/**
		 * Base function for shooting a zombie : you kill him, the bullet stops.
		 * @param	zombie to shoot
		 * @return whether the bullet was stopped by the impact
		 */
		public function shoot(zombie:Zombie):Boolean
		{
			zombie.kill();
			
			return false;
		}
	}

}