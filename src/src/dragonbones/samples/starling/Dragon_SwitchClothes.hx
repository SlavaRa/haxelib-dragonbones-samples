package dragonbones.samples.starling;
import dragonbones.Armature;
import dragonbones.factorys.ArmatureFactory;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.text.TextField;

/**
 * @author SlavaRa
 */
class Dragon_SwitchClothes extends Sprite {
	
	public static inline var RESOURCES_DATA = "../../../../assets/DragonWithClothes.png";
	
	public function new() {
		super();
		_moveDir = 0;
		_speedX = 0;
		_speedY = 0;
		_textures = ["parts/clothes1", "parts/clothes2", "parts/clothes3", "parts/clothes4"];
		_textureIndex = 0;
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	var _factory:ArmatureFactory;
	var _armature:Armature;
	var _armatureClip:Sprite;
	var _textField:TextField;
	var _isLeft:Bool;
	var _isRight:Bool;
	var _isJumping:Bool;
	var _moveDir:Int;
	var _speedX:Float;
	var _speedY:Float;
	var _textures:Array<String>;
	var _textureIndex:Int;
	
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
		_armature = _factory.buildArmature("Dragon");
		_armatureClip = _armature.display;
		_armatureClip.x = 400;
		_armatureClip.y = 550;
		addChild(_armatureClip);
		Starling.juggler.add(_armature);
		updateBehavior();
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyEventHandler);
		
		_textField = new TextField(600, 26, "C-change clothes; A-move left; D-move right; W-jump", "Verdana", 16, 0, true);
		_textField.color = 0xffffff;
		_textField.x = 60;
		_textField.y = 2;
		addChild(_textField);
	}
	
	function onKeyEventHandler(event:KeyboardEvent) {
		switch(event.keyCode) {
			case Keyboard.A, Keyboard.LEFT :
				_isLeft = event.type == KeyboardEvent.KEY_DOWN;
			case Keyboard.D, Keyboard.RIGHT :
				_isRight = event.type == KeyboardEvent.KEY_DOWN;
			case Keyboard.W, Keyboard.UP :
				jump();
			case Keyboard.C :
				if(event.type == KeyboardEvent.KEY_UP) {
					changeClothes();
				}
		}
		var dir:Int = 0;
		if(_isLeft && _isRight) {
			dir = _moveDir;
			return;
		} else if(_isLeft) {
			dir = -1;
		} else if(_isRight) {
			dir = 1;
		}
		if(dir == _moveDir) {
			return;
		} else {
			_moveDir = dir;
		}
		updateBehavior();
	}
	
	function changeClothes() {
		_textureIndex++;
		if(_textureIndex >= _textures.length) {
			_textureIndex = _textureIndex - _textures.length;
		}
		var textureName = _textures[_textureIndex];
		var image:Image = cast(_factory.getTextureDisplay(textureName), Image);
		var bone = _armature.getBone("clothes");
		bone.display.dispose();
		bone.display = image;
	}
	
	function onEnterFrameHandler(?_) updateMove();
	
	function updateBehavior() {
		if(_isJumping) {
			return;
		}
		if(_moveDir == 0) {
			_speedX = 0;
			_armature.animation.gotoAndPlay("stand");
		} else {
			_speedX = 6 * _moveDir;
			_armatureClip.scaleX =  - _moveDir;
			_armature.animation.gotoAndPlay("walk");
		}
	}
	
	function updateMove() {
		if(_speedX != 0) {
			_armatureClip.x += _speedX;
			if(_armatureClip.x < 0) {
				_armatureClip.x = 0;
			} else if(_armatureClip.x > 800) {
				_armatureClip.x = 800;
			}
		}
		if(_isJumping) {
			if(_speedY <= 0 && _speedY + 1 > 0 ) {
				_armature.animation.gotoAndPlay("fall");
			}
			_speedY +=  1;
		}
		if(_speedY != 0) {
			_armatureClip.y += _speedY;
			if (_armatureClip.y > 540) {
				_armatureClip.y = 550;
				_isJumping = false;
				_speedY = 0;
				updateBehavior();
			}
		}
	}
	
	function jump() {
		if(_isJumping) {
			return;
		}
		_speedY = -17;
		_isJumping = true;
		_armature.animation.gotoAndPlay("jump");
	}
}