#import <WebKit/WebKit.h>
#import "BMAppDelegate.h"
#import "BMSecondViewController.h"
#import "BMThirdViewController.h"

@implementation BMThirdViewController {
    int currentRepo;
	int appLanguage;
	NSArray *languageArray;
    NSMutableArray *repoArray;
	NSMutableArray *modNameArray;
	NSMutableArray *modDetailArray;
	NSMutableArray *modCategoryArray;
	NSMutableArray *buttonArray;
	NSMutableArray *installedArray;
}

@synthesize indexPath;
@synthesize myIndexPath;

- (void)loadView {
	[super loadView];
	[self getUserDefaults];
    self.title = [self getString:modDetailArray[indexPath.section][indexPath.row][myIndexPath.row]];
	CGRectMake(0, 0, 10, 10);
	WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
	WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
	webView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:webView];
	webView.navigationDelegate = self;
	webView.UIDelegate = self;

	// Autolayout
	NSDictionary *views = NSDictionaryOfVariableBindings(webView);
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView(>=0)]-0-|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[webView(>=0)]-0-|" options:0 metrics:nil views:views]];

	NSString *urlString = [NSString stringWithFormat:@"https://%@.github.io/BMRepository/%@/%@",repoArray[currentRepo],languageArray[appLanguage],[self getFullID:indexPath.section:indexPath.row:myIndexPath.row]];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (NSString *)BMLocalizedString:(NSString *)key {
    NSString *path = [[NSBundle mainBundle] pathForResource:languageArray[appLanguage] ofType:@"lproj"];
    return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:@"" table:nil];
}

- (NSString *)getFullString :(int)i :(int)j :(int)k {
	return [self getString:modDetailArray[i][j][k]];
}

- (NSString *)getFullID :(int)i :(int)j :(int)k {
	return [NSString stringWithFormat:@"%@.%@.%@",[self getID:modCategoryArray[i]],[self getID:modNameArray[i][j]],[self getID:modDetailArray[i][j][k]]];
}

- (NSString *)getString:(NSString *)string{
	NSArray *array = [string componentsSeparatedByString:@":"];
	if ([array count] == 2) {
		return array[0];
	} else {
		return @"error";
	}
}

- (NSString *)getID:(NSString *)string{
	NSArray *array = [string componentsSeparatedByString:@":"];
	if ([array count] == 2) {
		return array[1];
	} else {
		return @"error";
	}
}

// get NSUserDefaults
- (void)getUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    appLanguage = [ud integerForKey:@"appLanguage"];
	languageArray = [ud arrayForKey:@"AppleLanguages"];
    repoArray = [[ud arrayForKey:@"repoArray"] mutableCopy];
    currentRepo = [ud integerForKey:@"currentRepo"];
	buttonArray = [[ud arrayForKey:@"buttonArray"] mutableCopy];
	installedArray = [[ud arrayForKey:@"installedArray"] mutableCopy];
	modCategoryArray = [[ud arrayForKey:@"modCategoryArray"] mutableCopy];
	modNameArray = [[ud arrayForKey:@"modNameArray"] mutableCopy];
	modDetailArray = [[ud arrayForKey:@"modDetailArray"] mutableCopy];
}

@end
