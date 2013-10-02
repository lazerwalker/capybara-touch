#import "TCPServer.h"
#import "CTCapybaraClient.h"

@interface CTInterface : NSObject<NSStreamDelegate, TCPServerDelegate>

@property (strong, nonatomic) id<CTCapybaraDelegate>delegate;

- (void)startWithPort:(NSInteger)port domain:(NSString *)domain;

@end
