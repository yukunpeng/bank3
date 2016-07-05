package  utils{
	
	public class QuesManager {	
		private var quesObj:Object;
		
		private var pos:int;
		
		private var quesArr:Array;
		
		private var radioNum:int;
		private var checkNum:int;
		private var judgeNum:int;
		
		
		//重置题目
		public function resetPos():void{
			pos=0;
		}
		//获取题目数目
		public function getQuesSum():int{
			return quesArr.length;
		}
		//获取题目编号
		public function getQuesPos():int{
			return pos+1;
		}
		//获取题目类型
		public function getQuesType():String{
			if(pos+1<=radioNum){
				return "单选题";
			}else if(pos+1<=radioNum+checkNum){
				return "多选题";
			}else{
				return "判断题";
			}
		}
		
		//获取当前题目
		public function getQues():Object{
			return quesArr[pos];
		}
		//进入下一题
		public function gotoNext():void{
			pos++;
		}
		//题目是否结束
		public function isQuesOver():Boolean{
			if(pos>=quesArr.length)return true;
			return false;
		}
				
		//
		public function setQues(obj:Object):void{
			quesObj=obj;
			upsetQues();
		}
		
		private function upsetQues():void{
			quesArr=[];
			var i:int;
			var arr:Array;
			if(quesObj["radio"]){
				arr=quesObj["radio"];
				arr=SysManager.upsetArr(arr);
				for(i=0;i<arr.length;i++){
					quesArr.push(arr[i]);
				}
				radioNum=arr.length;
			}else{
				radioNum=0;
			}
			if(quesObj["check"]){
				arr=quesObj["check"];
				arr=SysManager.upsetArr(arr);
				for(i=0;i<arr.length;i++){
					quesArr.push(arr[i]);
				}
				checkNum=arr.length;
			}else{
				checkNum=0;
			}
			if(quesObj["judge"]){
				arr=quesObj["judge"];
				arr=SysManager.upsetArr(arr);
				for(i=0;i<arr.length;i++){
					quesArr.push(arr[i]);
				}
				judgeNum=arr.length;
			}else{
				judgeNum=0;
			}
		}
		
		public function QuesManager() {
			// constructor code
		}
		private static var ins:QuesManager;
		public static function getIns():QuesManager{
			if(!QuesManager.ins){
				QuesManager.ins=new QuesManager();
			}
			return QuesManager.ins;
		}

	}
	
}
