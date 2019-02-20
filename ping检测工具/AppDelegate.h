//
//  AppDelegate.h
//  ping检测工具
//
//  Created by 方景琦 on 2016/12/6.
//  Copyright © 2016年 Retouch. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s & 0xFF00) >> 8))/255.0 blue:((s & 0xFF))/255.0  alpha:1.0]


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

