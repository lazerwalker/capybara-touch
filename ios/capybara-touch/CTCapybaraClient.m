#import "CTCapybaraClient.h"
#import "CTInterface.h"
#import "NSArray+Enumerable.h"
#import "UIFakeTouch.h"

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

        self.webView = [[UIWebView alloc] init];
        self.webView.delegate = self;
    }
    return self;
}

- (void)connect {
    [self.interface startWithPort:9292 domain:@"localhost"];
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

- (void)javascriptCommand:(NSArray *)arguments {
    NSString *command = arguments[0];

    NSArray *args = [arguments subarrayWithRange:NSMakeRange(1, arguments.count - 1)];
    args = [args map:^id(NSString *argument, NSUInteger idx) {
        return [NSString stringWithFormat:@"\"%@\"", [self stripJsonArrayFromNodeIndex:argument]];
    }];

    NSString *js = [NSString stringWithFormat:@"Capybara.%@(%@);", command, [args componentsJoinedByString:@", "]];
    NSString *result = [self execute:js];
    NSLog(@"JS Result: %@", result);
    if (![result isEqualToString:@"wait"]) {
        if ([result isEqualToString:@""]) {
            result = @"false";
        }

        [self.interface sendSuccessMessage:result];
    }

}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self injectCapybaraIntoCurrentPage];

    if (self.webViewLoadCompletionBlock) {
        self.webViewLoadCompletionBlock();
        self.webViewLoadCompletionBlock = nil;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSDictionary *mapping = @{
                              @"click": @"tapAtPoint:"
                              };

    if (!([request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"http"])) {

        NSString *action = mapping[request.URL.host];
        if (action) {
            SEL actionSelector = NSSelectorFromString(action);

            NSString *jsonString = [request.URL.path substringFromIndex:1];
            NSData *jsonData = [jsonString dataUsingEncoding:NSStringEncodingConversionAllowLossy];
            NSError *jsonError;

            NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonError];

            if ([self respondsToSelector:actionSelector]) {
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [self performSelector:actionSelector withObject:data];
                #pragma clang diagnostic pop
            }
        }
        return NO;
    }

    return YES;
}

- (void)tapAtPoint:(NSDictionary *)point {
    UIFakeTouch *touch = [[UIFakeTouch alloc] initInView:self.webView point:CGPointMake([point[@"x"] floatValue], [point[@"y"] floatValue])];
    [touch sendTap];
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

// Turns '["5"]' into "5"
- (NSString *)stripJsonArrayFromNodeIndex:(NSString *)string {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\\\"(\\d+)\\\"\\]" options:0 error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (result && result.numberOfRanges == 2) {
        return [string substringWithRange:[result rangeAtIndex:1]];
    } else {
        return string;
    }
}

@end
