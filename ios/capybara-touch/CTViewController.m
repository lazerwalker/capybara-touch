#import "CTViewController.h"
#import "CTInterface.h"

@interface CTViewController ()

@property (strong, nonatomic) CTInterface *interface;

@end

@implementation CTViewController

- (id)init {
    if (self = [super init]) {
        self.interface = [[CTInterface alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.view = self.webView;
    self.webView.delegate = self;

    [self.webView loadHTMLString:@"<html><head><title>HI MOM</title></head><body><h1>I'M A WEB PAGE</h1></body></html>" baseURL:[NSURL URLWithString:@"hi"]];
}

- (void)injectCapybara {
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"capybara" ofType:@"js"];
NSData *fileData = [NSData dataWithContentsOfFile:fileName];
    NSString *capybaraString = [[NSString alloc] initWithData:fileData encoding:NSStringEncodingConversionAllowLossy];
    [self.webView stringByEvaluatingJavaScriptFromString: capybaraString];
    [self.interface startWithPort:9292 domain:@"localhost"];
}

- (NSString *)execute:(NSString *)js {
    return [self.webView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self injectCapybara];
}

@end
