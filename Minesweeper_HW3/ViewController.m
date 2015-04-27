//
//  ViewController.m
//  Minesweeper_HW3
//
//  Created by Bharath Darapu on 11/1/14.
//  Copyright (c) 2014 Syracuse. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, assign) CGFloat dw, dh;  // width and height of cell
@property (nonatomic, assign) CGFloat x, y;    // touch point coordinates
@property (nonatomic, assign) int row, col;    // selected cell in cell grid
@property (nonatomic, assign) BOOL inMotion;   // YES iff in process of dragging
@property (nonatomic, strong) NSString *s;     // item to drag around grid
@end

@implementation ViewController

@synthesize gameNew; //synthesize the new game button
@synthesize dw, dh, row, col, x, y, inMotion, s;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.view setBackgroundColor: [UIColor blackColor]];
    
    //setup action for the button click
    [gameNew addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//method to run on buttonclick
-(void)buttonAction
{
    //loops through and finds all subviews associated with the controller
    if ([self.view subviews])
    {
        for (UIView *subview in [self.view subviews])
        {
            //calls setNeedsDisplay method which will re-render the view / calls the drawrect method in the view
            [subview setNeedsDisplay];
        }
    }
}

@end
