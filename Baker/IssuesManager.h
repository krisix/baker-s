//
//  IssuesManager.h
//  Baker-extd
//
//  Created by Krzysztof Wolski on 04.06.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//
//  Read & downloaded issues.json file


#import <Foundation/Foundation.h>

#import "Issue.h"
#import "JSONKit.h"


@class IssuesManager;


@protocol IssuesManagerDelegate

- (void)issuesManagerDidDownload;
- (void)refreshCoverImage:(UIImageView *)coverImageView issueIndex:(NSInteger)index;

@end


@interface IssuesManager : NSObject <IssueDelegate> {
    
}


//
// issue list
@property (nonatomic, retain) NSMutableArray *issuesList;
//
// delegate
@property (nonatomic, retain) id <IssuesManagerDelegate> delegate;

- (id)init;

- (BOOL)isThreadWorking;


@end
