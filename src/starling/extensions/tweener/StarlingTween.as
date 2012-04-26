package starling.extensions.tweener
{
	import starling.animation.Tween;
	import starling.core.Starling;
	
	/**
	 * 
	 * used in TweenManager class.
	 * 
	 * @author volzh
	 * 
	 */
	public class StarlingTween extends Tween
	{
		private var _onComplete:Function;
		
		private var _currentTween:StarlingTween;
		internal var nextTween:StarlingTween;
		private var _parallelTweens:Vector.<StarlingTween> = new <StarlingTween>[];
		
		public function StarlingTween(target:Object, time:Number, transition:String="linear")
		{
			super(target, time, transition);
			super.onComplete = this.checkComplete;
		}
		
		private function checkComplete():void
		{
			for (var i:int = 0; i < _parallelTweens.length; i++) 
			{
				if (_parallelTweens[i].isComplete == false){
					return;
				}
			}
			if (this.isComplete == true){
				if (nextTween != null){
					nextTween.play();
					_currentTween = nextTween;
				} else if (_onComplete != null){
					_onComplete.apply(null, super.onCompleteArgs);
				}
			}
		}
		
		internal function addParallel(value:StarlingTween):void
		{
			_parallelTweens.push(value);
		}

		public function play():void
		{
			_currentTween = this;
			Starling.juggler.add(this); 
			for (var i:int = 0; i < _parallelTweens.length; i++) 
			{
				_parallelTweens[i].play();
			}
		}
		
		public function stop():void
		{
			_currentTween = this;
			Starling.juggler.remove(_currentTween);
			for (var i:int = 0; i < _parallelTweens.length; i++) 
			{
				_parallelTweens[i].stop();
			}
		}
		
		public function pause():void
		{
			Starling.juggler.remove(_currentTween);
			for (var i:int = 0; i < _parallelTweens.length; i++) 
			{
				_parallelTweens[i].pause();
			}
		}
		
		public function resume():void
		{
			Starling.juggler.add(_currentTween);
			for (var i:int = 0; i < _parallelTweens.length; i++) 
			{
				_parallelTweens[i].resume();
			}
		}
		
		public override function set onComplete(value:Function):void
		{
			_onComplete = value;
		}
		
		public override function get onComplete():Function
		{
			return _onComplete;
		}
	}
}