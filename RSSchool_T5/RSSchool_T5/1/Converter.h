#import <Foundation/Foundation.h>

extern NSString *KeyPhoneNumber;
extern NSString *KeyCountry;

@interface PNConverter : NSObject
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>* countryNumberToCountryCode;
@property (nonatomic, strong) NSDictionary<NSString*, NSNumber*>* countryCodeToNumberLength;
@property (nonatomic, strong) NSDictionary<NSNumber*, NSString*>* numberLengthToFormat;

- (NSDictionary*)converToPhoneNumberNextString:(NSString*)string;
@end


