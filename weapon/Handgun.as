package weapon 
{
	import entity.Player;
	import levels.Level;
	/**
	 * ...
	 * @author Neamar
	 */
	public final class Handgun extends Weapon
	{
		public function Handgun(level:Level, player:Player) 
		{
			cooldown = Main.stage.frameRate;
			magazineCapacity = 6;
			magazineNumber = 50;
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