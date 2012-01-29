package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * Head Up Display for the player
	 * 
	 * @author Neamar
	 */
	public final class Hud extends Sprite 
	{
		protected var finalMessagePosition:int = Main.WIDTH - 120;
		
		public function Hud() 
		{

		}
		
		/**
		 * Display a message
		 * @param	msg
		 */
		public function displayMessage(msg:String):void
		{
			var message:TextField = new TextField();
			message.textColor = 0xFFFFFF;
			message.width = Main.WIDTH;
			message.y = Main.WIDTH + 15;
			message.autoSize = TextFieldAutoSize.CENTER;
			message.multiline = false;
			addChild(message);
			message.text = msg;
			
			message.addEventListener(Event.ENTER_FRAME, moveMessage);
		}
		
		protected function moveMessage(e:Event):void
		{
			var message:TextField = (e.target as TextField);
			message.y -=2;
			
			if (message.y <= finalMessagePosition + 90)
			{
				if (message.y <= finalMessagePosition + 30)
				{
					message.alpha = (message.y - finalMessagePosition) / 60
				}
				else
				{
					message.alpha = (message.y - finalMessagePosition) / 45 + .5
				}
			}
			
			if (message.y == finalMessagePosition)
			{
				message.removeEventListener(Event.ENTER_FRAME, moveMessage);
				removeChild(message);
			}
		}
	}

}