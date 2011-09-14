package weapon 
{
	/**
	 * ...
	 * @author Neamar
	 */
	public class Railgun extends Weapon
	{
		public function Railgun(level:Level) 
		{
			cooldown = Main.stage.frameRate;
			super(level);
		}
		
		public override function fire():int		{
			super.fire();
			raycast(0);
			
			return 15;
		}
		
		public override function shoot(zombie:Zombie):Boolean
		{
			super.shoot(zombie);
			
			return true;
		}
	}

}