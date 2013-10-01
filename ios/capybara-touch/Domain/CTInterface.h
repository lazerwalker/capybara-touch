#import "TCPServer.h"

@interface CTInterface : NSObject<NSStreamDelegate, TCPServerDelegate>

- (void)startWithPort:(NSInteger)port domain:(NSString *)domain;

@end
