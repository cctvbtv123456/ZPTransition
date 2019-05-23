//
//  ZPPushTransitionDelegate.m
//  ZPTransition
//
//  Created by mac on 2019/5/10.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "ZPPushTransitionDelegate.h"
#import "AnimationTabScrollStyle.h"
#import "AnimationAppStoreStylePush.h"
#import "AnimationUIViewFrameStyle.h"
#import "AnimationWindowScaleStylePush.h"

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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if ([gestureRecognizer isMemberOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        
        if ([otherGestureRecognizer isMemberOfClass:[UIScreenEdgePanGestureRecognizer class]] || [otherGestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]]) {
            return NO;
        }
    }
    
    if ([gestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]]) {
        if ([otherGestureRecognizer isMemberOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark 系统自带侧滑
- (void)addPanGestureForViewController:(UIViewController *)viewController{
    
    UIScreenEdgePanGestureRecognizer *edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(doInteractiveTypePop:)];
    edgePan.edges = UIRectEdgeLeft;
    [viewController.view addGestureRecognizer:edgePan];
}

- (void)doInteractiveTypePop:(UIPanGestureRecognizer *)gesture{
    
    CGPoint translation = [gesture translationInView:gesture.view];
    CGFloat percentComplete = 0;
    
    // 左右滑动的百分比
    percentComplete = translation.x / [[UIApplication sharedApplication] keyWindow].frame.size.width;
    percentComplete = fabs(percentComplete);
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        self.isInteraction = YES;
        [self.popController.navigationController popViewControllerAnimated:YES];
        
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        
        self.isInteraction = NO;
        [self updateInteractiveTransition:percentComplete];
        
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        
        self.isInteraction = NO;
        if (percentComplete > 0.3f) {
            [self finishInteractiveTransition];
        }else{
            [self cancelInteractiveTransition];
        }
        
    }else{
        self.isInteraction = NO;
        [self cancelInteractiveTransition];
    }
}

#pragma mark  自定义全屏手势
- (void)addPanGestureForViewController:(UIViewController *)viewController directionTypes:(ZPPanDirectionType)directionTypes{
    
    if (directionTypes == 0) return;
    
    self.startDirection = ZPPanDirectionNone;
    viewController.panDirectionTypes = directionTypes;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doGestureRecognizerPop:)];
    pan.delegate = self;
    [viewController.view addGestureRecognizer:pan];
}

#pragma mark  交互
- (void)doGestureRecognizerPop:(UIPanGestureRecognizer *)gesture{
    
    CGFloat gestureHeight = UIScreen.mainScreen.bounds.size.height;
    CGPoint translation = [gesture translationInView:gesture.view];
    
    CGFloat percentCompleteX = 0.0;
    CGFloat percentCompleteY = 0.0;
    CGFloat percentComplete = 0.0;
    
    // 左右滑动的百分比
    percentCompleteX = translation.x / UIScreen.mainScreen.bounds.size.width;
    percentCompleteX = fabs(percentCompleteX);
    
    // 上下滑动的百分比
    percentCompleteY = translation.y / gestureHeight;
    percentCompleteY = fabs(percentCompleteY);
    
    ZPPanDirectionType panDirection = ZPPanDirectionNone;
    //如果开始是左右（上下）方向，之后也是以左右（上下）为标准
    if (ZPPanDirectionEdgeLeft == self.startDirection || ZPPanDirectionEdgeRight == self.startDirection) {
        if (translation.x > 0) {
            // 右侧
            panDirection = ZPPanDirectionEdgeLeft;
        }else{
            // 左侧
            panDirection = ZPPanDirectionEdgeRight;
        }
        percentComplete = percentCompleteX;
        
    }else if (ZPPanDirectionEdgeUp == self.startDirection || ZPPanDirectionEdgeDown == self.startDirection){
        
        if (translation.y > 0) {
            // 下滑
            panDirection = ZPPanDirectionEdgeUp;
        }else if (translation.y < 0){
            // 上滑
            panDirection = ZPPanDirectionEdgeDown;
        }
        percentComplete = percentCompleteY;
        
    }else{
        
        if (fabs(translation.x) > fabs(translation.y)) {
            if (translation.x > 0) {
                // 右滑
                panDirection = ZPPanDirectionEdgeLeft;
            }else if (translation.x < 0){
                // 左滑
                panDirection = ZPPanDirectionEdgeDown;
            }
            percentComplete = percentCompleteX;
        }else{
            if (translation.y > 0) {
                // 下滑
                panDirection = ZPPanDirectionEdgeUp;
            }else if (translation.y < 0){
                // 上滑
                panDirection = ZPPanDirectionEdgeDown;
            }
            percentComplete = percentCompleteY;
        }
        
        if (ZPPanDirectionNone == self.startDirection) {
            self.startDirection = panDirection;
        }
    }
    
    //当为左右滑时，不让scrollView滚动；当上下滑时，记录改变方向前的percentComplete
    WS(weakSelf);
    [self handleScrollViewPercentComplete:percentComplete directionType:panDirection block:^(CGFloat bPercentComplete, ZPPanDirectionType bPanDirection) {
        
        //转场进度动画处理
        [weakSelf handleGesture:gesture percentComplete:bPercentComplete directionType:bPanDirection];
    }];
    
}

