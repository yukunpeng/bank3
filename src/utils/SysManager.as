package utils
{
	import flash.external.ExternalInterface;

	
	public class SysManager
	{
		//保存成绩
		public static function saveScore(score:Number):void{
			ExternalInterface.call("doLMSSetValue","cmi.core.score.raw", score+"");
		}
		//关闭窗口
		public static function closeWindow():void{
			ExternalInterface.call("window_close");
		}

		
		public static function getScore():Number{
			var scoreStr:String=ExternalInterface.call("doLMSSetValue","cmi.core.score.raw");
			return Number(scoreStr);
		}
		//发送passed
		public static function sendPassed():void{
			var str:String = ExternalInterface.call("doLMSGetValue","cmi.core.lesson_status");
       		if(str!="passed"  &&  str!="completed"){
				trace("passed");
                ExternalInterface.call("doLMSSetValue","cmi.core.lesson_status", "passed");
       		}
		}

		
		//发送complete
		public static function sendComplete():void{
			var str:String = ExternalInterface.call("doLMSGetValue","cmi.core.lesson_status");
			if(str!="completed"){
				trace("completed");
                ExternalInterface.call("doLMSSetValue","cmi.core.lesson_status", "completed");
       		}
			
		}
		
		//获取播放状态列表
		public static function saveState(arr:Array):void{
			//保存目前播放状态
			var str:String=arr.toString();
			ExternalInterface.call("doLMSSetValue", "cmi.suspend_data", str);
		}
		
		//获取播放状态列表
		//last2：题目完成状态，last1:上次退出时视频pos(-1代表正再做题)
		public static function getStateArr(len:int):Array{
			//len代表视频数目
			var arr:Array;
			var str:String = ExternalInterface.call("doLMSGetValue", "cmi.suspend_data");
			if(!str){
				str="";
				//没有操作过课程
				for(var i:int=0;i<len;i++){
					str+="1,";
				}
				//题目未回答1，播放视频0
				str+="1,0";
				//保存课程操作结果
				ExternalInterface.call("doLMSSetValue", "cmi.suspend_data", str);
			}
			arr=str.split(",");
			return arr;
		}

		
		//比较两个数组元素是否相同
		public static function compareArr(arr1:Array,arr2:Array):Boolean{
			if(arr1.length!=arr2.length){
				return false;
			}
			for(var i:int=0;i<arr1.length;i++){
				if(arr2.indexOf(arr1[i])==-1){
					return false;
				}
			}
			return true;
		}
		//打乱数组
		public static function upsetArr(arr:Array):Array{
			var a:Array=[];
			while(arr.length>0){
				var pos:int=Math.floor(Math.random()*arr.length);
				a.push(arr.splice(pos,1)[0]);
			}
			return a;
		}
	}
}