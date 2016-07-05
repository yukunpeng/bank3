package  utils{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class SoundManager {		
		private var bg:Sound;
		private var sdc:SoundChannel;
		
		private var pos:int=0;
		private var fun:Function;
		//加载外部声音
		public function loadSound(url:String,fun:Function):void{
			this.fun=fun;
			bg=new Sound();
			bg.addEventListener(Event.COMPLETE,loadCom);
			bg.load(new URLRequest(url));
		}
		//声音加载完毕
		private function loadCom(e:Event):void{
			fun();
		}
	
		public function SoundManager() {
			// constructor code
			
		}
		//播放声音
		public function play():void{
			sdc=bg.play(pos,0);
			sdc.addEventListener(Event.SOUND_COMPLETE,soundCom);
		}
		//声音暂停
		public function pause():void{
			sdc.removeEventListener(Event.SOUND_COMPLETE,soundCom);
			pos=sdc.position;
			sdc.stop();
		}
		//声音播放完毕，从头再来
		private function soundCom(e:Event):void{
			sdc.removeEventListener(Event.SOUND_COMPLETE,soundCom);
			pos=0;
			play();
		}
		//单例
		private static var ins:SoundManager;
		public static function getIns():SoundManager{
			if(!SoundManager.ins){
				SoundManager.ins=new SoundManager();
			}
			return SoundManager.ins;
		}

	}
	
}
