//
//  Issue.m
//  Baker-extd
//
//  Created by Krzysztof Wolski on 09.05.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Issue.h"

@implementation Issue

@synthesize number,
    numberDesc,
    releaseDate,
    title,
    mainTopic,
    downloadUrl,
    directory,
    coverLocal,
    coverRemote,
    downloaded,
    downloadPathType,
    issueIndex,
    coverImageView,
    delegate
    ;


- (void) didFinishDownloadingImageCover:(UIImageView *)tCoverImageView {
    
    NSLog(@" >>> testing separate threads for image cover %@", [self coverRemote]);
    
    coverImageView = [[UIImageView alloc] initWithImage:[tCoverImageView image]];
    
    [delegate didFinishDownloadingCover:tCoverImageView issueIndex:[self issueIndex]];
    
}


- (void) downloadCoverImage:(NSDictionary *)threadParams {
    
    //
    // separate thread for downloading cover image
    //         NSDictionary *threadParams = [[NSDictionary alloc] 
    // initWithObjects:[NSArray arrayWithObjects:[self coverRemote], [self coverLocal], [self directory], privateDocsPath, documentsCoverPath, nil] 
    // forKeys:[NSArray arrayWithObjects:@"coverRemote", @"coverLocal", @"directory", @"privateDocsPath", @"documentsCoverPath", nil]];    
    //
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *tCoverRemote = (NSString *)[threadParams objectForKey:@"coverRemote"];
    NSString *tCoverLocal = (NSString *)[threadParams objectForKey:@"coverLocal"];
    NSString *tDirectory = (NSString *)[threadParams objectForKey:@"directory"];
    NSString *tPrivateDocsPath = (NSString *)[threadParams objectForKey:@"privateDocsPath"];
    NSString *tDocumentsCoverPath = (NSString *)[threadParams objectForKey:@"documentsCoverPath"];
    
    UIImageView *tCoverImageView;

    NSError *requestError = nil;
    NSHTTPURLResponse *urlResponse = nil;
    
    NSURL *url = [[NSURL URLWithString:tCoverRemote] retain];
    NSData *data = [[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:&urlResponse error:&requestError] retain];
    
    BOOL coverImageFound = NO;
    
    if (urlResponse != nil) {
        
        if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300) {
            
            //
            // destination directory
            NSString *dstDirectoryIssuePath = [[NSString stringWithFormat:@"%@/%@", tPrivateDocsPath, tDirectory] retain];
            //
            // destination cover image file
            NSString *dstCoverIssuePath = [[NSString stringWithFormat:@"%@/%@", tPrivateDocsPath, tCoverLocal] retain];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:dstDirectoryIssuePath]) {
                
                //
                // create directory if doesn't exist
                [[NSFileManager defaultManager] createDirectoryAtPath:dstDirectoryIssuePath withIntermediateDirectories:YES attributes:nil error:nil];
                
            }
            
            //
            // write image data
            [data writeToFile:dstCoverIssuePath atomically:NO];
            
            NSLog(@" >>> dstDirectoryIssuesPath: %@", dstDirectoryIssuePath);
            NSLog(@" >>> dstCoverIssuePath: %@", dstCoverIssuePath);
            
            tCoverImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:tDocumentsCoverPath]];
            
            [dstCoverIssuePath release];
            [dstDirectoryIssuePath release];
            
            coverImageFound = YES;
            
        }
        else if ([urlResponse statusCode] == 404) {
            
            NSLog(@" >>> File %@ doesn't exist on the server.", url);
            
        }
        else if ([urlResponse statusCode] == 403) {
            
            NSLog(@" >>> Access to %@ denied.", url);
            
        }
        else {
            
            NSLog(@" >>> Status code when downloading %@: %d", url, [urlResponse statusCode]);
            
        }
        
    }
    else {
        
        NSLog(@" >>> Request error when downloading %@: %d", url, [requestError code]);
        
    }

//    [data release];
//    [url release];
    
    if (!coverImageFound) {
        
        //
        // cover image not found 
        // load replacement cover image
        
        NSString *bundleReplacementCoverPath        = [[[NSBundle mainBundle] pathForResource:@"cover-not-found.png" ofType:nil] retain];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:bundleReplacementCoverPath]) {
            
            tCoverImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:bundleReplacementCoverPath]];
            
        }
        
        [bundleReplacementCoverPath release];
        
    }

    //[NSThread sleepForTimeInterval:15];
    
    [self performSelectorOnMainThread:@selector(didFinishDownloadingImageCover:) withObject:tCoverImageView waitUntilDone:NO];
    
    [pool release];
    
}


