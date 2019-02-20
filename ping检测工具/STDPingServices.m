//
//  STDPingServices.m
//  STKitDemo
//
//  Created by SunJiangting on 15-3-9.
//  Copyright (c) 2015年 SunJiangting. All rights reserved.
//

#import "STDPingServices.h"
#import "NSObject+NSLocalNotification.h"
#define LOCALNOTIFICATION_KEY             @"localNotificationKey"



@implementation STDPingItem

- (NSString *)description {
    switch (self.status) {
        case STDPingStatusDidStart:
            return [NSString stringWithFormat:@"进入ping检测......\nPING %@ (%@): %ld data bytes",self.originalAddress, self.IPAddress, (long)self.dateBytesLength];
        case STDPingStatusDidReceivePacket:
            return [NSString stringWithFormat:@"\n%@  %ld bytes from %@: --->icmp_seq=%ld  --->ttl=%ld  --->time=%.3f ms",[self changeDateToStringWithDate:self.date] ,(long)self.dateBytesLength, self.IPAddress, (long)self.ICMPSequence, (long)self.timeToLive, self.timeMilliseconds];
        case STDPingStatusDidTimeout:
            return [NSString stringWithFormat:@"Request timeout for icmp_seq %ld", (long)self.ICMPSequence];
        case STDPingStatusDidFailToSendPacket:
            return [NSString stringWithFormat:@"Fail to send packet to %@: icmp_seq=%ld", self.IPAddress, (long)self.ICMPSequence];
        case STDPingStatusDidReceiveUnexpectedPacket:
            return [NSString stringWithFormat:@"Receive unexpected packet from %@: icmp_seq=%ld", self.IPAddress, (long)self.ICMPSequence];
        case STDPingStatusError:
            return [NSString stringWithFormat:@"Can not ping to %@", self.originalAddress];
        default:
            break;
    }
    if (self.status == STDPingStatusDidReceivePacket) {
    }
    return super.description;
}


-(NSString*)changeDateToStringWithDate:(NSDate *)date {
    
    NSDateFormatter*formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    
    NSString*dateTime = [formatter stringFromDate:date];

    return dateTime;
    
}



//检测完毕调用的方法
+ (NSString *)statisticsWithPingItems:(NSArray *)pingItems {
    
    YYCache *cache = [YYCache cacheWithName:@"mydb"];
    
    __block NSMutableArray *storeArray;
    
    // 异步读取
    [cache objectForKey:@"pingItemArray" withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
        if (object) {
            storeArray = (NSMutableArray *)object;

        }else{
            storeArray = [NSMutableArray array];
        }
        
        [storeArray addObject:(NSMutableArray *)pingItems];
        
        [cache.diskCache setObject:storeArray forKey:@"pingItemArray"];
    }];

    



    __block NSInteger receivedCount = 0, allCount = 0;
    __block double allTimeMilliseconds = 0.,heighestTimeMilliseconds = 0,lowestTimeMilliseconds = 100000;

    
    [pingItems enumerateObjectsUsingBlock:^(STDPingItem *obj, NSUInteger idx, BOOL *stop) {
        
        
        if (obj.status != STDPingStatusFinished && obj.status != STDPingStatusError) {
            
            allCount ++;
            if (obj.status == STDPingStatusDidReceivePacket) {
                receivedCount ++;
                
                allTimeMilliseconds += obj.timeMilliseconds;
                
                heighestTimeMilliseconds = obj.timeMilliseconds>heighestTimeMilliseconds?obj.timeMilliseconds:heighestTimeMilliseconds;
                lowestTimeMilliseconds = obj.timeMilliseconds<lowestTimeMilliseconds?obj.timeMilliseconds:lowestTimeMilliseconds;
            }
            
            
        }
    }];
    
    
    
    
    
    NSMutableString *description = [NSMutableString stringWithCapacity:50];
    [description appendFormat:@"\n\n\n -----------------  ping 统计报告  ------------------\n"];
    
    CGFloat lossPercent = (CGFloat)(allCount - receivedCount) / MAX(1.0, allCount) * 100;
    
    double averageTimeMilliSeconds = (double)(allTimeMilliseconds/receivedCount);
    
    [description appendFormat:@"\n1.总共发送了 %ld 个包, 收到了 %ld 个包,  丢包率为 %.1f%%,  \n\n2.最高延迟时间: %.3fms\n   最低延迟时间: %.3fms\n   平均延迟时间: %.3fms\n", (long)allCount, (long)receivedCount, lossPercent,heighestTimeMilliseconds,lowestTimeMilliseconds,averageTimeMilliSeconds];
    
    
    
    //注册发送本地推送前先删除之前的推送,不然会一直保存,并重复发送
    [self cancelLocalNotificationWithKey:LOCALNOTIFICATION_KEY];
    //-------------------发送本地推送--------------------
    [self registerLocalNotification:0 content:[NSString stringWithFormat:@"ping测试已经完成\n丢包率为百分之%.1f---平均延迟时间:%.3fms",  lossPercent,averageTimeMilliSeconds] key:LOCALNOTIFICATION_KEY];
    
    
    return [description stringByReplacingOccurrencesOfString:@".0%" withString:@"%"];
}






