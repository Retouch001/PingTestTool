//
//  AppDelegate.m
//  ping检测工具
//
//  Created by 方景琦 on 2016/12/6.
//  Copyright © 2016年 Retouch. All rights reserved.
//

#import "AppDelegate.h"
#import "BGTask.h"
#import "BGLogation.h"

#import "NSObject+NSLocalNotification.h"


#define LOCALNOTIFICATION_KEY             @"localNotificationKey"


@interface AppDelegate ()

@property (strong , nonatomic) BGTask *task;
@property (strong , nonatomic) NSTimer *bgTimer;
@property (strong , nonatomic) BGLogation *bgLocation;
@property (strong , nonatomic) CLLocationManager *location;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIViewController *rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    
    self.window.rootViewController = rootViewController;
    
    [self.window makeKeyAndVisible];
    
    
    [self configureNavitationBarStyle];
    

    [application setApplicationIconBadgeNumber:0];

    
    
    _task = [BGTask shareBGTask];
    UIAlertController *alert;
    //判断定位权限
    if([UIApplication sharedApplication].backgroundRefreshStatus == UIBackgroundRefreshStatusDenied)
    {
        alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"应用不能正常使用定位功能\n需要在在--设置--通用--后台应用刷新开启此功能" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ensureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }] ;
        
        UIAlertAction *goToSetAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            //定位服务设置界面
            NSURL*url=[NSURL URLWithString:@"Prefs:root=General&path=REFRESHING"];
            
            Class LSApplicationWorkspace = NSClassFromString(@"LSApplicationWorkspace");
            
            [[LSApplicationWorkspace performSelector:@selector(defaultWorkspace)] performSelector:@selector(openSensitiveURL:withOptions:) withObject:url withObject:nil];
        }];
        
        [alert addAction:ensureAction];
        [alert addAction:goToSetAction];
        
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];

    }
    else if ([UIApplication sharedApplication].backgroundRefreshStatus == UIBackgroundRefreshStatusRestricted)
    {
        
        alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备不可以定位" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }] ;
        
        [alert addAction:action];
        
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];

     }
    else
    {
        self.bgLocation = [[BGLogation alloc]init];
        [self.bgLocation startLocation];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(log) userInfo:nil repeats:YES];
    }

    
    
    
    
    return YES;
}



-(void)defaultWorkspace{
    
}

-(void)openSensitiveURL:(NSURL *)url withOptions:(NSDictionary *)dic{

}

-(void)log
{
    NSLog(@"执行");
}



-(void)startBgTask
{
    [_task beginNewBackgroundTask];
}




-(void)configureNavitationBarStyle{
    //再plist文件中设置View controller-based status bar appearance 为 NO才能起效
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //导航条上标题的颜色
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    //导航条上UIBarButtonItem颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    //    //TabBar选中图标的颜色,默认是蓝色
    //    [[UITabBar appearance] setTintColor:[UIColor colorWithHex:0x15A230]];
    //    //TabBarItem选中的颜色
    //    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x15A230]} forState:UIControlStateSelected];
    
    //导航条的背景颜色
    [[UINavigationBar appearance] setBarTintColor:UIColorFromHex(0xD83938)];
    
    
    
    
    //    //TabBar的背景颜色
    //    [[UITabBar appearance] setBarTintColor:[UIColor titleBarColor]];
    
    //    [UISearchBar appearance].tintColor = [UIColor redColor];
    //    //当某个class被包含在另外一个class内时，才修改外观。
    //    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setCornerRadius:14.0];
    //    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setAlpha:0.6];
    //
    //
    //    UIPageControl *pageControl = [UIPageControl appearance];
    //    pageControl.pageIndicatorTintColor = [UIColor colorWithHex:0xDCDCDC];
    //    pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    //
    //    [[UITextField appearance] setTintColor:[UIColor nameColor]];
    //    [[UITextView appearance]  setTintColor:[UIColor nameColor]];
    
}




/**
 只有当发送出一个本地通知, 并且满足以下条件时, 才会调用该方法
 APP 处于前台情况
 当用用户点击了通知, 从后台, 进入到前台时,
 当锁屏状态下, 用户点击了通知, 从后台进入前台
 
 注意: 当App彻底退出时, 用户点击通知, 打开APP , 不会调用这个方法
 
 但是会把通知的参数传递给 application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
 
 */

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    [application setApplicationIconBadgeNumber:0];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"报告完成提醒" message:notification.alertBody preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self.window.rootViewController presentViewController:alertVC animated:YES completion:nil];
    
    
    // 查看当前的状态出于(前台: 0)/(后台: 2)/(从后台进入前台: 1)
    NSLog(@"applicationState.rawValue: %zd", application.applicationState);
    
    // 执行响应操作
    // 如果当前App在前台,执行操作
    if (application.applicationState == UIApplicationStateActive) {
        
    } else if (application.applicationState == UIApplicationStateInactive) {
        // 后台进入前台
    } else if (application.applicationState == UIApplicationStateBackground) {
        // 当前App在后台
    }
    
    
}






//监听通知操作行为的点击
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    NSLog(@"监听通知操作行为的点击");
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
