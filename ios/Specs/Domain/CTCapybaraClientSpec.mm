#import "CTCapybaraClient+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CTCapybaraClientSpec)

describe(@"CTCapybaraClient", ^{
    __block CTCapybaraClient *client;

    beforeEach(^{
        client = [[CTCapybaraClient alloc] init];
        client.webView = nice_fake_for([UIWebView class]);
    });

    it(@"should set the interface's delegate to self", ^{
        client.interface.delegate should equal(client);
    });

    describe(@"visit", ^{
        it(@"should tell the web view to load the page", ^{
            __block NSURLRequest *request;
            client.webView stub_method(@selector(loadRequest:)).and_do(^(NSInvocation *invocation) {
                [invocation getArgument:&request atIndex:2];
            });

            [client visit:@"http://google.com"];

            request.URL.absoluteString should equal(@"http://google.com");
        });

        it(@"should respond successfully", ^{
            spy_on(client.interface);
            [client visit:@"http://google.com"];
//            client.interface should have_received(@selector(sendSuccessMessage));
        });
    });

    describe(@"findXpath", ^{
        it(@"should tell the web view to grab an xpath", ^{
            [client findXpath:@"foo"];
            client.webView should have_received(@selector(stringByEvaluatingJavaScriptFromString:)).with(@"Capybara.findXpath(\"foo\");");
        });

        xit(@"should respond successfully", ^{
            spy_on(client.interface);
            [client visit:@"http://google.com"];
            client.interface should have_received(@selector(sendSuccessMessage));
        });
    });
});

SPEC_END
