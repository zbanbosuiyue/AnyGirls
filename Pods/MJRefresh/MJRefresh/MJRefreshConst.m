//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
#import <UIKit/UIKit.h>

const CGFloat MJRefreshHeaderHeight = 54.0;
const CGFloat MJRefreshFooterHeight = 44.0;
const CGFloat MJRefreshFastAnimationDuration = 0.25;
const CGFloat MJRefreshSlowAnimationDuration = 0.4;

NSString *const MJRefreshKeyPathContentOffset = @"contentOffset";
NSString *const MJRefreshKeyPathContentInset = @"contentInset";
NSString *const MJRefreshKeyPathContentSize = @"contentSize";
NSString *const MJRefreshKeyPathPanState = @"state";

NSString *const MJRefreshHeaderLastUpdatedTimeKey = @"MJRefreshHeaderLastUpdatedTimeKey";

NSString *const MJRefreshHeaderIdleText = @"Let Go to Refresh";
NSString *const MJRefreshHeaderPullingText = @"Let Go to Refresh";
NSString *const MJRefreshHeaderRefreshingText = @"Refreshing...";

NSString *const MJRefreshAutoFooterIdleText = @"点击或上拉加载更多";
NSString *const MJRefreshAutoFooterRefreshingText = @"Refreshing...";
NSString *const MJRefreshAutoFooterNoMoreDataText = @"Finished";

NSString *const MJRefreshBackFooterIdleText = @"上拉可以加载更多";
NSString *const MJRefreshBackFooterPullingText = @"Let Go to Refresh";
NSString *const MJRefreshBackFooterRefreshingText = @"Refreshing...";
NSString *const MJRefreshBackFooterNoMoreDataText = @"Finished";