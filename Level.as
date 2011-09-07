package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
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
			player = new Player();
			bitmapLevel = new BitmapLevel();
			hitmap.bitmapData.lock();
			
//Landscape influence :
			var landscapeInfluence:BitmapData = heatmap.addNewLayer('landscape');
			landscapeInfluence.applyFilter(hitmap.bitmapData, hitmap.bitmapData.rect, new Point(), new GlowFilter(0, 1, 30, 30, 2, 12 ));
			var playerInfluence:BitmapData = heatmap.addNewLayer('player');
			var playerInfluenceShape:Shape = new Shape();
			var transformationMatrix:Matrix = new Matrix();
			transformationMatrix.createGradientBox(Main.WIDTH, Main.HEIGHT, 0, -Main.WIDTH2, -Main.HEIGHT2);
			playerInfluenceShape.graphics.beginGradientFill(GradientType.RADIAL, [0, 0], [1, .5], [0, 255], transformationMatrix);
			playerInfluenceShape.graphics.drawCircle(0, 0, Main.WIDTH);
			playerInfluence.draw(playerInfluenceShape, new Matrix(1, 0, 0, 1, 200, 200));
			heatmap.apply();
			
			
			addChild(bitmapLevel);
			addChild(player);
			addChild(player.lightMask);
			
			player.lightMask.cacheAsBitmap = true;
			this.cacheAsBitmap = true;
			mask = player.lightMask;
			
		}
	
}