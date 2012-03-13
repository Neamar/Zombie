package achievements.display 
{
	import achievements.Achievement;
	import achievements.weapon.RangeAchievement;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Static class handling the images for an item
	 * For optimisation purposes, only one bitmapdata is generated for each type of achievements
	 * 
	 * @author Neamar
	 */
	public final class AchievementItemImage extends Sprite 
	{
		[Embed(source = "../../assets/achievements/achievement.png")]
		public static const achievementsClass:Class;
		public static const achievementsBitmapData:BitmapData = (new AchievementItemImage.achievementsClass).bitmapData;
		
		[Embed(source = "../../assets/achievements/range_achievement.png")]
		public static const range_achievementsClass:Class;
		public static const range_achievementsBitmapData:BitmapData = (new AchievementItemImage.range_achievementsClass).bitmapData;
		
		public static var achievementImage:Dictionary = new Dictionary();
		achievementImage[RangeAchievement] = range_achievementsBitmapData;//TODO: aweful

		public static function getImageFor(achievement:Achievement):BitmapData
		{
			trace(achievement)
			if (achievement is RangeAchievement)
				return range_achievementsBitmapData;
			else
				return achievementsBitmapData;
		}

	}

}