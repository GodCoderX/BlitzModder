#import "BMAppDelegate.h"
#import "BMRootViewController.h"
#import "BMSecondViewController.h"
#import "BMRepoViewController.h"
#import "BMSettingsViewController.h"

@implementation BMAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[BMRootViewController alloc] init]];
	self.window.rootViewController = self.rootViewController;
    [[NSUserDefaults standardUserDefaults] setObject:@[@"en", @"ja"] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	[self.window makeKeyAndVisible];
}

@end
