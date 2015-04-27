//
//  MyView.m
//  Minesweeper custom view implementation file
//
//  Created by Robert Irwin on 9/18/14.
//  Edited by Bharath Darapu on 10/10/14.
//  Copyright (c) 2014 Robert Irwin. All rights reserved.
//

#import "MyView.h"

@interface MyView ()
@property (nonatomic, assign) CGFloat dw, dh;  // width and height of cell
@property (nonatomic, assign) CGFloat x, y;    // touch point coordinates
@property (nonatomic, assign) int row, col;    // selected cell in cell grid
@property (nonatomic, assign) BOOL inMotion;   // YES iff in process of dragging
@property (nonatomic, strong) NSString *s;     // item to drag around grid

@end

@implementation MyView

bool toggleFlag = false;

@synthesize dw, dh, row, col, x, y, inMotion, s;

- (id)initWithFrame:(CGRect)frame {
    return self = [super initWithFrame:frame];
}

//contains the implementation to draw the view and calls the other subsequent methods
- (void)drawRect:(CGRect)rect
{
    
    //initializing the array and the backup with values 0
    for(int i=0;i<16;i++)
    {
        for(int j=0;j<16;j++)
        {
            minesArray[i][j] = 0;
            tempArray[i][j]=0;
        }
    }
    
    [self generateRandomMines]; //method generates the mines randomly
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();  // obtain graphics context
    // CGContextScaleCTM( context, 0.5, 0.5 );  // shrink into upper left quadrant
    CGRect bounds = [self bounds];          // get view's location and size
    CGFloat w = CGRectGetWidth( bounds ) ;   // w = width of view (in points)
    CGFloat h = CGRectGetHeight ( bounds ); // h = height of view (in points)
    dw = w/16.0f;                           // dw = width of cell (in points)
    dh = h/16.0f;                           // dh = height of cell (in points)
    
    // draw lines to form a 16x16 cell grid
    CGContextBeginPath( context );               // begin collecting drawing operations
    for ( int i = 0;  i < 16;  ++i )
    {
        // draw horizontal grid line
        CGContextMoveToPoint( context, 0, i*dh );
        CGContextAddLineToPoint( context, w, i*dh );
    }
    for ( int i = 0;  i < 16;  ++i )
    {
        // draw vertical grid line
        CGContextMoveToPoint( context, i*dw, 0 );
        CGContextAddLineToPoint( context, i*dw, h );
    }
    [[UIColor grayColor] setStroke];             // use gray as stroke color
    CGContextDrawPath( context, kCGPathStroke ); // execute collected drawing ops
    
    [self setMinesAndNumbers]; //calculates the numbers to be set around the mines
    [self setMinesImages]; //sets the mine images
    [self setNumberImages]; //sets the numbers
    [self setTempArray]; //copies the data
    [self setButtons]; //sets the buttons as the top most view
    
}


