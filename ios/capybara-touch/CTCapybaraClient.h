#import <Foundation/Foundation.h>

@protocol CTCapybaraDelegate<NSObject>

- (void)visit:(NSString *)url;
- (void)findXpath:(NSString *)xpath;
- (void)reset;

@end

@interface CTCapybaraClient : NSObject<CTCapybaraDelegate>

- (void)connect;
- (void)didFinishLoadingWebView;

@property (strong, nonatomic) UIWebView *webView;

@end

