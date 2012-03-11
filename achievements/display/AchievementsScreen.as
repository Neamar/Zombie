package achievements.display
{
	import achievements.display.AchievementItem;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.utils.Dictionary;

	/**
	 * This class is used to display the tree of all achievements.
	 * Since it is computationally expensive, we don't keep it in memory during the levels.
	 * Therefore, it is recomputed at the end of each level, and marked available for GC at the beginning of another level.
	 */
	public final class AchievementsScreen extends Sprite
	{
		/**
		 * Maximal depth ; beyond that you can't unlock an achievement.
		 */
		public var maxDepth:int;
		
		/**
		 * Translate an ID to a sprite object.
		 */
		public var idToItem:Vector.<Vector.<AchievementItem>> = new Vector.<Vector.<AchievementItem>>();
		
		public function AchievementsScreen(tree:Vector.<Array>, maxDepth:int, unlocked:Vector.<Vector.<int>>)
		{
			this.maxDepth = maxDepth;
			
			//Define the style for the graph lines
			graphics.lineStyle(1, 0xAAAAAA);
			
			//What is the maximal size we can allow for a subtree ?
			var subtreeLength:int = (Main.WIDTH - 20) / tree.length;
			this.y = 10;
			
			//Display all icons
			for (var subtreeId:int = 0; subtreeId < tree.length; subtreeId++)
			{
				//Create the vector for future access using the achievement coordinates (subtree_id, item_id)
				idToItem[subtreeId] = new Vector.<AchievementItem>(tree[subtreeId].length);
				
				//Create the root item for this tree
				var root:AchievementItem = addAchievement(subtreeId * subtreeLength, subtreeLength, 0, 1, 0, tree[subtreeId], subtreeId);
				
				//Enable the item for click only if it is reachable
				if(tree[subtreeId][0][1] <= maxDepth)
					root.enable();
			}

			//Check unlocked items
			for each(var pos:Vector.<int> in unlocked)
			{
				idToItem[pos[0]][pos[1]].activate();
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
		 * @param	subtreeId id of the current subtree
		 * 
		 * @return newly added image
		 */
		public function addAchievement(marginLeft:int, availableWidth:int, childIndex:int, numChildren:int, currentItem:int, tree:Array, subtreeId:int):AchievementItem
		{
			//Position the achievement
			var achievement:AchievementItem = new AchievementItem(this, tree[currentItem]);
			achievement.y = marginLeft + (childIndex + .5) * (availableWidth / numChildren);
			achievement.x = 30 + tree[currentItem][1] * 50;
			addChild(achievement);
			
			//Store for access by coordinates :
			idToItem[subtreeId][currentItem] = achievement;
			
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
				graphics.moveTo(achievement.x, achievement.y);
				graphics.lineTo(achievement.x + 20, achievement.y);
					
				for (i = 0; i < children.length; i++)
				{
					var child:AchievementItem = addAchievement(newMarginLeft, newAvailableWidth, i, children.length, children[i], tree, subtreeId);
					achievement.children.push(child);
					
					graphics.moveTo(achievement.x + 20, achievement.y);
					graphics.lineTo(achievement.x + 20, child.y);
					graphics.lineTo(child.x, child.y);
				}
			}
			
			return achievement;
		}
	}
}