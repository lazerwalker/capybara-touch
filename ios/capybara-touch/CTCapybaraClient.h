#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CTCapybaraDelegate<NSObject>

- (void)visit:(NSString *)url;
- (void)findXpath:(NSString *)xpath;
- (void)reset;
- (void)javascriptCommand:(NSArray *)arguments;
- (void)currentURL;
- (void)body;

@end

@interface CTCapybaraClient : NSObject<CTCapybaraDelegate, UIWebViewDelegate>

- (void)connect;

@property (strong, nonatomic) UIWebView *webView;

@end

