//
//  PressTransitionDelegate.m
//  ZPTransition
//
//  Created by mac on 2019/5/22.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//



#import "PressTransitionDelegate.h"
#import "ZPAnimationTypeBottomViewAlert.h"

@interface PressTransitionDelegate()

@property (nonatomic, assign) BOOL isInteraction, isMiss;
// 侧滑距离     改变手势方向时刷新转场进度
@property (nonatomic, assign) CGFloat edgeLeftBeganFloat, lastPercentComplete;
// 监测开始的手势,由上下滑转左右滑，还是按照上下为基础
@property (nonatomic, assign) ZPPanDirectionType startDirection;

@end

@implementation PressTransitionDelegate

+ (instancetype)shareInstance{
    static PressTransitionDelegate *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PressTransitionDelegate alloc] init];
    });
    return _instance;
}

#pragma mark 是否识别多手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark 系统自带侧滑
- (void)addEdgeLeftGestureForViewController:(UIViewController *)vc{
    UIScreenEdgePanGestureRecognizer *edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(doInteractiveTypeDisMiss:)];
    edgePan.edges = UIRectEdgeLeft;
    [vc.view addGestureRecognizer:edgePan];
}

- (void)doInteractiveTypeDisMiss:(UIPanGestureRecognizer *)gesture{
    CGPoint translation = [gesture translationInView:gesture.view];
    CGFloat percentComplete = 0.0;
    
    // 左右滑动的百分比
    percentComplete = translation.x / UIScreen.mainScreen.bounds.size.width;
    percentComplete = fabs(percentComplete);
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        self.isInteraction = YES;
        [self.disMissController dismissViewControllerAnimated:YES completion:nil];
        
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        
        self.isInteraction = NO;
        [self updateInteractiveTransition:percentComplete];
        
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        
        self.isInteraction = NO;
        if (percentComplete > 0.5f)
            [self finishInteractiveTransition];
        else
            [self cancelInteractiveTransition];
        
    }else{
        
        self.isInteraction = NO;
        [self cancelInteractiveTransition];
    }
}

#pragma mark 自定义全屏手势
- (void)addPanGestureForViewController:(UIViewController *)vc directionTypes:(ZPPanDirectionType)directionTypes{
    
    if (directionTypes == 0) return;
    self.startDirection = ZPPanDirectionNone;
    vc.panDirectionTypes = directionTypes;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doGestureRecognizerDisMiss:)];
    pan.delegate = self;
    [vc.view addGestureRecognizer:pan];
}

- (void)doGestureRecognizerDisMiss:(UIPanGestureRecognizer *)gesture{
    
    CGFloat gestureHeight = UIScreen.mainScreen.bounds.size.height;
    if (self.disMissController.animationType == ZPAnimationTypeBottomViewAlert) {
        gestureHeight = ZPTransitionPressHeight;
    }
    CGPoint translation = [gesture translationInView:gesture.view];
    CGFloat percentComleteX = 0.0;
    CGFloat percentComleteY = 0.0;
    CGFloat percentComlete  = 0.0;
    
    // 左右滑动的百分比
    percentComleteX = translation.x / UIScreen.mainScreen.bounds.size.width;
    percentComleteX = fabs(percentComleteX);
    
    // 上下滑动百分比
    percentComleteY = translation.y / gestureHeight;
    percentComleteY = fabs(percentComleteY);
    
    ZPPanDirectionType panDirection = ZPPanDirectionNone;
    
    //如果开始是左右（上下）方向，之后也是以左右（上下）为标准
    if (ZPPanDirectionEdgeLeft == self.startDirection || ZPPanDirectionEdgeRight == self.startDirection) {
        if (translation.x > 0) {
            panDirection = ZPPanDirectionEdgeLeft;
        }else if (translation.x < 0){
            panDirection = ZPPanDirectionEdgeRight;
        }
        percentComlete = percentComleteX;
    }else if (ZPPanDirectionEdgeUp == self.startDirection || ZPPanDirectionEdgeDown == self.startDirection){
        if (translation.y > 0) {
            // 下滑
            panDirection = ZPPanDirectionEdgeUp;
        }else if (translation.y < 0){
            // 上滑
            panDirection = ZPPanDirectionEdgeDown;
        }
        percentComlete = percentComleteY;
    }else{
        if (fabs(translation.x) > fabs(translation.y)) {
            if (translation.x > 0) {
                // 右滑
                panDirection = ZPPanDirectionEdgeLeft;
            }else if (translation.x < 0){
                // 左滑
            }
            percentComlete = percentComleteX;
        }else{
            if (translation.y > 0) {
                // 下滑
                panDirection = ZPPanDirectionEdgeUp;
            }else{
                // 上滑
                panDirection = ZPPanDirectionEdgeDown;
            }
            percentComlete = percentComleteY;
        }
        if (ZPPanDirectionNone == self.startDirection) {
            self.startDirection = panDirection;
        }
    }
    
    // 当为左右滑时，不让scrollView滚动；当上下滑时，记录改变方向前的percentComplete
    WS(weakSelf);
    [self handleScrollViewPercentComplete:percentComlete directionType:panDirection block:^(CGFloat bPercentComplete, ZPPanDirectionType bPanDirection) {
        // 转场进度动画处理
        [weakSelf handleGesture:gesture percentCompele:bPercentComplete directionType:bPanDirection];
    }];
}

