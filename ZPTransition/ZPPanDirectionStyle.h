//
//  ZPPanDirectionStyle.h
//  ZPTransition
//
//  Created by mac on 2019/5/10.
//  Copyright © 2019 zhihuiketang. All rights reserved.
//

#ifndef ZPPanDirectionStyle_h
#define ZPPanDirectionStyle_h

#import <UIKit/UIKit.h>

//位移枚举
typedef NS_ENUM(NSInteger,ZPPanDirectionType){
    ZPPanDirectionNone          = 0,                //不增加滑动手势
    ZPPanDirectionEdgeLeft      = 1 << 0,           //响应右滑手势
    ZPPanDirectionEdgeRight     = 1 << 1,           //响应左滑手势
    ZPPanDirectionEdgeUp        = 1 << 2,           //响应下滑手势
    ZPPanDirectionEdgeDown      = 1 << 3            //响应上滑手势
};

typedef NS_ENUM(NSUInteger, ZPAnimationType) {
    
    ZPAnimationTypeNone = 0,
    //push
    ZPAnimationTypeUIViewFrame,//视图移动
    ZPAnimationTypeWindowScale,//视图稍微放大缩小
    ZPAnimationTypeAppStore,//视图稍微放大缩小
    //press
    ZPAnimationTypeBottomViewAlert,//视图从底部弹出
    //tab
    ZPAnimationTypeTabScroll    //tabbar点击滚动
};

#endif /* ZPPanDirectionStyle_h */
