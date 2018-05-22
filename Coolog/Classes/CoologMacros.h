//
//  CoologMacros.h
//  Pods
//
//  Created by Yao Li on 2018/5/21.
//

#import "COLLogFormatter.h"

#ifndef CoologMacros_h
#define CoologMacros_h

#define CLogWithType(type, atag, frmt, ...) \
do {[[COLLogManager sharedInstance] logWithType:type tag:atag message:[NSString stringWithFormat:(frmt), ##__VA_ARGS__]];} while(0)

#define CLogError(tag, frmt, ...) \
CLogWithType(COLLogTypeError, tag, frmt, ##__VA_ARGS__)
#define CLogWarning(tag, frmt, ...) \
CLogWithType(COLLogTypeWarning, tag, frmt, ##__VA_ARGS__)
#define CLogInfo(tag, frmt, ...) \
CLogWithType(COLLogTypeInfo, tag, frmt, ##__VA_ARGS__)
#define CLogDefault(tag, frmt, ...) \
CLogWithType(COLLogTypeDefault, tag, frmt, ##__VA_ARGS__)
#define CLogDebug(tag, frmt, ...) \
CLogWithType(COLLogTypeDebug, tag, frmt, ##__VA_ARGS__)

#define CLogE(frmt, ...) \
CLogError(nil, frmt, ##__VA_ARGS__)
#define CLogW(frmt, ...) \
CLogWarning(nil, frmt, ##__VA_ARGS__)
#define CLogI(frmt, ...) \
CLogInfo(nil, frmt, ##__VA_ARGS__)
#define CLog(frmt, ...) \
CLogDefault(nil, frmt, ##__VA_ARGS__)
#define CLogD(frmt, ...) \
CLogDebug(nil, frmt, ##__VA_ARGS__)

#endif /* CoologMacros_h */
