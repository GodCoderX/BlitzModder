#import <QuartzCore/QuartzCore.h>
#import "BMRootViewController.h"
#import "BMProcessViewController.h"
#import "NSTask.h"

@implementation BMProcessViewController {
    bool success;
    bool downloadFinished;
    int currentRepo;
    int appLanguage;
	NSString *blitzPath;
	NSString *savePath;
    NSArray *languageArray;
    NSMutableArray *repoArray;
	NSMutableArray *modCategoryArray;
	NSMutableArray *modNameArray;
	NSMutableArray *modDetailArray;
	NSMutableArray *buttonArray;
	NSMutableArray *installedArray;
	UITextView *logView;
	UIButton *btn;
	UIProgressView *progressView;
}

@synthesize removeQueueArray;
@synthesize installQueueArray;

- (void)loadView {
	[super loadView];
    [self getUserDefaults];
    success = 1;
    self.title = [self BMLocalizedString:@"Running"];
    self.navigationItem.hidesBackButton = YES;

	savePath = @"/var/root/Library/Caches/BlitzModder";

    NSTextStorage *textStorage = [NSTextStorage new];
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
    [textStorage addLayoutManager:layoutManager];
    [layoutManager addTextContainer:textContainer];

	CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenRatioWidth = screenRect.size.width / 320;
    CGFloat screenRatioHeight = screenRect.size.height / 568;

    CGFloat padding_w = screenRatioWidth * 20;
    CGFloat padding_h = screenRatioHeight * 20;

    CGFloat viewLabelWidth = (self.view.frame.size.width - padding_w * 2);
    CGFloat viewLabelHeight = (self.view.frame.size.height - padding_h);

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(padding_w,padding_h,viewLabelWidth,viewLabelHeight - padding_h * 4)];
    textView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    textView.textColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize:13];
    textView.editable = NO;
    textView.layer.cornerRadius = 10.0f;
    [self.view addSubview:textView];
    logView = textView;

    btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    btn.tintColor = [UIColor whiteColor];
	btn.titleLabel.font = [UIFont systemFontOfSize:20];
    btn.frame = CGRectMake(padding_w, viewLabelHeight - padding_h * 3, viewLabelWidth, padding_h * 4);
    btn.hidden = YES;
    [btn setTitle:[self BMLocalizedString:@"Return to Mod List"] forState:UIControlStateNormal];
    [btn setTitle:[self BMLocalizedString:@"Return to Mod List"] forState:UIControlStateHighlighted];
    [btn setTitle:[self BMLocalizedString:@"Return to Mod List"] forState:UIControlStateDisabled];
    [btn addTarget:self action:@selector(backToRootView:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn];

	progressView = [[UIProgressView alloc] init];
	progressView.frame = CGRectMake(padding_w * 2, viewLabelHeight - padding_h, viewLabelWidth - padding_w * 2, padding_h);
	progressView.hidden = YES;
	[self.view addSubview:progressView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:NO];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    	[self startProcess];
	});
}

- (NSString *)BMLocalizedString:(NSString *)key {
    NSString *path = [[NSBundle mainBundle] pathForResource:languageArray[appLanguage] ofType:@"lproj"];
    return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:@"" table:nil];
}

- (void)backToRootView:(id)sender {
	BMRootViewController *rootViewController = [[BMRootViewController alloc] init];
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;

    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:rootViewController animated:NO];
}

- (void)startProcess {
	success = YES;
	progressView.hidden = NO;
    for (int l = 0; l < removeQueueArray.count; l++) {
        int i = [removeQueueArray[l][0] intValue];
        int j = [removeQueueArray[l][1] intValue];
        int k = [removeQueueArray[l][2] intValue];
        downloadFinished = NO;
        [self downloadData:i:j:k:@"Remove"];
        while (!downloadFinished) {}
        if (success) {
            [self installData:i:j:k:@"Remove"];
        }
        success = YES;
    }
    for (int l = 0; l < installQueueArray.count; l++) {
        int i = [installQueueArray[l][0] intValue];
        int j = [installQueueArray[l][1] intValue];
        int k = [installQueueArray[l][2] intValue];
        downloadFinished = NO;
        [self downloadData:i:j:k:@"Install"];
        while (!downloadFinished) {}
        if (success) {
            [self installData:i:j:k:@"Install"];
        }
        success = YES;
    }
	if ([NSThread isMainThread]) {
		progressView.hidden = YES;
    	btn.hidden = NO;
    } else {
    	dispatch_async(dispatch_get_main_queue(), ^{
			progressView.hidden = YES;
			btn.hidden = NO;
    	});
    }
}

