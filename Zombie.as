package 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class Zombie extends Entity 
	{
		public const RADIUS:int = 5;
		
		public function Zombie(parent:Level)
		{
			x = 300;
			y = 200;
			super(parent);
			
			this.graphics.lineStyle(1, 0xFF0000);
			this.graphics.beginFill(0xF00000);
			this.graphics.drawCircle(0, 0, RADIUS);
			this.graphics.moveTo(0, 0);
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		public function onFrame(e:Event):void
		{
			
		}
	}
	
}