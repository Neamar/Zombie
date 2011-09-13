﻿package {
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.system.System;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	public class MovieMonitor extends Sprite {
		private var xml:XML;
		private var theText:TextField;
		private var fps:int=0;
		private var ms:uint;
		private var lastTimeCheck:uint;
		private var maxMemory:Number=0;
		private var fpsVector:Vector.<Number>=new Vector.<Number>();
		private var childrenCount:int;
		public function MovieMonitor():void {
			xml =
			<xml>
			<sectionTitle>FPS MONITOR</sectionTitle>
			<sectionLabel>FPS: </sectionLabel>
			<framesPerSecond>-</framesPerSecond>
			<sectionLabel>Minute average: </sectionLabel>
			<averageFPS>-</averageFPS>
			<sectionLabel>ms per frame: </sectionLabel>
			<msFrame>-</msFrame>
			<sectionTitle>MEMORY MONITOR</sectionTitle>
			<sectionLabel>Direct: </sectionLabel>
			<directMemory>-</directMemory>
			<sectionLabel>Max direct: </sectionLabel>
			<directMemoryMax>-</directMemoryMax>
			<sectionLabel>Total: </sectionLabel>
			<veryTotalMemory>-</veryTotalMemory>
			<sectionLabel>Garbage: </sectionLabel>
			<garbageMemory>-</garbageMemory>
			<sectionTitle>STAGE MONITOR</sectionTitle>
			<sectionLabel>Children: </sectionLabel>
			<nChildren>-</nChildren>
			<sectionTitle>GAME MONITOR</sectionTitle>
			<sectionLabel>Zombie:</sectionLabel>
			<nZombie>-</nZombie>
			<sectionLabel>--active:</sectionLabel>
			<nActiveZombie>-</nActiveZombie>
			<sectionLabel>Weapon:</sectionLabel>
			<currentWeapon>-</currentWeapon>
			</xml>;
			var style:StyleSheet = new StyleSheet();
			style.setStyle("xml",{fontSize:"9px",fontFamily:"arial"});
			style.setStyle("sectionTitle",{color:"#FFAA00"});
			style.setStyle("sectionLabel",{color:"#CCCCCC",display:"inline"});
			style.setStyle("framesPerSecond",{color:"#FFFFFF"});
			style.setStyle("msFrame",{color:"#FFFFFF"});
			style.setStyle("averageFPS",{color:"#FFFFFF"});
			style.setStyle("directMemory",{color:"#FFFFFF"});
			style.setStyle("veryTotalMemory",{color:"#FFFFFF"});
			style.setStyle("garbageMemory",{color:"#FFFFFF"});
			style.setStyle("directMemoryMax",{color:"#FFFFFF"});
			style.setStyle("nChildren",{color:"#FFFFFF"});
			style.setStyle("nZombie",{color:"#FFFFFF"});
			style.setStyle("nActiveZombie",{color:"#FFFFFF"});
			style.setStyle("currentWeapon",{color:"#FFFFFF"});
			theText = new TextField();
			theText.alpha=0.8;
			theText.autoSize=TextFieldAutoSize.LEFT;
			theText.styleSheet=style;
			theText.condenseWhite=true;
			theText.selectable=false;
			theText.mouseEnabled=false;
			theText.background=true;
			theText.backgroundColor=0x000000;
			addChild(theText);
			addEventListener(Event.ENTER_FRAME, update);
		}
		private function update(e:Event):void {
			var timer:int=getTimer();
			if (timer-1000>lastTimeCheck) {
				var vectorLength:int=fpsVector.push(fps);
				if (vectorLength>60) {
					fpsVector.shift();
				}
				var vectorAverage:Number=0;
				for (var i:Number = 0; i < fpsVector.length; i++) {
					vectorAverage+=fpsVector[i];
				}
				vectorAverage=vectorAverage/fpsVector.length;
				xml.averageFPS=Math.round(vectorAverage);
				var directMemory:Number=System.totalMemory;
				maxMemory=Math.max(directMemory,maxMemory);
				xml.directMemory=(directMemory/1048576).toFixed(3);
				xml.directMemoryMax=(maxMemory/1048576).toFixed(3);
				xml.framesPerSecond = fps + " / " + stage.frameRate;
				childrenCount=0;
				countDisplayList(stage);
				xml.nChildren=childrenCount;
				fps=0;
				lastTimeCheck = timer;
				
				xml.nZombie = Level.current.zombies.length.toString();
				xml.nActiveZombie = Zombie.frameWaker[(Zombie.frameNumber + 1) % Zombie.MAX_DURATION].length.toString();
				xml.currentWeapon = Level.current.player.currentWeapon;
				xml.currentWeapon = xml.currentWeapon.toString().replace('object ', '');
			}
			fps++;
			xml.msFrame=(timer-ms);
			ms=timer;
			theText.htmlText=xml;
		}
		public function countDisplayList(container:DisplayObjectContainer):void {
			childrenCount+=container.numChildren;
			for (var i:uint=0; i < container.numChildren; i++) {
				if (container.getChildAt(i) is DisplayObjectContainer) {
					countDisplayList(DisplayObjectContainer(container.getChildAt(i)));
				}
			}
		}
	}
}