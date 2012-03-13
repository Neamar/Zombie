package achievements.display
{
	import achievements.Achievement;
	import achievements.AchievementsHandler;
	import achievements.display.AchievementItem;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
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
		 * Number of achievement to pick between each level
		 */
		public const ACHIEVEMENTS_TO_PICK_PER_LEVEL:int = 3;
		
		/**
		 * Width (in pixels) for one unity of depth
		 */
		public const WIDTH_PER_DEPTH:int = 50;
		
		/**
		 * Defines the tree and weight of each tree for its layout
		 */
		public var treeWeight:Vector.<Array> = Vector.<Array>([
			["Handgun",	1],
			["Shotgun",	1],
			["Railgun",	.4],
			["Uzi",	1],
			["Player",	.75]
		]);
		
		/**
		 * The handler for the achievements
		 */
		public var handler:AchievementsHandler;
		
		/**
		 * Maximal depth ; beyond that you can't unlock an achievement.
		 */
		public var maxDepth:int;
		
		/**
		 * Translate an ID to a item object.
		 * The ID is a two-dimensional integer ;
		 * the first one being the subtree id, the second one the item id in this particular subtree.
		 */
		public var idToItem:Vector.<Vector.<AchievementItem>> = new Vector.<Vector.<AchievementItem>>();
		
		public var numberOfAchievementsPicked:int = 0;
		
		public var achievementsHelp:AchievementsHelp = new AchievementsHelp();
		
		/**
		 * Create a new screen to display the achievements
		 * 
		 * @param	handler the object managing achievements
		 * @param	tree the tree with all the datas in it. The content of this array is explained in AchievementsHandler::achievementsList
		 * @param	maxDepth the maximal depth achievements can be unlocked
		 * @param	unlocked an array of the already unlocked achievements.
		 */
		public function AchievementsScreen(handler:AchievementsHandler, tree:Vector.<Vector.<Achievement>>, maxDepth:int, unlocked:Vector.<Vector.<int>>)
		{
			this.handler = handler;
			this.maxDepth = maxDepth;
			
			var totalWeight:Number = 0;
			for each(var w:Array in treeWeight)
				totalWeight += w[1];
			
			//What is the maximal size we can allow for a subtree ?
			//Keep 20px of room for a little padding on top and bottom.
			const margin:int = 3;
			var totalHeight:int = Main.WIDTH - margin;
			var currentTop:int = 0;
			this.y = margin;
			
			//Display a rectangle for unselectable items
			this.graphics.beginFill(0x222222, 1);
			this.graphics.drawRect((maxDepth + 1) * WIDTH_PER_DEPTH, 0, Main.WIDTH, totalHeight);
			this.graphics.endFill();
			
			//Define the style for the graph lines
			graphics.lineStyle(1, 0xAAAAAA);
			
			//Display all icons
			for (var subtreeId:int = 0; subtreeId < tree.length; subtreeId++)
			{
				//Create the vector for future access using the achievement coordinates (subtree_id, item_id)
				idToItem[subtreeId] = new Vector.<AchievementItem>(tree[subtreeId].length);
		
				//Create the root item for this tree
				//This function is recursive and will build the whole subtree.
				var root:AchievementItem = addAchievementItem(currentTop + margin, totalHeight * treeWeight[subtreeId][1] / totalWeight - 20, 0, 1, 0, tree[subtreeId], subtreeId);
				
				//Enable the item for click only if it is reachable, i.e it's depth is accessible.
				if(tree[subtreeId][0].depth <= maxDepth)
					root.enable();
					
				currentTop += totalHeight * treeWeight[subtreeId][1] / totalWeight;
			}

			//Activate previously unlocked items
			//This will also enable their children.
			for each(var pos:Vector.<int> in unlocked)
			{
				idToItem[pos[0]][pos[1]].activate();
			}
			
			//Add and hide the help
			addChild(achievementsHelp);
			achievementsHelp.visible = false;
		}
		
		public function destroy():void
		{
			graphics.clear();
			removeChild(achievementsHelp);
			achievementsHelp.graphics.clear();
			while (numChildren != 0)
			{
				(removeChildAt(0) as AchievementItem).destroy();				
			}
		}

		/**
		 * Add a new achievement item on the screen.
		 * 
		 * @param	marginTop constrain the item's y-position between marginTop...
		 * @param	availableHeight ...and availableHeight.
		 * @param	childIndex index of the current child
		 * @param	numChildren number of child to fit on this hierarchy
		 * @param	currentItem current item id in the tree parameter
		 * @param	tree global array of all the data, as defined in AchievementsHandler::achievementsList
		 * @param	subtreeId id of the subtree being built
		 * 
		 * @return newly added item
		 */
		public function addAchievementItem(marginTop:int, availableHeight:int, childIndex:int, numChildren:int, currentItem:int, tree:Vector.<Achievement>, subtreeId:int):AchievementItem
		{
			//Create and position the achievement
			var achievement:AchievementItem = new AchievementItem(this, tree[currentItem]);
			achievement.y = marginTop + (childIndex + .5) * (availableHeight / numChildren);
			achievement.x = 30 + tree[currentItem].depth * WIDTH_PER_DEPTH;
			addChild(achievement);
			
			//Store for future access by coordinates :
			idToItem[subtreeId][currentItem] = achievement;
			
			//Find all children of this particular item
			var children:Vector.<int> = new Vector.<int>();
			for (var i:int = 0; i < tree.length; i++)
			{
				if (tree[i].childOf == currentItem)
					children.push(i);
			}
			
			//Compute where we'll be able to put the children
			var newMarginLeft:int = marginTop + childIndex * availableHeight / numChildren;
			var newAvailableWidth:int = availableHeight / numChildren;
			
			if (children.length > 0)
			{
				graphics.moveTo(achievement.x, achievement.y);
				graphics.lineTo(achievement.x + 20, achievement.y);
					
				//Add all children on the screen
				for (i = 0; i < children.length; i++)
				{
					var child:AchievementItem = addAchievementItem(newMarginLeft, newAvailableWidth, i, children.length, children[i], tree, subtreeId);
					achievement.children.push(child);
					
					graphics.moveTo(achievement.x + 20, achievement.y);
					
					if (children.length > 1)
					{
						graphics.lineTo(achievement.x + 20, child.y);
						graphics.lineTo(child.x, child.y);
					}
					else
					{
						//Workaround for rounding bug causing lines to be badly displayed (achievement.y != child.y)
						graphics.lineTo(child.x, achievement.y);
					}
				}
			}
			
			achievement.addEventListener(MouseEvent.MOUSE_OVER, displayHelp);
			
			return achievement;
		}
		
		/**
		 * Display the tooltip
		 * @param	item the item fir which help should be displayed
		 */
		public function displayHelp(e:MouseEvent):void
		{
			var item:AchievementItem = (e.target) as AchievementItem;
			
			achievementsHelp.visible = true;
			achievementsHelp.x = Math.min(Main.WIDTH - achievementsHelp.width - 2, item.x + item.width/2);
			if (item.y + item.height/2 + 2 + achievementsHelp.height > Main.WIDTH)
				achievementsHelp.y = item.y + item.height/2 - achievementsHelp.height - 2;
			else
				achievementsHelp.y = item.y + item.height/2 + 5;
				
			item.addEventListener(MouseEvent.MOUSE_OUT, removeHelp);
		}
		
		public function removeHelp(e:MouseEvent):void
		{
			achievementsHelp.visible = false;
			
			(e.target as AchievementItem).removeEventListener(MouseEvent.MOUSE_OUT, removeHelp);
		}
		
		public function stackAchievement(achievement:Achievement):void
		{
			handler.stackAchievement(achievement);
			
			numberOfAchievementsPicked++;
			
			//If we picked all the achievements for now, keep going.
			if(numberOfAchievementsPicked >= ACHIEVEMENTS_TO_PICK_PER_LEVEL)			
				dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}