- (void)handleScrollViewPercentComplete:(CGFloat)percentComplete directionType:(ZPPanDirectionType)panDirection block:(void(^)(CGFloat bPercentComplete,ZPPanDirectionType bPanDirection))block{
    
    if (self.scrollView) {
        if (ZPPanDirectionEdgeUp == self.startDirection || ZPPanDirectionEdgeDown == self.startDirection) {
            
            if (self.scrollView.contentOffset.y <= 0) {
                self.scrollView.bounces = NO;
            }else{
                self.scrollView.bounces = YES;
            }
            
            if (self.scrollView.contentOffset.y <= 0) {
                if (ZPPanDirectionEdgeUp == panDirection) {
                    
                    self.scrollView.contentOffset = CGPointMake(0, 0);
                    percentComplete = percentComplete - self.lastPercentComplete;
                    
                }else if (ZPPanDirectionEdgeDown == panDirection){
                    
                    self.lastPercentComplete = percentComplete;
                    percentComplete = 0;
                }
            }else{
                
                if (ZPPanDirectionEdgeUp == panDirection) {
                    self.lastPercentComplete = percentComplete;
                    if (self.scrollView.contentOffset.y > 0) {
                        percentComplete = 0;
                    }
                }else if (ZPPanDirectionEdgeDown == panDirection){
                    
                }
            }
        }else if (ZPPanDirectionEdgeLeft == self.startDirection || ZPPanDirectionEdgeRight == self.startDirection){
            self.scrollView.scrollEnabled = NO;
        }
    }
    
    block(percentComplete, panDirection);
}

- (void)handleGesture:(UIPanGestureRecognizer *)gesture percentComplete:(CGFloat)percentComplete directionType:(ZPPanDirectionType)directionType{
    
    // 对于不包含的手势禁止动画
    if (!(self.popController.panDirectionTypes &directionType)) {
        percentComplete = 0;
    }
    // 向右滑动起始位置超出TLPanEdgeInside则失效
    if (ZPPanDirectionEdgeLeft == directionType) {
        if (self.edgeLeftBeganFloat > PanEdgeInside) {
            percentComplete = 0;
        }
    }
    
    CGFloat targetFloat;
    // 针对ZPAnimationAppStore，滑动屏幕时,增大滑动进度,增加自动pop效果
    if (ZPAnimationTypeAppStore == self.popController.animationType) {
        targetFloat = 1;
        percentComplete = percentComplete * 3;
    }else{
        targetFloat = 0.4;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        [self gestureRecognizerStateBegan:gesture];
        
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        
        [self gestureRecognizerStateChanged:gesture percentComplete:percentComplete targetFloat:targetFloat];
        
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        
        [self gestureRecognizerStateEnded:gesture percentComplete:percentComplete targetFloat:targetFloat directionType:directionType];
        
    }else{
        
        self.isInteraction = NO;
        [self cancelInteractiveTransition];
    }
}

- (void)gestureRecognizerStateBegan:(UIPanGestureRecognizer *)gesture{
    
    if (self.scrollView) {
        if (self.scrollView.contentOffset.y == 0) {
            self.lastPercentComplete = 0;
        }
    }
    
    self.edgeLeftBeganFloat = [gesture locationInView:gesture.view].x;
    self.isInteraction = YES;
    [self.popController.navigationController popViewControllerAnimated:YES];
}

- (void)gestureRecognizerStateChanged:(UIPanGestureRecognizer *)gesture percentComplete:(CGFloat)percentComplete targetFloat:(CGFloat)targetFloat{
    
    // 针对ZPAnimationAppStore，增加自动pop功能
    if (ZPAnimationTypeAppStore == self.popController.animationType && percentComplete > targetFloat) {
        
        self.isInteraction = YES;
        [self finishInteractiveTransition];
        [self.popController.navigationController popViewControllerAnimated:YES];
        
    }else{
     
        self.isInteraction = NO;
        [self updateInteractiveTransition:percentComplete];
    }
}