- (void)handleScrollViewPercentComplete:(CGFloat)percentComplete directionType:(ZPPanDirectionType)panDirection block:(void(^)(CGFloat bPercentComplete, ZPPanDirectionType bPanDirection))block{
    
    if (self.scrollView) {
        if (ZPPanDirectionEdgeUp == self.startDirection || ZPPanDirectionEdgeDown == self.startDirection) {
            if (self.scrollView.contentOffset.y <= 10){
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
                }else if (ZPPanDirectionEdgeDown == panDirection){}
            }
            
        }else if (ZPPanDirectionEdgeLeft == self.startDirection || ZPPanDirectionEdgeRight == self.startDirection){
            self.scrollView.scrollEnabled = NO;
        }
    }
    
    block(percentComplete, panDirection);
}

- (void)handleGesture:(UIPanGestureRecognizer *)gesture percentCompele:(CGFloat)percentComplete directionType:(ZPPanDirectionType)diectionType{
    
    //对于不包含的手势禁止动画
    if (!(self.disMissController.panDirectionTypes &diectionType)) {
        percentComplete = 0;
    }
    //向右滑动起始位置超出TLPanEdgeInside则失效
    if (ZPPanDirectionEdgeLeft == diectionType) {
        if (self.edgeLeftBeganFloat > PanEdgeInside) {
            percentComplete = 0;
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        [self gestureRecognizerStateBegan:gesture];
        
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        
        self.isInteraction = NO;
        [self updateInteractiveTransition:percentComplete];
        
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        
        [self gestureRecognizerStateEnded:gesture percentComplete:percentComplete directionType:diectionType];
        
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
    [self.disMissController dismissViewControllerAnimated:YES completion:nil];
}

- (void)gestureRecognizerStateEnded:(UIPanGestureRecognizer *)gesture percentComplete:(CGFloat)percentComplete directionType:(ZPPanDirectionType)directionType{
    
    if ((ZPPanDirectionEdgeLeft == self.startDirection || ZPPanDirectionEdgeRight == self.startDirection) && [gesture velocityInView:gesture.view].x >= 250) {
        //左右轻扫，快速返回
        [self finishInteractiveTransition];
        [self.disMissController dismissViewControllerAnimated:YES completion:nil];
        
    }else if ((ZPPanDirectionEdgeUp == self.startDirection || ZPPanDirectionEdgeDown == self.startDirection) && self.scrollView.contentOffset.y <= 0 && ZPPanDirectionEdgeUp == directionType && [gesture velocityInView:gesture.view].y >= 250){
        
        [self finishInteractiveTransition];
        [self.disMissController dismissViewControllerAnimated:YES completion:nil];
        
    }else{
        // 正常返回
        if (percentComplete > 0.3f) {
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

#pragma mark pres动画
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.isMiss = NO;
    if (ZPAnimationTypeBottomViewAlert == presented.animationType) {
        return [ZPAnimationTypeBottomViewAlertPress new];
    }
    
    return nil;
}

#pragma mark dis动画
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    self.isMiss = YES;
    if (ZPAnimationTypeBottomViewAlert == dismissed.animationType) {
        return [ZPAnimationTypeBottomViewAlertDiss new];
    }
    return nil;
}

#pragma mark 是否返回交互
- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    
    if (self.isMiss) {
        return self.isInteraction ? self : nil;
    }
    return nil;
}

@end
