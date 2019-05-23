//
//  AnimationWindowScaleStylePush.m
//  ZPTransition
//
//  Created by mac on 2019/5/22.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#define ZPTransitionTime 0.5

#import "AnimationWindowScaleStylePush.h"

@implementation AnimationWindowScaleStylePush

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return ZPTransitionTime;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.frame = transitionContext.containerView.bounds;
    [transitionContext.containerView addSubview:toView];
    
    UIColor *color = transitionContext.containerView.backgroundColor;
    transitionContext.containerView.backgroundColor = [UIColor blackColor];
    
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    toView.frame = CGRectMake(toView.frame.size.width, toView.frame.origin.y, toView.frame.size.width, toView.frame.size.height);
    
    [UIView animateWithDuration:ZPTransitionTime animations:^{
        
        toView.frame = CGRectMake(0, toView.frame.origin.y, toView.frame.size.width, toView.frame.size.height);
        fromView.transform = CGAffineTransformMakeScale(0.95, 0.95);
        
    } completion:^(BOOL finished) {
        
        transitionContext.containerView.backgroundColor = color;
        fromView.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end

////////////////////

@implementation AnimationWindowScaleStylePop

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    return ZPTransitionTime;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    toView.frame = transitionContext.containerView.bounds;
    [transitionContext.containerView addSubview:toView];
    [transitionContext.containerView bringSubviewToFront:fromView];
    
    UIColor *color = transitionContext.containerView.backgroundColor;
    transitionContext.containerView.backgroundColor = [UIColor blackColor];
    
    toView.transform = CGAffineTransformMakeScale(0.95, 0.95);
    CGRect origin = fromView.frame;
    
    [UIView animateWithDuration:ZPTransitionTime animations:^{
        
        fromView.frame = CGRectMake(fromView.frame.size.width, fromView.frame.origin.y, fromView.frame.size.width, fromView.frame.size.height);
        toView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        if (!transitionContext.transitionWasCancelled) {
            transitionContext.containerView.backgroundColor = color;
            fromView.frame = origin;
        }
        toView.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
