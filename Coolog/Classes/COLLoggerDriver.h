//
//  COLLoggerDriver.h
//  Coolog
//
//  Created by Yao Li on 2018/5/18.
//

#import <Foundation/Foundation.h>
#import "COLLogger.h"
#import "COLLogFormatter.h"

typedef NS_ENUM(NSUInteger, COLLoggerLevel) {
    COLLoggerLevelOff = 0,
    COLLoggerLevelError,
    COLLoggerLevelWarning,
    COLLoggerLevelInfo,
    COLLoggerLevelDefault,
    COLLoggerLevelDebug,
    COLLoggerLevelAll,
};

@interface COLLoggerDriver : NSObject
@property (strong, nonatomic) id<COLLogger> logger;
@property (strong, nonatomic) COLLogFormatter *formatter;
@property (assign, nonatomic) COLLoggerLevel level;

- (instancetype)initWithLogger:(id<COLLogger>)logger
                     formatter:(COLLogFormatter *)formatter
                         level:(COLLoggerLevel)level NS_DESIGNATED_INITIALIZER;

- (void)logWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message date:(NSDate *)date thread:(NSThread *)thread;
@end
