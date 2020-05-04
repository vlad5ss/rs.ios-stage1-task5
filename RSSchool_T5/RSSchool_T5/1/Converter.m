#import "Converter.h"
#import <Foundation/Foundation.h>

// Do not change
NSString *KeyPhoneNumber = @"phoneNumber";
NSString *KeyCountry = @"country";
NSString *KeyCountryCode = @"countryCode";
const int MaxNumberLength = 12;

@implementation PNConverter
static NSString *trimPlus(NSString *string) {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+"]];
}

static NSDictionary *getCountryInfo(NSString *string){
    NSMutableDictionary *result =  [@{KeyCountry:@"", KeyCountryCode: @""} mutableCopy];
    if(!string || string.length == 0) return [result copy];
    NSDictionary *countryCodes = @{
                                   @"77"  : @{KeyCountry: @"KZ", KeyCountryCode : @"7"  },
                                   @"7"   : @{KeyCountry: @"RU", KeyCountryCode : @"7"   },
                                   @"373" : @{KeyCountry: @"MD", KeyCountryCode : @"373" },
                                   @"374" : @{KeyCountry: @"AM", KeyCountryCode : @"374" },
                                   @"375" : @{KeyCountry: @"BY", KeyCountryCode : @"375" },
                                   @"380" : @{KeyCountry: @"UA", KeyCountryCode : @"380" },
                                   @"992" : @{KeyCountry: @"TJ", KeyCountryCode : @"992" },
                                   @"993" : @{KeyCountry: @"TM", KeyCountryCode : @"993" },
                                   @"994" : @{KeyCountry: @"AZ", KeyCountryCode : @"994" },
                                   @"996" : @{KeyCountry: @"KG", KeyCountryCode : @"996" },
                                   @"998" : @{KeyCountry: @"UZ", KeyCountryCode : @"998" }};
    
    for(NSString *code in countryCodes.allKeys){
        if([string rangeOfString:code].location == 0){
            result[KeyCountry] = countryCodes[code][KeyCountry];
            result[KeyCountryCode] = countryCodes[code][KeyCountryCode];
        }
    }
    
    return [result copy];
}

static NSString *format(NSString *string, NSString *country){
    if(!string || string.length == 0 || !country || country.length == 0) return string;
    
    NSDictionary *formats = @{
                              @"RU" : @"(xxx) xxx-xx-xx",
                              @"KZ" : @"(xxx) xxx-xx-xx",
                              @"MD" : @"(xx) xxx-xxx",
                              @"AM" : @"(xx) xxx-xxx",
                              @"BY" : @"(xx) xxx-xx-xx",
                              @"UA" : @"(xx) xxx-xx-xx",
                              @"TJ" : @"(xx) xxx-xx-xx",
                              @"TM" : @"(xx) xxx-xxx",
                              @"AZ" : @"(xx) xxx-xx-xx",
                              @"KG" : @"(xx) xxx-xx-xx",
                              @"UZ" : @"(xx) xxx-xx-xx"
                              };
    
    NSString *format = [formats objectForKey:country];
    if(!format) return string;
    
    NSMutableString *formatNumber = [NSMutableString new];
    for(int i = 0, j = 0; i < format.length && j < string.length; i++){
        NSString *formatChar = [format substringWithRange:NSMakeRange(i, 1)];
        NSString *numberChar = [string substringWithRange:NSMakeRange(j, 1)];
        if([formatChar isEqualToString:@"x"]){
            [formatNumber appendString:numberChar];
            j++;
        } else {
            [formatNumber appendString:formatChar];
        }
    }
    
    return [formatNumber copy];
}


- (NSDictionary*)converToPhoneNumberNextString:(NSString*)string; {
    NSMutableDictionary *result = [@{KeyPhoneNumber: @"", KeyCountry: @""} mutableCopy];
    if(!string || string.length == 0)
        return [result copy];
    
    NSString *formatString = trimPlus(string);
    NSDictionary *countryInfo = getCountryInfo(formatString);
    NSString *countryCode = countryInfo[KeyCountryCode];
    NSString *country = countryInfo[KeyCountry];
    if(country.length == 0) {
        if(formatString.length > MaxNumberLength){
            formatString = [formatString substringWithRange:NSMakeRange(0, MaxNumberLength)];
        }
        result[KeyPhoneNumber] = [NSString stringWithFormat:@"+%@", formatString];
    } else {
        formatString = [string substringFromIndex:countryCode.length];
        formatString = format(formatString, country);
        NSMutableString *resultString = [NSMutableString new];
        [resultString appendString:@"+"];
        [resultString appendString:countryCode];
        if(formatString.length > 0){
            [resultString appendFormat:@" %@", formatString];
        }
        
        result[KeyPhoneNumber] = [resultString copy];
        result[KeyCountry] = country;
    }
    
    return [result copy];
}
@end
