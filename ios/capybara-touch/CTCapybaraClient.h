#import <Foundation/Foundation.h>

@protocol CTCapybaraDelegate<NSObject>

- (void)visit:(NSString *)url;
- (void)findXpath:(NSString *)xpath;
- (void)reset;
- (void)javascriptCommand:(NSArray *)arguments;

@end

@interface CTCapybaraClient : NSObject<CTCapybaraDelegate>

- (void)connect;
- (void)didFinishLoadingWebView;

@property (strong, nonatomic) UIWebView *webView;

@end

