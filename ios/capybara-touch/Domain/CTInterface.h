#import "CTCapybaraClient.h"

@interface CTInterface : NSObject

@property (strong, nonatomic) id<CTCapybaraDelegate>delegate;

- (void)startWithPort:(NSInteger)port domain:(NSString *)domain;
- (void)sendSuccessMessage;
- (void)sendSuccessMessage:(NSString *)message;

@end
