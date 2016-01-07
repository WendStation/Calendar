

#import <Foundation/Foundation.h>


typedef void (^ PostSubmitMeetingSuccessBlock) ();
typedef void (^ PostSubmitMeetingFailedBlock) ();

@interface SubmitMeetingDatasource : NSObject


- (void)submitMeeting:(NSMutableDictionary *)paraDic
              succeed:(PostSubmitMeetingSuccessBlock)succeed
               failed:(PostSubmitMeetingFailedBlock)failed;


@end
