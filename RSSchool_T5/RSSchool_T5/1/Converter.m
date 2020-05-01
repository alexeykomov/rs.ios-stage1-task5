#import "Converter.h"

// Do not change
NSString *KeyPhoneNumber = @"phoneNumber";
NSString *KeyCountry = @"country";

@implementation PNConverter
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.countryNumberToCountryCode = @{
            @"375": @"BY",
            @"7": @"RU",
            @"373": @"MD",
            @"374": @"AM",
            @"380": @"UA",
            @"992": @"TJ",
            @"993": @"TM",
            @"994": @"AZ",
            @"996": @"KG",
            @"998": @"UZ",
        };
        
        self.countryCodeToNumberLength = @{
            @"BY": @9,
            @"KZ": @10,
            @"RU": @10,
            @"MD": @8,
            @"AM": @8,
            @"UA": @9,
            @"TJ": @9,
            @"TM": @8,
            @"AZ": @9,
            @"KG": @9,
            @"UZ": @9,
        };
        self.numberLengthToFormat = @{
            @"10": @"(xxx) xxx-xx-xx",
            @"9": @"(xx) xxx-xx-xx",
            @"8": @"(xx) xxx-xxx"
        };
    }
    return self;
}


- (NSDictionary*)converToPhoneNumberNextString:(NSString*)string; {
    // good luck
    
    NSString __block *foundCountryCode = nil;
    NSString __block *foundCountryNumber = nil;
    
    BOOL shouldAppendPlus = YES;
    if ([string length] > 0) {
        NSRange potentialPlus = NSMakeRange(0, 1);
        if ([[string substringWithRange:potentialPlus] isEqualToString:@"+"]) {
            shouldAppendPlus = NO;
        };
    }
    
    [self.countryNumberToCountryCode enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *keyAsString = (NSString*) key;
        NSString *valueAsString = (NSString*) obj;
        
        NSString *searchRegex = [@"^" stringByAppendingString:keyAsString];
        NSLog(@"Regexp: %@", searchRegex);
        NSRange searchedLocation = [string rangeOfString:searchRegex options:NSRegularExpressionSearch];
        NSLog(@"Found occurence of %@: %lu", searchRegex, (unsigned long)searchedLocation.location);
        if (searchedLocation.location != NSNotFound) {
            foundCountryNumber = keyAsString;
            foundCountryCode = valueAsString;
            if ([foundCountryCode isEqualToString:@"RU"]) {
                NSRange firstTwo = NSMakeRange(0, 2);
                if ([string length] >= 2 && [[string substringWithRange:firstTwo] isEqualToString:@"77"]) {
                    foundCountryCode = @"KZ";
                }
            }
        };
    }];
    
    NSMutableString *resultPhoneNumber = [[NSMutableString alloc] init];
    if (foundCountryCode == nil) {
        if (shouldAppendPlus) {
            [resultPhoneNumber appendString:@"+"];
        }
        if (shouldAppendPlus && [string length] > 12) {
            NSRange firstTwelve = NSMakeRange(0, 12);
            [resultPhoneNumber appendString:[string substringWithRange:firstTwelve]];
            return @{KeyPhoneNumber: resultPhoneNumber, KeyCountry: @""};
        }
        if (!shouldAppendPlus && [string length] > 13) {
            NSRange firstThirteen = NSMakeRange(0, 13);
            [resultPhoneNumber appendString:[string substringWithRange:firstThirteen]];
            return @{KeyPhoneNumber: resultPhoneNumber, KeyCountry: @""};
        }
        
        [resultPhoneNumber appendString:string];
        return @{KeyPhoneNumber: resultPhoneNumber, KeyCountry: @""};
    }
    
    NSLog(@"Found country code: %@", foundCountryCode);
    
    NSNumber *length = [self.countryCodeToNumberLength valueForKey:foundCountryCode];
    NSRange r = NSMakeRange([foundCountryNumber length], [string length] - [foundCountryNumber length]);
    NSString *phoneNumber = [string substringWithRange:r];
    NSMutableString *preferredFormat = [[NSMutableString alloc] initWithString:[self.numberLengthToFormat valueForKey:[length stringValue]]];
    
    int counterNumber = 0;
    int lastNumberPosition = [preferredFormat length] - 1;
    if ([phoneNumber length] > 0) {
        for (int counterFormatChar = 0; counterFormatChar < [preferredFormat length]; counterFormatChar++) {
            NSRange r = NSMakeRange(counterFormatChar, 1);
            if ([[preferredFormat substringWithRange:r] isEqualToString:@"x"]) {
                NSRange phoneRange = NSMakeRange(counterNumber, 1);
                NSString *phoneCharToTake = [phoneNumber substringWithRange:phoneRange];
                [preferredFormat replaceCharactersInRange:r withString:phoneCharToTake];
                
                counterNumber++;
                if (counterNumber == [phoneNumber length]) {
                    lastNumberPosition = counterFormatChar;
                    break;
                }
            }
        }
    }
    
    NSLog(@"Formatted phone number: %@", preferredFormat);
    NSRange tillLastNumber = NSMakeRange(0, lastNumberPosition + 1);
    if (shouldAppendPlus) {
        [resultPhoneNumber appendString:@"+"];
    }
    [resultPhoneNumber appendString:foundCountryNumber];
    if ([phoneNumber length] > 0) {
        [resultPhoneNumber appendString:@" "];
        [resultPhoneNumber appendString:[preferredFormat substringWithRange:tillLastNumber]];
    }
    
    return @{KeyPhoneNumber: resultPhoneNumber,
             KeyCountry: foundCountryCode};
}
@end
