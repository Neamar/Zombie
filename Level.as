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
		
		/**
		 * B&W map listing (un-)available places.
		 */
		public var hitmap:Bitmap;
		
		/**
		 * Texture for the game
		 */
		public var bitmapLevel:Bitmap;
		
		/**
		 * Influence map, to compute easily multiples pathfindings without burying CPU
		 * 
		 * @see http://aigamedev.com/open/tutorials/potential-fields/
		 */
		public var heatmap:Heatmap;
		
		public function Level()
		{
			heatmap= new Heatmap();
			hitmap = new Hitmap();
			player = new Player(this);
			bitmapLevel = new BitmapLevel();
			//Small optimisation, available since we never update the hitmap
			hitmap.bitmapData.lock();
			
			//Landscape influence, to allow foe to escape obstacles.
			var landscapeInfluence:BitmapData = heatmap.addNewLayer('landscape');
			landscapeInfluence.applyFilter(hitmap.bitmapData, hitmap.bitmapData.rect, new Point(), new GlowFilter(0, 1, 30, 30, 2, 12 ));
			heatmap.apply();
			
			//Layouting everything on the display list
			addChild(bitmapLevel);
			addChild(player);
			addChild(player.lightMask);//Mask ought to be added, else it ain't taken into account
			
			player.lightMask.cacheAsBitmap = true;//If not cached, mask won't apply alpha.
			this.cacheAsBitmap = true;//Same.
			mask = player.lightMask;
			
			Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, toggleDebugMode);
		}
		
		/**
		 * Press T to toggle debug mode and view the influence map.
		 * @param	e
		 */
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
				
				//Player ought to be visible at any time
				setChildIndex(player, numChildren - 1);
			}
		}
	}
	
}