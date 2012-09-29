//
//  IssuesManager.m
//  Baker-extd
//
//  Created by Krzysztof Wolski on 04.06.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "IssuesManager.h"

@implementation IssuesManager


@synthesize issuesList,
    delegate;


//
// bundle path to issues.json
NSString *bundleIssuesJSONfilename;
//
// private docs path
NSString *privateDocsPath;
//
// private docs path to issues.json
NSString *privateIssuesJSONfilename;
//
// thread for downloading issues.json
NSThread *downloadIssueThread;


- (void)refreshIssuesJson {
    
    //
    // read content of issues.json
    //
    
    //
    // check where file exists - priority for private docs path
    NSString *fileJSON;
    if ([[NSFileManager defaultManager] fileExistsAtPath:privateIssuesJSONfilename])
        fileJSON = [NSString stringWithContentsOfFile:privateIssuesJSONfilename encoding:NSUTF8StringEncoding error:nil];
    else 
        fileJSON = [NSString stringWithContentsOfFile:bundleIssuesJSONfilename encoding:NSUTF8StringEncoding error:nil];
    
    //
    // start parsing issues.json
    NSDictionary *ret = nil;
    NSError *err = nil;
    
    ret = [fileJSON objectFromJSONStringWithParseOptions:JKParseOptionNone error:&err];
    if ([err userInfo] == nil) {
        
        //
        // check if there is info about last change date
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *lastUpdateDateLocal;
        NSString *lastUpdateLocal = (NSString *)[ret objectForKey:@"issues-last-update-date"];
        
        if (lastUpdateLocal != nil) {
            
            lastUpdateDateLocal = [dateFormat dateFromString:lastUpdateLocal];
            
        }
        
        //
        // check if there is info about remote issues.json file
        NSString *remoteIssuesJSONUrl = (NSString *)[ret objectForKey:@"issues-remote-url"];
        if (remoteIssuesJSONUrl != nil) {
            
            //
            // try to download remote issues.json
            NSError *requestError;
            NSHTTPURLResponse *urlResponse = nil;
            
            NSURL *url = [[NSURL URLWithString:remoteIssuesJSONUrl] retain];
            NSData *data = [[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:&urlResponse error:&requestError] retain];
            
            if (urlResponse != nil) {
                
                if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300) {
                    
                    //
                    // file downloaded ok - start parsing
                    NSString *remoteIssuesJSONContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@" >>> remoteIssuesJSONContent: %@", remoteIssuesJSONContent);
                    
                    NSDictionary *jsonContent = nil;
                    NSError *jsonErr = nil;
                    
                    jsonContent = [remoteIssuesJSONContent objectFromJSONStringWithParseOptions:JKParseOptionNone error:&jsonErr];
                    if ([jsonErr userInfo] == nil) {
                        
                        NSDate *lastUpdateDateRemote;
                        NSString *lastUpdateRemote = (NSString *)[jsonContent objectForKey:@"issues-last-update-date"];
                        
                        if (lastUpdateRemote != nil) {
                            
                            lastUpdateDateRemote = [dateFormat dateFromString:lastUpdateRemote];
                            
                            if ([lastUpdateDateRemote compare:lastUpdateDateLocal] == NSOrderedSame) {
                                
                                //
                                // it is the same date
                                
                                NSLog(@" >>> it is the same date");
                                
                            }
                            else if ([lastUpdateDateRemote compare:lastUpdateDateLocal] == NSOrderedDescending) {
                                
                                //
                                // downloaded file is newer
                                // save file to local folder
                                
                                NSLog(@" >>> downloaded file is newer");
                                
                                [data writeToFile:privateIssuesJSONfilename atomically:NO];                                
                                
                            }
                            else {
                                
                                //
                                // downloaded file is older
                                
                                NSLog(@" >>> downloaded file is older");
                                
                            }
                            
                        }
                        
                    }
                    else {
                        
                        NSLog(@" >>> errors when parsing remote downloaded issues.json");
                        
                    }
                    
                }
                else if ([urlResponse statusCode] == 404) {
                    
                    NSLog(@" >>> File issues.json doesn't exist on the server.");
                    
                }
                else if ([urlResponse statusCode] == 403) {
                    
                    NSLog(@" >>> Access to issues.json denied.");
                    
                }
                else {
                    
                    NSLog(@" >>> HTTP error code when downloading issues.json: %d", [urlResponse statusCode]);
                    
                }
                
            }
            else {
                
                NSLog(@" >>> Request error when downloading issues.json: %d", [requestError code]);
                
            }
            
        }
        
        //        [lastUpdateLocal release];
        //        [lastUpdateDateLocal release];
        [dateFormat release];
        
    }
    else {
        
        NSLog(@" >>> error while reading issues.json");
        
    }
    
    NSLog(@" >>> issuesJSONfilename: %@, fileJSON: %@", bundleIssuesJSONfilename, fileJSON);
    
}


