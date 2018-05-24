//
//  COLLoggerDriver.h
//  Coolog
//
//  Created by Yao Li on 2018/5/18.
//

#import <Foundation/Foundation.h>
#import "COLLogger.h"
#import "COLLogFormatter.h"

typedef NS_ENUM(NSUInteger, COLLogLevel) {
    COLLogLevelOff = 0,
    COLLogLevelError,
    COLLogLevelWarning,
    COLLogLevelInfo,
    COLLogLevelDefault,
    COLLogLevelDebug,
    COLLogLevelAll,
};

@interface COLLoggerDriver : NSObject
@property (strong, nonatomic) id<COLLogger> logger;
@property (strong, nonatomic) id<COLFormatable> formatter;
@property (assign, nonatomic) COLLogLevel level;

- (instancetype)initWithLogger:(id<COLLogger>)logger
                     formatter:(id<COLFormatable>)formatter
                         level:(COLLogLevel)level NS_DESIGNATED_INITIALIZER;

- (void)logWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message timeInterval:(NSTimeInterval)timeInterval;
@end
