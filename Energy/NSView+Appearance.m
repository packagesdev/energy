
#import "NSView+Appearance.h"

NSString * const NRG_NSAppearanceNameAqua=@"NSAppearanceNameAqua";

NSString * const NRG_NSAppearanceNameDarkAqua=@"NSAppearanceNameDarkAqua";

@implementation NSView (Appearance_NRG)

- (BOOL)NRG_isEffectiveAppareanceDarkAqua
{
	if (NSAppKitVersionNumber<NSAppKitVersionNumber10_14)
		return NO;
	
	if ([self conformsToProtocol:@protocol(NSAppearanceCustomization)]==NO)
		return NO;
	
	id tAppearance=self.effectiveAppearance;
	
	NSString * tBestMatch=(NSString *)[tAppearance performSelector:@selector(bestMatchFromAppearancesWithNames:) withObject:@[NRG_NSAppearanceNameAqua,NRG_NSAppearanceNameDarkAqua]];
	
	return [tBestMatch isEqualToString:NRG_NSAppearanceNameDarkAqua];
}

@end
