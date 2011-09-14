package weapon 
{
	/**
	 * ...
	 * @author Neamar
	 */
	public class Uzi extends Weapon
	{
		public function Uzi(level:Level) 
		{
			cooldown = Main.stage.frameRate / 15;
			super(level);
		}
		
		public override function fire():int		{
			super.fire();
			raycast(0);
			
			return 7;
		}
	}

}