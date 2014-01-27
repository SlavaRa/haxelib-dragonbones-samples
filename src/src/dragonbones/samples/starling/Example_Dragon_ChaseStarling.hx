package dragonbones.samples.starling;
import dragonbones.Armature;
import dragonbones.Bone;
import dragonbones.TypeDefs.ArmatureFactory;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.ui.Mouse;
import flash.utils.ByteArray;
import openfl.Assets;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.TouchEvent;
import starling.textures.Texture;

/**
 * @author SlavaRa
 */
class Example_Dragon_ChaseStarling extends Sprite {
	
	static inline var DRAGON_WITH_CLOTHES_ASSET = "../../../../assets/DragonWithClothes.png";
	static inline var STARLING_IMG = "../../../../assets/starling.png";
	
	public function new() {
		super();
		_mouseX = 0;
		_mouseY = 0;
		_moveDir = 0;
		_speedX = 0;
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	var _factory:ArmatureFactory;
	var _armature:Armature;
	var _armatureClip:Sprite;
	var _mouseX:Float;
	var _mouseY:Float;
	var _moveDir:Int;
	var _dist:Float;
	var _speedX:Int;
	var _starlingBird:DisplayObject;
	var _r:Float;
	var _head:Bone;
	var _armR:Bone;
	var _armL:Bone;
	
	function onAddedToStage(?_) {
		_starlingBird = addChild(new Image(Texture.fromBitmapData(Assets.getBitmapData("assets/starling.png"))));
		
		var urlLoader = new URLLoader();
		urlLoader.addEventListener(flash.events.Event.COMPLETE, onUrlLoaderComplete);
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.load(new URLRequest(DRAGON_WITH_CLOTHES_ASSET));
	}
	
	function onUrlLoaderComplete(event:flash.events.Event) {
		var urlLoader = cast(event.target, URLLoader);
		urlLoader.removeEventListener(flash.events.Event.COMPLETE, onUrlLoaderComplete);
		
		_factory = new ArmatureFactory();
		_factory.onDataParsed.addOnce(onFactoryDataParsed);
		_factory.parseData(cast(urlLoader.data, ByteArray));
	}
	
	function onFactoryDataParsed() {
		_armature = _factory.buildArmature("Dragon");
		_armatureClip = _armature.display;
		_armatureClip.x = 400;
		_armatureClip.y = 550;
		addChild(_armatureClip);
		Starling.juggler.add(_armature);
		updateBehavior(0);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		stage.addEventListener(TouchEvent.TOUCH, onStageTouch);
		Mouse.hide();
		_head = _armature.getBone("head");
		_armR = _armature.getBone("armUpperR");
		_armL = _armature.getBone("armUpperL");
	}
	
	function checkDist() {
		_dist = _armatureClip.x - _mouseX;
		if(_dist < 150) {
			updateBehavior(1);
		} else if(_dist > 190) {
			updateBehavior( -1);
		} else {
			updateBehavior(0);
		}
	}
	
	function updateBehavior(dir:Int) {
		if(_moveDir == dir) {
			return;
		}
		_moveDir = dir;
		if(_moveDir == 0) {
			_speedX = 0;
			_armature.animation.gotoAndPlay("stand");
		} else {
			_speedX = 6 * _moveDir;
			_armature.animation.gotoAndPlay("walk");
		}
	}
	
	function updateMove() {
		if(_speedX != 0) {
			_armatureClip.x += _speedX;
			if(_armatureClip.x < 0)  {
				_armatureClip.x = 0;
			} else if(_armatureClip.x > 800)  {
				_armatureClip.x = 800;
			}
		}
	}
	
	function updateBones() {
		_r = Math.PI + Math.atan2(_mouseY - _armatureClip.y + _armatureClip.height / 2, _mouseX - _armatureClip.x);
		if(_r > Math.PI) {
			_r -= Math.PI * 2;
		}
		_head.node.rotation = _r * 0.3;
		_armR.node.rotation = _r * 0.8;
		_armL.node.rotation = _r * 1.5;
		_starlingBird.rotation = _r * 0.2;
	}
	
	function onEnterFrame(_) {
		checkDist();
		updateMove();
		updateBones();
	}
	
	function onStageTouch(event:TouchEvent) {
		var touch = event.getTouch(stage);
		if(touch != null) {
			var point = touch.getLocation(stage);
			_mouseX = point.x;
			_mouseY = point.y;
			_starlingBird.x = _mouseX - 73;
			_starlingBird.y = _mouseY - 73;
		}
	}
}