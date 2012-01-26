package weapon 
{
	import entity.Player;
	import entity.Zombie;
	import levels.Level;
	/**
	 * ...
	 * @author Neamar
	 */
	public final class Railgun extends Weapon
	{
		public function Railgun(level:Level, player:Player) 
		{
			cooldown = 45;
			magazineCapacity = Infinity;
			ammoInCurrentMagazine = 50;
			
			super(level, player);
		}
		
		public override function fire():int		{
			if (beforeFiring())
			{
				raycast(0);
			
				return 15;
			}
			return 0;
		}
		
		public override function shoot(zombie:Zombie):Boolean
		{
			super.shoot(zombie);
			
			//Return true so as not to stop raycasting. See raycast() function.
			return true;
		}
	}

}