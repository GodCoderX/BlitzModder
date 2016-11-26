#import <QuartzCore/QuartzCore.h>
#import "BMRootViewController.h"
#import "BMProcessViewController.h"
#import "BMConfirmationViewController.h"

@interface BMConfirmationViewController()
@end

@implementation BMConfirmationViewController {
    int appLanguage;
	int currentRepo;
	NSString *removeList;
	NSString *installList;
	NSArray *languageArray;
    NSMutableArray *repoArray;
	NSMutableArray *modNameArray;
	NSMutableArray *modDetailArray;
	NSMutableArray *modCategoryArray;
	NSMutableArray *buttonArray;
	NSMutableArray *installedArray;
}

@synthesize removeQueueArray;
@synthesize installQueueArray;

- (void)loadView {
	[super loadView];
    [self getUserDefaults];
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];

	for (int l = 0; l < removeQueueArray.count; l++) {
		int i = [removeQueueArray[l][0] intValue];
		int j = [removeQueueArray[l][1] intValue];
		int k = [removeQueueArray[l][2] intValue];
		if (l == 0) {
			removeList = [[NSString alloc] initWithString:[self getFullString:i:j:k]];
		} else {
			removeList = [NSString stringWithFormat:@"%@\n%@",removeList,[self getFullString:i:j:k]];
		}
	}
	for (int l = 0; l < installQueueArray.count; l++) {
		int i = [installQueueArray[l][0] intValue];
		int j = [installQueueArray[l][1] intValue];
		int k = [installQueueArray[l][2] intValue];
		if (l == 0) {
			installList = [[NSString alloc] initWithString:[self getFullString:i:j:k]];
		} else {
			installList = [NSString stringWithFormat:@"%@\n%@",installList,[self getFullString:i:j:k]];
		}
	}

    self.tableView.allowsMultipleSelection = NO;
    self.title = [self BMLocalizedString:@"Confirm"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.hidesBackButton = YES;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self BMLocalizedString:@"Cancel"] style:UIBarButtonItemStyleDone target:self action:@selector(backToRootView:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self BMLocalizedString:@"Confirm"] style:UIBarButtonItemStyleDone target:self action:@selector(confirmButtonTapped:)];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:appLanguage inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (NSString *)BMLocalizedString:(NSString *)key {
    NSString *path = [[NSBundle mainBundle] pathForResource:languageArray[appLanguage] ofType:@"lproj"];
    return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:@"" table:nil];
}

- (void)backToRootView:(id)sender {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;

    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)confirmButtonTapped:(id)sender {
	BMProcessViewController *processViewController = [[BMProcessViewController alloc] init];

	processViewController.removeQueueArray = removeQueueArray;
	processViewController.installQueueArray = installQueueArray;

	CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;

    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:processViewController animated:NO];
}

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (removeQueueArray.count == 0) {
		return 1;
	} else if (installQueueArray.count == 0) {
		return 1;
	} else {
		return 2;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self BMLocalizedString:@"Queue"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"MultilineCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	cell.detailTextLabel.numberOfLines = 0;
	if (removeQueueArray.count == 0) {
		cell.textLabel.text = [self BMLocalizedString:@"Install"];
		cell.detailTextLabel.text = installList;
	} else if (installQueueArray.count == 0) {
		cell.textLabel.text = [self BMLocalizedString:@"Remove"];
		cell.detailTextLabel.text = removeList;
	} else {
		if (indexPath.row == 0) {
			cell.textLabel.text = [self BMLocalizedString:@"Remove"];
			cell.detailTextLabel.text = removeList;
		} else if (indexPath.row == 1) {
			cell.textLabel.text = [self BMLocalizedString:@"Install"];
			cell.detailTextLabel.text = installList;
		}
	}
	return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
	UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
	CGSize bounds = CGSizeMake(self.tableView.frame.size.width - 30.0, CGFLOAT_MAX);
	CGSize detailSize = [cell.detailTextLabel.text sizeWithFont: cell.detailTextLabel.font
                                                constrainedToSize: bounds
                                                lineBreakMode:NSLineBreakByClipping];
    return detailSize.height + 25.0;
}

- (NSString *)getFullString:(int)i :(int)j :(int)k {
	return [self getString:modDetailArray[i][j][k]];
}

- (NSString *)getFullID:(int)i :(int)j :(int)k {
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

@end
