//
//  ViewController.m
//  YBRouterDemo
//
//  Created by fengbang on 2019/10/11.
//  Copyright © 2019 王颖博. All rights reserved.
//

#import "ViewController.h"
#import "YBItem.h"


/**屏幕的宽和高*/
#define FULL_SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define FULL_SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#define VIEWLAYOUT_W  KV_SCREEN_WIDTH/375
#define VIEWLAYOUT_H  (IS_IPHONEX?VIEWLAYOUT_W:KV_SCREEN_HEIGHT/667)
#define YBLAYOUT_W(w) w*VIEWLAYOUT_W//
#define YBLAYOUT_H(h) h*VIEWLAYOUT_H//

#define IS_IPHONEX      (FULL_SCREEN_HEIGHT==812)
#define TAB_BAR_H  (IS_IPHONEX ? 49.0+34.0 : 49.0)
#define STATUS_BAR_H  (IS_IPHONEX ? 44.0 : 20.0)
#define NAVIGATION_H (STATUS_BAR_H+44)

/**设置 view 圆角和边框*/
#define YBViewBorderRadius(View, radius, borderWidth, borderColor)\
\
[View.layer setCornerRadius:(radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(borderWidth)];\
[View.layer setBorderColor:[borderColor CGColor]];

#define YBViewShadow(View,shadowColor,offset,opacity,radius)\
View.layer.shadowOffset = offset;\
View.layer.shadowOpacity = opacity;\
View.layer.shadowRadius = radius;\
[View.layer setShadowColor:[shadowColor CGColor]];


typedef NS_ENUM(NSUInteger,YBRouterVCTag) {
    YBRouterVCTagDemo,
    YBRouterVCTagTest,
    YBRouterVCTagTestFirst,
};



@interface ViewController ()
@property (nonatomic, copy) NSArray *titleArray;

@end

@implementation ViewController


#pragma mark - override
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configNavigationUI];
    
    [self configData];
    
    [self configButtons];
    
    NSLog(@"");
}

#pragma mark - configData
- (void)configData {
    NSMutableArray *mutArray = [NSMutableArray array];
    [mutArray addObject:YB_CREATE_ITEM(YBRouterVCTagDemo, @"DemoVC")];
    [mutArray addObject:YB_CREATE_ITEM(YBRouterVCTagTest, @"TestVC")];
    [mutArray addObject:YB_CREATE_ITEM(YBRouterVCTagTestFirst, @"TestFirstVC")];
    self.titleArray = mutArray.copy;
}

#pragma mark - configUI
- (void)configNavigationUI {
    NSString *title = @"YBRouterDemo";
    self.title = title;
    self.navigationController.navigationItem.title = title;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)configButtons {
    UIButton *lastButton;
    CGFloat leftMargin = 25.f;
    CGFloat rightMargin = 25.f;
    CGFloat topMargin = NAVIGATION_H + 50.f;//第一行与父视图的上边距
    CGFloat space_horizontal = 20.f;//列间距
    CGFloat space_vertical = 20.f;//行间距
    
    for (int i=0;i<self.titleArray.count;i++) {
        YBItem *item = self.titleArray[i];
        UIButton *button = [[UIButton alloc] init];
        [self.view addSubview:button];
        YBViewBorderRadius(button, 10, .8, [UIColor colorWithRed:(0/255.0) green:(116/255.0) blue:(243/255.0) alpha:1])
        button.tag = item.tag.integerValue;
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        [button setTitle:item.name?:@"" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:(0/255.0) green:(116/255.0) blue:(243/255.0) alpha:1] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGSize buttonSize = [button sizeThatFits:CGSizeMake(FULL_SCREEN_WIDTH-leftMargin-rightMargin, MAXFLOAT)];
        buttonSize = CGSizeMake(buttonSize.width+15, buttonSize.height+2);
        if (item.width>1e-6) {
            buttonSize = CGSizeMake(item.width, buttonSize.height);
        }
        CGFloat button_x = leftMargin;
        CGFloat button_y = topMargin;
        if (lastButton) {
            CGFloat button_max_x = CGRectGetMaxX(lastButton.frame)+space_horizontal+buttonSize.width+rightMargin;
            button_x = (button_max_x<=FULL_SCREEN_WIDTH)?(CGRectGetMaxX(lastButton.frame)+space_horizontal):leftMargin;
            button_y = (button_max_x<=FULL_SCREEN_WIDTH)?(CGRectGetMinY(lastButton.frame)):CGRectGetMaxY(lastButton.frame)+space_vertical;
        }
        button.frame = CGRectMake(button_x, button_y, buttonSize.width, buttonSize.height);
        
        lastButton = button;
    }
}

#pragma mark - actions

/**
调用路由的三种方式
*/
- (void)buttonClick:(UIButton *)sender {
    NSUInteger tag = sender.tag;
    NSString *title = sender.titleLabel.text;
    
    switch (tag) {
        case YBRouterVCTagDemo:
        {
            [self demoVC_action];
        }
            break;
        case YBRouterVCTagTest:
        {
            [self testVC_action];
        }
            break;
        case YBRouterVCTagTestFirst:
        {
            [self testFirstVC_action];
        }
            break;
            
        default:
            break;
    }
}

/// 三种方式跳转
- (void)demoVC_action {
    //第一种：默认类名即路由，由@YBControllerRegisterClass注册的路由，路由名为_classVC_classVC_
    NSLog(@"默认类名作为url：%@",_DemoVC_DemoVC_);
    
    //第二种：自定义的路由，由@YBControllerRegisterClassRouter注册的路由，路由名为_classVC_URL_
    NSLog(@"自定义controller的url：%@",_DemoVC_URL_);
    
    //第三种：手动注册路由，由routerRegisterClass方法注册的路由，路由名为自定义的字符串
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    [mutDic setObject:@"123456" forKey:@"appCode"];
    [mutDic setObject:@"JackMa" forKey:@"name"];
    //[YBRouter routerControllerURI:_DemoVC_DemoVC_ parameter:mutDic.copy handler:nil];
    [YBRouter routerControllerURI:_DemoVC_URL_ parameter:mutDic.copy handler:nil];
    //[YBRouter routerControllerURI:kRouterServerDemoVC parameter:mutDic.copy handler:nil];
}

/// 测试用注册url的方式跳转
- (void)testVC_action {
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict setObject:@"123" forKey:@"orderId"];
    [mutDict setObject:@"alipay" forKey:@"name"];
    [YBRouter routerControllerURI:kRouterServerTestVC parameter:mutDict.copy handler:nil];
}

/// 测试用宏定义自动生成的url跳转
- (void)testFirstVC_action {
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict setObject:@"456" forKey:@"orderId"];
    [mutDict setObject:@"wechat" forKey:@"name"];
    [YBRouter routerControllerURI:_TestFirstVC_TestFirstVC_ parameter:mutDict.copy handler:nil];
}

@end
