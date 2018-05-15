#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "COLConsoleLogger.h"
#import "COLEngine.h"
#import "COLFileLogger.h"
#import "COLLogFormat.h"
#import "COLLogger.h"

FOUNDATION_EXPORT double CoologVersionNumber;
FOUNDATION_EXPORT const unsigned char CoologVersionString[];

