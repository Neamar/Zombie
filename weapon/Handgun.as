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
			super(level);
		}
		
		public override function fire():void
		{
			raycast(0);
		}
	}

}