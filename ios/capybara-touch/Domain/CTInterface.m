#import "CTInterface.h"

@interface CTInterface ()

@property (strong, nonatomic) TCPServer *server;
@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;

@end

@implementation CTInterface

- (instancetype)init {
    if (self = [super init]) {
        self.server = [[TCPServer alloc] init];
    }
    return self;
}

- (void)startWithPort:(NSInteger)port domain:(NSString *)domain {
    self.server.port = port;
    self.server.domain = domain;
    NSError *error = [[NSError alloc] init];
    [self.server start:&error];
    self.server.delegate = self;

    NSLog(@"listening on port: %d", port);
}

#pragma mark - TCPServerDelegateProtocol
- (void)TCPServer:(TCPServer *)server didReceiveConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    NSLog(@"Received connection from address: %@", addr);

    if ([inputStream streamStatus] == NSStreamStatusNotOpen) {
        [inputStream open];
    }
    if ([outputStream streamStatus] == NSStreamStatusNotOpen) {
        [outputStream open];
    }

    inputStream.delegate = self;
    outputStream.delegate = self;

    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent {
    NSLog(@"Received stream event! %d, %d", streamEvent, [(NSInputStream *)stream hasBytesAvailable]);
    if (streamEvent == NSStreamEventHasBytesAvailable && [(NSInputStream *)stream hasBytesAvailable]) {
        uint8_t *buf;
        NSInteger len = [(NSInputStream *)stream read:buf maxLength:1024];
        if (len)        {
            NSString *tmpStr = [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
            NSLog(@"================> %@", tmpStr);
        } else {
            NSLog(@"No len?");
        }
    }
}
@end
