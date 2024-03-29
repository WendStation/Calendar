//
//  CenterCell.m
//  BanTang
//
//  Created by liaoyp on 15/4/22.
//  Copyright (c) 2015年 JiuZhouYunDong. All rights reserved.
//

#import "HorizontalScrollCell.h"

@implementation HorizontalScrollCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUpView];
        
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpView];
    }
    return self;

}
- (void)setUpView
{
    UICollectionViewFlowLayout *horizontalCellLayout = [UICollectionViewFlowLayout new];
    horizontalCellLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    horizontalCellLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:horizontalCellLayout];
    
    [_collectionView registerClass:NSClassFromString(self.reuseIdentifier) forCellWithReuseIdentifier:self.reuseIdentifier];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.contentView addSubview:_collectionView];
    
    UIView *superView = self.contentView;
    
    // 添加相对布局
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *constrainArray = @[@(NSLayoutAttributeTop),@(NSLayoutAttributeBottom),@(NSLayoutAttributeLeading),@(NSLayoutAttributeTrailing),@(NSLayoutAttributeWidth)];
    
    [constrainArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:_collectionView
                                                              attribute:obj.intValue
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:superView
                                                              attribute:obj.intValue
                                                             multiplier:1.0
                                                               constant:0]];
    }];
    

    
//    // 添加相对布局
//    lineView.translatesAutoresizingMaskIntoConstraints = NO;
//    void(^labelConstraintBlock)( NSLayoutAttribute,UIView *,CGFloat)  = ^(NSLayoutAttribute layoutAttribte,UIView *toItem,CGFloat value){
//        
//        switch (layoutAttribte) {
//            case NSLayoutAttributeHeight:
//            case NSLayoutAttributeWidth:
//                toItem = nil;
//                break;
//            default:
//                break;
//        }
//        [superView addConstraint:[NSLayoutConstraint constraintWithItem:lineView
//                                                              attribute:layoutAttribte
//                                                              relatedBy:NSLayoutRelationEqual
//                                                                 toItem:toItem
//                                                              attribute:layoutAttribte
//                                                             multiplier:1.0
//                                                               constant:value]];
//    };
//    labelConstraintBlock(NSLayoutAttributeBottom,superView,-0.5);
//    labelConstraintBlock(NSLayoutAttributeHeight,superView,0.5);
//    labelConstraintBlock(NSLayoutAttributeLeading,superView,15);
//    labelConstraintBlock(NSLayoutAttributeTrailing,superView,-15);

}

- (void)reloadData
{
    [_collectionView scrollRectToVisible:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) animated:NO];
    [_collectionView reloadData];
}


#pragma mark - UICollectionView data source

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.delegate horizontalCellContentsView:collectionView numberOfItemsInTableViewIndexPath:self.tableViewIndexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate horizontalCellContentsView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return[self.delegate horizontalCellContentsView:collectionView cellForItemAtContentIndexPath:indexPath inTableViewIndexPath:self.tableViewIndexPath];
}

#pragma mark - UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate horizontalCellContentsView:collectionView didSelectItemAtContentIndexPath:indexPath inTableViewIndexPath:self.tableViewIndexPath];
}

- (CGFloat)pageWidth {
    return _collectionView.frame.size.width / 3.5;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat rawPageValue = self.collectionView.contentOffset.x / self.pageWidth;
    CGFloat currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
    CGFloat nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
    
    BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
    BOOL flicked = fabs(velocity.x) > [self flickVelocity];
    if (pannedLessThanAPage && flicked) {
        proposedContentOffset.x = nextPage * self.pageWidth;
    } else {
        proposedContentOffset.x = round(rawPageValue) * self.pageWidth;
    }
    
    return proposedContentOffset;
}

- (CGFloat)flickVelocity {
    return 0.3;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
