# Coolog

Coolog is a expandable and flexible log framework for iOS.

[![CI Status](https://img.shields.io/travis/yao.li/Coolog.svg?style=flat)](https://travis-ci.org/yao.li/Coolog)
[![Version](https://img.shields.io/cocoapods/v/Coolog.svg?style=flat)](https://cocoapods.org/pods/Coolog)
[![License](https://img.shields.io/cocoapods/l/Coolog.svg?style=flat)](https://cocoapods.org/pods/Coolog)
[![Platform](https://img.shields.io/cocoapods/p/Coolog.svg?style=flat)](https://cocoapods.org/pods/Coolog)

## Features
* **Simple** Coolog has a simple usage. We make it as simple as possible to setup Coolog. Also, we provides some simplified methods of basic function.

* **Flexible** Coolog provides multiple log methods (Console, ASL and File) and log-level. 

* **Expandable** You can even customize your own logger and formatter, which are components of log-driver. Then your customized log-driver can also be added to log-engine. Do whatever you want in your customized logger.

* **Browser Tool** Coolog provides a browser tool, which makes it easy to debug. You just need to open a computer with a browser to debug the program. This is really convenient.
![BrowserTool](https://raw.githubusercontent.com/RyanLeeLY/Coolog/master/browserTool.gif)

## Installation

### cocoapods
```ruby
pod 'Coolog'
```

## Architecture

## Usage

### Setup

```objective-c
[[COLLogManager sharedInstance] setup];
    
[[COLLogManager sharedInstance] enableFileLog];  // open file log
[[COLLogManager sharedInstance] enableConsoleLog];  // open xcode console log
    
#ifdef DEBUG
    [COLLogManager sharedInstance].level = COLLogLevelAll;
#else
    [COLLogManager sharedInstance].level = COLLogLevelInfo;
#endif
```

### Log

```objective-c
CLogError(@"tag", @"%@", @"log content");
	
CLogWarning(@"tag", @"%@", @"log content");
	
CLogInfo(@"tag", @"%@", @"log content");
	
CLogDefault(@"tag", @"%@", @"log content");
	
CLogDebug(@"tag", @"%@", @"log content");
```

### Browser Tool
```objective-c
[[COLLogManager sharedInstance] enableRemoteConsole];
```
Make sure your pc and your phone under the same wifi. Open your browser and visit [http://coolog.oss-cn-hangzhou.aliyuncs.com/index.html?host=ws://YourPhoneIPAddr:9001/coolog]

### Advanced

The section below will introduce how to customize your own logger. You can follow 3 steps below.


* Step 1: Implement your own logger.

```objective-c
#import "COLLogger.h"
@interface MyLogger : NSObject <COLLogger>

@end
```

```objective-c
#import "MyLogger.h"
#import <os/log.h>

@implementation MyLogger
@synthesize formatterClass = _formatterClass;

+ (instancetype)logger {
    return [[MyLogger alloc] init];
}

// This is your own log method. It will be called by log engine. 
- (void)log:(NSString *)logString {
	//For example, here below uses os_log as its implementation.
    os_log(OS_LOG_DEFAULT, "%{public}s", [logString UTF8String]);
}
@end
```

* Step 2: Implement your own formatter.

```objective-c
#import "COLLogFormatter.h"

@interface MyLogFormatter : NSObject <COLFormatable>

@end
```

```objective-c
#import "MyLogFormatter.h"

@implementation MyLogFormatter
// The log's format depends on this method.
- (NSString *)completeLogWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message date:(NSDate *)date thread:(NSThread *)thread {
    return [NSString stringWithFormat:@"tag=[%zd], type=[%@], message=[%@], date=[%@], thread=[%@]", type, tag, message, date, thread];
}
@end
```

* Step 3: Add your logger to log engine.

```objective-c
COLLoggerDriver *myDriver = [[COLLoggerDriver alloc] initWithLogger:[MyLogger logger]
                                                              formatter:[[MyLogFormatter alloc] init]
                                                                  level:COLLogLevelInfo];
[[COLLogManager sharedInstance].logEngine addDriver:myDriver];
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Author

yao.li, liyaoxjtu2013@gmail.com

## License

Coolog is available under the MIT license. See the LICENSE file for more info.
