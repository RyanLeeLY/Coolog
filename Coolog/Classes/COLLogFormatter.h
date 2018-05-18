//
//  COLLogFormat.h
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, COLLogFormatType) {
    COLLogFormatTypeALS = 0,
    COLLogFormatTypeConsole,
    COLLogFormatTypeFile,
};

typedef NS_ENUM(NSUInteger, COLLogType) {
    COLLogTypeDebug = 0,
    COLLogTypeDefault,
    COLLogTypeInfo,
    COLLogTypeWarning,
    COLLogTypeError,
};

@protocol COLFormatable <NSObject>
- (NSString *)completeLogWithTag:(NSString *)tag type:(COLLogType)type message:(NSString *)message date:(NSDate *)date thread:(NSThread *)thread;
@end

@interface COLLogFormatter : NSObject <COLFormatable>
- (instancetype)initWithType:(COLLogFormatType)type;
@end
