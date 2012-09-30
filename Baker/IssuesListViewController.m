//
//  IssuesListViewController.m
//  Baker
//
//  Created by Krzysztof Wolski on 13.03.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


//
// includes

#import "BakerAppDelegate.h"
#import "IssuesListViewController.h"
#import "BakerViewController.h"
#import "JSONKit.h"

#import <QuartzCore/QuartzCore.h>


//
// defines

#define kALERT_VIEW_REMOVE_ISSUE_TAG 1

#define BACK_TO_READING_LABEL       @"BACK"     // @"POWRÓT"
#define OPEN_ISSUE_BUTTON_LABEL     @"OPEN"     // @"OTWÓRZ"
#define DOWNLOAD_ISSUE_BUTTON_LABEL @"DOWNLOAD"
#define REMOVE_ISSUE_BUTTON_LABEL   @"REMOVE"

#define REMOVE_ISSUE_TITLE          @"Removing issue"
#define REMOVE_ISSUE_MESSAGE        @"Are you sure you want to remove issue?"
#define REMOVE_ISSUE_CONFIRM        @"Remove"
#define REMOVE_ISSUE_CANCEL         @"Cancel"

#define REMOVE_ERROR_TITLE          @"Error when removing issue"
#define REMOVE_ERROR_MESSAGE        @"The issue was not removed from device."
#define REMOVE_ERROR_OK             @"OK"

#define ERROR_TITLE                     @"Error"
#define OK_BUTTON_LABEL                 @"OK"
#define ISSUE_DOES_NOT_EXIST_MESSAGE    @"Selected issue doesn't exist."
#define OTHER_ERROR_MESSAGE             @"Unknown error when opening issue."




@interface IssuesListViewController ()

@property (nonatomic,retain) UIButton *btnBack;
@property (nonatomic,retain) UIButton *btnOpenIssue;
@property (nonatomic,retain) UIButton *btnRemoveIssue;
@property (nonatomic,retain) UILabel *lblIssueName;
@property (nonatomic,retain) UITabBar *topBar;

@end

@implementation IssuesListViewController

@synthesize btnBack,
    btnOpenIssue,
    btnRemoveIssue,
    lblIssueName,
    topBar,
    delegate;


//
// array for image views
NSMutableArray *imgViewList;


