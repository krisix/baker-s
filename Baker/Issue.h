//
//  Issue.h
//  Baker-extd
//
//  Created by Krzysztof Wolski on 09.05.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ISSUE_DOWNLOAD_PATH_TYPE_NONE           0
#define ISSUE_DOWNLOAD_PATH_TYPE_BUNDLE         1
#define ISSUE_DOWNLOAD_PATH_TYPE_PRIVATE_DOCS   2


@class Issue;


#pragma mark - IssueDelegate

@protocol IssueDelegate

- (void)didFinishDownloadingCover:(UIImageView *)coverImageView issueIndex:(NSInteger)index;

@end


#pragma mark - Issue

@interface Issue : NSObject

#pragma mark - Properties

@property (nonatomic) NSInteger number;
@property (nonatomic,retain) NSString *numberDesc;

@property (nonatomic,retain) NSDate *releaseDate;

@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *mainTopic;

@property (nonatomic,retain) NSString *downloadUrl;

@property (nonatomic,retain) NSString *directory;

@property (nonatomic,retain) NSString *coverLocal;
@property (nonatomic,retain) NSString *coverRemote;

@property (nonatomic) BOOL downloaded;

@property (nonatomic) NSInteger downloadPathType;

@property (nonatomic) NSInteger issueIndex;

@property (nonatomic,retain) UIImageView *coverImageView;

//
// delegate
@property (nonatomic, retain) id <IssueDelegate> delegate;


#pragma mark - Public methods

- (id)initWithData:(NSDictionary *)data issueIndex:(NSInteger)index delegate:(id)del;
- (void)refreshBookStatus;


@end
