package  utils{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class LoadManager {
		private var loader:URLLoader;
		private var fun:Function;//回调函数
		
		public function loadJson(url:String,fun:Function):void{
			this.fun=fun;
			loader.load(new URLRequest(url));
		}
		
		public function LoadManager() {
			loader=new URLLoader();
			loader.addEventListener(Event.COMPLETE,loadJsonCom);
		}
		
		//外部json加载完毕
		private function loadJsonCom(e:Event):void{
			var obj:Object = JSON.parse(loader.data);
			fun(obj);
		}
		
		//获取加载单单例
		private static var ins:LoadManager;
		public static function getIns():LoadManager{
			if(!LoadManager.ins){
				LoadManager.ins=new LoadManager();
			}
			return LoadManager.ins;
		}

	}
	
}
