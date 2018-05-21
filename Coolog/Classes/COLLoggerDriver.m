//
//  COLLoggerDriver.m
//  Coolog
//
//  Created by Yao Li on 2018/5/18.
//

#import "COLLoggerDriver.h"
#import "COLALSLogger.h"
#import "COLConsoleLogger.h"
#import "COLFileLogger.h"

@implementation COLLoggerDriver
- (instancetype)initWithLogger:(id<COLLogger>)logger
                     formatter:(COLLogFormatter *)formatter
                         level:(COLLogLevel)level {
    self = [super init];
    if (self) {
        _logger = logger;
        _formatter = formatter;
        _level = level;
    }
    return self;
}

- (instancetype)init {
    return [self initWithLogger:[COLALSLogger logger] formatter:[[COLLogFormatter alloc] initWithType:COLLogFormatTypeALS] level:COLLogLevelDefault];
}

- (void)logWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message date:(NSDate *)date thread:(NSThread *)thread {
    if ((NSInteger)type < (NSInteger)self.level) {
        [self.logger log:[self.formatter completeLogWithType:type tag:tag message:message date:date thread:thread]];
    }
}
@end
