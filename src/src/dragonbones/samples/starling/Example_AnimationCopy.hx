package dragonbones.samples.starling;
import dragonbones.Armature;
import dragonbones.factorys.ArmatureFactory;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;

/**
 * @author SlavaRa
 */
class Example_AnimationCopy extends Sprite {
	
	private static inline var RESOURCES_DATA = "../../../../assets/Zombie_output.png";
	
	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	var _factory:ArmatureFactory;
	var _armature11:Armature;
	var _armature21:Armature;
	var _armature22:Armature;
	var _armature12:Armature;
	
	function onAddedToStage(?_) {
		var urlLoader = new URLLoader();
		urlLoader.addEventListener(flash.events.Event.COMPLETE, onUrlLoaderComplete);
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.load(new URLRequest(RESOURCES_DATA));
	}
	
	function onUrlLoaderComplete(event:flash.events.Event) {
		var urlLoader = cast(event.target, URLLoader);
		urlLoader.removeEventListener(flash.events.Event.COMPLETE, onUrlLoaderComplete);
		
		_factory = new ArmatureFactory();
		_factory.onDataParsed.addOnce(onFactoryDataParsed);
		_factory.parseData(cast(urlLoader.data, ByteArray));
	}
	
	function onFactoryDataParsed() {
		var skeletonData = _factory.getSkeletonData("Zombie");
		var armatureNames = skeletonData.armatureNames;
		var armatureName1 = armatureNames.splice(Std.int(Math.random() * armatureNames.length), 1)[0];
		var armatureName2 = armatureNames.splice(Std.int(Math.random() * armatureNames.length), 1)[0];
		
		_armature11 = _factory.buildArmature(armatureName1);
		_armature21 = _factory.buildArmature(armatureName2, armatureName1);
		_armature22 = _factory.buildArmature(armatureName2);
		_armature12 = _factory.buildArmature(armatureName1, armatureName2);
		
		var _display = _armature11.display;
		_display.x = 300;
		_display.y = 200;
		addChild(_display);
		
		_display = _armature21.display;
		_display.x = 500;
		_display.y = 200;
		addChild(_display);
		
		_display = _armature22.display;
		_display.x = 300;
		_display.y = 400;
		addChild(_display);
		
		_display = _armature12.display;
		_display.x = 500;
		_display.y = 400;
		addChild(_display);
		
		Starling.juggler.add(_armature11);
		Starling.juggler.add(_armature21);
		Starling.juggler.add(_armature22);
		Starling.juggler.add(_armature12);
		
		changeMovement();
	}
	
	public function changeMovement() {
		var _movement:String;
		do {
			_movement = _armature11.animation.movementList[Std.int(Math.random() * _armature11.animation.movementList.length)];
		} while (_movement == _armature11.animation.movementID);
		_armature11.animation.gotoAndPlay(_movement);
		_armature21.animation.gotoAndPlay(_movement);
		
		_movement = null;
		
		do {
			_movement = _armature22.animation.movementList[Std.int(Math.random() * _armature22.animation.movementList.length)];
		} while (_movement == _armature22.animation.movementID);
		_armature22.animation.gotoAndPlay(_movement);
		_armature12.animation.gotoAndPlay(_movement);
	}
}