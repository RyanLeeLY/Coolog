//
//  COLLogFormat.h
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, COLLogFormatType) {
    COLLogFormatTypeNSLog = 0,
    COLLogFormatTypeConsole,
    COLLogFormatTypeFile,
};

typedef NS_ENUM(NSUInteger, COLLogType) {
    COLLogTypeError = 0,
    COLLogTypeWarning,
    COLLogTypeInfo,
    COLLogTypeDefault,
    COLLogTypeDebug,
};

@protocol COLFormatable <NSObject>
- (NSString *)completeLogWithType:(COLLogType)type
                              tag:(NSString *)tag
                          message:(NSString *)message
                     timeInterval:(NSTimeInterval)timeInterval;
@end

@interface COLLogFormatter : NSObject <COLFormatable>
+ (instancetype)formatterWithType:(COLLogFormatType)type;
+ (instancetype)NSLogFormatter;
+ (instancetype)ConsoleFormatter;
+ (instancetype)FileFormatter;

- (instancetype)initWithType:(COLLogFormatType)type;
@end
