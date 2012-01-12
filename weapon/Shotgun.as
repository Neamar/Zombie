package weapon 
{
	import entity.Player;
	/**
	 * ...
	 * @author Neamar
	 */
	public class Shotgun extends Weapon
	{
		public function Shotgun(level:Level, player:Player) 
		{
			cooldown = Main.stage.frameRate;
			super(level, player);
		}
		
		public override function fire():int		{
			super.fire();
			
			//Amplitude goes from -10° to +10°, delta : 4. Max : 5 deaths.
			for (var i:int = -10; i <= 10; i+=4)
			{
				raycast(i * Player.TO_RADIANS);
			}
			
			return 20;
		}
	}

}