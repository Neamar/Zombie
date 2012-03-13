package achievements.display 
{
	import flash.display.Sprite;
	
	/**
	 * Display some contextual help
	 * @author Neamar
	 */
	public class AchievementsHelp extends Sprite 
	{
		
		public function AchievementsHelp() 
		{
			graphics.lineStyle(1, 0xFF0000);
			graphics.beginFill(0, .5);
			graphics.drawRoundRect(0, 0, 150, 50, 5, 5);
			graphics.endFill();
		}
		
		public function setContent(message:String):void
		{
			
		}
	}

}