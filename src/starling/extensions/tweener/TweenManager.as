package starling.extensions.tweener
{
	import flash.utils.Dictionary;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;

	/**
	 * 
	 * Tween을 생성 관리하는 클래스.
	 * TweenManager를 인스턴스로 생성하여, 인스턴스별로 관리 가능.
	 * 
	 * Make & Manage Tweens.
	 * TweenManager can be instance to manage separately.
	 * 
	 * @author volzh
	 * 
	 */
	public class TweenManager
	{
		private static var _tweenManager:Vector.<TweenManager> = new Vector.<TweenManager>();
		private static var _instance:TweenManager = new TweenManager();
		private var _tweeners:Vector.<StarlingTween> = new Vector.<StarlingTween>();
		
		public function TweenManager()
		{
			_tweenManager.push(this);
		}
		
		/**
		 * 
		 * 개별 tween 생성.
		 * Make tween.
		 * 
		 * @param target
		 * @param to
		 * @param from
		 * @param time
		 * @param easing
		 * @return 
		 * 
		 * @example
		 * <listing version='3.0'>
		 * var tw1:StarlingTween = TweenManager.tween(image1, {x:100, y:100}, {x:200, y:200}, 1);
		 * tw1.play();
		 * </listing>
		 */
		public static function tween(target:Object, to:Object, from:Object, time:Number, easing:String = Transitions.LINEAR):StarlingTween
		{
			return _instance.tween(target, to, from, time, easing);
		}
		
		/**
		 * 
		 * TweenManager의 instance를 생성하여 그룹별 관리가 용이하도록 tween을 생성.
		 * Make tween by instance of TweenManager.
		 * 
		 * @param target
		 * @param to
		 * @param from
		 * @param time
		 * @param easing
		 * @return 
		 * 
		 * @example
		 * <listing version='3.0'>
		 * var tmEffect:TweenManager = new TweenManager();
		 * var tw1:StarlingTween = tmEffect.tween(image1, {x:100, y:100}, {x:200, y:200}, 1);
		 * var tw2:StarlingTween = tmEffect.tween(image2, {x:100, y:100}, {x:200, y:200}, 1);
		 * tw1.play();
		 * tw2.play();
		 * 
		 * // tmEffect로 생성한 모든 tween 재생.
		 * // Play all tweens by tmEffect instance.
		 * tmEffect.play();
		 * 
		 * // tmEffect로 생성한 모든 tween 정지
		 * // Stop all tweens by tmEffect instance.
		 * tmEffect.stop();
		 * 
		 * // tmEffect로 생성한 모든 tween 일시 정지
		 * // Pause all tweens by tmEffect instance.
		 * tmEffect.pause();
		 * 
		 * // tmEffect로 생성한 모든 tween 다시 재생
		 * // Resume all tweens by tmEffect instance.
		 * tmEffect.resume();
		 * </listing>
		 */
		public function tween(target:Object, to:Object, from:Object, time:Number, easing:String = Transitions.LINEAR):StarlingTween
		{
			var tw:StarlingTween = new StarlingTween(target, time, easing);
			for (var property:String in to)
			{
				tw.animate(property, to[property]);
			}
			tw.onStart = function():void{
				for (var property:String in from)
				{
					target[property] = from[property];
				}
			};
			_tweeners.push(tw);
			return tw;
		}
		
		/**
		 * 
		 * 순차적인 재생을 하는 tween 생성.
		 * Make serial tweens.
		 * 
		 * @param args
		 * @return 
		 * 
		 * @example
		 * <listing version='3.0'>
		 * 	var tw2:StarlingTween = TweenManager.serial(
		 * 		TweenManager.tween(image1, {x:300, y:100}, {x:400, y:100}, 1, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image1, {x:300, y:200}, {x:300, y:100}, 0.5, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image1, {x:200, y:200}, {x:300, y:200}, 0.2, Transitions.EASE_OUT)
		 * 	);
		 * tw2.play();
		 * </listing>
		 */
		public static function serial(... args):StarlingTween
		{
			return _instance.serial(args);
		}
		
		/**
		 * 
		 * 순차적인 재생을 하는 tween을 생성.
		 * Make serial tweens.
		 * 
		 * @param args
		 * @return 
		 * 
		 * @example
		 * <listing version='3.0'>
		 * var tmEffect:TweenManager = new TweenManager();
		 * 	var tw2:StarlingTween = tmEffect.serial(
		 * 		TweenManager.tween(image1, {x:300, y:100}, {x:400, y:100}, 1, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image1, {x:300, y:200}, {x:300, y:100}, 0.5, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image1, {x:200, y:200}, {x:300, y:200}, 0.2, Transitions.EASE_OUT)
		 * 	);
		 * tw2.play();
		 * tmEffect.pause();
		 * </listing>
		 */
		public function serial(... args):StarlingTween
		{
			var tw:StarlingTween;
			for (var i:int = 0; i < args[0].length-1; i++) 
			{
				tw = args[0][i] as StarlingTween;
				tw.nextTween = args[0][i+1];
			}
			return args[0][0] as StarlingTween;
		}
		
		/**
		 * 
		 * 동시에 재생되는 tween을 생성.
		 * Make parallel tweens.
		 * 
		 * @param args
		 * @return 
		 * 
		 * @example
		 * <listing version='3.0'>
		 * 	var tw2:StarlingTween = TweenManager.parallel(
		 * 		TweenManager.tween(image1, {x:300, y:100}, {x:400, y:100}, 1, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image2, {x:300, y:200}, {x:300, y:100}, 0.5, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image3, {x:200, y:200}, {x:300, y:200}, 0.2, Transitions.EASE_OUT)
		 * 	);
		 * tw2.play();
		 * </listing>
		 */
		public static function parallel(... args):StarlingTween
		{
			return _instance.parallel(args);
		}
		
		/**
		 * 
		 * 동시에 재생되는 tween을 생성.
		 * Make parallel tweens.
		 * 
		 * @param args
		 * @return 
		 * 
		 * @example
		 * <listing version='3.0'>
		 * var tmEffect:TweenManager = new TweenManager();
		 * 	var tw2:StarlingTween = tmEffect.parallel(
		 * 		TweenManager.tween(image1, {x:300, y:100}, {x:400, y:100}, 1, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image2, {x:300, y:200}, {x:300, y:100}, 0.5, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image3, {x:200, y:200}, {x:300, y:200}, 0.2, Transitions.EASE_OUT)
		 * 	);
		 * tw2.play();
		 * tmEffect.pause();
		 * </listing>
		 */
		public function parallel(... args):StarlingTween
		{
			var tw:StarlingTween = args[0][0];
			for (var i:int = 1; i < args[0].length; i++) 
			{
				tw.addParallel(args[0][i]);
			}
			return args[0][0] as StarlingTween;
		}
		
		/**
		 * 
		 * 모든 트윈을 정지 시킴.
		 * play(), stop(), pause(), resume() 모두 동일하게 모든 트윈에 적용 됨.
		 * 
		 * Pause ALL tweens.
		 * 
		 * @example
		 * <listing version='3.0'>
		 * 	var tw2:StarlingTween = TweenManager.parallel(
		 * 		TweenManager.tween(image1, {x:300, y:100}, {x:400, y:100}, 1, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image2, {x:300, y:200}, {x:300, y:100}, 0.5, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image3, {x:200, y:200}, {x:300, y:200}, 0.2, Transitions.EASE_OUT)
		 * 	);
		 * TweenManager.pause();
		 * </listing>
		 * 
		 */
		public static function pause():void
		{
			var tm:TweenManager;
			for (var i:int = 0; i < _tweenManager.length; i++) 
			{
				tm = _tweenManager[i];
				tm.pause();
			}
		}
		
		/**
		 * 
		 * TweenManager의 instance로 생성된 모든 tween에 대해
		 * start(), stop(), pause(), resume() 이 적용됨.
		 * 
		 * Pause all tweens created by TweenManager instance.
		 * 
		 * @example
		 * <listing version='3.0'>
		 * var tmEffect:TweenManager = new TweenManager();
		 * 	var tw2:StarlingTween = tmEffect.parallel(
		 * 		TweenManager.tween(image1, {x:300, y:100}, {x:400, y:100}, 1, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image2, {x:300, y:200}, {x:300, y:100}, 0.5, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image3, {x:200, y:200}, {x:300, y:200}, 0.2, Transitions.EASE_OUT)
		 * 	);
		 * tmEffect.pause();
		 * </listing>
		 * 
		 */
		public function pause():void
		{
			for (var i:int = 0; i < _tweeners.length; i++) 
			{
				_tweeners[i].pause();
			}
		}
		
		/**
		 * 
		 * TweenManager의 instance로 생성된 모든 tween에 대해
		 * start(), stop(), pause(), resume() 이 적용됨.
		 * 
		 * Pause ALL tweens.
		 * 
		 * @example
		 * <listing version='3.0'>
		 * 	var tw2:StarlingTween = TweenManager.parallel(
		 * 		TweenManager.tween(image1, {x:300, y:100}, {x:400, y:100}, 1, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image2, {x:300, y:200}, {x:300, y:100}, 0.5, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image3, {x:200, y:200}, {x:300, y:200}, 0.2, Transitions.EASE_OUT)
		 * 	);
		 * tmEffect.resume();
		 * </listing>
		 * 
		 */
		public static function resume():void
		{
			var tm:TweenManager;
			for (var i:int = 0; i < _tweenManager.length; i++) 
			{
				tm = _tweenManager[i];
				tm.resume();
			}
		}
		
		/**
		 * 
		 * TweenManager의 instance로 생성된 모든 tween에 대해
		 * start(), stop(), pause(), resume() 이 적용됨.
		 * 
		 * Resume all tweens created by TweenManager instance.
		 * 
		 * @example
		 * <listing version='3.0'>
		 * var tmEffect:TweenManager = new TweenManager();
		 * 	var tw2:StarlingTween = tmEffect.parallel(
		 * 		TweenManager.tween(image1, {x:300, y:100}, {x:400, y:100}, 1, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image2, {x:300, y:200}, {x:300, y:100}, 0.5, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image3, {x:200, y:200}, {x:300, y:200}, 0.2, Transitions.EASE_OUT)
		 * 	);
		 * tmEffect.resume();
		 * </listing>
		 * 
		 */
		public function resume():void
		{
			for (var i:int = 0; i < _tweeners.length; i++) 
			{
				_tweeners[i].resume();
			}
		}
		
		/**
		 * 
		 * TweenManager의 instance로 생성된 모든 tween에 대해
		 * start(), stop(), pause(), resume() 이 적용됨.
		 * 
		 * Play ALL tweens.
		 * 
		 * @example
		 * <listing version='3.0'>
		 * 	var tw2:StarlingTween = TweenManager.parallel(
		 * 		TweenManager.tween(image1, {x:300, y:100}, {x:400, y:100}, 1, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image2, {x:300, y:200}, {x:300, y:100}, 0.5, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image3, {x:200, y:200}, {x:300, y:200}, 0.2, Transitions.EASE_OUT)
		 * 	);
		 * tmEffect.play();
		 * </listing>
		 * 
		 */
		public static function play():void
		{
			var tm:TweenManager;
			for (var i:int = 0; i < _tweenManager.length; i++) 
			{
				tm = _tweenManager[i];
				tm.play();
			}
		}
		
		/**
		 * 
		 * TweenManager의 instance로 생성된 모든 tween에 대해
		 * start(), stop(), pause(), resume() 이 적용됨.
		 * 
		 * Play all tweens created by TweenManager instance.
		 * 
		 * @example
		 * <listing version='3.0'>
		 * var tmEffect:TweenManager = new TweenManager();
		 * 	var tw2:StarlingTween = tmEffect.parallel(
		 * 		TweenManager.tween(image1, {x:300, y:100}, {x:400, y:100}, 1, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image2, {x:300, y:200}, {x:300, y:100}, 0.5, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image3, {x:200, y:200}, {x:300, y:200}, 0.2, Transitions.EASE_OUT)
		 * 	);
		 * tmEffect.play();
		 * </listing>
		 * 
		 */
		public function play():void
		{
			for (var i:int = 0; i < _tweeners.length; i++) 
			{
				_tweeners[i].play();
			}
		}
		
		/**
		 * 
		 * TweenManager의 instance로 생성된 모든 tween에 대해
		 * start(), stop(), pause(), resume() 이 적용됨.
		 * 
		 * Stop ALL tweens.
		 * 
		 * @example
		 * <listing version='3.0'>
		 * 	var tw2:StarlingTween = TweenManager.parallel(
		 * 		TweenManager.tween(image1, {x:300, y:100}, {x:400, y:100}, 1, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image2, {x:300, y:200}, {x:300, y:100}, 0.5, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image3, {x:200, y:200}, {x:300, y:200}, 0.2, Transitions.EASE_OUT)
		 * 	);
		 * tmEffect.stop();
		 * </listing>
		 * 
		 */
		public static function stop():void
		{
			var tm:TweenManager;
			for (var i:int = 0; i < _tweenManager.length; i++) 
			{
				tm = _tweenManager[i];
				tm.stop();
			}
		}
		
		/**
		 * 
		 * TweenManager의 instance로 생성된 모든 tween에 대해
		 * start(), stop(), pause(), resume() 이 적용됨.
		 * 
		 * Stop all tweens created by TweenManager instance.
		 * 
		 * @example
		 * <listing version='3.0'>
		 * var tmEffect:TweenManager = new TweenManager();
		 * 	var tw2:StarlingTween = tmEffect.parallel(
		 * 		TweenManager.tween(image1, {x:300, y:100}, {x:400, y:100}, 1, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image2, {x:300, y:200}, {x:300, y:100}, 0.5, Transitions.EASE_OUT),
		 * 		TweenManager.tween(image3, {x:200, y:200}, {x:300, y:200}, 0.2, Transitions.EASE_OUT)
		 * 	);
		 * tmEffect.stop();
		 * </listing>
		 * 
		 */
		public function stop():void
		{
			for (var i:int = 0; i < _tweeners.length; i++) 
			{
				_tweeners[i].stop();
			}
		}
	}
}