- (void)createUserInterface {
    
    imgViewList = [[NSMutableArray alloc] init];
    
    //
    // create default user interface for issues view
    //
    
    //
    // get screen size    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    int pageWidth = screenBounds.size.width;
    int pageHeight = screenBounds.size.height;

    // 
    // create default view
    UIView *defView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pageWidth, pageHeight)];
    defView.backgroundColor = [UIColor blackColor];
    [defView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ];
    defView.alpha = 0.0f;

    //
    // top bar for back button
    topBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, pageWidth, 50)];
    [topBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    //
    // back to reading button - placed on top bar
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setTitle:BACK_TO_READING_LABEL forState:UIControlStateNormal];
    [btnBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnBack setBackgroundColor:[UIColor clearColor]];
    btnBack.frame = CGRectMake(5, 5, 100, 40);
    [btnBack addTarget:self action:@selector(backToReading:) forControlEvents:UIControlEventTouchUpInside];
    
    [topBar addSubview:btnBack];

    // 
    // create scrollview for issues
    issuesScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((pageWidth * 0.5f) - (443 * 0.5f), 50 + 30 + 100, 443, 600)];
    issuesScrollView.backgroundColor  = [UIColor blackColor];
    issuesScrollView.contentSize      = CGSizeMake(443 * [[issuesManager issuesList] count], 600);
    issuesScrollView.delegate         = self;
    issuesScrollView.pagingEnabled    = YES;
    issuesScrollView.showsVerticalScrollIndicator     = NO;
    issuesScrollView.showsHorizontalScrollIndicator   = NO;
    issuesScrollView.alwaysBounceVertical     = NO;
    issuesScrollView.scrollsToTop             = NO;
    issuesScrollView.bounces                  = NO;
    [issuesScrollView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    [defView addSubview:issuesScrollView];

    //
    // add covers to scrollview
	for (int i=0; i < issuesNumber; i++) {
        
        Issue *issue = (Issue *)[[issuesManager issuesList] objectAtIndex:i];
        
        //
        // add right to the scroll view
        CGRect frame    = issuesScrollView.frame;
        frame.origin.x  = frame.size.width * i;
        frame.origin.y  = 0;
        [[issue coverImageView] setFrame:frame];

        [imgViewList addObject:[issue coverImageView]];
        
        [issuesScrollView addSubview:[imgViewList objectAtIndex:i]];
        
	}   // for
    
    //
    // creating page control
    pageControl = [[PageControl alloc] initWithFrame:CGRectMake(issuesScrollView.frame.origin.x, issuesScrollView.frame.size.height + issuesScrollView.frame.origin.y + 10, 443, 20)];
    
    pageControl.numberOfPages   = issuesNumber;
    pageControl.currentPage     = 0;
    [pageControl setDotColorCurrentPage:[UIColor whiteColor]];
    [pageControl setDotColorOtherPage:[UIColor grayColor]];

    [defView addSubview:pageControl];
    
    //
    // button for opening an issue
    btnOpenIssue = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnOpenIssue setTitle:OPEN_ISSUE_BUTTON_LABEL forState:UIControlStateNormal];
    [btnOpenIssue setFrame:CGRectMake(issuesScrollView.frame.origin.x + issuesScrollView.frame.size.width + 20, issuesScrollView.frame.size.height + issuesScrollView.frame.origin.y - 40, 100, 40)];
    [btnOpenIssue setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnOpenIssue setBackgroundColor:[UIColor blackColor]];
    [btnOpenIssue addTarget:self action:@selector(openIssue:) forControlEvents:UIControlEventTouchUpInside];
    btnOpenIssue.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [[btnOpenIssue layer] setCornerRadius:5.0f];
    [[btnOpenIssue layer] setBorderWidth:1.0f];
    [[btnOpenIssue layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    
    [defView addSubview:btnOpenIssue];

    //
    // button to remove issue
    btnRemoveIssue = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnRemoveIssue setTitle:REMOVE_ISSUE_BUTTON_LABEL forState:UIControlStateNormal];
    [btnRemoveIssue setFrame:CGRectMake(btnOpenIssue.frame.origin.x, btnOpenIssue.frame.origin.y + btnOpenIssue.frame.size.height + 20, 100, 40)];
    [btnRemoveIssue setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRemoveIssue setBackgroundColor:[UIColor redColor]];
    [btnRemoveIssue addTarget:self action:@selector(removeIssue:) forControlEvents:UIControlEventTouchUpInside];
    btnRemoveIssue.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnRemoveIssue setAlpha:0.0f];

    [[btnRemoveIssue layer] setCornerRadius:5.0f];
    [[btnRemoveIssue layer] setBorderWidth:1.0f];
    [[btnRemoveIssue layer] setBorderColor:[[UIColor redColor] CGColor]];
    
    [defView addSubview:btnRemoveIssue];

    //
    // label with issue number
    lblIssueName = [[UILabel alloc] initWithFrame:CGRectMake(issuesScrollView.frame.origin.x, pageControl.frame.origin.y + pageControl.frame.size.height + 20, 443, 20)];
    
    [lblIssueName setTextColor:[UIColor whiteColor]];
    [lblIssueName setBackgroundColor:[UIColor clearColor]];
    [lblIssueName setTextAlignment:UITextAlignmentCenter];
    
    [defView addSubview:lblIssueName];

    [defView addSubview:topBar];

    //
    // assign to main view
    self.view = defView;

    //
    // some cleaning
    [defView release];

    //
    // refresh magazine
    // automatically set current label, etc.
    [self refreshCurrentMagazine:0];
    
}   // createUserInterface


#pragma mark - View lifecycle


- (id)initWithIssuesList {
    
    return [self initWithNibName:nil bundle:nil];

}   // initWithIssuesList


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        //
        // create issue manager and set delegate
        // issue manager will check if issues.json file is newer on the server
        // and try to download it
        issuesManager = [[IssuesManager alloc] init];
        [issuesManager setDelegate:self];
        
        //
        // uncommented for single-threading
        issuesNumber = [[issuesManager issuesList] count];
        
        [self createUserInterface];
        [self becomeFirstResponder];
        
    }
    
    return self;
    
}   // initWithNibName


- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}


- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.

}


