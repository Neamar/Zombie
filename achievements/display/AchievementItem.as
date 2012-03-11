package achievements.display 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	
	/**
	 * ...
	 * @author Neamar
	 */
	public final class AchievementItem extends Sprite 
	{
		[Embed(source = "../../assets/achievements/achievement.png")]
		public static const achievementsClass:Class;
		public static const achievementsBitmapData:BitmapData = (new AchievementItem.achievementsClass).bitmapData;

		
		protected var container:AchievementsScreen;
		
		protected var datas:Array;
		public var children:Vector.<AchievementItem> = new Vector.<AchievementItem>();
		
		public function AchievementItem(container:AchievementsScreen, datas:Array) 
		{
			this.container = container;
			this.datas = datas;
			
			var image:Bitmap = new Bitmap(achievementsBitmapData);
			image.x = -image.width / 2;
			image.y = -image.height / 2;
			addChild(image);
			
			this.filters = [new ColorMatrixFilter([1/3, 1/3, 1/3, 0, 0,1/3, 1/3, 1/3, 0, 0, 1/3, 1/3, 1/3, 0, 0, 0, 0, 0, 1, 0])]
		}
		
		public function getDepth():int
		{
			return datas[1];
		}
		
		public function activate(e:MouseEvent = null):void
		{
			//First, disable the achievements to remove listeners
			this.disable();
			
			this.filters = [new GlowFilter(0x0FF00)];
			
			//Enable all available children.
			for each(var child:AchievementItem in children)
			{
				if(child.getDepth() <= container.maxDepth)
					child.enable();
			}
		}
		
		public function enable():void
		{
			this.filters = [];
			this.addEventListener(MouseEvent.CLICK, activate);
		}
		
		public function disable():void
		{
			this.filters = [];
			this.removeEventListener(MouseEvent.CLICK, activate);
		}
	}

}