-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.originalAddress forKey:@"originalAddress"];
    
    [aCoder encodeObject:self.IPAddress forKey:@"IPAddress"];
    
    [aCoder encodeObject:[NSNumber numberWithInteger:self.dateBytesLength] forKey:@"dateBytesLength"];
    
    [aCoder encodeObject:[NSNumber numberWithDouble:self.timeMilliseconds] forKey:@"timeMilliseconds"];
    
    [aCoder encodeObject:[NSNumber numberWithInteger:self.timeToLive] forKey:@"timeToLive"];
    
    [aCoder encodeObject:[NSNumber numberWithInt:self.status] forKey:@"status"];
    
    [aCoder encodeObject:self.date forKey:@"date"];
    
    [aCoder encodeObject:[NSNumber numberWithInteger:self.ICMPSequence] forKey:@"ICMPSequence"];

    
    
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        
        self.originalAddress = [aDecoder decodeObjectForKey:@"originalAddress"];
        
        self.IPAddress = [aDecoder decodeObjectForKey:@"IPAddress"];
        
        self.dateBytesLength = [[aDecoder decodeObjectForKey:@"dateBytesLength"] integerValue];
        
        self.timeMilliseconds = [[aDecoder decodeObjectForKey:@"timeMilliseconds"] doubleValue];
        
        self.timeToLive = [[aDecoder decodeObjectForKey:@"timeToLive"] integerValue];
        
        self.status = [[aDecoder decodeObjectForKey:@"status"] intValue];

        self.date = [aDecoder decodeObjectForKey:@"date"];
        
        self.ICMPSequence = [[aDecoder decodeObjectForKey:@"ICMPSequence"] integerValue];
}
    
    return self;
    
}








@end










@interface STDPingServices () <STSimplePingDelegate> {
    BOOL _hasStarted;
    BOOL _isTimeout;
    NSInteger   _repingTimes;
    NSInteger   _sequenceNumber;
    NSMutableArray *_pingItems;
}

@property(nonatomic, copy)   NSString   *address;
@property(nonatomic, strong) STSimplePing *simplePing;

@property(nonatomic, strong)void(^callbackHandler)(STDPingItem *item, NSArray *pingItems);

@end

@implementation STDPingServices

+ (STDPingServices *)startPingAddress:(NSString *)address monitorTime:(int)monitorTime
                      callbackHandler:(void(^)(STDPingItem *item, NSArray *pingItems))handler {
    
    STDPingServices *services = [[STDPingServices alloc] initWithAddress:address monitorTime:monitorTime];
    services.callbackHandler = handler;
    [services startPing];
    return services;
}

- (instancetype)initWithAddress:(NSString *)address monitorTime:(int)monitorTime{
    self = [super init];
    if (self) {
        self.timeoutMilliseconds = 500;
        self.maximumPingTimes = monitorTime;
        self.address = address;
        self.simplePing = [[STSimplePing alloc] initWithHostName:address];
        self.simplePing.addressStyle = STSimplePingAddressStyleAny;
        self.simplePing.delegate = self;
        _pingItems = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)startPing {
    _repingTimes = 0;
    _hasStarted = NO;
    [_pingItems removeAllObjects];
    [self.simplePing start];
}

- (void)reping {
    [self.simplePing stop];
    [self.simplePing start];
}

- (void)_timeoutActionFired {
    STDPingItem *pingItem = [[STDPingItem alloc] init];
    pingItem.ICMPSequence = _sequenceNumber;
    pingItem.originalAddress = self.address;
    pingItem.status = STDPingStatusDidTimeout;
    [self.simplePing stop];
    [self _handlePingItem:pingItem];
}



- (void)_handlePingItem:(STDPingItem *)pingItem {
    if (pingItem.status == STDPingStatusDidReceivePacket || pingItem.status == STDPingStatusDidTimeout) {
        [_pingItems addObject:pingItem];
    }
    if (_repingTimes < self.maximumPingTimes - 1) {
        if (self.callbackHandler) {
            self.callbackHandler(pingItem, [_pingItems copy]);
        }
        _repingTimes ++;
        NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(reping) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    } else {
        if (self.callbackHandler) {
            self.callbackHandler(pingItem, [_pingItems copy]);
        }
        [self cancel];
    }
}

- (void)cancel {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeoutActionFired) object:nil];
    [self.simplePing stop];
    STDPingItem *pingItem = [[STDPingItem alloc] init];
    pingItem.status = STDPingStatusFinished;
    [_pingItems addObject:pingItem];
    if (self.callbackHandler) {
        self.callbackHandler(pingItem, [_pingItems copy]);
    }
}

