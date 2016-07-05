package  panels{
	
	import flash.display.MovieClip;
	
	
	public class Shuiyin extends MovieClip {
		
		
		public function Shuiyin() {
			// constructor code
		}
		
		//获取加载单单例
		private static var ins:Shuiyin;
		public static function getIns():Shuiyin{
			if(!Shuiyin.ins){
				Shuiyin.ins=new Shuiyin();
			}
			return Shuiyin.ins;
		}

	}
	
}
