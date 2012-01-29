package weapon 
{
	import entity.Player;
	import levels.Level;
	/**
	 * ...
	 * @author Neamar
	 */
	public final class Uzi extends Weapon
	{
		public function Uzi(level:Level, player:Player) 
		{
			magazineCapacity = 20;
			magazineNumber = 15;
			
			//Low cooldown, but enough to avoid one shoot per frame.
			cooldown = Main.stage.frameRate / 15;
			super(level, player);
		}
		
		public override function fire():int		{
			
			if (beforeFiring())
			{
				raycast(0);
				
				return 7;
			}
			
			return 0;
		}
	}

}