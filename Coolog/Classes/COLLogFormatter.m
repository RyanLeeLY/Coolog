//
//  COLLogFormat.m
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import "COLLogFormatter.h"
#import "COLDateFormatter.h"

static NSString * COLLogALSFormatterString = @"[##TAG:%@##] [##TYPE:%@##] [##DATE:%@##] %@";
static NSString * COLLogConsoleFormatterString = @"[##TAG:%@##] [##TYPE:%@##] [##DATE:%@##] [##THREAD:%@##] %@";
static NSString * COLLogFileFormatterString = @"[##TAG:%@##] [##TYPE:%@##] [##DATE:%@##] [##THREAD:%@##] %@";

@interface COLLogFormatter ()
@property (copy, nonatomic) NSArray<NSString *> *tagStrings;
@end

@interface COLLogNSFormatter : COLLogFormatter
@end

@interface COLLogConsoleFormatter : COLLogFormatter
@end

@interface COLLogFileFormatter : COLLogFormatter
@end

static inline NSArray * COLLogTypeStringArray() {
    return @[@"Error", @"Warning", @"Info", @"Default", @"Debug"];
}

@implementation COLLogFormatter
+ (instancetype)formatterWithType:(COLLogFormatType)type {
    return [[COLLogFormatter alloc] initWithType:type];
}

+ (instancetype)NSLogFormatter {
    return [self formatterWithType:COLLogFormatTypeNSLog];
}

+ (instancetype)ConsoleFormatter {
    return [self formatterWithType:COLLogFormatTypeConsole];
}

+ (instancetype)FileFormatter {
    return [self formatterWithType:COLLogFormatTypeFile];
}

- (instancetype)initWithType:(COLLogFormatType)type {
    switch (type) {
        case COLLogFormatTypeNSLog:
            self = [[COLLogNSFormatter alloc] init];
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

- (NSString *)completeLogWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message timeInterval:(NSTimeInterval)timeInterval {
    return nil;
}

- (NSString *)typeStringWithType:(COLLogType)type {
    return self.tagStrings[type];
}
@end

@implementation COLLogNSFormatter
- (NSString *)completeLogWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message timeInterval:(NSTimeInterval)timeInterval {
    NSString *dateString = [[COLDateFormatter sharedInstance] dateStringWithTimeInterval:timeInterval];
    return [NSString stringWithFormat:COLLogALSFormatterString, tag, [self typeStringWithType:type], dateString, message];
}
@end

@implementation COLLogConsoleFormatter
- (NSString *)completeLogWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message timeInterval:(NSTimeInterval)timeInterval {
    NSString *dateString = [[COLDateFormatter sharedInstance] dateStringWithTimeInterval:timeInterval];
    return [NSString stringWithFormat:COLLogALSFormatterString, tag, [self typeStringWithType:type], dateString, message];
}
@end

@implementation COLLogFileFormatter
- (NSString *)completeLogWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message timeInterval:(NSTimeInterval)timeInterval {
    NSString *dateString = [[COLDateFormatter sharedInstance] dateStringWithTimeInterval:timeInterval];
    return [NSString stringWithFormat:COLLogALSFormatterString, tag, [self typeStringWithType:type], dateString, message];
}
@end