//identifies the button press on the view
-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event
{
    int touchRow, touchCol;
    CGPoint xy;
    
    [super touchesBegan: touches withEvent: event];
    
    UITouch *touch = [touches anyObject];
    
    //if it is a double tap
    if (touch.tapCount == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        toggleFlag = !toggleFlag; //toggles the flag which
        
        for ( id t in touches )
        {
            xy = [t locationInView: self];
            self.x = xy.x;  self.y = xy.y;
            touchRow = self.x / self.dw;  touchCol = self.y / self.dh;
            self.inMotion = (self.row == touchRow  &&  self.col == touchCol);
            
            if(toggleFlag) //sets the flag accordingly
            {
                UIImageView *myView;
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"flag.png"];
                [myView setFrame:CGRectMake(touchRow*self.dw, touchCol*self.dh, dw, dh)];
                minesArray[touchRow][touchCol] = 5;
            }
            else
            {
                minesArray[touchRow][touchCol] = tempArray[touchRow][touchCol];
                UIImageView *myView;
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"button.png"];
                [myView setFrame:CGRectMake(touchRow*self.dw, touchCol*self.dh, dw, dh)];
            }
        }
        
        
    }
    
    //if it is a single tap
    else if(touch.tapCount == 1)
    {
        //check if the game is done. if yes then show an alert and reset the game
        bool gameWon = false;
        gameWon = [self checkGameFinish];
        if(gameWon)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Winner!!!"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Restart"
                                                  otherButtonTitles:nil];
            alert.tag = 1;
            [alert show];
        }
        
        //the game is not done yet so continuing
        

        for ( id t in touches )
        {
            
            xy = [t locationInView: self];
            self.x = xy.x;  self.y = xy.y;
            touchRow = self.x / self.dw; //getting the row clicked based on coordinates
            touchCol = self.y / self.dh; //getting column clicked based on coordinates
            self.inMotion = (self.row == touchRow  &&  self.col == touchCol);
            
            //if stiked a mine then show an game over alert
            if(minesArray[touchRow][touchCol] == -1)
            {
                [self setMinesImages]; //uncover all mines
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                alert.tag = 1;
                [alert show];
                
            }
            
            //uncover the numbers if checked
            else  if(minesArray[touchRow][touchCol] == 5) //ignore if flag
                continue;
            else if(minesArray[touchRow][touchCol] == 1)
            {
                tempArray[touchRow][touchCol] = 6;
                UIImageView *myView;
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"number1.png"];
                [myView setFrame:CGRectMake(touchRow*self.dw, touchCol*self.dh, dw, dh)];
            }
            else if(minesArray[touchRow][touchCol] == 2)
            {
                tempArray[touchRow][touchCol] = 6;
                UIImageView *myView;
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"number2.png"];
                [myView setFrame:CGRectMake(touchRow*self.dw, touchCol*self.dh, dw, dh)];
            }
            else if(minesArray[touchRow][touchCol] == 3)
            {
                tempArray[touchRow][touchCol] = 6;
                UIImageView *myView;
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"number3.png"];
                [myView setFrame:CGRectMake(touchRow*self.dw, touchCol*self.dh, dw, dh)];
            }
            else if(minesArray[touchRow][touchCol] == 4)
            {
                tempArray[touchRow][touchCol] = 6;
                UIImageView *myView;
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"number4.png"];
                [myView setFrame:CGRectMake(touchRow*self.dw, touchCol*self.dh, dw, dh)];
            }
            else if(minesArray[touchRow][touchCol] == 0){
                //if blank space is clicked show surrounding numbers and blanks
                 [self uncoverSurroundingRow:touchRow col:touchCol];
            }
        }
        
    }
    
}

//mehtod implemetation to show surrounding numbers if blank space is clicked
-(void)uncoverSurroundingRow: (int)touchRow col:(int)touchCol
{
    UIImageView *myView;
    for(int i=touchRow-2;i<=touchRow+2;i++)
    {
        if(i<0||i>16)
            continue;
        for(int j=touchCol-2;j<=touchCol+2;j++)
        {
            if(j<0 || j>16)
                continue;
            if(minesArray[i][j]==0)
            {
                tempArray[i][j] = 6;
                myView = [[UIImageView alloc] init];
            [self addSubview:myView];
            myView.image = [UIImage imageNamed:@"empty.png"];
            [myView setFrame:CGRectMake(i*self.dw, j*self.dh, dw, dh)];
               
            }
            else if(minesArray[i][j] == 1)
            {
                tempArray[i][j] = 6;
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"number1.png"];
                [myView setFrame:CGRectMake(i*self.dw, j*self.dh, dw, dh)];
            }
            
            else if(minesArray[i][j] == 2)
            {
                tempArray[i][j] = 6;
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"number2.png"];
                [myView setFrame:CGRectMake(i*self.dw, j*self.dh, dw, dh)];
            }
            else if(minesArray[i][j] == 3)
            {
                tempArray[i][j] = 6;
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"number3.png"];
                [myView setFrame:CGRectMake(i*self.dw, j*self.dh, dw, dh)];
            }
            else if(minesArray[i][j] == 4)
            {
                tempArray[i][j] = 6;
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"number4.png"];
                [myView setFrame:CGRectMake(i*self.dw, j*self.dh, dw, dh)];
            }
        }
    }
    
}


