//
//  UIViewController+ZPTransition.h
//  ZPTransition
//
//  Created by mac on 2019/5/10.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ZPTransition)

@property (nonatomic, assign) BOOL isInteraction;

@property (nonatomic, assign) ZPAnimationType animationType;

@property (nonatomic, assign) ZPPanDirectionType panDirectionTypes;

- (void)setContainScrollView:(UIScrollView *)scrollView isPush:(BOOL)isPush;

- (void)tlPresentViewController:(UIViewController *)vc tlAnimationType:(ZPAnimationType)tlAnimationType animated:(BOOL)animated completion:(void (^__nullable)(void))completion;

//转场动画涉及的视图数组
- (NSArray *_Nonnull)tl_transitionUIViewFrameViews;

//AppStore转场的图片
- (NSString *_Nonnull)tl_transitionUIViewImage;

@end





@interface UINavigationController(ZPTransition)

@property (nonatomic, assign) BOOL hideNavBar;

@property (nonatomic, assign) NSInteger index;

- (void)tlPushViewController:(UIViewController *)vc tlAnimationType:(ZPAnimationType)tlAnimationType;

@end

NS_ASSUME_NONNULL_END
