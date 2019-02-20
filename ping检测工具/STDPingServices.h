//
//  STDPingServices.h
//  STKitDemo
//
//  Created by SunJiangting on 15-3-9.
//  Copyright (c) 2015年 SunJiangting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "STSimplePing.h"
#import "YYCache.h"

#ifdef DEBUG

#define Retouch_Log( s, ... ) NSLog( @"😁😁😁😁😁😁文件名%@  \n 方法名(%s) \n  行数(%d)  \n😁😁 %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent],__func__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#else

#define Retouch_Log( s, ... )

#endif



typedef NS_ENUM(NSInteger, STDPingStatus) {
    STDPingStatusDidStart,
    STDPingStatusDidFailToSendPacket,
    STDPingStatusDidReceivePacket,
    STDPingStatusDidReceiveUnexpectedPacket,
    STDPingStatusDidTimeout,
    STDPingStatusError,
    STDPingStatusFinished,
};

@interface STDPingItem : NSObject<NSCoding>

@property(nonatomic) NSString *originalAddress;//原始IP地址

@property(nonatomic, copy) NSString *IPAddress;//正在使用的IP地址

@property(nonatomic) NSUInteger dateBytesLength;//发送的数据包大小

@property(nonatomic) double     timeMilliseconds;//延迟的毫秒数

@property(nonatomic) NSInteger  timeToLive;//指定TTL值在对方的系统里停留的时间

@property(nonatomic) NSInteger  ICMPSequence;//第几个包

@property(nonatomic) STDPingStatus status;//ping的状态

@property(nonatomic,strong)NSDate *date;//item所对应的系统时间


+ (NSString *)statisticsWithPingItems:(NSArray *)pingItems;

@end




@interface STDPingServices : NSObject

/// 超时时间, default 500ms
@property(nonatomic) double timeoutMilliseconds;

//+ (STDPingServices *)startPingAddress:(NSString *)address
//                      callbackHandler:(void(^)(STDPingItem *pingItem, NSArray *pingItems))handler;
+ (STDPingServices *)startPingAddress:(NSString *)address monitorTime:(int)monitorTime
                      callbackHandler:(void(^)(STDPingItem *item, NSArray *pingItems))handler;

@property(nonatomic) NSInteger  maximumPingTimes;
- (void)cancel;

@end
