#import "CTInterface.h"

@interface CTInterface ()

@property (strong, nonatomic) TCPServer *server;
@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;

@property (strong, nonatomic) NSMutableArray *messageQueue;

@property (strong, nonatomic) NSString *incompleteIncomingMessage;
@end

@implementation CTInterface

- (NSDictionary *)commandMapping {
    return @{@"Visit": @"visit:",
             @"FindXpath": @"findXpath:",
             @"Reset": @"reset",
             @"Node": @"javascriptCommand:"
             };
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
    [self sendSuccessMessage:nil];
}

- (void)sendSuccessMessage:(NSString *)message {
    NSString *successMessage = @"ok\n";
    if (message) {
        successMessage = [NSString stringWithFormat:@"%@%d\n%@\n", successMessage, message.length, message];
    } else {
        successMessage = [successMessage stringByAppendingString:@"0\n"];
    }

    if([self.outputStream hasSpaceAvailable]) {
        [self streamOutgoingMessage:successMessage];
    } else {
        [self.messageQueue addObject:successMessage];
    }
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
    if (stream == self.inputStream && streamEvent == NSStreamEventHasBytesAvailable) {
        NSMutableString *inputString;
        if (self.incompleteIncomingMessage) {
            inputString = [self.incompleteIncomingMessage mutableCopy];
        } else {
            inputString = [[NSMutableString alloc] init];
        }

        while ([self.inputStream hasBytesAvailable]) {
            uint8_t inputBuffer[512];
            NSInteger len = [self.inputStream read:inputBuffer maxLength:512];
            if (len) {
                NSString *tmpStr = [[NSString alloc] initWithBytes:inputBuffer length:len encoding:NSUTF8StringEncoding];
                if (tmpStr) {
                    [inputString appendString:tmpStr];
                }
            };
        }

        NSArray *arguments = [inputString componentsSeparatedByString:@"\n"];

        NSLog(@"THE MESSAGE SO FAR: '%@'", inputString);
        if (arguments.count < 2 ||
            [arguments[1] isEqualToString:@""] ||
            arguments.count < 2 + ([arguments[1] intValue] * 2) ||
            inputString.length < [arguments[0] length] + [arguments[1] length] + [arguments[2] length] + [arguments[2] intValue]) {
            self.incompleteIncomingMessage = inputString;
            return;
        } else {
            NSLog(@"Full received message: '%@'", inputString);

            NSString *command = arguments[0];
            NSInteger numberOfArguments = [arguments[1] intValue];

            // If there's only 1 argument, commandArgument should be a NSString containing it.
            // Otherwise, it should be an NSArray.
            id commandArgument;
            if (numberOfArguments == 1) {
                commandArgument = arguments[3];
            } else if (numberOfArguments > 1) {
                NSMutableArray *args = [NSMutableArray array];
                for (int i = 0; i < numberOfArguments; i++) {
                    [args addObject:arguments[3 + (i*2)]];
                }
                commandArgument = [args copy];
            }

            NSLog(@"Interpreted command: '%@' arguments:'%@'", command, commandArgument);
            SEL commandSelector = [self delegateMethodFromCommand:command];

            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([self.delegate respondsToSelector:commandSelector]) {
                [self.delegate performSelector:commandSelector withObject:commandArgument];
            }
            #pragma clang diagnostic pop

            self.incompleteIncomingMessage = nil;
        }
    } else if (stream == self.outputStream && streamEvent == NSStreamEventHasSpaceAvailable) {
        if (self.messageQueue.count > 0) {
            NSInteger result = [self streamOutgoingMessage:self.messageQueue[0]];
            if (result == -1) {
                NSLog(@"Error sending outgoing message: '%@'", self.messageQueue[0]);
            } else {
                [self.messageQueue removeObjectAtIndex:0];
            }
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
    NSLog(@"==========> Sending message: '%@'", message);
    const uint8_t *messageBuffer = (const uint8_t *)[message UTF8String];
    return [self.outputStream write:messageBuffer maxLength:strlen(messageBuffer)];
}
@end