- (void)refreshIssuesJsonTest:(NSArray *)paths {
    
    //
    // read content of issues.json
    //
    
    NSString *privateIssuesJSONfilename2 = (NSString *)[paths objectAtIndex:1];
    NSString *bundleIssuesJSONfilename2 = (NSString *)[paths objectAtIndex:0];
    //NSString *privateDocsPath2 = (NSString *)[paths objectAtIndex:2];
    
    //
    // check where file exists - priority for private docs path
    NSString *fileJSON;
    if ([[NSFileManager defaultManager] fileExistsAtPath:privateIssuesJSONfilename2])
        fileJSON = [NSString stringWithContentsOfFile:privateIssuesJSONfilename2 encoding:NSUTF8StringEncoding error:nil];
    else 
        fileJSON = [NSString stringWithContentsOfFile:bundleIssuesJSONfilename2 encoding:NSUTF8StringEncoding error:nil];
    
    //
    // start parsing issues.json
    NSDictionary *ret = nil;
    NSError *err = nil;
    
    ret = [fileJSON objectFromJSONStringWithParseOptions:JKParseOptionNone error:&err];
    if ([err userInfo] == nil) {
        
        //
        // check if there is info about last change date
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *lastUpdateDateLocal;
        NSString *lastUpdateLocal = (NSString *)[ret objectForKey:@"issues-last-update-date"];
        
        if (lastUpdateLocal != nil) {
            
            lastUpdateDateLocal = [dateFormat dateFromString:lastUpdateLocal];
            
        }
        
        //
        // check if there is info about remote issues.json file
        NSString *remoteIssuesJSONUrl = (NSString *)[ret objectForKey:@"issues-remote-url"];
        if (remoteIssuesJSONUrl != nil) {
            
            //
            // try to download remote issues.json
            NSError *requestError;
            NSHTTPURLResponse *urlResponse = nil;
            
            NSURL *url = [[NSURL URLWithString:remoteIssuesJSONUrl] retain];
            NSData *data = [[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:&urlResponse error:&requestError] retain];
            
            if (urlResponse != nil) {
                
                if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300) {
                    
                    //
                    // file downloaded ok - start parsing
                    NSString *remoteIssuesJSONContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@" >>> remoteIssuesJSONContent: %@", remoteIssuesJSONContent);
                    
                    NSDictionary *jsonContent = nil;
                    NSError *jsonErr = nil;
                    
                    jsonContent = [remoteIssuesJSONContent objectFromJSONStringWithParseOptions:JKParseOptionNone error:&jsonErr];
                    if ([jsonErr userInfo] == nil) {
                        
                        NSDate *lastUpdateDateRemote;
                        NSString *lastUpdateRemote = (NSString *)[jsonContent objectForKey:@"issues-last-update-date"];
                        
                        if (lastUpdateRemote != nil) {
                            
                            lastUpdateDateRemote = [dateFormat dateFromString:lastUpdateRemote];
                            
                            if ([lastUpdateDateRemote compare:lastUpdateDateLocal] == NSOrderedSame) {
                                
                                //
                                // it is the same date
                                
                                NSLog(@" >>> it is the same date");
                                
                            }
                            else if ([lastUpdateDateRemote compare:lastUpdateDateLocal] == NSOrderedDescending) {
                                
                                //
                                // downloaded file is newer
                                // save file to local folder
                                
                                NSLog(@" >>> downloaded file is newer");
                                
                                [data writeToFile:privateIssuesJSONfilename2 atomically:NO];                                
                                
                            }
                            else {
                                
                                //
                                // downloaded file is older
                                
                                NSLog(@" >>> downloaded file is older");
                                
                            }
                            
                        }
                        
                    }
                    else {
                        
                        NSLog(@" >>> errors when parsing remote downloaded issues.json");
                        
                    }
                    
                }
                else if ([urlResponse statusCode] == 404) {
                    
                    NSLog(@" >>> File issues.json doesn't exist on the server.");
                    
                }
                else if ([urlResponse statusCode] == 403) {
                    
                    NSLog(@" >>> Access to issues.json denied.");
                    
                }
                else {
                    
                    NSLog(@" >>> HTTP error code when downloading issues.json: %d", [urlResponse statusCode]);
                    
                }
                
            }
            else {
                
                NSLog(@" >>> Request error when downloading issues.json: %d", [requestError code]);
                
            }
            
        }
        
        //        [lastUpdateLocal release];
        //        [lastUpdateDateLocal release];
        [dateFormat release];
        
    }
    else {
        
        NSLog(@" >>> error while reading issues.json");
        
    }
    
    NSLog(@" >>> issuesJSONfilename: %@, fileJSON: %@", bundleIssuesJSONfilename2, fileJSON);
    
}


