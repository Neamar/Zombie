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
		/**
		 * Amplitude of the shot.
		 * One bullet will go every 4° for [-halfAmplitude, halfAmplitude]
		 * Default : amplitude goes from -10° to +10° (halfAmplitude = 10), delta : 4. Max : 5 deaths.
		 */
		public var halfAmplitude:int;
		
		public function Shotgun(level:Level, player:Player) 
		{
			cooldown = 40;
			magazineCapacity = 1;
			magazineNumber = 4;
			reloadTime = 60;
			halfAmplitude = 10;
			
			super(level, player);
		}
		
		public override function fire():int		{
			if (beforeFiring())
			{
				for (var i:int = -halfAmplitude; i <= halfAmplitude; i += 4)
				{
					raycast(i * Player.TO_RADIANS);
				}
				
				return 20;
			}
			
			return 0;
		}
	}

}