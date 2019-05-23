//
//  TabTransitionDelegate.h
//  ZPTransition
//
//  Created by mac on 2019/5/22.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TabTransitionDelegate : UIPercentDrivenInteractiveTransition <UITabBarControllerDelegate>

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
