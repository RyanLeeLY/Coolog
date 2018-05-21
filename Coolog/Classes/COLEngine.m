//
//  COLEngine.m
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import "COLEngine.h"
#import "COLLoggerDriver.h"
#import "COLLogFormatter.h"
#import "COLALSLogger.h"
#import "COLConsoleLogger.h"
#import "COLFileLogger.h"
#import "COLLogger.h"

@interface COLEngine ()
@property (strong, nonatomic) NSMutableArray<COLLoggerDriver *> *drivers;

@property (strong, nonatomic) NSCache *formatterCache;
@end

@implementation COLEngine

- (void)addDriver:(COLLoggerDriver *)driver {
    [self.drivers addObject:driver];
}

- (void)removeDriver:(COLLoggerDriver *)driver {
    [self.drivers removeObject:driver];
}

- (void)removeAllDrivers {
    [self.drivers removeAllObjects];
}

- (void)logWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message date:(NSDate *)date thread:(NSThread *)thread {
    [self.drivers enumerateObjectsUsingBlock:^(COLLoggerDriver * _Nonnull driver, NSUInteger idx, BOOL * _Nonnull stop) {
        [driver logWithType:type tag:tag message:message date:date thread:thread];
    }];
}

#pragma mark - getter
- (NSMutableArray<COLLoggerDriver *> *)drivers {
    if (!_drivers) {
        _drivers = [NSMutableArray array];
    }
    return _drivers;
}

- (NSCache *)formatterCache {
    if (!_formatterCache) {
        _formatterCache = [[NSCache alloc] init];
    }
    return _formatterCache;
}
@end
