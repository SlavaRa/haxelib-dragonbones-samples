package dragonbones.samples.starling;
import dragonbones.Armature;
import dragonbones.TypeDefs.ArmatureFactory;
import dragonbones.TypeDefs.Event;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.KeyboardEvent;
import starling.text.TextField;

/**
 * @author SlavaRa
 */
class Example_Motorcycle_NestingSkeleton extends Sprite {
	
	private static inline var RESOURCES_DATA = "../../../../assets/Motorcycle_output.png";
	
	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	var _factory:ArmatureFactory;
	var _armature:Armature;
	var _armatureClip:Sprite;
	var _textField:TextField;
	var _moveDir:Int;
	var _isLeft:Bool;
	var _isRight:Bool;
	
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
		_armature = _factory.buildArmature("motorcycleMan");
		_armatureClip = _armature.display;
		_armatureClip.x = 400;
		_armatureClip.y = 400;
		addChild(_armatureClip);
		updateMovement();
		Starling.juggler.add(_armature);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyEventHandler);
		
		_textField = new TextField(700, 30, "Press A/D to lean forward/backward.", "Verdana", 16, 0, true);
		_textField.color = 0xffffff;
		_textField.x = 60;
		_textField.y = 5;
		addChild(_textField);
	}
	
	function move(dir:Int) {
		if (_moveDir == dir) {
			return;
		}
		_moveDir = dir;
		updateMovement();
	}

	function updateMovement() {
		if (_moveDir == 0) {
			_armature.animation.gotoAndPlay("stay");
		} else {
			if(_moveDir > 0) {
				_armature.animation.gotoAndPlay("right");
			} else {
				_armature.animation.gotoAndPlay("left");
			}
		}
	}
	
	function onKeyEventHandler(event:KeyboardEvent) {
		switch (event.keyCode) {
			case 37, 65:
				_isLeft = event.type == KeyboardEvent.KEY_DOWN;
				updateMove(-1);
			case 39, 68:
				_isRight = event.type == KeyboardEvent.KEY_DOWN;
				updateMove(1);
		}
	}
	
	function updateMove(dir:Int) {
		if (_isLeft && _isRight) {
			move(dir);
		} else if(_isLeft) {
			move(-1);
		} else if(_isRight) {
			move(1);
		} else {
			move(0);
		}
	}
}