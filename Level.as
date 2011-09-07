package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Neamar
	 */
	public class Level extends Sprite
	{
		[Embed(source = "assets/testlevelHitmap.png")] private static var Hitmap:Class;
		[Embed(source = "assets/testlevelBitmap.png")] private static var BitmapLevel:Class;
		
		public var player:Player;
		public var hitmap:Bitmap;
		public var bitmapLevel:Bitmap;
		public var heatmap:Heatmap;
		
		public function Level()
		{
			heatmap= new Heatmap();
			hitmap = new Hitmap();
			player = new Player(this);
			bitmapLevel = new BitmapLevel();
			hitmap.bitmapData.lock();
			
			//Landscape influence :
			var landscapeInfluence:BitmapData = heatmap.addNewLayer('landscape');
			landscapeInfluence.applyFilter(hitmap.bitmapData, hitmap.bitmapData.rect, new Point(), new GlowFilter(0, 1, 30, 30, 2, 12 ));
			heatmap.apply();
			
			
			addChild(bitmapLevel);
			addChild(player);
			addChild(player.lightMask);
			
			player.lightMask.cacheAsBitmap = true;
			this.cacheAsBitmap = true;
			mask = player.lightMask;
			
			Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, toggleDebugMode);
		}
		
		public function toggleDebugMode(e:KeyboardEvent):void
		{
			if(e.keyCode == 84)
			{
				if (bitmapLevel.parent == this)
				{
					removeChild(bitmapLevel);
					removeChild(player.lightMask);
					addChild(heatmap);
					mask = null;
				}
				else
				{
					removeChild(heatmap);
					addChild(bitmapLevel);
					addChild(player.lightMask);
					mask = player.lightMask;
				}
				
				setChildIndex(player, numChildren - 1);
			}
		}
	}
	
}