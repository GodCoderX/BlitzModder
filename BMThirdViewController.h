#import <WebKit/WebKit.h>
@interface BMThirdViewController : UIViewController <WKUIDelegate,WKNavigationDelegate>
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSIndexPath *myIndexPath;
@end
