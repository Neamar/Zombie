package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public class Player extends Sprite
	{
		public const RADIUS:int = 10;
		public const SPEED:int = 4;
		
		public var bindings:Object = { UP:38, DOWN:40, LEFT:37, RIGHT:39 };
		public var downKeys:Vector.<int> = new Vector.<int>();
		
		public function Player()
		{
			x = 200;
			y = 250;
			
			this.graphics.lineStyle(2);
			this.graphics.beginFill(0xAAAAAA, 1);
			this.graphics.drawCircle(0, 0, RADIUS);
			this.graphics.lineTo(0, 0);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
			Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Main.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		protected function onKeyDown(e:KeyboardEvent):void
		{
			if (downKeys.indexOf(e.keyCode) == -1)
			{
				downKeys.push(e.keyCode);
			}
		}
		
		protected function onKeyUp(e:KeyboardEvent):void
		{
			downKeys.splice(downKeys.indexOf(e.keyCode), 1);
		}
		
		protected function onFrame(e:Event):void
		{
			var angle:Number = Math.atan2(y - parent.mouseY, x - parent.mouseX);
			rotation = (Math.PI + angle) * 57.2957795;
			for each(var downKey:int in downKeys)
			{
				if (downKey == bindings.UP)
				{
					x += SPEED * Math.cos(rotation * 0.0174532925);
					y += SPEED * Math.sin(rotation * 0.0174532925);
				}
				else if (downKey == bindings.DOWN)
				{
					x -= SPEED * Math.cos(rotation * 0.0174532925);
					y -= SPEED * Math.sin(rotation * 0.0174532925);
				}
			}
		}
	}
	
}