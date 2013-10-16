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

    CGRect frame = self.view.bounds;
    self.view = self.client.webView;
    self.view.frame = frame;

    [self.client connect];
}

@end
