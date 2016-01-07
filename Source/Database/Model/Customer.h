//
//  Customer.h
//  Calendar
//
//  Created by 小华 on 15/10/21.
//
//

#import <CoreData/CoreData.h>

@interface Customer : NSManagedObject

@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * type;
@end
