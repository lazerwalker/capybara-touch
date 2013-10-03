#import "CTInterface.h"

@interface CTInterface ()

@property (strong, nonatomic) TCPServer *server;
@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;

@property (strong, nonatomic) NSMutableArray *messageQueue;

@end

@implementation CTInterface

- (NSDictionary *)commandMapping {
    return @{@"Visit": @"visit:"};
}

- (instancetype)init {
    if (self = [super init]) {
        self.server = [[TCPServer alloc] init];
        self.messageQueue = [NSMutableArray array];
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

- (void)sendSuccessMessage {
    if([self.outputStream hasSpaceAvailable]) {
        [self streamOutgoingMessage:@"ok"];
    } else {
        [self.messageQueue addObject:@"ok"];
    }
    [self.messageQueue addObject:@"ok"];
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

    self.inputStream = inputStream;
    self.outputStream = outputStream;
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent {
    NSLog(@"Received stream event. Stream: %@, Event: %d ", stream, streamEvent);
    NSLog(@"output has space? %d",[self.outputStream hasSpaceAvailable]);
    if (stream == self.inputStream && streamEvent == NSStreamEventHasBytesAvailable) {
        // TODO: Either guarantee that the ruby side only ever sends things that are at most 1024 long, or else properly implement streaming.
        uint8_t inputBuffer[1024];
        NSInteger len = [self.inputStream read:inputBuffer maxLength:1024];
        if (len) {
            NSString *tmpStr = [[NSString alloc] initWithBytes:inputBuffer length:len encoding:NSUTF8StringEncoding];

            NSLog(@"Full string = %@", tmpStr);
            NSArray *arguments = [tmpStr componentsSeparatedByString:@"\n"];

            NSString *command = arguments[0];
            NSString *argumentString = arguments[3];

            NSLog(@"%@: %@", command, argumentString);

            SEL commandSelector = [self delegateMethodFromCommand:command];

            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([self.delegate respondsToSelector:commandSelector]) {
                [self.delegate performSelector:commandSelector withObject:argumentString];
            }
            #pragma clang diagnostic pop
        }
    } else if (stream == self.outputStream && streamEvent == NSStreamEventHasSpaceAvailable) {
        if (self.messageQueue.count > 0) {
            NSLog(@"Result of stream: %d",[self streamOutgoingMessage:self.messageQueue[0]]);
            [self.messageQueue removeObjectAtIndex:0];
        }
    }
}

#pragma mark - Private
- (SEL)delegateMethodFromCommand:(NSString *)command {
    NSString *commandSelector = self.commandMapping[command];

    if (commandSelector) {
        return NSSelectorFromString(commandSelector);
    } else {
        return nil;
    }
}

- (NSInteger)streamOutgoingMessage:(NSString *)message {
    NSLog(@"Sending message: '%@'", message);
    const uint8_t *messageBuffer = (const uint8_t *)[@"ok\n" UTF8String];
    return [self.outputStream write:messageBuffer maxLength:strlen(messageBuffer)];
}
@end
