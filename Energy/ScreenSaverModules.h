
#import <AppKit/AppKit.h>

#import "ScreenSaverModule.h"

@interface ScreenSaverModules : NSObject

+ (id)sharedInstance;


- (Class)classForModule:(ScreenSaverModule *)inModule;

- (NSString *)pathForModuleName:(NSString *)inModuleName;
- (NSArray *)findAllModules;


- (id)loadModule:(ScreenSaverModule *)inModule frame:(NSRect)inFrame isPreview:(BOOL)isPreview;

- (ScreenSaverModule *)findModuleWithName:(NSString *)inName;
- (ScreenSaverModule *)moduleWithName:(NSString *)inName;

- (NSArray *)moduleNames;
- (NSString *)slideShowModuleName;
- (NSString *)basicModule;
- (NSString *)basicModuleName;

@end