- (void)st_simplePing:(STSimplePing *)pinger didStartWithAddress:(NSData *)address {
    NSData *packet = [pinger packetWithPingData:nil];
    if (!_hasStarted) {
        STDPingItem *pingItem = [[STDPingItem alloc] init];
        pingItem.IPAddress = pinger.IPAddress;
        pingItem.originalAddress = self.address;
        pingItem.dateBytesLength = packet.length - sizeof(STICMPHeader);
        pingItem.status = STDPingStatusDidStart;
        if (self.callbackHandler) {
            self.callbackHandler(pingItem, nil);
        }
        _hasStarted = YES;
    }
    [pinger sendPacket:packet];
    [self performSelector:@selector(_timeoutActionFired) withObject:nil afterDelay:self.timeoutMilliseconds / 1000.0];
}

// If this is called, the SimplePing object has failed.  By the time this callback is
// called, the object has stopped (that is, you don't need to call -stop yourself).

// IMPORTANT: On the send side the packet does not include an IP header.
// On the receive side, it does.  In that case, use +[SimplePing icmpInPacket:]
// to find the ICMP header within the packet.

- (void)st_simplePing:(STSimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    _sequenceNumber = sequenceNumber;
}

- (void)st_simplePing:(STSimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeoutActionFired) object:nil];
    _sequenceNumber = sequenceNumber;
    STDPingItem *pingItem = [[STDPingItem alloc] init];
    pingItem.ICMPSequence = _sequenceNumber;
    pingItem.originalAddress = self.address;
    pingItem.status = STDPingStatusDidFailToSendPacket;
    [self _handlePingItem:pingItem];
}

- (void)st_simplePing:(STSimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeoutActionFired) object:nil];
    STDPingItem *pingItem = [[STDPingItem alloc] init];
    pingItem.ICMPSequence = _sequenceNumber;
    pingItem.originalAddress = self.address;
    pingItem.status = STDPingStatusDidReceiveUnexpectedPacket;
//    [self _handlePingItem:pingItem];
}

- (void)st_simplePing:(STSimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet timeToLive:(NSInteger)timeToLive sequenceNumber:(uint16_t)sequenceNumber timeElapsed:(NSTimeInterval)timeElapsed {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeoutActionFired) object:nil];
    STDPingItem *pingItem = [[STDPingItem alloc] init];
    pingItem.IPAddress = pinger.IPAddress;
    pingItem.dateBytesLength = packet.length;
    pingItem.timeToLive = timeToLive;
    pingItem.timeMilliseconds = timeElapsed * 1000;
    pingItem.ICMPSequence = sequenceNumber;
    pingItem.originalAddress = self.address;
    pingItem.status = STDPingStatusDidReceivePacket;
    pingItem.date = [NSDate date];
    [self _handlePingItem:pingItem];
}

- (void)st_simplePing:(STSimplePing *)pinger didFailWithError:(NSError *)error {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeoutActionFired) object:nil];
    [self.simplePing stop];
    
    STDPingItem *errorPingItem = [[STDPingItem alloc] init];
    errorPingItem.originalAddress = self.address;
    errorPingItem.status = STDPingStatusError;
    if (self.callbackHandler) {
        self.callbackHandler(errorPingItem, [_pingItems copy]);
    }
    
    STDPingItem *pingItem = [[STDPingItem alloc] init];
    pingItem.originalAddress = self.address;
    pingItem.IPAddress = pinger.IPAddress ?: pinger.hostName;
    [_pingItems addObject:pingItem];
    pingItem.status = STDPingStatusFinished;
    if (self.callbackHandler) {
        self.callbackHandler(pingItem, [_pingItems copy]);
    }
}
@end
