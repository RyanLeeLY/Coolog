//
//  COLEngine.m
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import "COLEngine.h"
#import "COLLoggerDriver.h"
#import "COLLogFormatter.h"
#import "COLNSLogger.h"
#import "COLConsoleLogger.h"
#import "COLFileLogger.h"
#import "COLLogger.h"
#import <pthread.h>

@interface COLEngine ()
@property (strong, nonatomic) NSMutableArray<COLLoggerDriver *> *drivers;
@end

@implementation COLEngine
- (instancetype)init {
    self = [super init];
    if (self) {
        _drivers = [NSMutableArray array];
    }
    return self;
}

- (void)addDriver:(COLLoggerDriver *)driver {
    @synchronized(self) {
        [self.drivers addObject:driver];
    }
}

- (void)removeDriver:(COLLoggerDriver *)driver {
    @synchronized(self) {
        [self.drivers removeObject:driver];
    }
}

- (void)removeAllDrivers {
    @synchronized(self) {
        [self.drivers removeAllObjects];
    }
}

- (void)logWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message date:(NSDate *)date {
    [self.drivers enumerateObjectsUsingBlock:^(COLLoggerDriver * _Nonnull driver, NSUInteger idx, BOOL * _Nonnull stop) {
        [driver logWithType:type tag:tag message:message date:date];
    }];
}
@end
