package weapon
{
	import entity.Player;
	import levels.Level;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public final class Uzi extends JungleStyleWeapon
	{
		public function Uzi(level:Level, player:Player)
		{
			magazineCapacity = 15;
			magazineNumber = 15;
			cooldown = 4;
			reloadTime = 30;
			
			super(level, player);
			range = 100;
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