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

    self.inputStream = inputStream;
    self.outputStream = outputStream;
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent {
    NSLog(@"Received stream event");
    if (stream == self.inputStream && streamEvent == NSStreamEventHasBytesAvailable) {

        // TODO: Either guarantee that the ruby side only ever sends things that are at most 1024 long, or else properly implement streaming.
        uint8_t *inputBuffer[1024];
        NSInteger len = [self.inputStream read:inputBuffer maxLength:1024];
        if (len) {
            NSString *tmpStr = [[NSString alloc] initWithBytes:inputBuffer length:len encoding:NSUTF8StringEncoding];

            NSArray *arguments = [tmpStr componentsSeparatedByString:@"\n"];

            // TODO: Error handling when there aren't exactly 4 arguments

            NSString *verb = arguments[0];
            NSString *argumentString = arguments[3];

            // TODO: Split up argument string if argument count is > 1
            NSLog(@"%@: %@", verb, argumentString);
        }
    }
}
@end
