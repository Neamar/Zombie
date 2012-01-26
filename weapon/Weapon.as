package weapon 
{
	import entity.Player;
	import entity.Zombie;
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
		public var cooldown:int;
		
		/**
		 * Number of frames before the player can fire again after hitting "reload"
		 */
		public var reloadTime:int = -1;
		
		/**
		 * Id of last frame this weapon was used
		 */
		protected var lastShot:Number = 0;
		
		/**
		 * Capacity for a magazine
		 */
		public var magazineCapacity:int;
		
		/**
		 * Number of magazine availables
		 */
		public var magazineNumber:int;
		
		/**
		 * Ammunition in the currently loade magazine
		 */
		public var ammoInCurrentMagazine:int;
		
		/**
		 * Range of the weapon, in pixel.
		 */
		public var range:int;
		
		public function Weapon(level:Level, player:Player) 
		{
			this.parent = level;
			this.player = player;
			
			range = 150;
			if(reloadTime == -1)
				reloadTime = 2 * cooldown;
			
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
				
				return true;
			}
			
			return false;
		}
		
		public function reload():void
		{
			//Do not reload if the magazine is full or you don't have any more magazine
			if (magazineNumber > 0 && ammoInCurrentMagazine != magazineCapacity)
			{
				ammoInCurrentMagazine = magazineCapacity;
				magazineNumber--;
				
				//Forbid firing before reload "finish".
				//To do this, emulate a shoot.
				lastShot = player.frameNumber + reloadTime - cooldown;
			}
		}
		
		/**
		 * Throw a bullet in the direction asked for.
		 * 
		 * @param	deltaAngle (rad) offset current rotation with this angle.
		 * @param	limit max px before giving up and considering bullet lost.
		 * @return radius to the last casualty
		 */
		protected function raycast(deltaAngle:Number):int
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
				if (radius >= range)
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