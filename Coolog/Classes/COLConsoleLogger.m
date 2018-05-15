//
//  COLConsoleLogger.m
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import "COLConsoleLogger.h"
#import <PocketSocket/PSWebSocketServer.h>

@interface COLConsoleLogger () <PSWebSocketServerDelegate>
@property (strong, nonatomic) PSWebSocketServer *server;
@end

@implementation COLConsoleLogger
- (instancetype)init {
    self = [super init];
    if (self) {
        _server = [PSWebSocketServer serverWithHost:nil port:9001];
        _server.delegate = self;
        [_server start];
    }
    return self;
}

#pragma mark - PSWebSocketServerDelegate
- (void)serverDidStart:(PSWebSocketServer *)server {
    NSLog(@"Server did start…");
}

- (void)server:(PSWebSocketServer *)server didFailWithError:(NSError *)error {
    NSLog(@"Server websocket did fail… error: %@", error);
}

- (void)serverDidStop:(PSWebSocketServer *)server {
    NSLog(@"Server did stop…");
}

- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request {
    NSLog(@"Server should accept request: %@", request);
    return YES;
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Server websocket did receive message: %@", message);
}

- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    NSLog(@"Server websocket did open");
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Server websocket did close with code: %@, reason: %@, wasClean: %@", @(code), reason, @(wasClean));
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Server websocket did fail with error: %@", error);
}
@end
