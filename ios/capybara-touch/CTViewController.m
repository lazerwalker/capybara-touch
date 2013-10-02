#import "CTViewController.h"
#import "CTCapybaraClient.h"

@interface CTViewController ()

@property (strong, nonatomic) CTCapybaraClient *client;

@end

@implementation CTViewController

- (id)init {
    if (self = [super init]) {
        self.client = [[CTCapybaraClient alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.view = self.webView;
    self.webView.delegate = self;

    self.client.webView = self.webView;
    [self.client connect];
}

- (void)injectCapybara {
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"capybara" ofType:@"js"];
NSData *fileData = [NSData dataWithContentsOfFile:fileName];
    NSString *capybaraString = [[NSString alloc] initWithData:fileData encoding:NSStringEncodingConversionAllowLossy];
    [self.webView stringByEvaluatingJavaScriptFromString: capybaraString];
}

- (NSString *)execute:(NSString *)js {
    return [self.webView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self injectCapybara];
}

@end
