package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * Head Up Display for the player
	 * 
	 * @author Neamar
	 */
	public final class Hud extends Sprite 
	{
		/**
		 * Text format for the style to use when displaying message
		 */
		protected var textFormat:TextFormat = new TextFormat(null, null, null, true);
		
		/**
		 * Y-coordinate where a message should disappear
		 */
		protected var finalMessagePosition:int = Main.WIDTH - 120;
		public function Hud() 
		{
		}
		
		/**
		 * Display a message
		 * @param	msg
		 */
		public function displayMessage(msg:String, color:int = 0xFFFFFF):void
		{
			var message:TextField = new TextField();
			message.defaultTextFormat = textFormat;
			message.selectable = false;
			message.mouseEnabled = false;
			message.textColor = color;
			message.width = Main.WIDTH;
			message.y = int(Main.WIDTH + 5 + 15 * Math.random());
			message.autoSize = TextFieldAutoSize.CENTER;
			message.multiline = false;
			message.filters = [new BlurFilter(0, 0)];

			addChild(message);
			message.text = msg;
			
			message.addEventListener(Event.ENTER_FRAME, moveMessage);
		}
		
		protected function moveMessage(e:Event):void
		{
			var message:TextField = (e.target as TextField);
			message.y -=2;
			
			/**
			 * Rentrer dans la zone "à effets" pour faire disparaître le message
			 */
			if (message.y <= finalMessagePosition + 90)
			{
				if (message.y <= finalMessagePosition + 30)
				{
					message.alpha = (message.y - finalMessagePosition) / 60;
					var filter:BlurFilter = (message.filters[0] as BlurFilter);
					filter.blurY = 48 - 48 * (message.y - finalMessagePosition) / 30;
					message.filters = [filter];
				}
				else
				{
					message.alpha = (message.y - finalMessagePosition) / 45 + .5
				}
			}
			
			/**
			 * Fin du voyage !
			 */
			if (message.y == finalMessagePosition)
			{
				message.filters = [];
				message.removeEventListener(Event.ENTER_FRAME, moveMessage);
				removeChild(message);
			}
		}
	}

}