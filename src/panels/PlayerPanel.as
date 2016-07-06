package panels {
	
	import com.AutoText;
	import com.FoldMenu;
	import com.MainNav;
	import com.SubNav;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	
	import gs.TweenLite;
	
	import utils.LoadManager;
	import utils.QuesManager;
	import utils.SoundManager;
	import utils.SysManager;
	
	public class PlayerPanel extends MovieClip {
		//视频地址列表
		private var playArr:Array;
		//缩略图地址列表
		private var thumArr:Array;
		//文本地址列表
		public static var autoTfArr:Array=[];
		public static var practiceTf:AutoText;
		public static var overTf:AutoText;
		//当前播放的视频索引
		private var playPos:int=0;
		
		private var stateArr:Array;//last-2：题目回答状态，last-1：退出时的视频pos
		private var menuData:Object;
		//题目回答状态：1未回答,2回答中,3通过
		private var quesState:int=1;
		
		//开始答题
		public function beginAnswer():void{
			//保存正在做题
			stateArr[stateArr.length-1]=-1;
			if(quesState==1){
				quesState=2;
				stateArr[stateArr.length-2]=quesState;
			}
			SysManager.saveState(stateArr);
			//做题项选中
			FoldMenu.getIns().unSelectedAll();
			practiceTf.selected(true);
			updateListState(stateArr);
			//暂停视频
			this["player"].stop();
			//视频到预定位置
			if(this["player"].x>8){
				switchPlace();
			}
			Main.ins.addChild(AnswerPanel.getIns());
			AnswerPanel.getIns().resetAns();
		}
		
		//播放指定的视频
		public function playVideo(pos:int):void{
			//保存正在播放的视频pos
			setStateByPos(pos);
			stateArr[stateArr.length-1]=pos;
			SysManager.saveState(stateArr);
			//存在题目和结算，删除之
			if(Main.ins.contains(AnswerPanel.getIns())){
				Main.ins.removeChild(AnswerPanel.getIns());
			}
			if(Main.ins.contains(ResultPanel.getIns())){
				Main.ins.removeChild(ResultPanel.getIns());
			}
			
			FoldMenu.getIns().unSelectedAll();
			
			playPos=pos;
			//显示缩略图
			this["thumPic"].source=thumArr[pos];
			//播放指定视频
			this["player"].source=playArr[pos];
			
			PlayerPanel.autoTfArr[pos].selected(true);
			//从头开始播放
			this["player"].seekSeconds(0);
			this["player"].play();
		}
		
		//题目完成
		public function quesPass():void{
			if(quesState!=3){
				quesState=3;
				//保存题目通过
				stateArr[stateArr.length-2]=quesState;
				updateListState(stateArr);
				isAllLearnOver();
				SysManager.saveState(stateArr);
			}
		}
		
		public function PlayerPanel() {
			LoadManager.getIns().loadJson("asset/videolist.json",videoListCom);
		}
		
		private function videoListCom(obj:Object):void{
			menuData=obj;
			LoadManager.getIns().loadJson("asset/queslist.json",quesListcom);
			
			//初始化播放列表
			initPlayArr();
			
			//创建树状菜单
			addChild(FoldMenu.getIns());
			FoldMenu.getIns().setData(menuData);
			FoldMenu.getIns().x=7;
			FoldMenu.getIns().y=270;
			//检测视频播放完毕
			this["player"].addEventListener(Event.COMPLETE,videoOver);
			this.addEventListener(MouseEvent.CLICK,onHandel);
			SoundManager.getIns().loadSound("asset/bg.mp3",bgCom);
			//获取学习状态
			stateArr=SysManager.getStateArr(autoTfArr.length);
			updateListState(stateArr);
			
			
			
			this.addEventListener(Event.ENTER_FRAME,onEnter);
			this["proMc"]["clickMc"].addEventListener(MouseEvent.CLICK,proTouch);
			this["volumeMc"]["clickMc"].addEventListener(MouseEvent.CLICK,volumeTouch);
			
			this["proMc"]["thumMc"].addEventListener(MouseEvent.MOUSE_DOWN,thumDown);
			this["volumeMc"]["thumMc"].addEventListener(MouseEvent.MOUSE_DOWN,soundThumDown);
		}
		
		private function soundThumDown(e:MouseEvent):void{
			if(this["player"].stateResponsive){
				var rect:Rectangle=new Rectangle(0,0,this["volumeMc"]["bgMc"].width,0);
				this["volumeMc"]["thumMc"].startDrag(false,rect);
				this.stage.addEventListener(MouseEvent.MOUSE_UP,soundThumUp);
				this.stage.addEventListener(Event.ENTER_FRAME,soundThumEnter);
			}
		}
		private function soundThumUp(e:MouseEvent):void{
			this.stage.removeEventListener(MouseEvent.MOUSE_UP,soundThumUp);
			this.stage.removeEventListener(Event.ENTER_FRAME,soundThumEnter);
			this["volumeMc"]["thumMc"].stopDrag();
		}
	
		private function soundThumEnter(e:Event):void{
			//更新播放进度
			var per:Number=this["volumeMc"]["thumMc"].x/this["volumeMc"]["bgMc"].width;
			this["volumeMc"]["proMc"].width=this["volumeMc"]["thumMc"].x;
			this["player"].volume=per;
		}
		
		
		
		private function thumDown(e:MouseEvent):void{
			if(this["player"].stateResponsive){
				this.removeEventListener(Event.ENTER_FRAME,onEnter);
				this["player"].pause();
				var rect:Rectangle=new Rectangle(0,0,this["proMc"]["bgMc"].width,0);
				this["proMc"]["thumMc"].startDrag(false,rect);
				
				this.stage.addEventListener(MouseEvent.MOUSE_UP,thumUp);
			}
		}
		private function thumUp(e:MouseEvent):void{
			this["proMc"]["thumMc"].stopDrag();
			//更新播放进度
			var per:Number=this["proMc"]["thumMc"].x/this["proMc"]["bgMc"].width;
			this["player"].seekPercent(per*100);
			this["player"].play();
			this.stage.removeEventListener(MouseEvent.MOUSE_UP,thumUp);
			this.addEventListener(Event.ENTER_FRAME,onEnter);
		}
		
		
		private function volumeTouch(e:MouseEvent):void{
			if(this["player"].stateResponsive){
				//更新播放进度
				var per:Number=e.localX/this["volumeMc"]["bgMc"].width;
				this["volumeMc"]["proMc"].width=e.localX;
				this["volumeMc"]["thumMc"].x=e.localX;
				this["player"].volume=per;
			}
		}
		
		
		private function proTouch(e:MouseEvent):void{
			if(this["player"].stateResponsive){
				//更新播放进度
				var per:Number=e.localX/this["proMc"]["bgMc"].width;
				this["proMc"]["proMc"].width=e.localX;
				this["player"].seekPercent(per*100);
			}
		}
		
		private function quesListcom(obj:Object):void{
			//初始化题目状态
			this.quesState=stateArr[stateArr.length-2];
			//设置题目
			QuesManager.getIns().setQues(obj);
			//恢复程序退出时候的状态
			if(stateArr[stateArr.length-1]==-1){
				beginAnswer();
			}else{
				this.playVideo(stateArr[stateArr.length-1]);
			}
			
			updateListState(stateArr);
			isAllLearnOver();
			//向服务器提交成绩0
			SysManager.saveScore(0);
		}

		public function isAllLearnOver():Boolean{
			//更新有子菜单的主菜单
			for(var i:int=0;i<FoldMenu.getIns()["con"].numChildren-1;i++){
				mainNav=FoldMenu.getIns()["con"].getChildAt(i) as MainNav;
				if(mainNav.state!=3){
					return false;
				}
			}
			var mainNav:MainNav=PlayerPanel.overTf.parent.parent as MainNav;
			mainNav.setState(3);
			return true;
		}
	
		
		//播放视频，修改其播放状态
		private function setStateByPos(pos:int):void{
			//该视频还没有播放过
			if(getStateByPos(pos)==1){
				stateArr[pos]=2;
				
				//保存目前播放状态
				SysManager.saveState(stateArr); 
			}
			updateListState(stateArr);
		}
		
		//根据视频索引获取该视频的学习状态
		private function getStateByPos(pos:int):int{
			//该视频是二级菜单
			if(autoTfArr[pos].parent.parent is SubNav){
				var subNav:SubNav=autoTfArr[pos].parent.parent as SubNav;
				return subNav.getState();
			}else{
				//该视频属于一级菜单
				var mainNav:MainNav=autoTfArr[pos].parent.parent as MainNav;
				return mainNav.getState();
			}
		}
		
		private function onEnter(e:Event):void{
			//更新视频时间
			var totalTime:Number=this["player"].totalTime;
			var curTime:Number=this["player"].playheadTime;
			this["timeTf"].text=getTimeStr(curTime)+"/"+getTimeStr(totalTime);
			
			//更新播放进度
			var per:Number=curTime/totalTime;
			this["proMc"]["proMc"].width=this["proMc"]["bgMc"].width*per;
			this["proMc"]["thumMc"].x=this["proMc"]["bgMc"].width*per;
		}
		
		private var learnState:String;
				
		//更新列表播放状态
		private function updateListState(arr:Array):void{
			var i:int;
			var mainNav:MainNav;
			//子菜单或无子菜单的主菜单，状态更新
			for(i=0;i<autoTfArr.length;i++){
				//状态显示正没学过，按照数据设置
				if(autoTfArr[i].parent.parent.getState()==1){
					autoTfArr[i].parent.parent.setState(arr[i]);
				}else if(autoTfArr[i].parent.parent.getState()==2){
					//状态显示正在学习，数据显示完成了，完成
					if(arr[i]==3)autoTfArr[i].parent.parent.setState(3);
				}else{
					//状态显示完成了，数据显示没有完成，则正在学习
					if(arr[i]!=3)autoTfArr[i].parent.parent.setState(2);
				}
			}
			//更新有子菜单的主菜单
			for(i=0;i<FoldMenu.getIns()["con"].numChildren;i++){
				mainNav=FoldMenu.getIns()["con"].getChildAt(i) as MainNav;
				//具有子菜单再操作
				if(mainNav["subCon"].numChildren>0){
					var state:int=1;
					var is1:Boolean=false;
					var is2:Boolean=false;
					var is3:Boolean=false;
					for(var j:int=0;j<mainNav["subCon"].numChildren;j++){
						var subNav:SubNav=mainNav["subCon"].getChildAt(j) as SubNav;
						if(subNav.getState()==1){
							is1=true;
						}
						if(subNav.getState()==2){
							is2=true;
						}
						if(subNav.getState()==3){
							is3=true;
						}
					}
					//未学习
					if(is1&&!is2&&!is3){
						mainNav.setState(1);
					}else if(!is1&&!is2&&is3){
						//已学完
						mainNav.setState(3);
					}else{
						mainNav.setState(2);
					}
				}
			}
			//更新题目状态
			mainNav=practiceTf.parent.parent as MainNav;
			mainNav.setState(quesState);
		}
		
		//背景音乐加载完毕
		private function bgCom():void{
			SoundManager.getIns().play();
			this["musicMc"].addEventListener(MouseEvent.CLICK,musicBtnClick);
		}
		//点击音乐按钮
		private function musicBtnClick(e:MouseEvent):void{
			if(this["musicMc"].currentFrame==1){
				this["musicMc"].gotoAndStop(2);
				SoundManager.getIns().pause();
			}else{
				this["musicMc"].gotoAndStop(1);
				SoundManager.getIns().play();
			}
		}
		//视频播放完毕
		private function videoOver(e:Event):void{
			isAllLearnOver();
			if(stateArr[playPos]!=3){
				stateArr[playPos]=3;
				SysManager.saveState(stateArr);
				updateListState(stateArr);
			}
			//播放下一个视频
			if(playPos<playArr.length-1){
				FoldMenu.getIns().unSelectedAll();
				playPos++;
				playVideo(playPos);
			}else{
				//开始答题
				beginAnswer();
			}
			
			//是否发送complete
			if(PlayerPanel.getIns().isAllLearnOver()){
				SysManager.sendComplete();
			}
			
		}
		
		private function onHandel(e:MouseEvent):void{
			switch(e.target){
				case this["preBtn"]:
					//上一曲
					if(playPos!=0){
						playPos--;
						playVideo(playPos);
					}
					break;
				case this["nextBtn"]:
					//下一曲
					if(playPos<playArr.length-1){
						playPos++;
						playVideo(playPos);
					}else{
						beginAnswer();
					}
					break;
				case this["replayBtn"]:
					//从头播放
					playVideo(playPos);
					break;
				case this["switchBtn"]:
					//切换位置
					switchPlace();
					break;
			}
		}
		
		private function switchPlace():void{
			if(this["player"].x>8){
				TweenLite.to(this["player"], 0.3, {x:8,y:97,width:300,height:170});
				TweenLite.to(this["thumPic"], 0.3, {x:314,y:96,width:960,height:540});
			}else{
				TweenLite.to(this["player"], 0.3, {x:314,y:96,width:960,height:540});
				TweenLite.to(this["thumPic"], 0.3, {x:8,y:97,width:300,height:170});
			}
			
		}
		
		//=========================================
		//获取两位数字
		private function get2Str(num:int):String{
			if(num<10){
				return "0"+num;
			}
			return num+"";
		}
		//根据秒，换算得到--分:秒
		private function getTimeStr(value:int):String{
			//时
			var h:int=Math.floor(value/3600);
			//分
			var m:int=Math.floor((value%3600)/60);
			//秒
			var s:int=value%60;
			
			var str:String="";
			if(h>0){
				str+=get2Str(h)+":";
			}
			str+=get2Str(m)+":"+get2Str(s);
			
			return str;
		}

		//获取加载单单例
		private static var ins:PlayerPanel;
		public static function getIns():PlayerPanel{
			if(!PlayerPanel.ins){
				PlayerPanel.ins=new PlayerPanel();
			}
			return PlayerPanel.ins;
		}
		//初始化视频播放列表
		private function initPlayArr():void{
			this.playArr=[];
			this.thumArr=[];
			
			var k:int;
			var url:String;
			var urlArr:Array;
			var temp:String;
			var tempArr:Array;
			
			
			for(var i:int=0;i<menuData.length;i++){
				//该一级菜单有子目录
				if(menuData[i]["subArr"]){
					for(var j:int=0;j<menuData[i]["subArr"].length;j++){
						url=menuData[i]["subArr"][j]["url"];
						urlArr=url.split("|");
						temp=menuData[i]["subArr"][j]["pic"];
						tempArr=temp.split("|");
						for(k=0;k<urlArr.length;k++){
							playArr.push(urlArr[k]);
							thumArr.push(tempArr[k]);
						}
					}
				}else if(menuData[i]["over"]){
					
				}else{
					//该一级菜单没有子目录
					url=menuData[i]["url"];
					urlArr=url.split("|");
					temp=menuData[i]["pic"];
					tempArr=temp.split("|");
					for(k=0;k<urlArr.length;k++){
						playArr.push(urlArr[k]);
						thumArr.push(tempArr[k]);
					}
				}
			}
		}
	}
	
}
