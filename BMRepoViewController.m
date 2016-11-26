#import "BMRepoViewController.h"
#import "SVProgressHUD/SVProgressHUD.h"

@interface BMRepoViewController()
@end

@implementation BMRepoViewController {
    NSInteger appLanguage;
    NSArray *languageArray;
    NSMutableArray *repoArray;
    BOOL exists;
    BOOL okRepo;
    BOOL downloaded;
    BOOL checked;
}

- (void)loadView {
    [super loadView];
	[self getUserDefaults];
    self.title = [self BMLocalizedString:@"Repository List"];
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped:)];
    [self getUserDefaults];
}

- (NSString *)BMLocalizedString:(NSString *)key {
    NSString *path = [[NSBundle mainBundle] pathForResource:languageArray[appLanguage] ofType:@"lproj"];
    return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:@"" table:nil];
}

- (void)getUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    appLanguage = [ud integerForKey:@"appLanguage"];
	languageArray = [ud arrayForKey:@"AppleLanguages"];
    repoArray = [[ud arrayForKey:@"repoArray"] mutableCopy];
}

- (void)saveUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:appLanguage forKey:@"appLanguage"];
    [ud setObject:[repoArray copy] forKey:@"repoArray"];
    [ud synchronize];
}

- (void)checkRepo:(NSString *)repo {
    checked = NO;
    okRepo = NO;
	for (int i = 0; i < [languageArray count]; i++) {
		downloaded = NO;
		exists = NO;
		NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
		NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
		NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/%@/BMRepository/raw/master/%@.plist",repo,languageArray[i]]];
		NSURLSessionDataTask *task = [session dataTaskWithURL:requestURL
											completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
												if (!error) {
													NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
													NSLog(@"%ld",(long)statusCode);
													if (statusCode == 404) {
														exists = NO;
													} else {
														exists = YES;
													}
												} else {
													[self showError:[self BMLocalizedString:@"Your internet connection seems to be offline."]];
												}
												downloaded = YES;
											}];
		[task resume];
		while (!downloaded) {} // wait for completion of download
		if (!exists) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self showError:[NSString stringWithFormat:[self BMLocalizedString:@"%@.plist does NOT exist! Please contact the owner of this repository."],languageArray[i]]];
			});
			checked = YES;
			okRepo = NO;
			return;
		}
	}
	checked = YES;
	okRepo = YES;
}

- (void)showError:(NSString *)errorMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self BMLocalizedString:@"Error"] message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[self BMLocalizedString:@"OK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)addButtonTapped:(id)sender {
    UIAlertController *textAlert = [UIAlertController alertControllerWithTitle:[self BMLocalizedString:@"Enter Repository"]
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [textAlert addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"subdiox";
    }];
    UIAlertAction *keywordOkAction = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                NSString *textField = textAlert.textFields.firstObject.text;
                                                                BOOL sameRepo = NO;
                                                                for (int i = 0; i < [repoArray count]; i++) {
                                                                    if ([repoArray[i] isEqualToString:textField]) {
                                                                        sameRepo = YES;
                                                                    }
                                                                }
                                                                if (sameRepo) {
                                                                    [self showError:[self BMLocalizedString:@"This repository has already been registered."]];
                                                                } else {
                                                                    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                                                                    [SVProgressHUD showWithStatus:[self BMLocalizedString:@"Checking Repository..."]];
                                                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                        [self checkRepo:textField];
                                                                        while (!checked) {}
                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                            [SVProgressHUD dismiss];
                                                                            if (okRepo) {
                                                                                [repoArray insertObject:textField atIndex:[repoArray count]];
                                                                                [self.tableView reloadData];
                                                                                [self saveUserDefaults];
                                                                            }
                                                                        });
                                                                    });
                                                                }
                                                            }];

    UIAlertAction *keywordCancelAction = [UIAlertAction actionWithTitle:[self BMLocalizedString:@"Cancel"]
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
                                                                }];
    [textAlert addAction:keywordCancelAction];
    [textAlert addAction:keywordOkAction];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        textAlert.popoverPresentationController.sourceView = self.view;
        textAlert.popoverPresentationController.sourceRect = self.view.bounds;
        textAlert.popoverPresentationController.permittedArrowDirections = 0;
    }
    [self presentViewController:textAlert animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return repoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = repoArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [repoArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self saveUserDefaults];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return NO;
    } else {
        return YES;
    }
}

@end
