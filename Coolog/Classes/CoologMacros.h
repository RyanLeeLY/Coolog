//
//  CoologMacros.h
//  Pods
//
//  Created by Yao Li on 2018/5/21.
//

#import "COLLogFormatter.h"

#ifndef CoologMacros_h
#define CoologMacros_h

#define CLogMethod(type, atag, frmt, ...) \
do {[[COLLogManager sharedInstance] logWithType:type tag:atag message:[NSString stringWithFormat:(frmt), ##__VA_ARGS__]];} while(0)

#define CLogError(tag, frmt, ...) \
CLogMethod(COLLogTypeError, tag, frmt, ##__VA_ARGS__)
#define CLogWarning(tag, frmt, ...) \
CLogMethod(COLLogTypeWarning, tag, frmt, ##__VA_ARGS__)
#define CLogInfo(tag, frmt, ...) \
CLogMethod(COLLogTypeInfo, tag, frmt, ##__VA_ARGS__)
#define CLogDefault(tag, frmt, ...) \
CLogMethod(COLLogTypeDefault, tag, frmt, ##__VA_ARGS__)
#define CLogDebug(tag, frmt, ...) \
CLogMethod(COLLogTypeDebug, tag, frmt, ##__VA_ARGS__)

#endif /* CoologMacros_h */
