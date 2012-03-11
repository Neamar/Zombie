package achievements.display 
{
	import achievements.Achievement;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	
	/**
	 * An AchievementItem.
	 * Technically speaking, this a graphical container allowing the player to pick an achievement
	 * Technical data is embedded in the datas attribute.
	 * 
	 * @author Neamar
	 */
	public final class AchievementItem extends Sprite 
	{
		[Embed(source = "../../assets/achievements/achievement.png")]
		public static const achievementsClass:Class;
		public static const achievementsBitmapData:BitmapData = (new AchievementItem.achievementsClass).bitmapData;

		public static const emptyFilter:Array = [];
		public static const activatedFilter:Array = [new GlowFilter(0x0FF00)];
		public static const defaultFilter:Array = [new ColorMatrixFilter([1 / 3, 1 / 3, 1 / 3, 0, 0, 1 / 3, 1 / 3, 1 / 3, 0, 0, 1 / 3, 1 / 3, 1 / 3, 0, 0, 0, 0, 0, 1, 0])];
		/**
		 * Store the item parent, in order to access the maxDepth attributes.
		 */
		protected var container:AchievementsScreen;
		
		/**
		 * Which achievement are we holding ?
		 * @see AchievementsHandler::achievementList
		 */
		protected var achievement:Achievement;
		
		/**
		 * Stores the children of this item
		 */
		public var children:Vector.<AchievementItem> = new Vector.<AchievementItem>();
		
		/**
		 * Build a new Achievement container
		 * 
		 * @param	container parent of this item
		 * @param	datas the datas to use to generate tehc achievement once this item is clicked
		 */
		public function AchievementItem(container:AchievementsScreen, achievement:Achievement) 
		{
			this.container = container;
			this.achievement = achievement;
			
			//Add an image inside
			var image:Bitmap = new Bitmap(achievementsBitmapData);
			image.x = -image.width / 2;
			image.y = -image.height / 2;
			addChild(image);
			
			//As a default, black-and-white the item to show it is unavailable.
			this.filters = defaultFilter;
			
			//Display tooltip on mouseover
			this.addEventListener(MouseEvent.MOUSE_OVER, displayTooltip);
		}
		
		public function destroy():void
		{
			this.removeEventListener(MouseEvent.MOUSE_OVER, displayTooltip);
			removeChildAt(0);
			disable();
			container = null;
			achievement = null;
			children = null;
		}
		
		/**
		 * Return the depth of the current item
		 * @return depth
		 */
		public function getDepth():int
		{
			return achievement.depth;
		}
		
		public function getMessage():String
		{
			return achievement.message;
		}
		
		/**
		 * Give the player the selected achievement
		 * @param	e
		 */
		public function activate(e:MouseEvent = null):void
		{
			//First, disable the item to remove listeners
			this.disable();
			
			//Then add filter to show it is activated
			this.filters = activatedFilter;
			
			//And enable all available children.
			for each(var child:AchievementItem in children)
			{
				if(child.getDepth() <= container.maxDepth)
					child.enable();
			}
			
			//If the event is null, it means we've been called directly and there is no need
			//to inform our parent.
			//Else,bubble up the information.
			if (e != null)
			{			
				//Eventually, inform our parent we've been picked
				container.stackAchievement(achievement);
			}
		}
		
		/**
		 * Enable graphically the item, allowing the player to pick it
		 */
		public function enable():void
		{
			this.filters = emptyFilter;
			this.addEventListener(MouseEvent.CLICK, activate);
		}
		
		/**
		 * Disable the item, forbidding the player to pick it.
		 */
		public function disable():void
		{
			this.filters = emptyFilter;
			this.removeEventListener(MouseEvent.CLICK, activate);
		}
		
		protected function displayTooltip(e:Event):void
		{
			//TODO: remove
			container.handler.game.hud.displayMessage(achievement.message);
		}
	}

}