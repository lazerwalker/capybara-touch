#import "CTCapybaraClient.h"
#import "CTInterface.h"

@interface CTCapybaraClient ()

@property (strong, nonatomic) CTInterface *interface;
@property (copy, nonatomic) void (^webViewLoadCompletionBlock)();
@property (strong, nonatomic) NSString *capybaraJS;

@end

@implementation CTCapybaraClient

- (instancetype)init
{
    if (self = [super init]) {
        self.interface = [[CTInterface alloc] init];
        self.interface.delegate = self;
    }
    return self;
}

- (void)connect {
    [self.interface startWithPort:9292 domain:@"localhost"];
}

- (void)didFinishLoadingWebView {
    [self injectCapybaraIntoCurrentPage];

    if (self.webViewLoadCompletionBlock) {
        self.webViewLoadCompletionBlock();
        self.webViewLoadCompletionBlock = nil;
    }
}

#pragma mark - CTCapybaraDelegate methods

- (void)visit:(NSString *)urlString {
    NSLog(@"Loading URL: %@", urlString);

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];

    __weak CTCapybaraClient *weakSelf = self;
    self.webViewLoadCompletionBlock = ^{
        [weakSelf.interface sendSuccessMessage];
    };
}

- (void)findXpath:(NSString *)xpath {
    NSString *jsString = [NSString stringWithFormat:@"Capybara.findXpath(\"%@\");", xpath];
    NSString *result = [self execute:jsString];
    NSLog(@"Result = %@", result);

    [self.interface sendSuccessMessage:result];
}

- (void)reset {
    [self.interface sendSuccessMessage];
}

#pragma mark - Private
- (NSString *)execute:(NSString *)js {
    return [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)injectCapybaraIntoCurrentPage {
    if (!self.capybaraJS) {
        NSString *fileName = [[NSBundle mainBundle] pathForResource:@"capybara" ofType:@"js"];
        NSData *fileData = [NSData dataWithContentsOfFile:fileName];
        self.capybaraJS = [[NSString alloc] initWithData:fileData encoding:NSStringEncodingConversionAllowLossy];
    }

    [self execute:self.capybaraJS];
}

@end