- (void)checkCoverImageView {
    
    NSString *privateDocsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Private Documents"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:privateDocsPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:privateDocsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *bundleCoverPath        = [[[NSBundle mainBundle] pathForResource:[self coverLocal] ofType:nil] retain];
    NSString *documentsCoverPath     = [[privateDocsPath stringByAppendingPathComponent:[self coverLocal]] retain];

    if ([[NSFileManager defaultManager] fileExistsAtPath:bundleCoverPath]) {
        
        coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:bundleCoverPath]];
        
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:documentsCoverPath]) {
        
        NSLog(@" >>> documentsCoverPath: %@", documentsCoverPath);
        
        coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:documentsCoverPath]];                        
        
    }
    else {
        
        //
        // download from URL
        
        NSLog(@" >>> Cover image doesn't exist - downloading... %@", [self coverRemote]);
        
        coverImageView = [[UIImageView alloc] init];

        //
        // testing separate threads
        NSDictionary *threadParams = [[NSDictionary alloc] 
                                      initWithObjects:[NSArray arrayWithObjects:[self coverRemote], [self coverLocal], [self directory], privateDocsPath, documentsCoverPath, nil] 
                                      forKeys:[NSArray arrayWithObjects:@"coverRemote", @"coverLocal", @"directory", @"privateDocsPath", @"documentsCoverPath", nil]];    
        
        NSThread *downloadCoverImage = [[NSThread alloc] initWithTarget:self selector:@selector(downloadCoverImage:) object:threadParams];
        [downloadCoverImage start];
        
        /**
         * moved to separate thread

        NSError *requestError = nil;
        NSHTTPURLResponse *urlResponse = nil;
        
        NSURL *url = [[NSURL URLWithString:[self coverRemote]] retain];
        NSData *data = [[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:&urlResponse error:&requestError] retain];
        
        BOOL coverImageFound = NO;
        
        if (urlResponse != nil) {
            
            if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300) {

                //
                // destination directory
                NSString *dstDirectoryIssuePath = [[NSString stringWithFormat:@"%@/%@", privateDocsPath, [self directory]] retain];
                //
                // destination cover image file
                NSString *dstCoverIssuePath = [[NSString stringWithFormat:@"%@/%@", privateDocsPath, [self coverLocal]] retain];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:dstDirectoryIssuePath]) {
                    
                    //
                    // create directory if doesn't exist
                    [[NSFileManager defaultManager] createDirectoryAtPath:dstDirectoryIssuePath withIntermediateDirectories:YES attributes:nil error:nil];
                    
                }
                
                //
                // write image data
                [data writeToFile:dstCoverIssuePath atomically:NO];
                
                NSLog(@" >>> dstDirectoryIssuesPath: %@", dstDirectoryIssuePath);
                NSLog(@" >>> dstCoverIssuePath: %@", dstCoverIssuePath);
                
                [data release];
                [url release];
                
                coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:documentsCoverPath]];
                
                [dstCoverIssuePath release];
                [dstDirectoryIssuePath release];
                
                coverImageFound = YES;

            }
            else if ([urlResponse statusCode] == 404) {
                
                NSLog(@" >>> File %@ doesn't exist on the server.", url);
                
            }
            else if ([urlResponse statusCode] == 403) {
                
                NSLog(@" >>> Access to %@ denied.", url);
                
            }
            else {
                
                NSLog(@" >>> Status code when downloading %@: %d", url, [urlResponse statusCode]);
                
            }
            
        }
        else {
            
            NSLog(@" >>> Request error when downloading %@: %d", url, [requestError code]);
            
        }
        
        if (!coverImageFound) {
            
            //
            // cover image not found 
            // load replacement cover image
            
            NSString *bundleReplacementCoverPath        = [[[NSBundle mainBundle] pathForResource:@"gfx/cover-not-found.png" ofType:nil] retain];
 
            if ([[NSFileManager defaultManager] fileExistsAtPath:bundleReplacementCoverPath]) {
                
                coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:bundleReplacementCoverPath]];
                
            }
            
            [bundleReplacementCoverPath release];

        }
        
         * moved to separate thread
         *
         */
       
    }
    
}


//
// initialize new object based on data from NSDictionary
//
- (id)initWithData:(NSDictionary *)data issueIndex:(NSInteger)index delegate:(id)del {
    
    self = [super init];
    
    if (self) {
        
        [self setDelegate:del];

        [self setNumber:(NSInteger)[data objectForKey:@"issue-number"]];
        [self setNumberDesc:(NSString *)[data objectForKey:@"issue-number-desc"]];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        [self setReleaseDate:[df dateFromString:(NSString *)[data objectForKey:@"release-date"]]];
        
        [self setTitle:(NSString *)[data objectForKey:@"title"]];
        [self setMainTopic:(NSString *)[data objectForKey:@"main-topic"]];

        [self setDownloadUrl:(NSString *)[data objectForKey:@"download-url"]];

        [self setDirectory:(NSString *)[data objectForKey:@"directory"]];

        [self setCoverLocal:(NSString *)[data objectForKey:@"cover-local"]];
        [self setCoverRemote:(NSString *)[data objectForKey:@"cover-remote"]];
        
        [self setIssueIndex:index];
        
        //
        // check cover image and download it if needed
        [self checkCoverImageView];

        //
        // check if book is downloaded
        [self refreshBookStatus];
        

    }

    return self;
    
}   // initWithData


- (void)refreshBookStatus {
    
    //
    // refresh book status
    //

    NSString *privateDocsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Private Documents"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:privateDocsPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:privateDocsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *privateBookPath = [[privateDocsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/book.json", [self directory]]] retain];
    NSString *bundleBookPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@/book.json", [self directory]] ofType:nil];
    
    if (bundleBookPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:bundleBookPath]) {
        
        // 
        // book exists at bundle book path
        
        [self setDownloaded:YES];
        [self setDownloadPathType:ISSUE_DOWNLOAD_PATH_TYPE_BUNDLE];
        
    }
    else if (privateDocsPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:privateBookPath]) {
        
        //
        // book exists at private documents
        
        [self setDownloaded:YES];
        [self setDownloadPathType:ISSUE_DOWNLOAD_PATH_TYPE_PRIVATE_DOCS];
        
    }
    else {
        
        //
        // book is not downloaded
        
        [self setDownloaded:NO];
        [self setDownloadPathType:ISSUE_DOWNLOAD_PATH_TYPE_NONE];
        
    }

}


@end
