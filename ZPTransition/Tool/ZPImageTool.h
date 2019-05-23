//
//  ZPImageTool.h
//  ZPTransition
//
//  Created by mac on 2019/5/22.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZPImageTool : NSObject

+ (void)asyncImageWithImageName:(NSString *)imageName block:(void(^)(UIImage *image))block;

@end

NS_ASSUME_NONNULL_END
