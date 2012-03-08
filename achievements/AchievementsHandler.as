package achievements 
{
	import achievements.player.*;
	import achievements.weapon.*;
	import entity.Player;
	import flash.display.Sprite;
	import flash.events.Event;
	import weapon.*;
	/**
	 * Handle the list of unlocks.
	 * 
	 * TODO : remove event zombie dead
	 * TODO : remove code handling hot-plugging achievements
	 * 
	 * @author Neamar
	 */
	public class AchievementsHandler 
	{
		/**
		 * List of all the available achievements.
		 * 
		 * Each row respects the following structure :
		 * [achievement:Achievement, ...params]
		 * 
		 * where achievement is a Class (and not an object)
		 * params is the params to use for the achievements
		 */
		public var achievementsList:Vector.<Array> = Vector.<Array>([
		
		//Handgun achievement tree
		[
			[-1, 0, "Handgun unlocked.", UnlockAchievement, Handgun],
			[0, 1, "Increased range for the handgun", RangeAchievement, Handgun, 250],
			[1, 2, "Infinite range for the handgun", RangeAchievement, Handgun, 3000],
			[0, 1, "Higher capacity for the handgun: 6 bullets", CapacityAchievement, Handgun, 6],
			[3, 2, "Higher capacity for the handgun: 10 bullets", CapacityAchievement, Handgun, 10],
			[4, 4, "Higher capacity for the handgun : 16 bullets", CapacityAchievement, Handgun, 16],
			[0, 1, "Jungle-style reload for the handgun", JungleAchievement, Handgun, true],
			[0, 2, "Faster cooldown for the handgun", CooldownAchievement, Handgun, 20],
			[7, 3, "Faster cooldown for the handgun", CooldownAchievement, Handgun, 15],
			[0, 4, "Faster reload for the handgun", ReloadAchievement, Handgun, 30],			
			[0, 4, "Automatic reload for the handgun", AutomaticAchievement, Handgun, true],
		],
		
		//Shotgun achievement tree
		[
			[-1, 1, "Shotgun unlocked.", UnlockAchievement, Shotgun],
			[0, 2, "Increased range for the shotgun", RangeAchievement, Shotgun, 200],
			[1, 3, "Increased range for the shotgun", RangeAchievement, Shotgun, 300],
			[2, 6, "Infinite range for the shotgun", RangeAchievement, Shotgun, 3000],
			[0, 2, "Higher capacity for the shotgun : 2 bullets", CapacityAchievement, Shotgun, 2],
			[4, 4, "Higher capacity for the shotgun : 6 bullets", CapacityAchievement, Shotgun, 6],
			[0, 3, "Faster cooldown for the shotgun", CooldownAchievement, Shotgun, 30],
			[6, 5, "Faster cooldown for the shotgun", CooldownAchievement, Shotgun, 20],
			[0, 4, "Faster reload for the shotgun", ReloadAchievement, Shotgun, 40],
			[0, 5, "Automatic reload for the shotgun", AutomaticAchievement, Shotgun, true],
			[0, 5, "Wider shot for the shotgun", AmplitudeAchievement, Shotgun, 14],
			[10, 7, "Wider shot for the shotgun", AmplitudeAchievement, Shotgun, 16],
		],
		
		//Railgun achievement tree
		[
			[-1, 2, "Unlock Railgun", UnlockAchievement, Railgun],
			[0, 4, "Infinite range for the railgun", RangeAchievement, Railgun, 3000],
			[0, 3, "Faster cooldown for the handgun", CooldownAchievement, Railgun, 30],
			[2, 5, "Faster cooldown for the railgun", CooldownAchievement, Railgun, 20],
		],
		
		//Uzi achievement tree
		[
			[-1, 4, "Unlock Uzi", UnlockAchievement, Uzi],
			[0, 5, "Increased range for the uzi", RangeAchievement, Uzi, 150],
			[1, 7, "Increased range for the uzi", RangeAchievement, Uzi, 200],
			[2, 8, "Infinite range for the uzi", RangeAchievement, Uzi, 3000],
			[0, 5, "Jungle-style reload for the uzi", JungleAchievement, Uzi, true],
			[0, 5, "Higher capacity for the uzi : 25 bullets", CapacityAchievement, Uzi, 25],
			[5, 6, "Higher capacity for the uzi : 30 bullets", CapacityAchievement, Uzi, 30],
			[0, 7, "Faster cooldown for the uzi", CooldownAchievement, Uzi, 2],
			[0, 7, "Faster reload for the uzi", ReloadAchievement, Uzi, 15],
			[0, 8, "Automatic reload for the uzi", AutomaticAchievement, Uzi, true],
		],
		
		//Player achievement tree
		[
			[-1, 2, "Enable Player Achievement", LifeAchievement, 50],
			[0, 3, "Increased subconscious vision (10%)", SubconcsiousVisionAchievement, 10],
			[1, 5, "Increased subconscious vision (15%)", SubconcsiousVisionAchievement, 15],
			[2, 7, "Increased subconscious vision (20%)", SubconcsiousVisionAchievement, 20],
			[0, 4, "More life for the player", LifeAchievement, 75],
			[4, 6, "More life for the player", LifeAchievement, 100],
			[0, 3,"Faster recuperation for the player", ConvalescenceAchievement, 2],
			[6, 5, "Faster recuperation for the player", ConvalescenceAchievement, 1],
			[0, 4, "Wider vision for the player", VisionAchievement, 60],
			[0, 6, "Tamed bloodrush", BloodrushAchievement, true],	
		],
		]);
		
		/**
		 * Game associated with those achievements
		 */
		public var game:Game;

		/**
		 * The sprite which display all achievements.
		 * null when it is not displayed.
		 */
		private var achievementsScreen:AchievementsScreen = null;
		
		/**
		 * Creates the handler.
		 * @param	game to operate on
		 * @param	startAtAchievement whether or not to directly unlock some achievement (to restore previous session for instance)
		 */
		public function AchievementsHandler(game:Game, startAtAchievement:int = 0) 
		{
			this.game = game;
		}
		
		/**
		 * Create a new sprite, displaying all the achievements.
		 * @return the interactive sprite with all the achievements.
		 */
		public function getAchievementsScreen():Sprite
		{
			achievementsScreen = new AchievementsScreen(achievementsList);
			return achievementsScreen;
		}
		
		/**
		 * Apply achievement precedently recorded (from another game, or another level)
		 */
		public function applyDefaultsAchievements():void
		{
			//TODO
		}
		
		/**
		 * Apply the achievement.
		 * 
		 * @param	datas an array, respecting the row-structure of achievementsList
		 * @return achievement string (to be displayed)
		 */
		protected function applyAchievement(datas:Array):String
		{
			var currentAchievement:Achievement = new datas[1]();
			currentAchievement.setGame(game);
			currentAchievement.setParams(datas.slice(2));

			currentAchievement.apply();
			
			return datas[0];
		}
	}
}