-(void)viewWillDisappear:(BOOL)animated {
    
    NSLog(@"viewWillDisappear");
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

	return YES;

}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    //
    // transition for rotating device
    //
    
    //NSLog(@" >>> width: %f; height: %f", self.view.frame.size.width, self.view.frame.size.height);
    
    [pageControl setFrame:CGRectMake(issuesScrollView.frame.origin.x, issuesScrollView.frame.size.height + issuesScrollView.frame.origin.y + 10, 443, 20)];
    [btnOpenIssue setFrame:CGRectMake(issuesScrollView.frame.origin.x + issuesScrollView.frame.size.width + 20, issuesScrollView.frame.size.height + issuesScrollView.frame.origin.y - 40, 100, 40)];
    [btnRemoveIssue setFrame:CGRectMake(btnOpenIssue.frame.origin.x, btnOpenIssue.frame.origin.y + btnOpenIssue.frame.size.height + 20, 100, 40)];
    [lblIssueName setFrame:CGRectMake(issuesScrollView.frame.origin.x, pageControl.frame.origin.y + pageControl.frame.size.height + 20, 443, 20)];

    
    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
        
        NSLog(@" >>> IssuesListViewController rotates from portrait");
        
    }
    else if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
    
        NSLog(@" >>> IssuesListViewController rotates from landscape");
        
    }
    
}


- (void)dealloc {

    [btnBack release];
    
    [issuesScrollView release];
    [pageControl release];
    
    [super dealloc];
    
}


- (void)hideView {

    [UIView beginAnimations:@"hideIssuesListViewController" context:nil]; {
        
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.view.alpha = 0.0f;
        
    }
    [UIView commitAnimations];
    
    [self resignFirstResponder];

}


#pragma mark - IBActions


- (IBAction)backToReading:(id)sender {

    //
    // back to currently reading issue
    //

    [UIView beginAnimations:@"backToReading" context:nil]; {
        
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.view.alpha = 0.0f;
        
        [UIView commitAnimations];
    }

}   // backToReading


- (IBAction)removeIssue:(id)sender {
    
    //
    // remove issue from device
    // show alert to confirm user action
    //
        
    UIAlertView *removeAlertView = [[UIAlertView alloc] initWithTitle:REMOVE_ISSUE_TITLE message:REMOVE_ISSUE_MESSAGE delegate:self cancelButtonTitle:REMOVE_ISSUE_CANCEL otherButtonTitles:REMOVE_ISSUE_CONFIRM, nil];
    [removeAlertView setTag:kALERT_VIEW_REMOVE_ISSUE_TAG];
    
    [removeAlertView show];
    
    [removeAlertView release];

}

     
- (IBAction)openIssue:(id)sender {
    
    //
    // open selected issue
    //
    
    NSLog(@" >>> open selected issue... %d", [pageControl currentPage]);
    
    BakerViewController *rootViewController = ((BakerAppDelegate *)[[UIApplication sharedApplication] delegate]).rootViewController;
    
    if (rootViewController != nil) {
    
        NSString *bookPath = [NSString stringWithFormat:@"book%d", [pageControl currentPage]];
        
        Issue *issue = (Issue *)[[issuesManager issuesList] objectAtIndex:[pageControl currentPage]];
        
        //
        // check if book is downloaded
        NSString *privateDocsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Private Documents"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:privateDocsPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:privateDocsPath withIntermediateDirectories:YES attributes:nil error:nil];
        }

        BOOL bookExists = NO;
        if ([issue downloaded] == YES) {
            
            if ([issue downloadPathType] == ISSUE_DOWNLOAD_PATH_TYPE_BUNDLE || [issue downloadPathType] == ISSUE_DOWNLOAD_PATH_TYPE_PRIVATE_DOCS) {
                
                bookExists = YES;
                
            }
            
        }
        else {
            
            //
            // need to download the book
            NSLog(@" >>> Issue is not downloaded.");
            
            [rootViewController resetDocumentsBookPath:[privateDocsPath stringByAppendingPathComponent:bookPath]];
            
            NSNotification *notification = [NSNotification notificationWithName:@"download-url" object:[issue downloadUrl]];
            [rootViewController downloadBook:notification];
            
            //
            // change download status of issue
            // set download path type
            // and refresh button text
            [issue setDownloaded:YES];
            [issue setDownloadPathType:ISSUE_DOWNLOAD_PATH_TYPE_PRIVATE_DOCS];
            
            [self refreshCurrentMagazine:[pageControl currentPage]];
            
            [self hideView];
            
        }

        if (bookExists) {
            
            if ([rootViewController refreshBookPath:bookPath] == YES) {
                
                // 
                // issue opened - hide view
                [self hideView];
                
            }
            else {
                
                //
                // no issue found - show allert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:ISSUE_DOES_NOT_EXIST_MESSAGE delegate:self cancelButtonTitle:OK_BUTTON_LABEL otherButtonTitles:nil];
                [alert show];
                
                [alert release];
                
            }
            
        }
    
        //
        // call delegate to open selected issue
        [delegate didSelectedIssue:[pageControl currentPage]];
        
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:OTHER_ERROR_MESSAGE delegate:self cancelButtonTitle:OK_BUTTON_LABEL otherButtonTitles:nil];
        [alert show];
        
        [alert release];
    
    }
    
}   // openIssue


