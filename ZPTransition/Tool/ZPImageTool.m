//
//  ZPImageTool.m
//  ZPTransition
//
//  Created by mac on 2019/5/22.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#import "ZPImageTool.h"

@implementation ZPImageTool

+ (void)asyncImageWithImageName:(NSString *)imageName block:(void (^)(UIImage * _Nonnull))block{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (image) {
                if (block) {
                    block(image);
                }
            }
        });
        
    });
    
}

@end
