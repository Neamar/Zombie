package weapon 
{
	import entity.Player;
	import levels.Level;
	/**
	 * ...
	 * @author Neamar
	 */
	public final class Shotgun extends Weapon
	{
		public function Shotgun(level:Level, player:Player) 
		{
			cooldown = 40;
			magazineCapacity = 1;
			magazineNumber = 4;
			reloadTime = 60;
			
			super(level, player);
		}
		
		public override function fire():int		{
			if (beforeFiring())
			{
				//Amplitude goes from -10° to +10°, delta : 4. Max : 5 deaths.
				for (var i:int = -10; i <= 10; i+=4)
				{
					raycast(i * Player.TO_RADIANS);
				}
				
				return 20;
			}
			
			return 0;
		}
	}

}