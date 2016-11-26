#import "BMAppDelegate.h"
#import "BMRootViewController.h"
#import "BMSecondViewController.h"
#import "BMThirdViewController.h"
#import "NSTask.h"

@implementation BMSecondViewController {
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

- (void)loadView {
	[super loadView];
	[self getUserDefaults];
    self.title = [self getString:modNameArray[indexPath.section][indexPath.row]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (NSString *)BMLocalizedString:(NSString *)key {
    NSString *path = [[NSBundle mainBundle] pathForResource:languageArray[appLanguage] ofType:@"lproj"];
    return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:@"" table:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [modDetailArray[indexPath.section][indexPath.row] count];
}

- (void)changeSwitch:(id)sender {
    NSIndexPath *myIndexPath = [self.tableView indexPathForCell:(UITableViewCell*)[sender superview]];
	int i = indexPath.section;
	int j = indexPath.row;
	int k = myIndexPath.row;
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on == YES) {
		[buttonArray addObject:[self getSaveID:i:j:k]];
    } else {
		[buttonArray removeObject:[self getSaveID:i:j:k]];
    }
    [self saveUserDefaults];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)myIndexPath {
	int i = indexPath.section;
	int j = indexPath.row;
	int k = myIndexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
	}
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = sw;
    [sw addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    if ([buttonArray containsObject:[self getSaveID:i:j:k]]) {
        sw.on = YES;
    } else {
        sw.on = NO;
    }
    cell.textLabel.text = [self getFullString:i:j:k];
    if ([installedArray containsObject:[self getSaveID:i:j:k]]) {
        cell.detailTextLabel.text = [self BMLocalizedString:@"Installed"];
        cell.detailTextLabel.textColor = [UIColor blueColor];
    } else {
        cell.detailTextLabel.text = [self BMLocalizedString:@"Not Installed"];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)myIndexPath {
	[self.tableView deselectRowAtIndexPath:myIndexPath animated:YES];
	BMThirdViewController *thirdViewController = [[BMThirdViewController alloc] init];

	thirdViewController.indexPath = indexPath;
	thirdViewController.myIndexPath = myIndexPath;

	thirdViewController.modalPresentationStyle = UIModalPresentationPopover;
	UIPopoverPresentationController *popController = thirdViewController.popoverPresentationController;
	popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
	popController.delegate = self;
	popController.sourceView = self.view;

	CGRect rectOfCellInTableView = [self.tableView rectForRowAtIndexPath:myIndexPath];
	popController.sourceRect = CGRectMake(30, rectOfCellInTableView.origin.y, 50, 50);

	[self presentViewController:thirdViewController animated:YES completion:nil];

}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
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

// save NSUserDefaults
- (void)saveUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:appLanguage forKey:@"appLanguage"];
	[ud setObject:languageArray forKey:@"AppleLanguages"];
    [ud setObject:[repoArray copy] forKey:@"repoArray"];
    [ud setInteger:currentRepo forKey:@"currentRepo"];
	[ud setObject:[buttonArray copy] forKey:@"buttonArray"];
	[ud setObject:[installedArray copy] forKey:@"installedArray"];
	[ud setObject:[modCategoryArray copy] forKey:@"modCategoryArray"];
	[ud setObject:[modNameArray copy] forKey:@"modNameArray"];
	[ud setObject:[modDetailArray copy] forKey:@"modDetailArray"];
    [ud synchronize];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self saveUserDefaults];
	[super viewWillDisappear:animated];
}

@end
