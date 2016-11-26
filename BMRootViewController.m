#import <QuartzCore/QuartzCore.h>
#import "BMAppDelegate.h"
#import "BMRootViewController.h"
#import "BMSecondViewController.h"
#import "BMProcessViewController.h"
#import "BMSettingsViewController.h"
#import "BMListViewController.h"
#import "BMConfirmationViewController.h"
#import "NSTask.h"
#import "OrderedDictionary.h"
#import "SVProgressHUD/SVProgressHUD.h"

@interface BMRootViewController()
@property (nonatomic, retain) UIWindow *window;
@end

@implementation BMRootViewController {
    bool success;
    bool finished;
 	int currentRepo;
	int appLanguage;
	NSString *savePath;
	NSString *blitzPath;
	NSArray *languageArray;
	NSMutableArray *modNameArray;
	NSMutableArray *modDetailArray;
	NSMutableArray *modCategoryArray;
    NSMutableArray *repoArray;
	NSMutableArray *buttonArray;
	NSMutableArray *installedArray;
    UIView *loadingView;
}

// initialize view
- (void)viewDidLoad {
	[super viewDidLoad];

	// initialize NSUserDefaults
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults setObject:@"0" forKey:@"appLanguage"];
    [defaults setObject:@[@"subdiox"] forKey:@"repoArray"];
	[defaults setObject:@"0" forKey:@"currentRepo"];
	[defaults setObject:[NSMutableArray array] forKey:@"modCategoryArray"];
	[defaults setObject:[NSMutableArray array] forKey:@"modNameArray"];
	[defaults setObject:[NSMutableArray array] forKey:@"modDetailArray"];
	[defaults setObject:@"" forKey:@"blitzPath"];
	[defaults setObject:[NSMutableArray array] forKey:@"buttonArray"];
	[defaults setObject:[NSMutableArray array] forKey:@"installedArray"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

	[self getUserDefaults];

	savePath = @"/var/root/Library/Caches/BlitzModder";

	// run methods
	[self checkBlitzExists];
    [self makeSaveDirectory];
    [self getUserDefaults];
	[self checkForUpdate];
    [self refreshMods];

	if (repoArray[0] == @"GodCoderX") {
		repoArray = @"subdiox";
		[self saveUserDefaults];
	}

	// initialize rootViewController
    BMRootViewController *rootViewController = [[BMRootViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.window.rootViewController = navigationController;

	// initialize title button
	UIButton *titleLabelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    titleLabelButton.backgroundColor = [UIColor clearColor];
    titleLabelButton.showsTouchWhenHighlighted = YES;
    titleLabelButton.tintColor = [UIColor blackColor];
    [titleLabelButton setTitle:[self BMLocalizedString:@"Mods List ▼"] forState:UIControlStateNormal];
    titleLabelButton.frame = CGRectMake(0, -10, 0, 0);
    titleLabelButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [titleLabelButton addTarget:self action:@selector(titleTapped:) forControlEvents:UIControlEventTouchUpInside];
    [titleLabelButton sizeToFit];

	// initialize subtitle label
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, 0, 0)];
    subTitleLabel.backgroundColor = [UIColor clearColor];
    subTitleLabel.textColor = [UIColor grayColor];
    subTitleLabel.font = [UIFont systemFontOfSize:12];
    subTitleLabel.text = repoArray[currentRepo];
    [subTitleLabel sizeToFit];

	float widthDiff = subTitleLabel.frame.size.width - titleLabelButton.frame.size.width;
    if (widthDiff > 0) {
        CGRect frame = titleLabelButton.frame;
        frame.origin.x = widthDiff / 2;
        titleLabelButton.frame = CGRectIntegral(frame);
    } else {
        CGRect frame = subTitleLabel.frame;
        frame.origin.x = fabsf(widthDiff) / 2;
        subTitleLabel.frame = CGRectIntegral(frame);
    }

	// add title and subtitle views
    UIView *twoLineTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(subTitleLabel.frame.size.width, titleLabelButton.frame.size.width), 30)];
    [twoLineTitleView addSubview:titleLabelButton];
    [twoLineTitleView addSubview:subTitleLabel];
    self.navigationItem.titleView = twoLineTitleView;

	// initialize UIRefreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(refreshOccurred:) forControlEvents:UIControlEventValueChanged];

	// initialize UITableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

	// initialize navigation bar items
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self BMLocalizedString:@"Settings"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonTapped:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self BMLocalizedString:@"Apply"] style:UIBarButtonItemStyleDone target:self action:@selector(applyButtonTapped:)];

	// run a method
	[self getUserDefaults];

	// initialize NSNotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadView) name:@"reloadData" object:nil];
}

