//
//  COLLogFormat.m
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import "COLLogFormatter.h"

static NSString * COLLogALSFormatterString = @"[##TAG:%@##] [##TYPE:%@##] [##DATE:%@##] [##THREAD:%@##] %@";
static NSString * COLLogConsoleFormatterString = @"[##TAG:%@##] [##TYPE:%@##] [##DATE:%@##] [##THREAD:%@##] %@";
static NSString * COLLogFileFormatterString = @"[##TAG:%@##] [##TYPE:%@##] [##DATE:%@##] [##THREAD:%@##] %@";

@interface COLLogFormatter ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (copy, nonatomic) NSArray<NSString *> *tagStrings;
@end

@interface COLLogALSFormatter : COLLogFormatter
@end

@interface COLLogConsoleFormatter : COLLogFormatter
@end

@interface COLLogFileFormatter : COLLogFormatter
@end

static inline NSArray * COLLogTypeStringArray() {
    return @[@"Debug", @"Default", @"Info", @"Warning", @"Error"];
}

@implementation COLLogFormatter
- (instancetype)initWithType:(COLLogFormatType)type {
    switch (type) {
        case COLLogFormatTypeALS:
            self = [[COLLogALSFormatter alloc] init];
            break;
        case COLLogFormatTypeConsole:
            self = [[COLLogConsoleFormatter alloc] init];
            break;
        case COLLogFormatTypeFile:
            self = [[COLLogFileFormatter alloc] init];
            break;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _tagStrings = COLLogTypeStringArray();
    }
    return self;
}

- (NSString *)completeLogWithTag:(NSString *)tag type:(COLLogType)type message:(NSString *)message date:(NSDate *)date thread:(NSThread *)thread {
    return nil;
}

- (NSString *)typeStringWithType:(COLLogType)type {
    return self.tagStrings[type];
}

#pragma mark - getter
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    return _dateFormatter;
}
@end

@implementation COLLogALSFormatter
- (NSString *)completeLogWithTag:(NSString *)tag type:(COLLogType)type message:(NSString *)message date:(NSDate *)date thread:(NSThread *)thread {
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:COLLogALSFormatterString, tag, [self typeStringWithType:type], dateString, thread, message];
}
@end

@implementation COLLogConsoleFormatter
- (NSString *)completeLogWithTag:(NSString *)tag type:(COLLogType)type message:(NSString *)message date:(NSDate *)date thread:(NSThread *)thread {
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:COLLogALSFormatterString, tag, [self typeStringWithType:type], dateString, thread, message];
}
@end

@implementation COLLogFileFormatter
- (NSString *)completeLogWithTag:(NSString *)tag type:(COLLogType)type message:(NSString *)message date:(NSDate *)date thread:(NSThread *)thread {
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:COLLogALSFormatterString, tag, [self typeStringWithType:type], dateString, thread, message];
}
@end