import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;

class AchievementsScreen extends Sprite
{
	[Embed(source = "../assets/achievements/achievement.png")]
	public static const achievementsClass:Class;
	public static const achievementsData:BitmapData = (new AchievementsScreen.achievementsClass).bitmapData;
	
	public function AchievementsScreen(tree:Vector.<Array>)
	{
		graphics.lineStyle(1, 0xAAAAAA);
		//Which is the maximal size we can allow for a subtree ?
		var subtreeLength:int = Main.WIDTH / tree.length;
		
		for (var subtreeId:int = 0; subtreeId < tree.length; subtreeId++)
		{
			addAchievement(subtreeId * subtreeLength, subtreeLength, 0, 1, 0, tree[subtreeId]);
		}
	}

	/**
	 * Add a new achivement tile on the screen.
	 * 
	 * @param	marginLeft constrain the item between marginLeft...
	 * @param	availableWidth ...and availableWidth.
	 * @param	childIndex index of the current child
	 * @param	numChildren number of child to fit on this hierarchy
	 * @param	currentItem current item id in the tree array
	 * @param	tree global array
	 * 
	 * @return newly added image
	 */
	public function addAchievement(marginLeft:int, availableWidth:int, childIndex:int, numChildren:int, currentItem:int, tree:Array):Bitmap
	{
		//Position the achievement
		var achievement:Bitmap = new Bitmap(achievementsData);
		achievement.x = marginLeft + (childIndex + .5) * (availableWidth / numChildren) - achievement.width/2;
		achievement.y = 30 + tree[currentItem][1] * 50 - achievement.height/2;
		addChild(achievement);
		
		//Find all childs and add them
		var children:Vector.<int> = new Vector.<int>();
		for (var i:int = 0; i < tree.length; i++)
		{
			if (tree[i][0] == currentItem)
				children.push(i);
		}
		
		var newMarginLeft:int = marginLeft + childIndex * availableWidth / numChildren;
		var newAvailableWidth:int = availableWidth / numChildren;
		
		if (children.length > 0)
		{
			graphics.moveTo(achievement.x + achievement.width/2, achievement.y);
			graphics.lineTo(achievement.x + achievement.width/2, achievement.y + 25);
				
			for (i = 0; i < children.length; i++)
			{
				var child:Bitmap = addAchievement(newMarginLeft, newAvailableWidth, i, children.length, children[i], tree);
				
				graphics.moveTo(achievement.x + achievement.width/2, achievement.y + 25);
				graphics.lineTo(child.x + child.width/2, achievement.y + 25);
				graphics.lineTo(child.x + child.width/2, child.y);
			}
		}
		return achievement;
	}
}