- (void)reloadView {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadData" object:nil];
    [self loadView];
	[self viewDidLoad];
	BMSecondViewController *secondViewController = [[BMSecondViewController alloc] init];
	[self.tableView selectRowAtIndexPath: secondViewController.indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

// called when title button is tapped
- (void)titleTapped:(id)sender {
    BMListViewController *listViewController = [[BMListViewController alloc] init];

	CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;

    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:listViewController animated:NO];
}

// called when settings button is tapped
- (void)settingsButtonTapped:(id)sender {
    BMSettingsViewController *settingsViewController = [[BMSettingsViewController alloc] init];

	CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;

    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:settingsViewController animated:NO];
}

// called when the tableview is pulled down
- (void)refreshOccurred:(id)sender {
    [self getUserDefaults];
    [self refreshMods];
    while (!finished) {}
    [self.refreshControl endRefreshing];
}

// localize strings
- (NSString *)BMLocalizedString:(NSString *)key {
    NSString *path = [[NSBundle mainBundle] pathForResource:languageArray[appLanguage] ofType:@"lproj"];
    return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:@"" table:nil];
}

// make a directory to save temporary files
- (void)makeSaveDirectory {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSPipe *errPipe = [NSPipe pipe];
    [task setStandardError:errPipe];
    [task setLaunchPath: @"/bin/mkdir"];
    [task setStandardOutput:pipe];
    [task setArguments:[NSArray arrayWithObjects:@"-p",savePath,nil]];
    [task launch];
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    data = [[errPipe fileHandleForReading] readDataToEndOfFile];
    if (data != nil && [data length]) {
        NSString *strErr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self BMLocalizedString:@"Error"] message:strErr preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:[self BMLocalizedString:@"OK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)checkForUpdate {
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURL *requestURL = [NSURL URLWithString:@"https://github.com/GodCoderX/BlitzModder-iOS/raw/master/version"];
    NSURLSessionDataTask *task = [session dataTaskWithURL:requestURL
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
											if (!error) {
												NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
												if (statusCode == 404) {
	                                                dispatch_async(dispatch_get_main_queue(), ^{
	                                                    [self showError:[self BMLocalizedString:@"Failed to check for update. Please report this to GodCoderX."]];
	                                                    return;
	                                                });
	                                            } else {
													NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
													NSString *latestVersion = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
													NSLog(@"appVersion:%@,latestVersion:%@",appVersion,latestVersion);
													if ([self convertVersion:appVersion] < [self convertVersion:latestVersion]) {
														[self showError:[self BMLocalizedString:@"New version of BlitzModder is available. Please go to Cydia to get the update."]];
													} else if ([self convertVersion:appVersion] > [self convertVersion:latestVersion]) {
														[self showError:[self BMLocalizedString:@"You are using the newer version than latest one. Please report this to GodCoderX."]];
													}
	                                            }
											}}];
    [task resume];
}

- (double)convertVersion:(NSString *)version {
	NSArray *versionArray = [version componentsSeparatedByString:@"."];
	double converted = 0;
	for (int i = 0; i < versionArray.count; i++) {
		converted += [versionArray[i] doubleValue] * pow(10.0, (double)i);
	}
	return converted;
}

// get NSUserDefaults
- (void)getUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    appLanguage = [ud integerForKey:@"appLanguage"];
	languageArray = [ud arrayForKey:@"AppleLanguages"];
    repoArray = [[ud arrayForKey:@"repoArray"] mutableCopy];
    currentRepo = [ud integerForKey:@"currentRepo"];
	blitzPath = [ud stringForKey:@"blitzPath"];
	buttonArray = [[ud arrayForKey:@"buttonArray"] mutableCopy];
	installedArray = [[ud arrayForKey:@"installedArray"] mutableCopy];
	modCategoryArray = [[ud arrayForKey:@"modCategoryArray"] mutableCopy];
	modNameArray = [[ud arrayForKey:@"modNameArray"] mutableCopy];
	modDetailArray = [[ud arrayForKey:@"modDetailArray"] mutableCopy];
}

