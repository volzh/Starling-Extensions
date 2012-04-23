package starling.extensions.display
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import starling.display.MovieClip;
	import starling.textures.Texture;
	
	/**
	 * Flash CS tool에서 swf로 만든 MovieClip을 Starling에서 바로 사용할 수 있도록 하는 클래스.<br/>
	 * starling.display.MovieClip과 거의 동일하게 사용.
	 * 
	 * This SWFClip class extends starling.display.MovieClip.
	 * SWFClip loads texture once when it should be displayed.
	 * 
	 * @example
	 * <listing version='3.0'>
	 * [Embed(source="src/05.swf",mimeType="application/x-shockwave-flash")]
	 * private var _embedClip:Class;
	 * 
	 * // embed한 swf를 사용하는 경우
	 * // if use embeded swf
	 * var clip:SWFClip = new SWFClip(_embedClip);
	 * clip.loop = true;
	 * clip.play();
	 * this.addChild(clip);
	 * Starling.juggler.add(clip);
	 * 
	 * 
	 * // FileLoader등을 사용하여 외부 파일을 로드, 또는 movieclip의 인스턴스를 사용하는 경우
	 * // if load from external file
	 * FileLoader.loadFile('swf.zip', 'swf', onSwfLoad);
	 * 
	 * private function onSwfLoad():void
	 * {
	 * 	var clip:SWFClip = new SWFClip(FileLoader.getSWF('effect.swf').content);
	 * }
	 * 
	 * </listing>
	 */
	public class SWFClip extends starling.display.MovieClip
	{
		private static var _textures:Dictionary = new Dictionary();
		private var _needResetFps:Boolean = false;
		
		/**
		 * 
		 * starling.display.MovieClip의 instance 생성 시에 Vector.<Texture>를 넘기는 것과 달리,
		 * 임베드된 swc의 무비클립 클래스명을 파라미터로 사용.
		 * 
		 * @param mv 임베드된 swf의 무비클립 클래스명 또는 무비클립의 인스턴스. embeded swf class name or instance of MovieClip
		 * @param fps 명시하지 않을 경우 swf의 framerate를 자동 적용. if no parameter, it will be set by original swf's framerate.
		 * 
		 */
		public function SWFClip(mv:*, fps:Number = 0)
		{
			if (fps == 0){
				this._needResetFps = true;
				fps = 12;
			}
			
			var texture:Vector.<Texture>;
			texture = new Vector.<Texture>();
			texture.push(Texture.empty());
			super(texture,fps);
			
			var ldr:SWFTextureLoader = _textures[mv];
			
			if (ldr != null){
				if (ldr.isComplete)	this.setTextures(_textures[mv]);
				else ldr.addEventListener(Event.COMPLETE, onComplete);
			} else {
				ldr = new SWFTextureLoader(mv);
				_textures[mv] = ldr;
				if (mv is flash.display.MovieClip){
					this.setTextures(ldr);
				} else {
					ldr.addEventListener(Event.COMPLETE, onComplete);
				}
			}
		}
		
		protected function onComplete(event:Event):void
		{
			var ldr:SWFTextureLoader = event.target as SWFTextureLoader;
			this.setTextures(ldr);
		}
		
		private function setTextures(ldr:SWFTextureLoader):void
		{
			this.width = ldr.width;
			this.height = ldr.height;
			
			for (var i:int = 0; i < ldr.textures.length; i++)
			{
				if (i==0){
					this.setFrameTexture(i, ldr.textures[i]);
				} else {
					this.addFrame(ldr.textures[i]);
				}
			}
			
			if (this._needResetFps) this.fps = ldr.fps;
		}
		
	}
}