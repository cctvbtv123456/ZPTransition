//
//  AppDelegate.m
//  ZPTransition
//
//  Created by mac on 2019/5/10.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "AppDelegate.h"
#import "AnimationTabScrollStyle.h"
#import "TabTransitionDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    BaseViewController *vc0 = [NSClassFromString(@"ViewController0") new];
    BaseNavigationController *Nav0 = [[BaseNavigationController alloc] initWithRootViewController:vc0];
    
    UITabBarController *tabBarVC = [UITabBarController new];
    tabBarVC.viewControllers = @[Nav0];
    NSArray *titles = @[@"仿AppStore", @"视图位移", @"视图缩小", @"仿抖音评论"];
    NSArray *normalImages = @[@"tabbar0", @"tabbar1", @"tabbar2", @"tabbar3"];
    NSArray *highlightImages = @[@"tabbarSelect0", @"tabbarSelect1", @"tabbarSelect2", @"tabbarSelect3"];
    tabBarVC.delegate = [TabTransitionDelegate shareInstance];
    [tabBarVC.viewControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.index = idx;
    }];
    [tabBarVC.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.title = titles[idx];
        obj.image = [[UIImage imageNamed:normalImages[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        obj.selectedImage = [[UIImage imageNamed:highlightImages[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }];
    tabBarVC.tabBar.tintColor = [UIColor blackColor];
    tabBarVC.tabBar.barTintColor = [UIColor whiteColor];
    
    self.window.rootViewController = tabBarVC;
    
    return YES;
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
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
