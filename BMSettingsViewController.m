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

- (NSString *)getDisplayName:(NSString *) localeIdentifier {
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
    return [locale displayNameForKey:NSLocaleIdentifier value:localeIdentifier];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (indexPath.section == 0) {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = [self getDisplayName:languageArray[indexPath.row]];
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
			cell.detailTextLabel.text = [self BMLocalizedString:@"Use this button after you update the Blitz app."];
			cell.detailTextLabel.textColor = [UIColor grayColor];
		} else if (indexPath.row == 1) {
			cell.textLabel.text = [self BMLocalizedString:@"Website"];
			cell.detailTextLabel.text = [self BMLocalizedString:@"Refer to the usage of BlitzModder."];
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
			NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://godcoderx.com/blitzmodder/%@/index.html",languageArray[appLanguage]]];
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

// Contactボタンがタップされたとき
- (void)contactButtonTapped {
    // メールビュー生成
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;

	// 宛先
	[picker setToRecipients:[NSArray arrayWithObjects:@"godcoderx@gmail.com", nil]];

    // メール件名
    [picker setSubject:[self BMLocalizedString:@"BlitzModder Support"]];

    // 添付ファイル
	NSData *plistData = [NSData dataWithContentsOfFile:@"/var/root/Library/Preferences/com.godcoderx.blitzmodder.plist"];
    [picker addAttachmentData:plistData mimeType:@"application/x-plist" fileName:@"com.godcoderx.blitzmodder.plist"];

    // メール本文
	[picker setMessageBody:[NSString stringWithFormat:[self BMLocalizedString:@"\n\n\n\n\nDevice: %@\niOS Version: %@\nApp Version: %@"], [self platformString], [self iOSVersion], [self appVersion]] isHTML:NO];

    // メールビュー表示
    [self presentViewController:picker animated:YES completion:nil];
}

- (NSString *)platformString {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4(Rev A)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4(CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";    // GSM
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";    // GSM+CDMA
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5C";   // GSM
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5C";   // GSM+CDMA
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5S";   // GSM
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5S";   // GSM+CDMA
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";    // ?
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";    // ?
	if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
	if ([platform isEqualToString:@"iPod6,1"])   return @"iPod Touch 6G";
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 WiFi";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 GSM";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 CDMA";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 CDMAS";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini Wifi";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini (Wi-Fi + Cellular)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini (Wi-Fi + Cellular MM)";
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 WiFi";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 CDMA";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 GSM";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 Wifi";
	if ([platform isEqualToString:@"iPad4,1"])   return @"iPad 5 Wifi";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad 5 Cellular";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad 2 Mini Wifi";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad 2 Mini Cellular";
    if ([platform isEqualToString:@"iPad4,7"])   return @"iPad 3 Mini Wifi";
    if ([platform isEqualToString:@"i386"])      return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"Simulator";
    return [NSString stringWithFormat:@"Unknown:%@",platform];
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
            // キャンセル

            break;
        case MFMailComposeResultSaved:
            // 保存 (ここでアラート表示するなど何らかの処理を行う)

            break;
        case MFMailComposeResultSent:
            // 送信成功 (ここでアラート表示するなど何らかの処理を行う)

            break;
        case MFMailComposeResultFailed:
            // 送信失敗 (ここでアラート表示するなど何らかの処理を行う)

            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
