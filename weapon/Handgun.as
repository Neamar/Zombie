package weapon 
{
	import entity.Player;
	import levels.Level;
	/**
	 * ...
	 * @author Neamar
	 */
	public class Handgun extends Weapon
	{
		public function Handgun(level:Level, player:Player) 
		{
			cooldown = Main.stage.frameRate;
			super(level, player);
		}
		
		public override function fire():int		{
			super.fire();
			raycast(0);
			
			return 5;
		}
	}

}