- (void)gestureRecognizerStateEnded:(UIPanGestureRecognizer *)gesture percentComplete:(CGFloat)percentComplete targetFloat:(CGFloat)targetFloat directionType:(ZPPanDirectionType)directionType{
    
    if ((ZPPanDirectionEdgeLeft == self.startDirection || ZPPanDirectionEdgeRight == self.startDirection) && [gesture velocityInView:gesture.view].x >= 250) {
        // 左右轻扫，快速返回
        [self finishInteractiveTransition];
        [self.popController.navigationController popViewControllerAnimated:YES];
    }else if ((ZPPanDirectionEdgeUp == self.startDirection || ZPPanDirectionEdgeDown == self.startDirection) && [gesture velocityInView:gesture.view].x >= 250){
        
        [self finishInteractiveTransition];
        [self.popController.navigationController popViewControllerAnimated:YES];
    }else{
        
        // 正常返回
        if (percentComplete > targetFloat) {
            [self finishInteractiveTransition];
        }else{
            [self cancelInteractiveTransition];
        }
    }
    
    self.lastPercentComplete = 0;
    self.scrollView.scrollEnabled = YES;
    self.startDirection = ZPPanDirectionNone;
    self.isInteraction = NO;
}

#pragma mark  动画
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    
    if (operation == UINavigationControllerOperationPush) {
        
        self.isPop = NO;
        if (ZPAnimationTypeUIViewFrame == toVC.animationType) {
            
            return [AnimationUIViewFrameStyle new];
            
        }else if (ZPAnimationTypeWindowScale == toVC.animationType){
            
            return [AnimationWindowScaleStylePop new];
            
        }else if (ZPAnimationTypeAppStore == toVC.animationType){
            
            return [AnimationAppStoreStylePush new];
            
        }
        
    }else if (operation == UINavigationControllerOperationPop){
        
        self.isPop = YES;
        if (ZPAnimationTypeUIViewFrame == fromVC.animationType) {
            
            return [AnimationUIViewFrameStyle new];
            
        }else if (ZPAnimationTypeWindowScale == fromVC.animationType){
            
            return [AnimationWindowScaleStylePop new];
            
        }else if (ZPAnimationTypeAppStore == fromVC.animationType){
            
            AnimationAppStoreStylePop *obj = [AnimationAppStoreStylePop new];
            
            UIViewController *pushController = [self.popController.navigationController.childViewControllers lastObject];
            pushController.isInteraction = self.isInteraction;
            obj.isInteravtion = self.isInteraction;
            return obj;
        }
    }
    return nil;
}

#pragma mark 是否返回交互
- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController{
    
    if (self.isPop) {
        return self.isInteraction ? self : nil;
    }
    return nil;
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    [navigationController setNavigationBarHidden:navigationController.hideNavBar animated:YES];
    
    if (navigationController.viewControllers.count == 1) {
        if (ZPAnimationTypeAppStore == self.popController.animationType) {
            
            // 出现
            if (navigationController.tabBarController.tabBar.hidden && !self.isInteraction) {
                
                CGRect tabRect = navigationController.tabBarController.tabBar.frame;
                navigationController.tabBarController.tabBar.frame = CGRectMake(tabRect.origin.x, TLDeviceHeight +tabRect.size.height, tabRect.size.width, tabRect.size.height);
                navigationController.tabBarController.tabBar.hidden = NO;
                [UIView animateWithDuration:0.5 animations:^{
                    navigationController.tabBarController.tabBar.frame = CGRectMake(tabRect.origin.x, TLDeviceHeight - tabRect.size.height, tabRect.size.width, tabRect.size.height);
                }];
            }
        }
    }else if (navigationController.viewControllers.count == 2){
        
        // 消失
        CGRect tabRect = navigationController.tabBarController.tabBar.frame;
        navigationController.tabBarController.tabBar.frame = CGRectMake(tabRect.origin.x, TLDeviceHeight -tabRect.size.height, tabRect.size.width, tabRect.size.height);
        [UIView animateWithDuration:0.5 animations:^{
            navigationController.tabBarController.tabBar.frame = CGRectMake(tabRect.origin.x, TLDeviceHeight +tabRect.size.height, tabRect.size.width, tabRect.size.height);
        } completion:^(BOOL finished) {
            navigationController.tabBarController.tabBar.hidden = YES;
        }];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if (viewController == navigationController.viewControllers[0]) {
        navigationController.interactivePopGestureRecognizer.enabled = NO;
    }else{
        navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    if (navigationController.viewControllers.count == 1) {
        
        // 出现
        if (navigationController.tabBarController.tabBar.hidden) {
            
            CGRect tabRect = navigationController.tabBarController.tabBar.frame;
            navigationController.tabBarController.tabBar.frame = CGRectMake(tabRect.origin.x, TLDeviceHeight +tabRect.size.height, tabRect.size.width, tabRect.size.height);
            navigationController.tabBarController.tabBar.hidden = NO;
            [UIView animateWithDuration:0.5 animations:^{
                navigationController.tabBarController.tabBar.frame = CGRectMake(tabRect.origin.x, TLDeviceHeight -tabRect.size.height, tabRect.size.width, tabRect.size.height);
            }];
        }
    }
}

@end