// save NSUserDefaults
- (void)saveUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:appLanguage forKey:@"appLanguage"];
	[ud setObject:languageArray forKey:@"AppleLanguages"];
    [ud setObject:[repoArray copy] forKey:@"repoArray"];
    [ud setInteger:currentRepo forKey:@"currentRepo"];
	[ud setObject:blitzPath forKey:@"blitzPath"];
	[ud setObject:[buttonArray copy] forKey:@"buttonArray"];
	[ud setObject:[installedArray copy] forKey:@"installedArray"];
	[ud setObject:[modCategoryArray copy] forKey:@"modCategoryArray"];
	[ud setObject:[modNameArray copy] forKey:@"modNameArray"];
	[ud setObject:[modDetailArray copy] forKey:@"modDetailArray"];
    [ud synchronize];
}

// make a directory for saving repository data
- (void)makeRepoDirectory:(NSString *)repo {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSPipe *errPipe = [NSPipe pipe];
    [task setStandardError:errPipe];
    [task setLaunchPath: @"/bin/mkdir"];
    [task setStandardOutput:pipe];
    [task setArguments:[NSArray arrayWithObjects:@"-p",[NSString stringWithFormat:@"%@/%@",savePath,repo],nil]];
    [task launch];
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    data = [[errPipe fileHandleForReading] readDataToEndOfFile];
    if (data != nil && [data length]) {
        NSString *strErr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self BMLocalizedString:@"Error"] message:strErr preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:[self BMLocalizedString:@"OK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

// show error message
- (void)showError:(NSString *)errorMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self BMLocalizedString:@"Error"] message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[self BMLocalizedString:@"OK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

// refresh mods list
- (void)refreshMods {
    finished = NO;
    [self makeRepoDirectory:repoArray[currentRepo]];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/%@/BMRepository/raw/iOS/%@.plist",repoArray[currentRepo],languageArray[appLanguage]]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:requestURL
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            finished = YES;
											if (!error) {
												NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
												if (statusCode == 404) {
	                                                dispatch_async(dispatch_get_main_queue(), ^{
	                                                    [self showError:[NSString stringWithFormat:[self BMLocalizedString:@"%@.plist does NOT exist! Please contact the owner of this repository."],languageArray[appLanguage]]];
	                                                    return;
	                                                });
	                                            } else {
	                                                NSFileManager *fm = [NSFileManager defaultManager];
	                                                NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@.plist",savePath,repoArray[currentRepo],languageArray[appLanguage]];
	                                                [fm createFileAtPath:filePath contents:data attributes:nil];
	                                                NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:filePath];
	                                                [file writeData:data];
													MutableOrderedDictionary *dic = [[MutableOrderedDictionary alloc] initWithContentsOfFile:filePath];
													modCategoryArray = [NSMutableArray array];
													modNameArray = [NSMutableArray array];
													modDetailArray = [NSMutableArray array];
													modCategoryArray = [[dic allKeys] mutableCopy];
													for (id key1 in [dic allKeys]) {
														[modNameArray addObject:[dic[key1] allKeys]];
														NSMutableArray *tempArray = [NSMutableArray array];
														for (id key2 in [dic[key1] allKeys]) {
															[tempArray addObject:[[dic[key1][key2] allKeys] mutableCopy]];
														}
														[modDetailArray addObject:tempArray];
													}
													[self saveUserDefaults];
													dispatch_async(dispatch_get_main_queue(), ^{
														[self.tableView reloadData];
													});
	                                            }
											} else {
												[self showError:[self BMLocalizedString:@"Your internet connection seems to be offline."]];
											}
										}];
    [task resume];
}

- (NSString *)getFullString :(int)i :(int)j :(int)k {
	return [self getString:modDetailArray[i][j][k]];
}

- (NSString *)getFullID :(int)i :(int)j :(int)k {
	return [NSString stringWithFormat:@"%@.%@.%@",[self getID:modCategoryArray[i]],[self getID:modNameArray[i][j]],[self getID:modDetailArray[i][j][k]]];
}

