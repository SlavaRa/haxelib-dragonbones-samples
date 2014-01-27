package dragonbones.samples;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
#if (flash11 && starling)
import starling.core.Starling;
import dragonbones.samples.starling.Example_Dragon_ChaseStarling;
import dragonbones.samples.starling.Example_Dragon_SwitchClothes;
import dragonbones.samples.starling.Example_AnimationCopy;
import dragonbones.samples.starling.Example_Cyborg_AnimationMixing;
import dragonbones.samples.starling.Example_Motorcycle_NestingSkeleton;
#end

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
		#if (flash11 && starling)
		new Starling(TestView, stage).start();
		#else
		//TODO:
		#end
	}
}

#if (flash11 && starling)
private class TestView extends starling.display.Sprite {
	public function new() {
		super();
		addChild(new Example_Dragon_ChaseStarling());
		//addChild(new Example_Dragon_SwitchClothes());
		//addChild(new Example_AnimationCopy());
		//addChild(new Example_Cyborg_AnimationMixing());
		//addChild(new Example_Motorcycle_NestingSkeleton());
	}
}
#end