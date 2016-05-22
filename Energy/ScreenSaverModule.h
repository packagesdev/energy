
#import <AppKit/AppKit.h>

#define SSStandardType 0

/*#define SSQCType
#define SSMobileMeGalleryType
#define SSRSSFeedType
#define SSSlideshowType
#define SSUserPicturesType
#define SSILifeMediaType
#define SSShuffleType
#define SSRandomType
#define SSOtherType*/

@interface ScreenSaverModule : NSObject <NSCopying>

+ (NSString *)shuffleModuleName;
+ (NSString *)defaultModuleName;
+ (id)floatingMessageModuleWithMessage:(NSString *)inString;

+ (id)moduleWithName:(NSString *)inName;
+ (id)moduleWithPath:(NSString *)inPath;
+ (id)localizedSaverNameForPath:(NSString *)inPath;

- (int)type;
- (NSImage *)thumbnail;
- (NSString *)name;
- (NSString *)displayName;

- (BOOL)requiresGraphicsAcceleration;
- (BOOL)isQC;
- (BOOL)isSlideshow;
- (BOOL)isScreenSaver;

@end
