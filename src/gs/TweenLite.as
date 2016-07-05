/*
VERSIO
CODED BY: Jack Doyle, jack@greensock.com
Copyright 2008, GreenSock (This work is subject to the terms in http://www.greensock.com/terms_of_use.html.)
*/

package gs {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.utils.*;

	public class TweenLite {
		public static var version:Number = 8.15;
		public static var killDelayedCallsTo:Function = TweenLite.killTweensOf;
		public static var defaultEase:Function = TweenLite.easeOut;
		public static var overwriteManager:Object; //makes it possible to integrate the gs.utils.tween.OverwriteManager for adding autoOverwrite capabilities
		protected static var _all:Dictionary = new Dictionary(); //Holds references to all our tween targets.
		protected static var _curTime:uint;
		private static var _classInitted:Boolean;
		private static var _sprite:Sprite = new Sprite(); //A reference to the sprite that we use to drive all our ENTER_FRAME events.
		private static var _listening:Boolean; //If true, the ENTER_FRAME is being listened for (there are tweens that are in the queue)
		private static var _timer:Timer = new Timer(2000);
	
		public var duration:Number; //Duration (in seconds)
		public var vars:Object; //Variables (holds things like alpha or y or whatever we're tweening)
		public var delay:Number; //Delay (in seconds)
		public var startTime:int; //Start time
		public var initTime:int; //Time of initialization. Remember, we can build in delays so this property tells us when the frame action was born, not when it actually started doing anything.
		public var tweens:Array; //Contains parsed data for each property that's being tweened (each has to have a target, property, start, and a change).
		public var target:Object; //Target object (often a MovieClip)
		
		protected var _active:Boolean; //If true, this tween is active.
		protected var _subTweens:Array; //Only used for associated sub-tweens like tint and volume
		protected var _hst:Boolean; //Has sub-tweens. Tracking this as a Boolean value is faster than checking _subTweens.length
		protected var _hasUpdate:Boolean; //has onUpdate. Tracking this as a Boolean value is faster than checking this.vars.onUpdate == null.
		protected var _isDisplayObject:Boolean; //We need to know if the target is a DisplayObject so that we can apply visibility changes, do tint and Sound tweens, etc
		protected var _initted:Boolean;
		protected var _timeScale:Number; //Allows you to speed up or slow down a tween. Default is 1 (normal speed) 0.5 would be half-speed
		
		public function TweenLite($target:Object, $duration:Number, $vars:Object) {
			if ($target == null) {return};
			if (!_classInitted) {
				_curTime = getTimer();
				_sprite.addEventListener(Event.ENTER_FRAME, executeAll);
				if (overwriteManager == null) {
					overwriteManager = {mode:1, enabled:false};
				}
				_classInitted = true;
			}
			this.vars = $vars;
			this.duration = $duration || 0.001; //Easing equations don't work when the duration is zero.
			this.delay = $vars.delay || 0;
			_timeScale = $vars.timeScale || 1;
			_active = ($duration == 0 && this.delay == 0);
			this.target = $target;
			_isDisplayObject = ($target is DisplayObject);
			if (!(this.vars.ease is Function)) {
				this.vars.ease = defaultEase;
			}
			if (this.vars.easeParams != null) {
				this.vars.proxiedEase = this.vars.ease;
				this.vars.ease = easeProxy;
			}
			if (!isNaN(Number(this.vars.autoAlpha))) {
				this.vars.alpha = Number(this.vars.autoAlpha);
				this.vars.visible = (this.vars.alpha > 0);
			}
			this.tweens = [];
			_subTweens = [];
			_hst = _initted = false;
			this.initTime = _curTime;
			this.startTime = this.initTime + (this.delay * 1000);
			
			var mode:int = ($vars.overwrite == undefined || (!overwriteManager.enabled && $vars.overwrite > 1)) ? overwriteManager.mode : int($vars.overwrite);
			if (_all[$target] == undefined || ($target != null && mode == 1)) { 
				delete _all[$target];
				_all[$target] = new Dictionary(true);
			} else if (mode > 1 && this.delay == 0) {
				overwriteManager.manageOverwrites(this, _all[$target]);
			}
			_all[$target][this] = this;
			
			if ((this.vars.runBackwards == true && this.vars.renderOnStart != true) || _active) {
				initTweenVals();
				if (_active) { //Means duration is zero and delay is zero, so render it now, but add one to the startTime because this.duration is always forced to be at least 0.001 since easing equations can't handle zero.
					render(this.startTime + 1);
				} else {
					render(this.startTime);
				}
				var v:* = this.vars.visible;
				if (this.vars.isTV == true) {
					v = this.vars.exposedProps.visible;
				}
				if (v != null && this.vars.runBackwards == true && _isDisplayObject) {
					this.target.visible = Boolean(v);
				}
			}
			if (!_listening && !_active) {
				_timer.addEventListener("timer", killGarbage);
            	_timer.start();
				_listening = true;
			}
		}
		
		public function initTweenVals($hrp:Boolean = false, $reservedProps:String = ""):void {
			var p:String, i:int;
			var v:Object = this.vars;
			if (v.isTV == true) {
				v = v.exposedProps; //Enables use of the TweenLiteVars, TweenFilterLiteVars, and TweenMaxVars utility classes.
			}
			if (!$hrp && this.delay != 0 && overwriteManager.enabled) {
				overwriteManager.manageOverwrites(this, _all[this.target]);
			}
			if (this.target is Array) {
				var endArray:Array = this.vars.endArray || [];
				for (i = 0; i < endArray.length; i++) {
					if (this.target[i] != endArray[i] && this.target[i] != undefined) {
						this.tweens[this.tweens.length] = {o:this.target, p:i.toString(), s:this.target[i], c:endArray[i] - this.target[i], name:i.toString()}; //o: object, p:property, s:starting value, c:change in value,
					}
				}
			} else {
				
				if ((typeof(v.tint) != "undefined" || this.vars.removeTint == true) && _isDisplayObject) { //If we're trying to change the color of a DisplayObject, then set up a quasai proxy using an instance of a TweenLite to control the color.
					var clr:ColorTransform = this.target.transform.colorTransform;
					var endClr:ColorTransform = new ColorTransform();
					if (v.alpha != undefined) {
						endClr.alphaMultiplier = v.alpha;
						delete v.alpha;
					} else {
						endClr.alphaMultiplier = this.target.alpha;
					}
					if (this.vars.removeTint != true && ((v.tint != null && v.tint != "") || v.tint == 0)) { //In case they're actually trying to remove the colorization, they should pass in null or "" for the tint
						endClr.color = v.tint;
					}
					addSubTween("tint", tintProxy, {progress:0}, {progress:1}, {target:this.target, color:clr, endColor:endClr});
				}
				if (v.frame != null && _isDisplayObject) {
					addSubTween("frame", frameProxy, {frame:this.target.currentFrame}, {frame:v.frame}, {target:this.target});
				}
				if (!isNaN(this.vars.volume) && this.target.hasOwnProperty("soundTransform")) { //If we're trying to change the volume of an object with a soundTransform property, then set up a quasai proxy using an instance of a TweenLite to control the volume.
					addSubTween("volume", volumeProxy, this.target.soundTransform, {volume:this.vars.volume}, {target:this.target});
				}
				
				for (p in v) {
					if (p == "ease" || p == "delay" || p == "overwrite" || p == "onComplete" || p == "onCompleteParams" || p == "runBackwards" || p == "visible" || p == "autoOverwrite" || p == "persist" || p == "onUpdate" || p == "onUpdateParams" || p == "autoAlpha" || p == "timeScale" || p == "onStart" || p == "onStartParams" ||p == "renderOnStart" || p == "proxiedEase" || p == "easeParams" || ($hrp && $reservedProps.indexOf(" " + p + " ") != -1)) { 
						
					} else if (!(_isDisplayObject && (p == "tint" || p == "removeTint" || p == "frame")) && !(p == "volume" && this.target.hasOwnProperty("soundTransform"))) {
						//if (this.target.hasOwnProperty(p)) { //REMOVED because there's a bug in Flash Player 10 (Beta) that incorrectly reports that DisplayObjects don't have a "z" property. This check wasn't entirely necessary anyway - it just prevented runtime errors if/when developers tried tweening properties that didn't exist.
							if (typeof(v[p]) == "number") {
								this.tweens[this.tweens.length] = {o:this.target, p:p, s:this.target[p], c:v[p] - this.target[p], name:p}; //o:object, p:property, s:starting value, c:change in value
							} else {
								this.tweens[this.tweens.length] = {o:this.target, p:p, s:this.target[p], c:Number(v[p]), name:p}; //o:object, p:property, s:starting value, c:change in value
							}
						//}
					}
				}
			}
			if (this.vars.runBackwards == true) {
				var tp:Object;
				for (i = this.tweens.length - 1; i > -1; i--) {
					tp = this.tweens[i];
					tp.s += tp.c;
					tp.c *= -1;
				}
			}
			if (v.visible == true && _isDisplayObject) {
				this.target.visible = true;
			}
			if (this.vars.onUpdate != null) {
				_hasUpdate = true;
			}
			_initted = true;
		}
		
		protected function addSubTween($name:String, $proxy:Function, $target:Object, $props:Object, $info:Object = null):void {
			var sub:Object = {name:$name, proxy:$proxy, target:$target, info:$info};
			_subTweens[_subTweens.length] = sub;
			for (var p:String in $props) {
				if (typeof($props[p]) == "number") {
					this.tweens[this.tweens.length] = {o:$target, p:p, s:$target[p], c:$props[p] - $target[p], sub:sub, name:$name}; //o:Object, p:Property, s:Starting value, c:Change in value, sub:Subtween object;
				} else {
					this.tweens[this.tweens.length] = {o:$target, p:p, s:$target[p], c:Number($props[p]), sub:sub, name:$name};
				}
			}
			_hst = true; //has sub tweens. We track this with a boolean value as opposed to checking _subTweens.length for speed purposes
		}
		
		public static function to($target:Object, $duration:Number, $vars:Object):TweenLite {
			return new TweenLite($target, $duration, $vars);
		}
		
		//This function really helps if there are objects that we just want to animate into place (they are already at their end position on the stage for example). 
		public static function from($target:Object, $duration:Number, $vars:Object):TweenLite {
			$vars.runBackwards = true;
			return new TweenLite($target, $duration, $vars);
		}
		
		public static function delayedCall($delay:Number, $onComplete:Function, $onCompleteParams:Array = null):TweenLite {
			return new TweenLite($onComplete, 0, {delay:$delay, onComplete:$onComplete, onCompleteParams:$onCompleteParams, overwrite:0});
		}
		
		public function render($t:uint):void {
			var time:Number = ($t - this.startTime) / 1000, factor:Number, tp:Object, i:int;
			if (time >= this.duration) {
				time = this.duration;
				factor = 1;
			} else {
				factor = this.vars.ease(time, 0, 1, this.duration);
			}
			for (i = this.tweens.length - 1; i > -1; i--) {
				tp = this.tweens[i];
				tp.o[tp.p] = tp.s + (factor * tp.c);
			}
			if (_hst) { //has sub-tweens
				for (i = _subTweens.length - 1; i > -1; i--) {
					_subTweens[i].proxy(_subTweens[i]);
				}
			}
			if (_hasUpdate) {
				this.vars.onUpdate.apply(null, this.vars.onUpdateParams);
			}
			if (time == this.duration) {
				complete(true);
			}
		}
		
		public static function executeAll($e:Event = null):void {
			var t:uint = _curTime = getTimer();
			if (_listening) {
				var a:Dictionary = _all, p:Object, tw:Object;
				for each (p in a) {
					for (tw in p) {
						if (p[tw] != undefined && p[tw].active) {
							p[tw].render(t);
						}
					}
				}
			}
		}
		
		public function complete($skipRender:Boolean = false):void {
			if (!$skipRender) {
				if (!_initted) {
					initTweenVals();
				}
				this.startTime = _curTime - (this.duration * 1000) / _timeScale;
				render(_curTime); //Just to force the final render
				return;
			}
			if (this.vars.visible != undefined && _isDisplayObject) {
				if (!isNaN(this.vars.autoAlpha) && this.target.alpha == 0) {
					this.target.visible = false;
				} else if (this.vars.runBackwards != true) {
					this.target.visible = this.vars.visible;
				}
			}
			if (this.vars.persist != true) {
				removeTween(this); //moved above the onComplete callback in case there's an error in the user's onComplete - this prevents constant errors
			}
			if (this.vars.onComplete != null) {
				this.vars.onComplete.apply(null, this.vars.onCompleteParams);
			}
		}
		
		public static function removeTween($t:TweenLite = null):void {
			if ($t != null && _all[$t.target] != undefined) {
				_all[$t.target][$t] = null; //prevents garbage collection issues.
				delete _all[$t.target][$t];
			}
		}
		
		public static function killTweensOf($tg:Object = null, $complete:Boolean = false):void {
			if ($tg != null && _all[$tg] != undefined) {
				if ($complete) {
					var o:Object = _all[$tg];
					for (var tw:* in o) {
						o[tw].complete(false);
					}
				}
				delete _all[$tg];
			}
		}
		
		public function killVars($vars:Object):void {
			if (overwriteManager.enabled) {
				overwriteManager.killVars($vars, this.vars, this.tweens, _subTweens, []);
			}
		}
		
		public static function killGarbage($e:TimerEvent):void {
			var tg_cnt:uint = 0, found:Boolean, p:Object, twp:Object, tw:Object;
			for (p in _all) {
				found = false;
				for (twp in _all[p]) {
					found = true;
					break;
				}
				if (!found) {
					delete _all[p];
				} else {
					tg_cnt++;
				}
			}
			if (tg_cnt == 0) {
				_timer.removeEventListener("timer", killGarbage);
				_timer.stop();
				_listening = false;
			}
		}
		
		public static function easeOut($t:Number, $b:Number, $c:Number, $d:Number):Number {
			return -$c * ($t /= $d) * ($t - 2) + $b;
		}
		
//---- PROXY FUNCTIONS ------------------------------------------------------------------------
		
		protected function easeProxy($t:Number, $b:Number, $c:Number, $d:Number):Number { //Just for when easeParams are passed in via the vars object.
			return this.vars.proxiedEase.apply(null, arguments.concat(this.vars.easeParams));
		}
		public static function tintProxy($o:Object):void {
			var n:Number = $o.target.progress, r:Number = 1 - n, sc:Object = $o.info.color, ec:Object = $o.info.endColor;
			$o.info.target.transform.colorTransform = new ColorTransform(sc.redMultiplier * r + ec.redMultiplier * n,
																		  sc.greenMultiplier * r + ec.greenMultiplier * n,
																		  sc.blueMultiplier * r + ec.blueMultiplier * n,
																		  sc.alphaMultiplier * r + ec.alphaMultiplier * n,
																		  sc.redOffset * r + ec.redOffset * n,
																		  sc.greenOffset * r + ec.greenOffset * n,
																		  sc.blueOffset * r + ec.blueOffset * n,
																		  sc.alphaOffset * r + ec.alphaOffset * n);
		}
		public static function frameProxy($o:Object):void {
			$o.info.target.gotoAndStop(Math.round($o.target.frame));
		}
		public static function volumeProxy($o:Object):void {
			$o.info.target.soundTransform = $o.target;
		}
		
		
//---- GETTERS / SETTERS -----------------------------------------------------------------------
		
		public function get active():Boolean {
			if (_active) {
				return true;
			} else if (_curTime >= this.startTime) {
				_active = true;
				if (!_initted) {
					initTweenVals();
				} else if (this.vars.visible != undefined && _isDisplayObject) {
					this.target.visible = true;
				}
				if (this.vars.onStart != null) {
					this.vars.onStart.apply(null, this.vars.onStartParams);
				}
				if (this.duration == 0.001) { //In the constructor, if the duration is zero, we shift it to 0.001 because the easing functions won't work otherwise. We need to offset the this.startTime to compensate too.
					this.startTime -= 1;
				}
				return true;
			} else {
				return false;
			}
		}
		
	}
	
}