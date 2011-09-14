package weapon 
{
	/**
	 * ...
	 * @author Neamar
	 */
	public class Handgun extends Weapon
	{
		public function Handgun(level:Level) 
		{
			cooldown = Main.stage.frameRate;
			super(level);
		}
		
		public override function fire():int		{
			super.fire();
			raycast(0);
			
			return 5;
		}
	}

}