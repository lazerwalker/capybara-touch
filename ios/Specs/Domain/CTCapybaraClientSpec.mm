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

        it(@"should respond successfully", ^{
            spy_on(client.webView);
            client.webView stub_method(@selector(stringByEvaluatingJavaScriptFromString:)).and_return(@"1");
            spy_on(client.interface);
            [client findXpath:@"foo"];
            client.interface should have_received(@selector(sendSuccessMessage:)).with(@"1");
        });
    });

    describe(@"currentURL", ^{
        it(@"should return the current URL", ^{
            [client visit:@"http://google.com"];
            client.interface should have_received(@selector(sendSuccessMessage:)).with(@"http://google.com");
        });
    });

    xdescribe(@"body", ^{

    });

    describe(@"node", ^{
        it(@"should send the JS command on to the web view", ^{
            [client javascriptCommand:@[@"isAttached", @"[\"1\"]"]];

             client.webView should have_received(@selector(stringByEvaluatingJavaScriptFromString:)).with(@"Capybara.isAttached(1);");
        });

        context(@"when the request is true", ^{
            it(@"should respond successfully", ^{
                spy_on(client.webView);
                client.webView stub_method(@selector(stringByEvaluatingJavaScriptFromString:)).and_return(@"true");
                spy_on(client.interface);
                [client javascriptCommand:@[@"isAttached", @"[\"1\"]"]];
                client.interface should have_received(@selector(sendSuccessMessage:)).with(@"true");
            });
        });

        context(@"when the request is false", ^{
            it(@"should respond successfully", ^{
                spy_on(client.webView);
                client.webView stub_method(@selector(stringByEvaluatingJavaScriptFromString:)).and_return(@"");
                spy_on(client.interface);
                [client javascriptCommand:@[@"isAttached", @"[\"1\"]"]];
                client.interface should have_received(@selector(sendSuccessMessage:)).with(@"false");
            });
        });

        context(@"when the request is wait", ^{
            it(@"should not respond", ^{
                spy_on(client.webView);
                client.webView stub_method(@selector(stringByEvaluatingJavaScriptFromString:)).and_return(@"wait");
                spy_on(client.interface);
                client.interface should_not have_received(@selector(sendSuccessMessage:));
            });
        });

    });
});

SPEC_END
