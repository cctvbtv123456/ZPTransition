//
//  ZPPushTransitionDelegate.h
//  ZPTransition
//
//  Created by mac on 2019/5/10.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZPPushTransitionDelegate : UIPercentDrivenInteractiveTransition<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic ,weak) UIViewController *popController;
@property (nonatomic ,weak) UIScrollView *scrollView;

+ (instancetype)shareInstance;

//系统自带侧滑
- (void)addPanGestureForViewController:(UIViewController *)viewController;
//自定义全屏手势
- (void)addPanGestureForViewController:(UIViewController *)viewController directionTypes:(ZPPanDirectionType)directionTypes;

@end

NS_ASSUME_NONNULL_END
