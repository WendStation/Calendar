//
//  MessageListItem.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/9.
//
//

#import "BaseItem.h"

@interface MessageListItem : BaseItem

@property(nonatomic, strong)NSString *messageId;
@property(nonatomic, strong)NSString *userId;
@property(nonatomic, strong)NSString *type;
@property(nonatomic, strong)NSString *subtype;
@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *text;
@property(nonatomic, strong)NSString *iOSText;
@property(nonatomic, strong)NSString *data;
@property(nonatomic, strong)NSString *read;
@property(nonatomic, strong)NSString *createBy;
@property(nonatomic, strong)NSString *creationTime;

//- (instancetype)initWithMessageListItem:(NSDictionary *)dict;

@end