-(void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{
    [super touchesEnded: touches withEvent: event];
}


-(void) touchesCancelled: (NSSet *) touches withEvent: (UIEvent *) event
{
    [super touchesCancelled: touches withEvent: event];
}


//generates the random mines
-(void)generateRandomMines
{
    int lowerBound = 0;
    int upperBound = 15;
    
    for(int i=0;i<50;i++)
    {
        int rndRow = lowerBound + arc4random() % (upperBound - lowerBound);
        int rndColumn = lowerBound + arc4random() % (upperBound - lowerBound);
        minesArray[rndRow][rndColumn] = -1;
    }
    
    
}


//sets the numbers around the mines
//extra caoution had to be taken for the corners
-(void)setMinesAndNumbers
{
    for(int i=0;i<16;i++)
    {
        for(int j=0;j<16;j++)
        {
            if(minesArray[i][j] == -1)
            {
                //number1 if i=0 or j = 0
                if(i==0 && j!=0 && j!=15)
                {
                    for(int a= i ;a<= i+1 ;a++)
                    {
                        for(int b= j-1 ;b<= j+1 ; b++)
                        {
                            if(minesArray [a][b] ==-1)
                                continue;
                            else if(minesArray [a][b] == 1)
                                minesArray[a][b] = 2;
                            else if(minesArray[a][b] == 2)
                                minesArray[a][b] = 3;
                            else if(minesArray[a][b] == 3)
                                minesArray[a][b] = 4;
                            else
                                minesArray[a][b] = 1;
                        }
                    }
                    
                } else
                    
                    // number1 if j=0
                    if(j==0 && i!=0 && i!=15)
                    {
                        for(int a= i-1 ;a<= i+1 ;a++)
                        {
                            for(int b= j ;b<= j+1 ; b++)
                            {
                                if(minesArray [a][b] ==-1)
                                    continue;
                                else if(minesArray [a][b] == 1)
                                    minesArray[a][b] = 2;
                                else if(minesArray[a][b] == 2)
                                    minesArray[a][b] = 3;
                                else if(minesArray[a][b] == 3)
                                    minesArray[a][b] = 4;
                                else
                                    minesArray[a][b] = 1;
                            }
                        }
                        
                    } else
                        
                        //number 1 if i=0 and j =0
                        if(i==0 && j==0)
                        {
                            for(int a= i ;a<= i+1 ;a++)
                            {
                                for(int b= j ;b<= j+1 ; b++)
                                {
                                    if(minesArray [a][b] ==-1)
                                        continue;
                                    else if(minesArray [a][b] == 1)
                                        minesArray[a][b] = 2;
                                    else if(minesArray[a][b] == 2)
                                        minesArray[a][b] = 3;
                                    else if(minesArray[a][b] == 3)
                                        minesArray[a][b] = 4;
                                    else
                                        minesArray[a][b] = 1;
                                }
                            }
                            
                        } else
                            
                            //number 1 if i =15 && j =15
                            if(i==15 && j==15)
                            {
                                for(int a= i-1 ;a<= i ;a++)
                                {
                                    for(int b= j-1 ;b<= j ; b++)
                                    {
                                        if(minesArray [a][b] ==-1)
                                            continue;
                                        else if(minesArray [a][b] == 1)
                                            minesArray[a][b] = 2;
                                        else if(minesArray[a][b] == 2)
                                            minesArray[a][b] = 3;
                                        else if(minesArray[a][b] == 3)
                                            minesArray[a][b] = 4;
                                        else
                                            minesArray[a][b] = 1;
                                    }
                                }
                                
                            } else
                                
                                // number 1 if i =15
                                if(i==15 && j!=15 && j!=0)
                                {
                                    for(int a= i -1 ;a<= i ;a++)
                                    {
                                        for(int b= j-1 ;b<= j+1 ; b++)
                                        {
                                            if(minesArray [a][b] ==-1)
                                                continue;
                                            else if(minesArray [a][b] == 1)
                                                minesArray[a][b] = 2;
                                            else if(minesArray[a][b] == 2)
                                                minesArray[a][b] = 3;
                                            else if(minesArray[a][b] == 3)
                                                minesArray[a][b] = 4;
                                            else
                                                minesArray[a][b] = 1;
                                        }
                                    }
                                    
                                } else
                                    
                                    // number 1 if i =15
                                    if(i!=15 && j==15 && i!=0)
                                    {
                                        for(int a= i -1 ;a<= i +1 ;a++)
                                        {
                                            for(int b= j-1 ;b<= j ; b++)
                                            {
                                                if(minesArray [a][b] ==-1)
                                                    continue;
                                                else if(minesArray [a][b] == 1)
                                                    minesArray[a][b] = 2;
                                                else if(minesArray[a][b] == 2)
                                                    minesArray[a][b] = 3;
                                                else if(minesArray[a][b] == 3)
                                                    minesArray[a][b] = 4;
                                                else
                                                    minesArray[a][b] = 1;
                                            }
                                        }
                                        
                                    } else
                                        //number 1 if i=0 j =15
                                        
                                        if(i == 0 && j==15)
                                        {
                                            for(int a= i ;a<= i+1 ;a++)
                                            {
                                                for(int b= j-1 ;b<= j ; b++)
                                                {
                                                    if(minesArray [a][b] ==-1)
                                                        continue;
                                                    else if(minesArray [a][b] == 1)
                                                        minesArray[a][b] = 2;
                                                    else if(minesArray[a][b] == 2)
                                                        minesArray[a][b] = 3;
                                                    else if(minesArray[a][b] == 3)
                                                        minesArray[a][b] = 4;
                                                    else
                                                        minesArray[a][b] = 1;
                                                }
                                            }
                                            
                                        } else
                                            //number 1 if i=15 and j = 0
                                            
                                            if(i == 15 && j==0)
                                            {
                                                for(int a= i -1  ;a<= i ;a++)
                                                {
                                                    for(int b= j ;b<= j+1 ; b++)
                                                    {
                                                        if(minesArray [a][b] ==-1)
                                                            continue;
                                                        else if(minesArray [a][b] == 1)
                                                            minesArray[a][b] = 2;
                                                        else if(minesArray[a][b] == 2)
                                                            minesArray[a][b] = 3;
                                                        else if(minesArray[a][b] == 3)
                                                            minesArray[a][b] = 4;
                                                        else
                                                            minesArray[a][b] = 1;
                                                    }
                                                }
                                                
                                            }
                                            else
                                            {
                                                for(int a= i -1 ;a<= i +1 ;a++)
                                                {
                                                    for(int b= j-1 ;b<= j +1 ; b++)
                                                    {
                                                        if(minesArray [a][b] ==-1)
                                                            continue;
                                                        else if(minesArray [a][b] == 1)
                                                            minesArray[a][b] = 2;
                                                        else if(minesArray[a][b] == 2)
                                                            minesArray[a][b] = 3;
                                                        else if(minesArray[a][b] == 3)
                                                            minesArray[a][b] = 4;
                                                        else
                                                            minesArray[a][b] = 1;
                                                    }
                                                }
                                            }
                
            }
        }
    }
    
}


//sets the numbers respectively around the mines
-(void)setNumberImages
{
    UIImageView *myView;
    
    
    for(int i=0;i<16 ;i++)
    {
        for(int j=0;j<16;j++)
        {
            if(minesArray[i][j] == 1)
            {
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"number1.png"];
                [myView setFrame:CGRectMake(i*self.dw, j*self.dh, dw, dh)];
            }
            
            else if(minesArray[i][j] == 2)
            {
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"number2.png"];
                [myView setFrame:CGRectMake(i*self.dw, j*self.dh, dw, dh)];
            }
            else if(minesArray[i][j] == 3)
            {
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"number3.png"];
                [myView setFrame:CGRectMake(i*self.dw, j*self.dh, dw, dh)];
            }
            else if(minesArray[i][j] == 4)
            {
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"number4.png"];
                [myView setFrame:CGRectMake(i*self.dw, j*self.dh, dw, dh)];
            }
            else if(minesArray[i][j] != -1){
                minesArray[i][j]=0;
                UIImageView *myView;
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"empty.png"];
                [myView setFrame:CGRectMake(i*self.dw, j*self.dh, dw, dh)];
            }
        }
    }
}


