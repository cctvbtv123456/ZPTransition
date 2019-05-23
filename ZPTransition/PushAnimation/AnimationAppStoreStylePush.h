//
//  AnimationAppStoreStylePush.h
//  ZPTransition
//
//  Created by mac on 2019/5/21.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnimationAppStoreStylePush : NSObject <UIViewControllerAnimatedTransitioning>

@end

//////////////

@interface AnimationAppStoreStylePop : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isInteravtion;

@end

NS_ASSUME_NONNULL_END
