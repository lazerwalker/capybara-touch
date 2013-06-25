#import <UIKit/UIKit.h>
#import "TCPServer.h"

@interface CTViewController : UIViewController<UIWebViewDelegate, TCPServerDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) TCPServer *server;

@end