- (void)parseIssuesJson {
    
    //
    // enumerate issues
    //
    
    //
    // check where file exists - priority for private docs path
    NSString *fileJSON;
    if ([[NSFileManager defaultManager] fileExistsAtPath:privateIssuesJSONfilename])
        fileJSON = [NSString stringWithContentsOfFile:privateIssuesJSONfilename encoding:NSUTF8StringEncoding error:nil];
    else 
        fileJSON = [NSString stringWithContentsOfFile:bundleIssuesJSONfilename encoding:NSUTF8StringEncoding error:nil];
    
    //
    // start parsing issues.json
    NSDictionary *ret = nil;
    NSError *err = nil;
    ret = [fileJSON objectFromJSONStringWithParseOptions:JKParseOptionNone error:&err];
    if ([err userInfo] == nil) {

        NSArray *arr = (NSArray *)[ret objectForKey:@"issues"];
        if (arr != nil) {
            
            for (int i = 0; i < [arr count]; i++) {
                
                NSLog(@" >>> object at index %d: %@", i, [arr objectAtIndex:i]);
                
                NSDictionary *dic = (NSDictionary *)[ret objectForKey:(NSString *)[arr objectAtIndex:i]];
                if (dic != nil) {
                    
                    NSLog(@" >>> url: %@", (NSString *)[dic objectForKey:@"url"]);
                    
                    [issuesList addObject:[[Issue alloc] initWithData:dic issueIndex:i delegate:self]];
                    
                }                    
                
            }
            
        }

    }
        
}


//
// initialize new object 
//
- (id)init {
    
    self = [super init];
    
    if (self) {
        
        issuesList = [[NSMutableArray alloc] init];

        //
        // bundle path to issues.json
        //NSString *bundleIssuesJSONfilename = [[NSBundle mainBundle] pathForResource:@"issues.json" ofType:nil];
        bundleIssuesJSONfilename = [[NSBundle mainBundle] pathForResource:@"issues.json" ofType:nil];
        
        //
        // private docs path to issues.json
        //NSString *privateDocsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Private Documents"];
        privateDocsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Private Documents"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:privateDocsPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:privateDocsPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        //NSString *privateIssuesJSONfilename = [[privateDocsPath stringByAppendingPathComponent:@"issues.json"] retain];
        privateIssuesJSONfilename = [[privateDocsPath stringByAppendingPathComponent:@"issues.json"] retain];
        
        //
        // without multi-threading application will start downloading file on main thread
        [self refreshIssuesJson];
        [self parseIssuesJson];
    
        if (delegate != nil) 
            [delegate issuesManagerDidDownload];

        //
        // code for multi-threading
        
        /*
        //
        // add argumens for separate thread
        NSArray *threadArgs = [NSArray arrayWithObjects:bundleIssuesJSONfilename, privateIssuesJSONfilename, privateDocsPath, nil];

        //
        // start new thread to download issues.json
        downloadIssueThread = [[NSThread alloc] initWithTarget:self selector:@selector(separateThreadDownload:) object:threadArgs];
        [downloadIssueThread start];
        */
        
    }
    
    return self;
    
}


- (void)downloadThreadFinished {
    
    //
    // called from separate thread after finishing work
    //

    //
    // when the file is downloaded we can start parsing it
    [self parseIssuesJson];
    
    //
    // if we have delegate we can inform it that data is downloaded
    if (delegate != nil) 
        [delegate issuesManagerDidDownload];
    
}


- (void)separateThreadDownload:(NSArray *)threadArgs {
    
    //
    // this method runs in separate thread to download data
    // 
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //
    // refresh issues.json file
    [self refreshIssuesJsonTest:threadArgs];
        
    //
    // perform selector on main thread
    // separate thread has finished downloading data
    // calling method that will parse issues.json file
    [self performSelectorOnMainThread:@selector(downloadThreadFinished) withObject:nil waitUntilDone:NO];
    
    [pool release];
    
}


- (BOOL)isThreadWorking {
    
    //
    // return YES when thread is working
    //
    
    if (downloadIssueThread != nil) {
        
        return [downloadIssueThread isExecuting];
        
    }
    else {
        
        return NO;
        
    }
    
}


- (void)dealloc {
    
    [issuesList release];
    
    [bundleIssuesJSONfilename release];
    [privateDocsPath release];
    [privateIssuesJSONfilename release];
    
    [super dealloc];
    
}


#pragma mark - IssueDelegate

- (void)didFinishDownloadingCover:(UIImageView *)coverImageView issueIndex:(NSInteger)index {
    
    [delegate refreshCoverImage:coverImageView issueIndex:index];
    
}

@end