//sets the images for mines
-(void) setMinesImages
{
    UIImageView *myView;
    
    for(int i=0;i<16 ;i++)
    {
        for(int j=0;j<16;j++)
        {
            if(minesArray[i][j] == -1)
            {
                myView = [[UIImageView alloc] init];
                [self addSubview:myView];
                myView.image = [UIImage imageNamed:@"minered.jpg"];
                [myView setFrame:CGRectMake(i*self.dw, j*self.dh, dw, dh)];
            }
        }
    }
}

//sets the buttons
-(void)setButtons
{
   
    UIImageView *myView;
    
    for(int i=0;i<16 ;i++)
    {
        for(int j=0;j<16;j++)
        {
            
            myView = [[UIImageView alloc] init];
            [self addSubview:myView];
            myView.image = [UIImage imageNamed:@"button.png"];
            [myView setFrame:CGRectMake(i*self.dw, j*self.dh, dw, dh)];
        }
    }
}


//a copy of the minesarray as a backup
-(void)setTempArray
{
    for(int i=0;i<16 ;i++)
    {
        for(int j=0;j<16;j++)
        {
            tempArray[i][j] = minesArray[i][j];
        }
    }
}


//reset game if it is over
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 1)
        [self setNeedsDisplay];
    
    
}


//check if the game is over
-(bool) checkGameFinish
{
    for(int i=0;i<16;i++)
    {
        for(int j=0; j<16;j++)
        {
            if(tempArray[i][j] != 6 || tempArray[i][j] !=-1 ||tempArray[i][j] !=5)
                return false;
            else
                return true;
            
            
        }
    }
    return false;
    
}

@end
