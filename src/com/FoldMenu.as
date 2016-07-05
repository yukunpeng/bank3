package  com{
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	
	public class FoldMenu extends MovieClip {
		private var menuData:Object;
		
		public function unSelectedAll():void{
			for(var i:int=0;i<this["con"].numChildren;i++){
				//循环一级菜单
				var mainNav:MainNav = this["con"].getChildAt(i) as MainNav;
				mainNav.selcted(false);
			}
		}
		
		//点击一级菜单，触发折叠
		public function resetH():void{
			//定位一级菜单位置
			var num:int=this["con"].numChildren;
			for(var i:int=1;i<num;i++){
				var mainNav:MainNav=this["con"].getChildAt(i) as MainNav;
				var preNav:MainNav=this["con"].getChildAt(i-1) as MainNav;
				if(preNav["subCon"].visible){
					mainNav.y=preNav.y+preNav.height+10;
				}else{
					mainNav.y=preNav.y+preNav.height-preNav["subCon"].height+10;
				}
			}
			//重置滑动条高度
			var maskH:Number=this["maskMc"].height;
			//内容高度
			var conH:Number=this["con"].height;
			if(conH>maskH){
				this["barMc"].visible=true;
				this["barMc"]["thumMc"].height=maskH/conH*this["barMc"]["bgMc"].height;
				if(this["barMc"]["thumMc"].height+this["barMc"]["thumMc"].y>this["barMc"]["bgMc"].height){
					this["barMc"]["thumMc"].y=this["barMc"]["bgMc"].height-this["barMc"]["thumMc"].height;
				}
			}else{
				this["barMc"].visible=false;
			}
			
			//定位菜单容器位置
			treeMenuEnter(null);
		}
		
		public var tempPos:int=0;
		//设置菜单树
		public function setData(menuData:Object):void{
			this.menuData=menuData;
			var pos:int=0;
			for(var i:int=0;i<menuData.length;i++){
				var mainNav:MainNav = new MainNav(menuData[i]);
				mainNav.y=this["con"].height+10;
				mainNav.x=10;
				this["con"].addChild(mainNav);
			}
			resetH();
		}
		
		public function FoldMenu() {
			initBar();
		}
		
		private function initBar():void{
			this["barMc"]["thumMc"].addEventListener(MouseEvent.MOUSE_DOWN,thumDown);
		}
		//开始拖动滚动条
		private function thumDown(e:MouseEvent):void{
			var rect:Rectangle=new Rectangle(0,0,0,this["barMc"]["bgMc"].height-this["barMc"]["thumMc"].height);
			this["barMc"]["thumMc"].startDrag(false,rect);
			stage.addEventListener(MouseEvent.MOUSE_UP,thumUp);
			
			this.addEventListener(Event.ENTER_FRAME,treeMenuEnter);
		}
		//释放拖动的滚动条
		private function thumUp(e:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_UP,thumUp);
			this.removeEventListener(Event.ENTER_FRAME,treeMenuEnter);
			this["barMc"]["thumMc"].stopDrag();
		}
		
		//树装状菜单滚动
		private function treeMenuEnter(e:Event):void{
			var per:Number=this["barMc"]["thumMc"].y/(this["barMc"]["bgMc"].height-this["barMc"]["thumMc"].height);
			//遮罩高度
			var maskH:Number=this["maskMc"].height;
			//内容高度
			var conH:Number=this["con"].height+20;
			if(conH<maskH){
				this["con"].y=0;
			}else{
				this["con"].y=(maskH-conH)*per;
			}
		}
		
		//获取加载单单例
		private static var ins:FoldMenu;
		public static function getIns():FoldMenu{
			if(!FoldMenu.ins){
				FoldMenu.ins=new FoldMenu();
			}
			return FoldMenu.ins;
		}
		
	}
	
}
