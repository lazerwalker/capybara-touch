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

- (void)javascriptCommand:(NSArray *)arguments {
    NSString *command = arguments[0];

    NSArray *args = [arguments subarrayWithRange:NSMakeRange(1, arguments.count - 1)];
    args = [args map:^id(NSString *argument, NSUInteger idx) {
        return [self stripJsonArrayFromNodeIndex:argument];
    }];

    NSString *js = [NSString stringWithFormat:@"Capybara.%@(%@);", command, [args componentsJoinedByString:@", "]];
    NSString *result = [self execute:js];
    if ([result isEqualToString:@""]) {
        result = @"false";
    }

    NSLog(@"JS Result: %@", result);
    [self.interface sendSuccessMessage:result];
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
