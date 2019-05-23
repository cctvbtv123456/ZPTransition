//
//  TabTransitionDelegate.m
//  ZPTransition
//
//  Created by mac on 2019/5/22.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "TabTransitionDelegate.h"
#import "AnimationTabScrollStyle.h"

@implementation TabTransitionDelegate

+ (instancetype)shareInstance{
    static TabTransitionDelegate *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[TabTransitionDelegate alloc] init];
    });
    return _instance;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    return [AnimationTabScrollStyle new];
}

@end
