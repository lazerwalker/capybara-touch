#import "CTViewController.h"
#import "CTCapybaraClient+Spec.h"

@interface CTViewController (Spec)
@property (strong, nonatomic) CTCapybaraClient *client;
@end

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CTViewControllerSpec)

describe(@"CTViewController", ^{
    __block CTViewController *controller;

    beforeEach(^{
        controller = [[CTViewController alloc] init];
    });

    describe(@"viewDidLoad", ^{
        beforeEach(^{
            spy_on(controller.client);
            [controller viewDidLoad];
        });

        it(@"should have a visible web view", ^{
            controller.view should be_instance_of([UIWebView class]);
        });

        it(@"should set the web view's delegate", ^{
            controller.webView.delegate should equal(controller);
        });

        it(@"should tell the client about the web view", ^{
            controller.client.webView should equal(controller.webView);
        });

        it(@"should connect to the client", ^{
            controller.client should have_received(@selector(connect));
        });
    });
});

SPEC_END
