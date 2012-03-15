package weapon
{
	import entity.Player;
	import levels.Level;
	import sounds.SoundManager;
	
	/**
	 * Shotgun weapon
	 * "Slow but effective"
	 * 
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
			magazineNumber = player.defaultMagazines.shotgun;
			reloadTime = 60;
			halfAmplitude = 10;
			
			super(level, player);
			shotSoundId = SoundManager.SHOTGUN_SHOT;
			reloadSoundId = SoundManager.SHOTGUN_RELOAD;
			noAmmoSoundId = SoundManager.SHOTGUN_NOAMMO;
		}
		
		public override function fire():int
		{
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