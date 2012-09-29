//
//  TopMenuViewController.m
//  Baker
//
//  Created by Krzysztof Wolski on 12.03.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopMenuViewController.h"
#import "BakerAppDelegate.h"
#import "BakerViewController.h"

@interface TopMenuViewController ()

@property (nonatomic,retain) UIButton *btnGoToList;
@property (nonatomic,retain) UITabBar *mainTabBar;

@end


@implementation TopMenuViewController

@synthesize btnGoToList,
    mainTabBar,
    delegate;

- (void)createDefaultUserInterface {
    
    topMenuHeight = 50;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    pageWidth = screenBounds.size.width;
    pageY = 20;
    
    // creating default UIView
//    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, pageHeight + pageY - topMenuHeight - 20, 1024, topMenuHeight)];
//    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, (-1) * topMenuHeight - 20, 1024, topMenuHeight)];
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, (-1) * topMenuHeight, 1024, topMenuHeight)];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.view setOpaque:NO];

    mainTabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, pageWidth, 50)];
    [self.view addSubview:mainTabBar];
    

    
    // creating button
//    btnGoToList = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnGoToList = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGoToList.frame = CGRectMake(10, 10, 170, 30);
    btnGoToList.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [btnGoToList setImage:[UIImage imageNamed:@"gfx/btn-background~ipad.png"] forState:UIControlStateNormal];
    [btnGoToList setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 5.0, 5.0)];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 30)];
    [lblTitle setText:@"LISTA WYDAŃ"];
    [lblTitle setTextAlignment:UITextAlignmentCenter];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [btnGoToList addSubview:lblTitle];
    
    [lblTitle release];
    
//    [btnGoToList setImage:[UIImage imageWithContentsOfFile:@"gfx/btn-background~ipad.png"] forState:UIControlStateNormal];
    
    [btnGoToList addTarget:self action:@selector(showIssuesList:) forControlEvents:UIControlEventTouchUpInside];

    [mainTabBar addSubview:btnGoToList];
//    [self.view addSubview:btnGoToList];
    
}



- (id)initWithUserInterface {
    
    return [self initWithNibName:nil bundle:nil];
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self createDefaultUserInterface];
    }
    return self;
}


- (void)viewDidLoad
{

    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}


- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}


- (void)fadeOut {
    [UIView beginAnimations:@"fadeOutTopMenuView" context:nil]; {
        [UIView setAnimationDuration:0.0];
        
        self.view.alpha = 0.0;
    }
    [UIView commitAnimations];
}


- (void)fadeIn {
    [UIView beginAnimations:@"fadeInTopMenuView" context:nil]; {
        [UIView setAnimationDuration:0.2];
        
        self.view.alpha = 1.0;
    }
    [UIView commitAnimations];
}


- (void)willRotate {

    [self fadeOut];

}


- (BOOL)isIndexViewHidden {
    return [UIApplication sharedApplication].statusBarHidden;
}


- (void)setPageSizeForOrientation:(UIInterfaceOrientation)orientation statusBarHidden:(BOOL)isStatusBarHidden {
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
		pageWidth = screenBounds.size.height;
		//pageHeight = screenBounds.size.width;
    } else {
        pageWidth = screenBounds.size.width;
		//pageHeight = screenBounds.size.height;
	}
    
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    if (sharedApplication.statusBarHidden) {
        pageY = 0;
    } else {
        pageY = 0;
    }
    //pageY = 20;
    
    [mainTabBar setFrame:CGRectMake(mainTabBar.frame.origin.x, mainTabBar.frame.origin.y, pageWidth, mainTabBar.frame.size.height)];
    
    NSLog(@"Set TopMenuView size to %dx%d, with pageY set to %d", pageWidth, pageHeight, pageY);
}


//
// initial default position for view
// fix for rotating device
//
NSInteger posY = 20;


- (void)rotateFromOrientation:(UIInterfaceOrientation)fromInterfaceOrientation toOrientation:(UIInterfaceOrientation)toInterfaceOrientation{

    if ([UIApplication sharedApplication].statusBarHidden) {

        //
        // if status bar is hidden then set default y position to 20
        // fix for rotating device
        //

        posY = 20;
    }
    else {
        
        //
        // set default y position to 0
        //
        
        posY = 0;
        
    }

    BOOL hidden = [self isIndexViewHidden]; // cache hidden status before setting page size
    
    [self setPageSizeForOrientation:toInterfaceOrientation statusBarHidden:hidden];
    [self setTopMenuViewHidden:hidden withAnimation:NO];
    [self fadeIn];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)setTopMenuViewHidden:(BOOL)hidden withAnimation:(BOOL)animation {
    CGRect frame;
    
    if (hidden) {
        frame = CGRectMake(0, self.view.frame.size.height * (-1) - 20, self.view.frame.size.width, self.view.frame.size.height);
    } else {
        frame = CGRectMake(0, posY, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    if (animation) {
        [UIView beginAnimations:@"slideTopMenuView" context:nil]; {
            [UIView setAnimationDuration:0.3];
            
            [self.view setFrame:frame];
        }
        [UIView commitAnimations];
    } else {
        [self.view setFrame:frame];
    }

}

- (IBAction)showIssuesList:(id)sender {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Test" message:@"Show Issues List" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertView show];
    
    [delegate openIssuesListViewController];
    
}

@end
