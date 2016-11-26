@interface BMProcessViewController : UIViewController <NSURLSessionDelegate>
@property (strong, nonatomic) NSMutableArray *removeQueueArray;
@property (strong, nonatomic) NSMutableArray *installQueueArray;
@end