#pragma mark - ScrollView assistans

- (void)loadScrollViewWithPage:(int)page {
    
    if (page < 0)
        return;
    
    if (page >= pageControl.numberOfPages)
        return;
    
}


#pragma mark - ScrollView delegates

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    //NSLog(@"scrollViewWillBeginDragging");
    
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
    //NSLog(@"scrollViewWillBeginDecelerating");
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //NSLog(@"scrollViewDidEndDecelerating");
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //
    // change active issue
    //
    
    //NSLog(@"scrollViewDidScroll");

    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    pageControl.currentPage = page;
    
    [self refreshCurrentMagazine:page];
    
}


#pragma mark - AlertView delegates


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //
    // handle alert view windows
    //
    
    if (alertView.tag == kALERT_VIEW_REMOVE_ISSUE_TAG) {
        
        // 
        // button clicked inside confirming remove issue alert
        
        if (buttonIndex == 1) {
            
            //
            // removing confirmed
            
            BakerViewController *rootViewController = ((BakerAppDelegate *)[[UIApplication sharedApplication] delegate]).rootViewController;
            
            if (rootViewController != nil) {
                
                NSString *bookPath = [NSString stringWithFormat:@"book%d", [pageControl currentPage]];
                
                if ([rootViewController removeBook:bookPath]) {
                    
                    //
                    // book is removed
                    
                    [(Issue *)[[issuesManager issuesList] objectAtIndex:[pageControl currentPage]] refreshBookStatus];
                    
                    [self refreshCurrentMagazine:[pageControl currentPage]];
                    
                }
                else {
                    
                    //
                    // error when removing book
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:REMOVE_ERROR_TITLE message:REMOVE_ERROR_MESSAGE delegate:self cancelButtonTitle:REMOVE_ERROR_OK otherButtonTitles:nil];
                    [alert show];
                    
                }
                
            }
            
        }
        
    }
    
}


#pragma mark - Public methods


- (void)refreshCurrentMagazine:(NSInteger)currentIssueIndex {
    
    //
    // get Issue object and made some changes to UI
    //

    Issue *currentIssue = (Issue *)[[issuesManager issuesList] objectAtIndex:currentIssueIndex];
    if (currentIssue != nil) {
        
        [lblIssueName setText:[currentIssue title]];
        
        if (![currentIssue downloaded]) {
            
            //
            // issue is downloaded
            
            [btnOpenIssue setTitle:DOWNLOAD_ISSUE_BUTTON_LABEL forState:UIControlStateNormal];
            
            [UIView beginAnimations:@"hideBtnRemoveIssue" context:nil]; {
                
                [UIView setAnimationDuration:0.5f];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                
                //[btnRemoveIssue setAlpha:0.0f];
                
                [UIView commitAnimations];
                
            }
            
        }
        else {
            
            //
            // issue need to be download
            
            [btnOpenIssue setTitle:OPEN_ISSUE_BUTTON_LABEL forState:UIControlStateNormal]; 
            
            [UIView beginAnimations:@"showBtnRemoveIssue" context:nil]; {
                
                [UIView setAnimationDuration:0.5f];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                
                //[btnRemoveIssue setAlpha:1.0f];
                
                [UIView commitAnimations];
                
            }
            
        }
        
    }   // currentIssue != nil
    
}


#pragma mark - IssuesManagerDelegate

- (void)issuesManagerDidDownload {
    
    //
    // delegate method called after downloading issues.json file
    // create user interface
    //
    
    issuesNumber = [[issuesManager issuesList] count];
    
    //NSLog(@" >>> Download issues.json working: %d", [issuesManager isThreadWorking]);
    
    [self createUserInterface];

}


- (void)refreshCoverImage:(UIImageView *)coverImageView issueIndex:(NSInteger)index {
    
    NSLog(@" >>> refreshing cover image at index %d...", index);
    
    [imgViewList replaceObjectAtIndex:index withObject:coverImageView];
    
    CGRect frame    = issuesScrollView.frame;
    frame.origin.x  = frame.size.width * index;
    frame.origin.y  = 0;
    [coverImageView setFrame:frame];

    [issuesScrollView addSubview:[imgViewList objectAtIndex:index]];
    
}


@end
