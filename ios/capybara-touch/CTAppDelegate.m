#import "CTAppDelegate.h"

#import "CTViewController.h"

@implementation CTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[CTViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
