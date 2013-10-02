#import <Foundation/Foundation.h>

@protocol CTCapybaraDelegate<NSObject>

- (void)visit:(NSString *)url;

@end

@interface CTCapybaraClient : NSObject<CTCapybaraDelegate>

- (void)connect;

@property (strong, nonatomic) UIWebView *webView;

@end

