//
//  COLConsoleLogger.m
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import "COLConsoleLogger.h"
#import <PocketSocket/PSWebSocketServer.h>
#import <PocketSocket/PSWebSocket.h>

@interface COLConsoleLogger () <PSWebSocketServerDelegate> {
    dispatch_semaphore_t _clientsSemaphore;
}
@property (strong, nonatomic) PSWebSocketServer *server;
@property (copy, nonatomic) NSMutableArray<PSWebSocket *> *clients;

@property (assign, atomic) BOOL remoteEnabled;
@end

@implementation COLConsoleLogger
+ (instancetype)logger {
    return [[COLConsoleLogger alloc] init];
}

- (instancetype)initWithPort:(NSUInteger)port {
    self = [super init];
    if (self) {
        _clientsSemaphore = dispatch_semaphore_create(1);
        _server = [PSWebSocketServer serverWithHost:nil port:port];
        _server.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    return [self initWithPort:9001];
}

- (void)log:(NSString *)logString {
    printf("%s\n", [logString UTF8String]);
    if (self.remoteEnabled) {
        dispatch_semaphore_wait(_clientsSemaphore, DISPATCH_TIME_FOREVER);
        [self.clients enumerateObjectsUsingBlock:^(PSWebSocket * _Nonnull client, NSUInteger idx, BOOL * _Nonnull stop) {
            [client send:logString];
        }];
        dispatch_semaphore_signal(_clientsSemaphore);
    }
}

#pragma mark - PSWebSocketServerDelegate
- (void)serverDidStart:(PSWebSocketServer *)server {
    self.remoteEnabled = YES;
}

- (void)server:(PSWebSocketServer *)server didFailWithError:(NSError *)error {
    self.remoteEnabled = NO;
}

- (void)serverDidStop:(PSWebSocketServer *)server {
    self.remoteEnabled = NO;
}

- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request {
    NSLog(@"Socket request: %@", request.URL);
    if ([request.URL.path isEqualToString:@"/coolog"]) {
        return YES;
    }
    return NO;
}

- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request address:(NSData *)address trust:(SecTrustRef)trust response:(NSHTTPURLResponse *__autoreleasing *)response {
    NSLog(@"Socket request: %@", request.URL);
    if ([request.URL.path isEqualToString:@"/coolog"]) {
        return YES;
    }
    return NO;
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Server websocket did receive message: %@", message);
}

- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    dispatch_semaphore_wait(_clientsSemaphore, DISPATCH_TIME_FOREVER);
    [self.clients addObject:webSocket];
    dispatch_semaphore_signal(_clientsSemaphore);
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    dispatch_semaphore_wait(_clientsSemaphore, DISPATCH_TIME_FOREVER);
    [webSocket close];
    [self.clients removeObject:webSocket];
    dispatch_semaphore_signal(_clientsSemaphore);
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    dispatch_semaphore_wait(_clientsSemaphore, DISPATCH_TIME_FOREVER);
    [webSocket close];
    [self.clients removeObject:webSocket];
    dispatch_semaphore_signal(_clientsSemaphore);
}

#pragma mark - notification
- (void)applicationEnterForeground:(NSNotification *)notification {
    if (self.remoteEnabled) {
        [self startRemoteLogger];
    }
}

- (void)applicationEnterBackground:(NSNotification *)notification {
    if (self.remoteEnabled) {
        [self stopRemoteLogger];
    }
}

#pragma mark - getter & setter
- (NSMutableArray<PSWebSocket *> *)clients {
    if (!_clients) {
        _clients = [NSMutableArray array];
    }
    return _clients;
}

- (void)startRemoteLogger {
    [self.server start];
}

- (void)stopRemoteLogger {
    [self.server stop];
    
    dispatch_semaphore_wait(_clientsSemaphore, DISPATCH_TIME_FOREVER);
    [self.clients enumerateObjectsUsingBlock:^(PSWebSocket * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj close];
    }];
    [self.clients removeAllObjects];
    dispatch_semaphore_signal(_clientsSemaphore);
}
@end
