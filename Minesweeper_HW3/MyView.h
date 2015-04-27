//
//  MyView.h
//  Minesweeper custom view header file
//
//  Created by Robert Irwin on 9/18/14.
//  Edited by Bharath Darapu on 10/10/14.
//  Copyright (c) 2014 Robert Irwin. All rights reserved.

@import UIKit;

@interface MyView : UIView
{
    //declared two arrays -'c' style
    int minesArray[16][16]; //array whcih actually holds all the mine locations and the respective numbers surrounding it
    int tempArray[16][16]; //array which keeps a backup of the minesArray
}

- (void) generateRandomMines; //method which generates the mines
-(void) setMinesAndNumbers; //method which calculates the numbers based on the mine positions
-(void) setMinesImages; //sets the images of the mines
-(void) setNumberImages; //sets the numbers accordingly
-(void) setButtons; //sets the buttons--the top most view
-(void) setTempArray; //copies data from minesArray to the backup
-(bool) checkGameFinish; //checks if the game is finished or not
-(void) uncoverSurroundingRow:(int)touchRow col:(int)touchCol; //when user clicks on empty space show all empty spaces till                        surrounding that.
@end
