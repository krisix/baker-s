//
//  TopMenuViewController.h
//  Baker
//
//  Created by Krzysztof Wolski on 12.03.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IssuesListViewController.h"

@class TopMenuViewController;

@protocol TopMenuViewControllerDelegate <NSObject>

- (void)openIssuesListViewController;

@end

@interface TopMenuViewController : UIViewController {
    
    int pageY;
    int pageWidth;
	int pageHeight;
    int topMenuHeight;
    
}

@property (nonatomic,retain) id <TopMenuViewControllerDelegate> delegate;

- (id)initWithUserInterface; 

- (void)rotateFromOrientation:(UIInterfaceOrientation)fromInterfaceOrientation toOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)setTopMenuViewHidden:(BOOL)hidden withAnimation:(BOOL)animation;
- (void)willRotate;

@end
