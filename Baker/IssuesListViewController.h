//
//  IssuesListViewController.h
//  Baker
//
//  Created by Krzysztof Wolski on 13.03.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Downloader.h"
#import "Issue.h"
#import "IssuesManager.h"
#import "PageControl.h"

@class IssuesListViewController;

@protocol IssuesListViewControllerDelegate <NSObject>

- (void)didSelectedIssue:(NSInteger)issueNumber;

@end

@interface IssuesListViewController : UIViewController <UIScrollViewDelegate, IssuesManagerDelegate> {
    
    //
    // ui controls
    UIScrollView    *issuesScrollView;
    PageControl     *pageControl;
    
    // 
    // issues numbers
    NSInteger       issuesNumber;
    
    //
    // issues manager
    IssuesManager *issuesManager;
    
}


@property (nonatomic,retain) id <IssuesListViewControllerDelegate> delegate;


- (id)initWithIssuesList; 
- (void)refreshCurrentMagazine:(NSInteger)currentIssueIndex;


@end
