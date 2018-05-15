//
//  COLConsoleLogger.m
//  Coolog
//
//  Created by Yao Li on 2018/5/15.
//

#import "COLConsoleLogger.h"
#import <PocketSocket/PSWebSocketServer.h>
#import <PocketSocket/PSWebSocket.h>

@interface COLConsoleLogger () <PSWebSocketServerDelegate>
@property (strong, nonatomic) PSWebSocketServer *server;
@property (copy, nonatomic) NSMutableArray<PSWebSocket *> *clients;
@end

@implementation COLConsoleLogger
@synthesize formatterClass = _formatterClass;

- (instancetype)init {
    self = [super init];
    if (self) {
        _server = [PSWebSocketServer serverWithHost:nil port:9001];
        _server.delegate = self;
        [_server start];
    }
    return self;
}

- (void)log:(NSString *)logString {
    [self.clients enumerateObjectsUsingBlock:^(PSWebSocket * _Nonnull client, NSUInteger idx, BOOL * _Nonnull stop) {
        [client send:logString];
    }];
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
    if ([request.URL.path isEqualToString:@"/coolog"]) {
        return YES;
    }
    return NO;
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Server websocket did receive message: %@", message);
}

- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    [self.clients addObject:webSocket];
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self.clients removeObject:webSocket];
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self.clients removeObject:webSocket];
}

#pragma mark - getter
- (NSMutableArray<PSWebSocket *> *)clients {
    if (!_clients) {
        _clients = [NSMutableArray array];
    }
    return _clients;
}
@end
