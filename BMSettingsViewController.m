#import <QuartzCore/QuartzCore.h>
#import "BMRootViewController.h"
#import "BMRepoViewController.h"
#import "BMSettingsViewController.h"
#import "NSTask.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <sys/utsname.h>

@interface BMSettingsViewController()

@end

@implementation BMSettingsViewController {
    NSInteger appLanguage;
    NSArray *languageArray;
	NSInteger currentRepo;
	NSArray *repoArray;
}
- (void)loadView {
	[super loadView];
    [self getUserDefaults];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	self.tableView.alwaysBounceVertical = YES;
	self.tableView.allowsMultipleSelection = NO;
	self.title = [self BMLocalizedString:@"Settings"];
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
	self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

	self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self BMLocalizedString:@"Done"] style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:appLanguage inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
	NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
	if (indexPath.section == 1) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (NSString *)BMLocalizedString:(NSString *)key {
    NSString *path = [[NSBundle mainBundle] pathForResource:languageArray[appLanguage] ofType:@"lproj"];
    return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:@"" table:nil];
}

- (void)doneButtonTapped:(id)sender {
	[self getUserDefaults];
    [self backToRootView];
}

- (void)backToRootView {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
	if (repoArray.count <= currentRepo) {
		currentRepo = 0;
	}
	[self saveUserDefaults];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
}

- (void)getUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    appLanguage = [ud integerForKey:@"appLanguage"];
	languageArray = [ud arrayForKey:@"AppleLanguages"];
	repoArray = [[ud arrayForKey:@"repoArray"] mutableCopy];
    currentRepo = [ud integerForKey:@"currentRepo"];
}

- (void)saveUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:appLanguage forKey:@"appLanguage"];
	[ud setObject:[repoArray copy] forKey:@"repoArray"];
    [ud setInteger:currentRepo forKey:@"currentRepo"];
    [ud synchronize];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [languageArray count];
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
		return 2;
	} else if (section == 3) {
		return 1;
	}
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [self BMLocalizedString:@"Language Settings"];
    } else if (section == 1) {
        return [self BMLocalizedString:@"Repository"];
    } else if (section == 2) {
		return [self BMLocalizedString:@"Trouble Shooting"];
	} else if (section == 3) {
		return [self BMLocalizedString:@"Contact"];
	}
    return nil;
}

- (NSString *)getDisplayName:(NSString *)localeIdentifier {
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
    return [locale displayNameForKey:NSLocaleIdentifier value:localeIdentifier];
}

- (NSString *)getEnglishName:(NSString *)localeIdentifier {
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:languageArray[appLanguage]];
    return [locale displayNameForKey:NSLocaleIdentifier value:localeIdentifier];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (indexPath.section == 0) {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = [self getDisplayName:languageArray[indexPath.row]];
		cell.detailTextLabel.text = [self getEnglishName:languageArray[indexPath.row]];
		cell.detailTextLabel.textColor = [UIColor grayColor];
    } else if (indexPath.section == 1) {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = [self BMLocalizedString:@"Repository List"];
    } else if (indexPath.section == 2) {
		if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
		if (indexPath.row == 0) {
			cell.textLabel.text = [self BMLocalizedString:@"Reset All Settings"];
			cell.textLabel.textColor = [UIColor redColor];
			cell.detailTextLabel.text = [self BMLocalizedString:@"Tap here after you update Blitz or when something is wrong"];
			cell.detailTextLabel.textColor = [UIColor grayColor];
		} else if (indexPath.row == 1) {
			cell.textLabel.text = [self BMLocalizedString:@"Website"];
			cell.detailTextLabel.text = [self BMLocalizedString:@"Tap here to refer to the usage of BlitzModder"];
			cell.detailTextLabel.textColor = [UIColor grayColor];
		}

	} else if (indexPath.section == 3) {
		if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
		cell.textLabel.text = [self BMLocalizedString:@"Bug report / Feature request"];
		cell.textLabel.textColor = [UIColor blueColor];
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (indexPath.row == i) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                appLanguage = i;
                [self saveUserDefaults];
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else if (indexPath.section == 1) {
        BMRepoViewController *repoViewController = [[BMRepoViewController alloc] init];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
			UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self BMLocalizedString:@"Warning"] message:[self BMLocalizedString:@"Do you want to reset ALL settings?"] preferredStyle:UIAlertControllerStyleAlert];
			[alertController addAction:[UIAlertAction actionWithTitle:[self BMLocalizedString:@"Cancel"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			}]];
			[alertController addAction:[UIAlertAction actionWithTitle:[self BMLocalizedString:@"OK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				[self resetDefaults];
				[self removeTempDir];
			}]];
			[self presentViewController:alertController animated:YES completion:nil];
		} else if (indexPath.row == 1) {
			NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://subdiox.com/blitzmodder/%@/index.html",languageArray[appLanguage]]];
			[[UIApplication sharedApplication] openURL:url];
		}
	} else if (indexPath.section == 3) {
		[self contactButtonTapped];
	}
}

- (void)resetDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *dictionary = [defaults dictionaryRepresentation];
	for (id key in dictionary) {
		[defaults removeObjectForKey:key];
	}
	[defaults synchronize];
}

- (void)removeTempDir {
	NSTask *task = [[NSTask alloc] init];
	NSPipe *pipe = [NSPipe pipe];
	[task setStandardOutput:pipe];
	NSPipe *errPipe = [NSPipe pipe];
	[task setStandardError:errPipe];
	[task setLaunchPath: @"/bin/sh"];
	NSString *commandString = @"rm -rf /var/root/Library/Caches/BlitzModder";
	[task setArguments:[NSArray arrayWithObjects:@"-c",commandString,nil]];
	[task launch];
	NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
	if (data != nil && [data length]) {
		NSString *strOut = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		strOut = [NSString stringWithFormat:@"%@\n",strOut];
		NSLog(@"%@",strOut);
	}
	data = [[errPipe fileHandleForReading] readDataToEndOfFile];
	if (data != nil && [data length]) {
		NSString *strErr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		strErr = [NSString stringWithFormat:@"%@\n",strErr];
		[self showError:strErr];
	}
}
- (void)showError:(NSString *)errorMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self BMLocalizedString:@"Error"] message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[self BMLocalizedString:@"OK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)contactButtonTapped {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
	[picker setToRecipients:[NSArray arrayWithObjects:@"subdiox@gmail.com", nil]];
    [picker setSubject:[self BMLocalizedString:@"BlitzModder Support"]];
	NSData *plistData = [NSData dataWithContentsOfFile:@"/var/root/Library/Preferences/com.subdiox.blitzmodder.plist"];
    [picker addAttachmentData:plistData mimeType:@"application/x-plist" fileName:@"com.subdiox.blitzmodder.plist"];
	[picker setMessageBody:[NSString stringWithFormat:[self BMLocalizedString:@"\n\n\n\n\nDevice: %@\niOS Version: %@\nApp Version: %@"], [self platformString], [self iOSVersion], [self appVersion]] isHTML:NO];
    [self presentViewController:picker animated:YES completion:nil];
}

- (NSString *)platformString {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (NSString *)iOSVersion {
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)appVersion {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}

// アプリ内メーラーのデリゲートメソッド
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
