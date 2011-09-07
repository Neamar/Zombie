package 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Neamar
	 */
	public class Level extends Sprite
	{
		[Embed(source = "assets/testlevel.png")] private static var Hitmap:Class;
		
		public var player:Player;
		public var hitmap:Bitmap;
		
		public function Level()
		{
			hitmap = new Hitmap();
			player = new Player();
			hitmap.bitmapData.lock();
			addChild(hitmap);
			addChild(player);
		}
	}
	
}