//
//  AnimationUIViewFrameStyle.m
//  ZPTransition
//
//  Created by mac on 2019/5/22.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#define ZPTransitionTime 0.5

#import "AnimationUIViewFrameStyle.h"

@implementation AnimationUIViewFrameStyle

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return ZPTransitionTime;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    toView.alpha = 0;
    
    NSArray *fromSubViews = [fromVC zp_transitionUIViewFrameViews];
    NSArray *toSubViews = [toVC zp_transitionUIViewFrameViews];
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    
    NSMutableArray *fromSubViewCopyArr = [[NSMutableArray alloc]init];
    for (int i =0; i <fromSubViews.count; i ++) {
        
        UIView *fromSubView = fromSubViews[i];
        
        // YES，代表视图的属性改变渲染完毕后截屏，参数为NO代表立刻将当前状态的视图截图
        UIView *fromSubViewCopy = [fromSubView snapshotViewAfterScreenUpdates:NO];
        CGRect rect = [fromSubView convertRect:fromSubView.bounds toView:KeyWindow];
        fromSubViewCopy.frame = rect;
        [containerView addSubview:fromSubViewCopy];
        
        [fromSubViewCopyArr addObject:fromSubViewCopy];
    }
    
    
    //设置动画前的各个控件的状态
    for (UIView *toSubView in toSubViews) {
        toSubView.hidden = YES;
    }
    
    //开始做动画
    [UIView animateWithDuration:ZPTransitionTime animations:^{
        
        fromView.alpha = 0;
        toView.alpha = 1;
        for (int i =0; i <fromSubViewCopyArr.count; i ++) {
            
            UIView *fromSubViewCopy = fromSubViewCopyArr[i];
            UIView *toSubView = toSubViews[i];
            CGRect rect = [toSubView convertRect:toSubView.bounds toView:KeyWindow];
            fromSubViewCopy.frame = rect;
        }
        
    } completion:^(BOOL finished) {
        
        if (!transitionContext.transitionWasCancelled) {
            
            fromView.alpha = 1;
            for (UIView *toSubView in toSubViews) {
                toSubView.hidden = NO;
            }
        }
        for (UIView *fromSubViewCopy in fromSubViewCopyArr) {
            [fromSubViewCopy removeFromSuperview];
        }
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
