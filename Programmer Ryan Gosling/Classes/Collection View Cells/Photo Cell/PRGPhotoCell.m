//
//  PRGPhotoCell.m
//  Programmer Ryan Gosling
//
//  Created by Alexsander Akers on 7/11/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#import "PRGPhotoCell.h"

@interface PRGPhotoCell ()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation PRGPhotoCell

- (void)configureWithURL:(NSURL *)URL
{
	self.loading = YES;
	[self.activityIndicatorView startAnimating];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	[self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		self.imageView.image = image;
		
		[self.activityIndicatorView stopAnimating];
		self.loading = NO;
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		self.backgroundColor = [UIColor redColor];
		[self.activityIndicatorView stopAnimating];
		self.loading = NO;
	}];

}

@end
