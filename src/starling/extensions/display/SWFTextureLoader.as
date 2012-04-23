package starling.extensions.display
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.setTimeout;
	
	import starling.textures.Texture;
	
	public class SWFTextureLoader extends EventDispatcher
	{
		private var _width:Number;
		private var _height:Number;
		private var _fps:Number;
		private var _textures:Vector.<Texture> = new Vector.<Texture>();
		private var _isComplete:Boolean = false;
		
		/**
		 * 
		 * embed된 swf의 class name
		 * 
		 * @param clip
		 * 
		 */
		public function SWFTextureLoader(embedClip:*)
		{
			if (embedClip is MovieClip){
				this.initValues(embedClip);
				makeTextures(embedClip);
			} else {
				var clip:MovieClip = new embedClip();
				var ldr:Loader = new Loader();
				ldr.loadBytes(clip.movieClipData);
				ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			}
		}
		
		public function get isComplete():Boolean
		{
			return _isComplete;
		}

		public function get textures():Vector.<Texture>
		{
			return _textures;
		}

		public function get fps():Number
		{
			return _fps;
		}

		public function get height():Number
		{
			return _height;
		}

		public function get width():Number
		{
			return _width;
		}

		private function onComplete(e:Event):void
		{
			var ldr:LoaderInfo = e.target as LoaderInfo;
			this.initValues(ldr.content as MovieClip);
			makeTextures(ldr.content as MovieClip);
		}
		
		private function initValues(clip:MovieClip):void
		{
			this._width = clip.loaderInfo.width;
			this._height = clip.loaderInfo.height;
			this._fps = clip.loaderInfo.frameRate;
		}
		
		private function makeTextures(clip:MovieClip):void
		{
			var bmp:BitmapData;
			for (var i:int = 0; i < clip.totalFrames; i++) 
			{
				clip.gotoAndStop(i);
				bmp = new BitmapData(this._width, this._height, true, 0);
				bmp.draw(clip);
				_textures.push(Texture.fromBitmapData(bmp, false, true));
				bmp.dispose();
			}
			
			this._isComplete = true;
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}