# YBRouterDemo

## YBRouter路由，支持module模块间和controller间的跳转、传值以及回调

---

### **features:**

- 实现一行代码自动注册路由url，生成对应的router url；
- 在编译时进行类型检查，如果传入的不是类名则编译通不过；
- router支持controller之间跳转、传值回调以及模块间的通信；


### **预览图**

![screenShot](https://raw.githubusercontent.com/wangyingbo/YBRouterDemo/master/screenShot/screenShot1.png)

![screenShot](https://raw.githubusercontent.com/wangyingbo/YBRouterDemo/master/screenShot/screenShot2.png)

![screenShot](https://raw.githubusercontent.com/wangyingbo/YBRouterDemo/master/screenShot/screenShot3.png)

![screenShot](https://raw.githubusercontent.com/wangyingbo/YBRouterDemo/master/screenShot/screenShot4.png)

---

### **controller间通信介绍:**

**如controllerA到controllerB的跳转：**

- 只需在项目里建一个.h文件，然后在.h文件里调用一行代码注册controller；

		@YBControllerRegisterClass(DemoVC)
		
 默认路由url为类的类名，为了防止类名传错，在宏定义里进行了类名检查，所以如果导入一个类，则需要进行`@class DemoVC;`声明，在编译时抛出问题；
 
- 可自定controller对应的`router url`，使用方法：

		@YBControllerRegisterClassRouter(DemoVC, "bapp/userInfo?userId=123&token=xxxx")
		
此种方法自定义了类的url是`bapp/userInfo`，类似get请求规则，问号`?`前面是路由的url映射key，后面是参数，参数和参数之间以`&`隔开；

- 可自定义前缀，默认是`open://`开头的，如果需要自定义，则直接在.h文件里重新定义宏就行：

		#define ROUTER_PREFIX "weChat://" //可自定义前缀，需要多个前缀的话可参考YBRouter.h自己定义宏

- 跳转使用时，如下：

NSString *customUrl = [NSString stringWithCString:_DemoVC_URL_ encoding:NSUTF8StringEncoding];
    NSLog(@"自定义controller的url：%@",customUrl);
    
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    [mutDic setObject:@"123456" forKey:@"appCode"];
    [mutDic setObject:@"JackMa" forKey:@"name"];
    [YBRouter routerControllerURI:_DemoVC_URL_ parameter:mutDic.copy handler:nil];

调用`routerControllerURI:`时传入的url，如果是默认的touter url，则传入的url是`_className_className_`，如果是自定义的router url，则传入的url是`_className_URL_`，这两种router url名字都是在.h文件里声明类时，自动生成的静态常量字符串；

- 页面间传值，可在自定义的router url里参照get 请求的url结构拼接，也可以在调用`routerControllerURI:parameter:handler:`时自己手动传入；

		NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
		    [mutDic setObject:@"123456" forKey:@"appCode"];
		    [mutDic setObject:@"JackMa" forKey:@"name"];
		    [YBRouter routerControllerURI:_DemoVC_URL_ parameter:mutDic.copy handler:nil];

`hanlder:`是页面B发起的反向回调，可以在hanlder里写代码；

- controllerB可以遵守`YBRouterProtocol`或者`YBRouterKVCProtocol`协议；然后就可以在B页面拿到参数值：

继承`YBRouterProtocol`协议或者`YBRouterKVCProtocol`协议取得参数值方法：

	/**
	 controller之间跳转与传值
	 */
	- (void)configRouterParameters {
	    
	    NSLog(@"****************************************");
	    NSLog(@"遵守YBRouterKVCProtocol协议则KVC自动赋值");
	    NSLog(@"appCode:%@",self.appCode);
	    //name实现了协议里的routerIgnoredKeys方法后，不会自动赋值了
	    NSLog(@"name:%@",self.name);
	    
	    NSLog(@"****************************************");
	    NSLog(@"也可以遵守普通YBRouterProtocol协议，手动获取参数值");
	    NSDictionary *parameters = [self getRounterParameter];
	    NSString *appCode = parameters[@"appCode"];
	    NSString *name = parameters[@"name"];
	    NSLog(@"appCode:%@",appCode);
	    NSLog(@"name:%@",name);
	    
	    NSLog(@"****************************************");
	    NSLog(@"总的参数字典:%@",parameters);
	    
	    NSLog(@"****************************************");
	}
	

`YBRouterProtocol`协议有两个可选实现的方法：

	@protocol YBRouterProtocol <NSObject>
	@optional;
	/**暂无实义用处待定*/
	- (BOOL)implementationRouter;
	/**实现此协议决定当前是被present还是push出来*/
	- (BOOL)routerViewControllerIsPresented;
	@end

`YBRouterKVCProtocol`协议可选实现的方法：

	/**如果遵守YBRouterKVCProtocol协议，则所传的参数都需要有定义的成员属性或成员变量接收*/
	@protocol YBRouterKVCProtocol <YBRouterProtocol>
	/**KVC默认赋值时，需要被忽略的key*/
	- (NSArray<NSString *> *)routerIgnoredKeys;
	@end
	
- 在controllerB里可以通过

		self.rounterCompletion(nil);

回调controllerA里的hanlder，实现回调；

---

### **模块间通信介绍:**

- 可在.h文件里先声明注册对应的`module`和`method`，此宏会自动生成module对应的url，生成的经态常量字符串为：`_moduleName_methodName_`;

		//自定义模块间跳转的常量路由路径uri
		@YBRouterRegister(ModuleA, runDirectly)
		@YBRouterRegister(ModuleA, getSomeValue)
		@YBRouterRegister(ModuleA, runWithCallBack)
		@YBRouterRegister(ModuleA, callOtherModule)
		@YBRouterRegister(ModuleB, run)
		
- 宏内声明模块式，会利用`<mach-o/dyld.h>`的库函数对`target`和`method`进行类型检查，在编译时期就避免了传入的target和method不存在的情况；

		__attribute__((constructor))
		void _init() {
		    _dyld_register_func_for_add_image(dyld_callback);
		}
		
- 调用方式为：

		[YBRouter routerToURI:_ModuleA_runDirectly_ args:nil];
		
 调用的uri为声明模块时生成的经态常量字符串，后面的参数可任意传；
 
- 也可以通过`target`和`method`的方式实现调用；

![screenShot](https://raw.githubusercontent.com/wangyingbo/YBRouterDemo/master/screenShot/screenShot4.png)

		/**
		 测试模块间的通信与传值
		 */
		- (void)configModuleRouter {
		    
		    //1、直接调用
		    [YBRouter routerToURI:_ModuleA_runDirectly_ args:nil];
		    
		    //2、带返回值的调用方式
		    __unused id result = [YBRouter routerToURI:_ModuleA_getSomeValue_ args:nil];
		    
		    //3、带回调的调用方式
		    void(^callback)(BOOL result) = ^(BOOL result){
		        
		    };
		    [YBRouter routerToURI:_ModuleA_runWithCallBack_ args:@{@"callback": callback}];
		    
		    //4、调用其他组件
		    [YBRouter routerToURI:_ModuleA_callOtherModule_ args:nil];
		    
		    //5、执行方法
		    NSError *e = nil;
		    [YBRouter performTarget:@"ModuleA" action:@"b" args:nil error:&e];
		    if (e.code == -1) { // no target
		        NSLog(@"error:当前找不到target");
		    }
		    if (e.code == -2) { // mo method
		        NSLog(@"error:当前找不到method");
		    }
		    
		    //6、router_msgSend方法
		    id data = router_msgSend([ModuleA class], @selector(callClassSelector:array:dictionary:), @"testX",@[@(1),@"ahah"],@{@"name":@"Peny"});
		    NSLog(@"返回值：%@",data);
		    
		}