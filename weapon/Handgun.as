package weapon
{
	import entity.Player;
	import levels.Level;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public final class Handgun extends JungleStyleWeapon
	{
		public function Handgun(level:Level, player:Player)
		{
			cooldown = 30;
			magazineCapacity = 3;
			magazineNumber = 10;
			super(level, player);
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