- (void)downloadData: (int)i : (int)j : (int)k : (NSString *)installation {
    if ([installation isEqualToString:@"Install"]) {
        [self writeTextView:[NSString stringWithFormat:[self BMLocalizedString:@"Downloading %@..."],[self getFullID:i:j:k]]];
        [self download:[NSString stringWithFormat:@"https://github.com/%@/BMRepository/raw/iOS/Install/%@.zip",repoArray[currentRepo],[self getFullID:i:j:k]]];
        while (!downloadFinished) {}
        if (success) {
            [self writeTextView:[NSString stringWithFormat:@"%@\n",[self BMLocalizedString:@"Done"]]];
        }
    } else if ([installation isEqualToString:@"Remove"]) {
        [self writeTextView:[NSString stringWithFormat:[self BMLocalizedString:@"Downloading the removal data of %@..."],[self getFullID:i:j:k]]];
        [self download:[NSString stringWithFormat:@"https://github.com/%@/BMRepository/raw/iOS/Remove/%@.zip",repoArray[currentRepo],[self getFullID:i:j:k]]];
        while (!downloadFinished) {}
        if (success) {
            [self writeTextView:[NSString stringWithFormat:@"%@\n",[self BMLocalizedString:@"Done"]]];
        }
    }
}

- (void)download:(NSString *)urlString {
    downloadFinished = NO;
    NSURL *requestURL = [NSURL URLWithString:urlString];
	NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
	sessionConfiguration.timeoutIntervalForRequest = 30;
	NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:requestURL];
    [task resume];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    progressView.progress = 0;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    double percent = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    progressView.progress = percent;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    progressView.progress = 1.0;
	NSData *data = [NSData dataWithContentsOfURL:location];
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm createFileAtPath:[NSString stringWithFormat:@"%@/Data.zip",savePath] contents:data attributes:nil];
	NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:[NSString stringWithFormat:@"%@/Data.zip",savePath]];
	[file writeData:data];
	success = YES;
	downloadFinished = YES;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                 didReceiveResponse:(NSURLResponse *)response
                                  completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
	NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
	if (statusCode == 200) {
		completionHandler(NSURLSessionResponseAllow);
	} else if (statusCode == 404) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self writeTextView:[self BMLocalizedString:@"File Not Found(404)! Please contact the owner of this repository.\n"]];
		});
		success = NO;
		downloadFinished = YES;
		completionHandler(NSURLSessionResponseCancel);
	} else {
		completionHandler(NSURLSessionResponseCancel);
	}
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
	[session invalidateAndCancel];
	if (error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self writeTextView:[NSString stringWithFormat:@"\nError: %@\n",[error localizedDescription]]];
		});
		success = NO;
		downloadFinished = YES;
	}
}

- (void)installData: (int)i : (int)j : (int)k : (NSString *)installation {
	success = YES;
    if ([installation isEqualToString:@"Install"]) {
        [self writeTextView:[NSString stringWithFormat:[self BMLocalizedString:@"Installing %@..."],[self getFullID:i:j:k]]];
        [self install];
        if (success) {
			[installedArray addObject:[self getSaveID:i:j:k]];
            [self saveUserDefaults];
            [self writeTextView:[NSString stringWithFormat:@"%@\n",[self BMLocalizedString:@"Done"]]];
        }
        success = YES;
    } else if ([installation isEqualToString:@"Remove"]) {
        [self writeTextView:[NSString stringWithFormat:[self BMLocalizedString:@"Removing %@..."],[self getFullID:i:j:k]]];
        [self install];
        if (success) {
			[installedArray removeObject:[self getSaveID:i:j:k]];
            [self saveUserDefaults];
            [self writeTextView:[NSString stringWithFormat:@"%@\n",[self BMLocalizedString:@"Done"]]];
        }
        success = YES;
    }
}

- (void)install {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSPipe *errPipe = [NSPipe pipe];
    [task setStandardError:errPipe];
    [task setLaunchPath: @"/bin/sh"];
    NSString *commandString = [NSString stringWithFormat:@"unzip -o %@/Data.zip -d %@ && cp -rf %@/Data -T %@/Data && rm -rf %@/Data %@/Data.zip",savePath,savePath,savePath,blitzPath,savePath,savePath];
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
        success = NO;
        NSString *strErr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        strErr = [NSString stringWithFormat:@"%@\n",strErr];
        [self writeTextView:strErr];
    }
}

- (void)writeTextView:(NSString *)log {
    if ([NSThread isMainThread]) {
    	NSString *string = [logView.text stringByAppendingFormat:@"%@",log];
		if (3000 < string.length) {
        	string = [string substringFromIndex:string.length - 3000];
    	}
    	logView.text = string;
    	NSRange r = NSMakeRange(string.length, 0);
    	logView.selectedRange = r;
    	[logView scrollRangeToVisible:r];
    } else {
    	dispatch_async(dispatch_get_main_queue(), ^{
			NSString *string = [logView.text stringByAppendingFormat:@"%@",log];
			if (3000 < string.length) {
				string = [string substringFromIndex:string.length - 3000];
    		}
    		logView.text = string;
    		NSRange r = NSMakeRange(string.length, 0);
    		logView.selectedRange = r;
    		[logView scrollRangeToVisible:r];
    	});
    }
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

- (NSString *)getFullString:(int)i :(int)j :(int)k {
	return [self getString:modDetailArray[i][j][k]];
}

- (NSString *)getFullID:(int)i :(int)j :(int)k {
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

@end
