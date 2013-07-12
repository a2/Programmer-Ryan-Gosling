//
//  PRGPhotoCell.h
//  Programmer Ryan Gosling
//
//  Created by Alexsander Akers on 7/11/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

@interface PRGPhotoCell : UICollectionViewCell

@property (nonatomic, getter = isLoading) BOOL loading;

- (void)configureWithURL:(NSURL *)URL;

@end
