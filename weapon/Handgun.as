package weapon
{
	import entity.Player;
	import levels.Level;
	import sounds.SoundManager;
	
	/**
	 * Handgun weapon
	 * "You always need reliable fallback"
	 * 
	 * @author Neamar
	 */
	public final class Handgun extends JungleStyleWeapon
	{
		public function Handgun(level:Level, player:Player)
		{		
			cooldown = 30;
			magazineCapacity = 3;
			magazineNumber = player.defaultMagazines.handgun;
			super(level, player);
			
			firingSoundId = SoundManager.HANDGUN_NOAMMO;
			reloadSoundId = SoundManager.HANDGUN_NOAMMO;
			noAmmoSoundId = SoundManager.HANDGUN_NOAMMO;
		}
		
		public override function fire():int
		{
			if (beforeFiring())
			{
				raycast(0);
				
				return 5;
			}
			
			return 0;
		}
	}

}