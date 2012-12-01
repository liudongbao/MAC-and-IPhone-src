//
//  Cell.h
//  TicTacToe
//
//  Created by Swipe Interactive on 3/10/09.
//  Copyright Swipe Interactive 2009. All rights reserved.
//

#import "TicTacToeViewController.h"

@interface Cell : UIView {
	
	TicTacToeViewController *viewController;
	BOOL cellTappedRemote;
	BOOL cellTappedLocal;
	
}

-(id)initWithHPos:(NSInteger)i vPos:(NSInteger)j sender:(TicTacToeViewController *)sender;
-(void)remoteTap;
-(void)clearCell;

@end
