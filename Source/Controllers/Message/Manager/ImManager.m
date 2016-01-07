//
//  ImManager.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/11.
//
//

#import "ImManager.h"
#import "GroupListDatasource.h"
@interface ImManager()

@property (nonatomic, strong) GroupListDatasource * DS;
@property (nonatomic, assign) BOOL isStart;

@end
@implementation ImManager

+ (instancetype)shareInstance {
    static ImManager *im = nil;
    static dispatch_once_t  predicate;
    dispatch_once(&predicate, ^{
        im = [[ImManager alloc] init];
        im.DS = [[GroupListDatasource alloc] init];
        im.mesageRequestCircleSeconds = 60;
        im.groupListRequestCircleSeconds = 60;
        im.isStart = NO;
    });
    return im;
}

- (void)requestGlobalMessage {
    [self.DS postGlobalNewMessage:NO groupId:@"-1" succeed:^(id object) {
        [self performSelector:@selector(requestGlobalMessage) withObject:nil afterDelay:self.mesageRequestCircleSeconds];
    } failed:^(id object) {
        [self performSelector:@selector(requestGlobalMessage) withObject:nil afterDelay:self.mesageRequestCircleSeconds];
    }];
}

- (void)requestGroupList {
  [self.DS postGroupListSucceed:^(id object) {
      [self performSelector:@selector(requestGroupList) withObject:nil afterDelay:self.groupListRequestCircleSeconds];
  } failed:^(id object) {
      [self performSelector:@selector(requestGroupList) withObject:nil afterDelay:self.groupListRequestCircleSeconds];
  }];
}

-(void)onStart {
    if ([[NetworkManager sharedInstance] checkNetAndToken] && !self.isStart) {
        self.isStart = YES;
        [self requestGlobalMessage];
        [self requestGroupList];
    }
}

-(void)onStop {
    if (self.isStart) {
        [ImManager cancelPreviousPerformRequestsWithTarget:self];
        self.isStart = NO;
    }
}

@end
