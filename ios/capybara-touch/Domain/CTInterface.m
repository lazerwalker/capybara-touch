#import "CTInterface.h"
#import <GCDAsyncSocket.h>

static const NSUInteger SOCKET_TIMEOUT = 15;

@interface CTInterface ()<GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *server;
@property (strong, nonatomic) GCDAsyncSocket *socket;
@end

@implementation CTInterface

- (NSDictionary *)commandMapping {
    return @{@"Visit": @"visit:",
             @"FindXpath": @"findXpath:",
             @"FindCss": @"findCSS:",
             @"Reset": @"reset",
             @"Node": @"javascriptCommand:",
             @"CurrentUrl": @"currentURL",
             @"Body": @"body",
             @"Title": @"title"
             };
}

- (instancetype)init {
    if (self = [super init]) {
        self.server = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        self.server.delegate = self;
    }
    return self;
}

- (void)startWithPort:(NSInteger)port domain:(NSString *)domain {
    NSError *error;
    if (![self.server acceptOnPort:port error:&error]) {
        NSLog(@"Error starting the TCP server: %@", error);
    } else {
        NSLog(@"listening on port: %d", port);
    }
}

- (void)sendSuccessMessage {
    [self sendSuccessMessage:nil];
}

- (void)sendSuccessMessage:(NSString *)message {
    NSString *successMessage = @"ok\n";
    if (message) {
        successMessage = [NSString stringWithFormat:@"%@%lu\n%@", successMessage, strlen(message.UTF8String), message];
        if ([successMessage characterAtIndex:successMessage.length-1] != '\n') {
            successMessage = [successMessage stringByAppendingString:@"\n"];
        }
    } else {
        successMessage = [successMessage stringByAppendingString:@"0\n"];
    }

    [self streamOutgoingMessage:successMessage];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    self.socket = newSocket;
    [self.socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:SOCKET_TIMEOUT tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSString *inputString = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];

    NSArray *arguments = [inputString componentsSeparatedByString:@"\n"];
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

    SEL commandSelector = [self delegateMethodFromCommand:command];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.delegate respondsToSelector:commandSelector]) {
        NSLog(@"Received command: '%@', arguments: '%@'", command, commandArgument);
        [self.delegate performSelector:commandSelector withObject:commandArgument];
    } else {
        NSLog(@"Did not recognize command. Input string = '%@'", inputString);
    }
#pragma clang diagnostic pop
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    self.socket = nil;
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

- (void)streamOutgoingMessage:(NSString *)message {
    NSLog(@"Sending outgoing message: '%@'", message);
    NSData *messageData = [[message stringByAppendingString:@"\r"] dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:messageData withTimeout:SOCKET_TIMEOUT tag:0];
    [self.socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:SOCKET_TIMEOUT tag:0];
}
@end
