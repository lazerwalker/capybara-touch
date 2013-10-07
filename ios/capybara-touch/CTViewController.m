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
    NSLog(@"Connecting to client");
    [self.client connect];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.client didFinishLoadingWebView];
}


@end
