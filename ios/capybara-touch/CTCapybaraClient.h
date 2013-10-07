#import <Foundation/Foundation.h>

@protocol CTCapybaraDelegate<NSObject>

- (void)visit:(NSString *)url;
- (void)findXpath:(NSString *)xpath;

@end

@interface CTCapybaraClient : NSObject<CTCapybaraDelegate>

- (void)connect;
- (void)didFinishLoadingWebView;

@property (strong, nonatomic) UIWebView *webView;

@end

