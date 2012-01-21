package entity 
{
	import levels.Level;
	/**
	 * ...
	 * @author Neamar
	 */
	public class Survivor extends Zombie 
	{
		public function Survivor(parent:Level, x:int, y:int) 
		{
			super(parent, x, y);
			
			this.graphics.clear();
			this.graphics.lineStyle(1, 0x0000FF);
			this.graphics.beginFill(0x0000F0);
			this.graphics.drawCircle(0, 0, RADIUS);
			this.graphics.lineStyle(1, 0);
			this.graphics.lineTo(0, 0);
		}
		
		/**
		 * Survivor are not allowed to hit the player ;)
		 */
		public override function hit():void
		{
			
		}
		
		public override function kill():void
		{
			trace('You killed a civilian!');
			
			//Remove current survivor from global survivor list
			(parent as Level).survivors.splice((parent as Level).survivors.indexOf(this), 1);
			
			super.kill();
		}
	}

}