- (NSString *)getSaveID :(int)i :(int)j :(int)k {
	return [NSString stringWithFormat:@"%@.%@",repoArray[currentRepo],[self getFullID:i:j:k]];
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

// check whether WoTBlitz exists
- (void)checkBlitzExists {
    NSString *appsPath = @"";
    NSArray  *iOSVersions = [[[UIDevice currentDevice]systemVersion] componentsSeparatedByString:@"."];
    NSInteger iOSVersionMajor = [iOSVersions[0] intValue];
    NSInteger iOSVersionMinor = [iOSVersions[1] intValue];
    if ((iOSVersionMajor == 9 && iOSVersionMinor < 3) || iOSVersionMajor == 8) {
        appsPath = @"/var/mobile/Containers/Bundle/Application";
    } else if ((iOSVersionMajor == 9 && iOSVersionMinor >= 3) || iOSVersionMajor > 9) {
        appsPath = @"/var/containers/Bundle/Application";
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self BMLocalizedString:@"Warning"] message:[self BMLocalizedString:@"Your iOS Version is not supported.\nPlease update to iOS9 and jailbreak again."] preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [[NSPipe alloc] init];
    [task setLaunchPath: @"/usr/bin/find"];
    [task setStandardOutput:pipe];
    [task setArguments:[NSArray arrayWithObjects:appsPath,@"-maxdepth",@"2",@"-name",@"wotblitz.app", nil]];
    [task launch];
    NSFileHandle *handle = [pipe fileHandleForReading];
    NSData *data = [handle readDataToEndOfFile];
    blitzPath = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if ([blitzPath isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self BMLocalizedString:@"Warning"] message:[self BMLocalizedString:@"World of Tanks Blitz is not installed.\nPlease install it from App Store."] preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];
    }
	[self saveUserDefaults];
}

// called when Apply button is tapped
- (void)applyButtonTapped:(id)sender {
    [self getUserDefaults];
	NSMutableArray *removeQueueArray = [NSMutableArray array];
	NSMutableArray *installQueueArray = [NSMutableArray array];
    for (int i = 0; i < [modDetailArray count]; i++) {
        for (int j = 0; j < [modDetailArray[i] count]; j++) {
            for (int k = 0; k < [modDetailArray[i][j] count]; k++) {
                if (![buttonArray containsObject:[self getSaveID:i:j:k]] && [installedArray containsObject:[self getSaveID:i:j:k]]) {
					[removeQueueArray addObject:@[@(i),@(j),@(k)]];
                } else if ([buttonArray containsObject:[self getSaveID:i:j:k]] && ![installedArray containsObject:[self getSaveID:i:j:k]]) {
                    [installQueueArray addObject:@[@(i),@(j),@(k)]];
                }
            }
        }
    }
	[self saveUserDefaults];
	if (removeQueueArray.count + installQueueArray.count == 0) {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self BMLocalizedString:@"Notice"] message:[self BMLocalizedString:@"There are no changes to be applied."] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:[self BMLocalizedString:@"OK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
	} else {
		BMConfirmationViewController *confirmationViewController = [[BMConfirmationViewController alloc] init];

		confirmationViewController.removeQueueArray = removeQueueArray;
		confirmationViewController.installQueueArray = installQueueArray;

	    CATransition* transition = [CATransition animation];
	    transition.duration = 0.5;
	    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
	    transition.type = kCATransitionMoveIn;
	    transition.subtype = kCATransitionFromTop;

	    [self.navigationController.view.layer addAnimation:transition forKey:nil];
	    [self.navigationController pushViewController:confirmationViewController animated:NO];
	}
}

// UITableView settings
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [modNameArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [modNameArray[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self getString:modCategoryArray[section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    cell.textLabel.text = [self getString:modNameArray[indexPath.section][indexPath.row]];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BMSecondViewController *secondViewController = [[BMSecondViewController alloc] init];
    secondViewController.indexPath = indexPath;
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[self BMLocalizedString:@"Back"] style:UIBarButtonItemStylePlain target:self action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    [self.navigationController pushViewController:secondViewController animated:YES];
}

// deselect row when view appears
- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

@end
