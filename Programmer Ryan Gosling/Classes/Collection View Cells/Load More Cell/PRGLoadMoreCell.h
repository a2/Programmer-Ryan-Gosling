//
//  PRGLoadMoreCell.h
//  Programmer Ryan Gosling
//
//  Created by Alexsander Akers on 7/11/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

typedef void (^PRGRefreshFinishedBlock)(void);
typedef void (^PRGButtonTappedBlock)(PRGRefreshFinishedBlock block);

@interface PRGLoadMoreCell : UICollectionViewCell

@property (nonatomic, getter = isRefreshing) BOOL refreshing;
@property (nonatomic, copy) PRGButtonTappedBlock buttonTapped;

@end
