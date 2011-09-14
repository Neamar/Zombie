package weapon 
{
	/**
	 * ...
	 * @author Neamar
	 */
	public class Shotgun extends Weapon
	{
		public function Shotgun(level:Level) 
		{
			cooldown = Main.stage.frameRate;
			super(level);
		}
		
		public override function fire():int		{
			super.fire();
			for (var i:int = -10; i <= 10; i+=4)
			{
				raycast(i * Player.TO_RADIANS);
			}
			return 20;
		}
	}

}