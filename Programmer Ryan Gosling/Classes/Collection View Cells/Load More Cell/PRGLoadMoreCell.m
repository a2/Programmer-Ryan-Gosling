//
//  PRGLoadMoreCell.m
//  Programmer Ryan Gosling
//
//  Created by Alexsander Akers on 7/11/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#import "PRGLoadMoreCell.h"

@interface PRGLoadMoreCell ()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) IBOutlet UIButton *button;

@end

@implementation PRGLoadMoreCell

- (void)prepareForReuse
{
	self.buttonTapped = nil;
	self.refreshing = NO;
	
	[super prepareForReuse];
}
- (void)setButton:(UIButton *)button
{
	[_button removeTarget:self action:@selector(prg_buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
	_button = button;
	[_button addTarget:self action:@selector(prg_buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)setRefreshing:(BOOL)refreshing
{
	_refreshing = refreshing;
	if (_refreshing) {
		[self.activityIndicatorView startAnimating];
		self.button.hidden = YES;
	} else {
		[self.activityIndicatorView stopAnimating];
		self.button.hidden = NO;
	}
}

#pragma mark - Private Methods

- (void)prg_buttonTapped:(UIButton *)button
{
	self.refreshing = YES;
	
	if (!self.buttonTapped) return;
	
	__weak typeof(self) weakSelf = self;
	self.buttonTapped(^{
		typeof(&*weakSelf) blockSelf = weakSelf;
		blockSelf.refreshing = NO;
	});
}

@end
