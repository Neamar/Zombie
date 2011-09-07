package 
{
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	
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
		
		public function Level()
		{
			hitmap = new Hitmap();
			player = new Player();
			hitmap.bitmapData.lock();
			addChild(new BitmapLevel());
			addChild(player);
			addChild(player.lightMask);
			//mask = player.lightMask;
		}
	}
	
}