
#import <Foundation/Foundation.h>

@interface MPStyleManager : NSObject

+ (id)sharedManager;

- (NSArray *)allStyleIDs;

- (NSString *)localizedNameForStyleID:(NSString *)inStyleID;

@end