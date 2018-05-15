//
//  COLEngine.m
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import "COLEngine.h"
#import "COLLogFormatter.h"
#import "COLALSLogger.h"
#import "COLConsoleLogger.h"
#import "COLFileLogger.h"

@interface COLEngine ()
@property (strong, nonatomic) NSMutableArray<id<COLLogger>> *loggers;

@property (strong, nonatomic) NSCache *formatterCache;
@end

@implementation COLEngine
- (void)addLogger:(id<COLLogger>)logger {
    if ([logger isKindOfClass:[COLALSLogger class]]) {
        logger.formatterClass = [[[COLLogFormatter alloc] initWithType:COLLogFormatTypeALS] class];
    } else if ([logger isKindOfClass:[COLConsoleLogger class]]) {
        logger.formatterClass = [[[COLLogFormatter alloc] initWithType:COLLogFormatTypeConsole] class];
    } else if ([logger isKindOfClass:[COLFileLogger class]]) {
        logger.formatterClass = [[[COLLogFormatter alloc] initWithType:COLLogFormatTypeFile] class];
    }
    [self.loggers addObject:logger];
}

- (void)removeLogger:(id<COLLogger>)logger {
    [self.loggers removeObject:logger];
}

- (void)removeAllLogger {
    [self.loggers removeAllObjects];
}

- (void)logWithTag:(NSString *)tag type:(COLLogType)type message:(NSString *)message date:(NSDate *)date thread:(NSThread *)thread {
    [self.loggers enumerateObjectsUsingBlock:^(id<COLLogger>  _Nonnull logger, NSUInteger idx, BOOL * _Nonnull stop) {
        COLLogFormatter *formatter = [self formatterWithLogger:logger];
        if (formatter) {
            [logger log:[formatter completeLogWithTag:tag type:type message:message date:date thread:thread]];
        }
    }];
}

#pragma mark - private
- (COLLogFormatter *)formatterWithLogger:(id<COLLogger>)logger {
    Class formatterCls = logger.formatterClass;
    if (!formatterCls) {
        return nil;
    }
    
    NSString *className = NSStringFromClass(formatterCls);
    if ([self.formatterCache objectForKey:className]) {
        return [self.formatterCache objectForKey:className];
    } else {
        COLLogFormatter *formatter = [[formatterCls alloc] init];
        [self.formatterCache setObject:formatter forKey:className];
        return formatter;
    }
}

#pragma mark - getter
- (NSMutableArray<id<COLLogger>> *)loggers {
    if (!_loggers) {
        _loggers = [NSMutableArray array];
    }
    return _loggers;
}

- (NSCache *)formatterCache {
    if (!_formatterCache) {
        _formatterCache = [[NSCache alloc] init];
    }
    return _formatterCache;
}
@end
