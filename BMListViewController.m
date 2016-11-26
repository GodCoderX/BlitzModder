#import <QuartzCore/QuartzCore.h>
#import "BMRootViewController.h"
#import "BMListViewController.h"

@implementation BMListViewController {
    NSMutableArray *repoArray;
    NSInteger appLanguage;
    NSInteger currentRepo;
    NSArray *languageArray;
}

- (void)loadView {
    [super loadView];
    [self getUserDefaults];
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.allowsMultipleSelection = NO;
    self.title = [self BMLocalizedString:@"Select repository to show"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:[self BMLocalizedString:@"Done"]
                                              style:UIBarButtonItemStyleDone
                                              target:self
                                              action:@selector(doneButtonTapped:)
                                              ];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRepo inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)doneButtonTapped:(id)sender {
    [self saveUserDefaults];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [repoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = repoArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (indexPath.row == i) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            currentRepo = indexPath.row;
            [self saveUserDefaults];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
