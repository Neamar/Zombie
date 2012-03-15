package weapon
{
	import entity.Player;
	import levels.Level;
	import sounds.SoundManager;
	
	/**
	 * Uzi weapon
	 * "Fast and powerful"
	 * 
	 * @author Neamar
	 */
	public final class Uzi extends JungleStyleWeapon
	{
		public function Uzi(level:Level, player:Player)
		{
			magazineCapacity = 15;
			magazineNumber = player.defaultMagazines.uzi;
			cooldown = 4;
			reloadTime = 30;
			
			super(level, player);
			range = 100;
			shotSoundId = SoundManager.UZI_SHOT;
			reloadSoundId = SoundManager.UZI_RELOAD;
			noAmmoSoundId = SoundManager.UZI_NOAMMO;
		}
		
		public override function fire():int
		{
			if (beforeFiring())
			{
				raycast(0);
				
				return 7;
			}
			
			return 0;
		}
	}

}