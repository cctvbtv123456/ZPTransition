//
//  ZPPushTransitionDelegate.m
//  ZPTransition
//
//  Created by mac on 2019/5/10.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "ZPPushTransitionDelegate.h"

@interface ZPPushTransitionDelegate()
@property (nonatomic, assign) BOOL isInteraction;
@property (nonatomic, assign) BOOL isPop;
@property (nonatomic, assign) CGFloat edgeLeftBeganFloat;//侧滑距离
@property (nonatomic, assign) ZPPanDirectionType startDirection;//监测开始的手势,由上下滑转左右滑，还是按照上下为基础
@property (nonatomic, assign) CGFloat lastPercentComplete;//改变手势方向时刷新转场进度
@end

@implementation ZPPushTransitionDelegate

+ (instancetype)shareInstance{
    
    static ZPPushTransitionDelegate *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ZPPushTransitionDelegate alloc] init];
    });
    return _instance;
}

//系统自带侧滑
- (void)addPanGestureForViewController:(UIViewController *)viewController{
    
}
//自定义全屏手势
- (void)addPanGestureForViewController:(UIViewController *)viewController directionTypes:(ZPPanDirectionType)directionTypes{
    
}

@end
