package dragonbones.samples;
import dragonbones.samples.starling.Dragon_ChaseStarling;
import dragonbones.samples.starling.Dragon_SwitchClothes;
import dragonbones.samples.starling.Example_AnimationCopy;
import dragonbones.samples.starling.Example_Cyborg_AnimationMixing;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import starling.core.Starling;

/**
 * @author SlavaRa
 */
class Main extends Sprite {
	
	public static function main() {
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
	
	public function new() {
		super();	
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	var _isInitialized:Bool;

	function onAddedToStage(?_) {
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		stage.addEventListener(Event.RESIZE, onResize);
		#if ios
		haxe.Timer.delay(initialize, 100); // iOS 6
		#else
		initialize();
		#end
	}
	
	function onResize(?_) {
		if (!_isInitialized) {
			initialize();
		}
		// else (onResize or orientation change)
	}
	
	function initialize() {
		if (_isInitialized) {
			return;
		}
		
		_isInitialized = true;
		new Starling(StarlingMain, stage).start();
	}
}

private class StarlingMain extends starling.display.Sprite {
	public function new() {
		super();
		//addChild(new Dragon_ChaseStarling());
		//addChild(new Dragon_SwitchClothes());
		//addChild(new Example_AnimationCopy());
		addChild(new Example_Cyborg_AnimationMixing());
	}
}