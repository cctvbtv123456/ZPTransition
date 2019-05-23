//
//  PressTransitionDelegate.h
//  ZPTransition
//
//  Created by mac on 2019/5/22.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PressTransitionDelegate : UIPercentDrivenInteractiveTransition <UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIViewController *disMissController;

@property (nonatomic, weak) UIScrollView *scrollView;

+ (instancetype)shareInstance;

// 系统自带侧滑
- (void)addEdgeLeftGestureForViewController:(UIViewController *)vc;

// 自定义全屏手势
- (void)addPanGestureForViewController:(UIViewController *)vc directionTypes:(ZPPanDirectionType)directionTypes;

@end

NS_ASSUME_NONNULL_END
