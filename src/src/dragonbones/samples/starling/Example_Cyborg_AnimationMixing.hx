package dragonbones.samples.starling;
import dragonbones.Armature;
import dragonbones.Bone;
import dragonbones.events.AnimationEvent;
import dragonbones.TypeDefs.ArmatureFactory;
import flash.errors.Error;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.TouchEvent;
import starling.text.TextField;

/**
 * @author SlavaRa
 */
class Example_Cyborg_AnimationMixing extends Sprite {
	
	static inline var RESOURCES_DATA = "../../../../assets/Cyborg_AnimationMixing.dbswf";
	static inline var WEAPON_ANIMATION_GROUP = "weaponAnimationGroup";
	
	public function new() {
		super();
		_mouseX = 0;
		_mouseY = 0;
		_weaponID = -1;
		_speedX = 0;
		_speedY = 0;
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	var _textField:TextField;
	var _factory:ArmatureFactory;
	var _armature:Armature;
	var _armatureDisplay:Sprite;
	var _body:Bone;
	var _chest:Bone;
	var _head:Bone;
	var _armR:Bone;
	var _armL:Bone;
	var _weapon:Bone;
	var _left:Bool;
	var _right:Bool;
	var _mouseX:Float;
	var _mouseY:Float;
	var _isJumping:Bool;
	var _isSquat:Bool;
	var _moveDir:Int;
	var _face:Int;
	var _weaponID:Int = -1;
	var _speedX:Float;
	var _speedY:Float;
	
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
		_armature = _factory.buildArmature("cyborg");
		_body = _armature.getBone("body");
		_chest = _armature.getBone("chest");
		_head = _armature.getBone("head");
		_armR = _armature.getBone("upperarmR");
		_armL = _armature.getBone("upperarmL");
		_weapon = _armature.getBone("weapon");
		
		_armatureDisplay = _armature.display;
		_armatureDisplay.x = 400;
		_armatureDisplay.y = 500;
		addChild(_armatureDisplay);
		
		Starling.juggler.add(_armature);
		
		changeWeapon();
		
		_textField = new TextField(700, 30, "Press W/A/S/D to move. Press SPACE to switch weapens. Move mouse to aim.", "Verdana", 16, 0, true);
		_textField.color = 0xffffff;
		_textField.x = 60;
		_textField.y = 5;
		
		addChild(_textField);
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyEventHandler);
	}
	
	function onKeyEventHandler(event:KeyboardEvent) {
		switch (event.keyCode) {
			case 37, 65:
				_left = event.type == KeyboardEvent.KEY_DOWN;
				updateMove(-1);
			case 39, 68:
				_right = event.type == KeyboardEvent.KEY_DOWN;
				updateMove(1);
			case 38, 87:
				if(event.type == KeyboardEvent.KEY_DOWN) {
					jump();
				}
			case 83, 40:
				squat(event.type == KeyboardEvent.KEY_DOWN);
			case 32:
				if(event.type == KeyboardEvent.KEY_UP) {
					changeWeapon();
				}
		}
	}
	
	function updateMove(dir:Int) {
		if(_left && _right) {
			move(dir);
		} else if(_left) {
			move(-1);
		} else if(_right) {
			move(1);
		} else {
			move(0);
		}
	}
	
	function onMouseMoveHandler(event:TouchEvent) {
		try {
			var p = event.getTouch(stage).getLocation(stage);
			_mouseX = p.x;
			_mouseY = p.y;
		} catch(error:Error) {
		}
	}

	function onEnterFrameHandler(event:EnterFrameEvent) {
		if(!stage.hasEventListener(TouchEvent.TOUCH))  {
			stage.addEventListener(TouchEvent.TOUCH, onMouseMoveHandler);
		}
		updateSpeed();
		updateWeapon();
	}

	function move(dir:Int) {
		if(_moveDir == dir) {
			return;
		}
		_moveDir = dir;
		updateMovement();
	}

	function jump() {
		if(_isJumping) {
			return;
		}
		_speedY = -15;
		_isJumping = true;
		_armature.animation.gotoAndPlay("jump");
	}

	function squat(isDown:Bool) {
		if(_isSquat == isDown) {
			return;
		}
		_isSquat = isDown;
		updateMovement();
	}

	function changeWeapon() {
		_weaponID++;
		if(_weaponID >= 4) {
			_weaponID -= 4;
		}
		var animationName = "weapon" + (_weaponID + 1);
		_weapon.displayController = animationName;
		_armature.animation.gotoAndPlay(animationName, -1, -1, Math.NaN, 0, WEAPON_ANIMATION_GROUP, "sameGroup");
	}

	function updateMovement() {
		if(_isJumping) {
			return;
		}
		if(_isSquat) {
			_speedX = 0;
			_armature.animation.gotoAndPlay("squat");
			return;
		}
		if(_moveDir == 0) {
			_speedX = 0;
			_armature.animation.gotoAndPlay("stand");
		} else {
			if(_moveDir * _face > 0) {
				_speedX = 4* _face;
				_armature.animation.gotoAndPlay("run");
			} else {
				_speedX = -3 * _face;
				_armature.animation.gotoAndPlay("runBack");
			}
		}
	}

	function updateSpeed() {
		if(_isJumping) {
			if(_speedY <= 0 && (_speedY + 0.5) > 0 ) {
				_armature.animation.gotoAndPlay("fall");
			}
			_speedY += 0.5;
		}
		if(_speedX != 0) {
			_armatureDisplay.x += _speedX;
			if(_armatureDisplay.x < 0) {
				_armatureDisplay.x = 0;
			} else if(_armatureDisplay.x > 800) {
				_armatureDisplay.x = 800;
			}
		}
		if(_speedY != 0) {
			_armatureDisplay.y += _speedY;
			if(_armatureDisplay.y > 500) {
				_armatureDisplay.y = 500;
				_isJumping = false;
				_speedY = 0;
				_speedX = 0;
				_armature.animation.gotoAndPlay("fallEnd");
				_armature.addEventListener(AnimationEvent.MOVEMENT_CHANGE, armatureMovementChangeHandler);
			}
		}
	}

	function armatureMovementChangeHandler(event:AnimationEvent) {
		switch(event.movementID) {
			case "stand":
				_armature.removeEventListener(AnimationEvent.MOVEMENT_CHANGE, armatureMovementChangeHandler);
				updateMovement();
		}
	}

	function updateWeapon() {
		_face = _mouseX > _armatureDisplay.x ? 1 : -1;
		if(_armatureDisplay.scaleX * _face < 0) {
			_armatureDisplay.scaleX *= -1;
			updateMovement();
		}
		var r:Float;
		if(_face > 0) {
			r = Math.atan2(_mouseY - _armatureDisplay.y, _mouseX - _armatureDisplay.x);
		} else {
			r = Math.PI - Math.atan2(_mouseY - _armatureDisplay.y, _mouseX - _armatureDisplay.x);
			if(r > Math.PI) {
				r -= Math.PI * 2;
			}
		}
		_body.node.rotation = r * 0.25;
		_chest.node.rotation = r * 0.25;
		if(r > 0) {
			_head.node.rotation = r * 0.2;
		} else {
			_head.node.rotation = r * 0.4;
		}
		_armR.node.rotation = r * 0.5;
		if(r > 0) {
			_armL.node.rotation = r * 0.8;
		} else {
			_armL.node.rotation = r * 0.6;
		}
		_armature.invalidUpdate();
	}
}