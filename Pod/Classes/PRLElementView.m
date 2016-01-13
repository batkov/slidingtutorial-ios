//
//  PRLElementView.m
//  Parallax
//
//  Created by VLADISLAV KIRIN on 10/5/15.
//  Copyright (c) 2015 Cleveroad Inc. All rights reserved.
//

#import "PRLElementView.h"

CGFloat const kHeightSkipView = 40.;

@interface PRLElementView ()

@property (nonatomic, readwrite) CGFloat slippingCoefficient;
@property (nonatomic, readwrite) CGFloat offsetX;
@property (nonatomic, readwrite) CGFloat offsetY;
@property (nonatomic, readwrite) NSInteger pageNumber;
@property (nonatomic, readwrite) NSString *imageName;

@property (nonatomic, readwrite) CGFloat centerXOffset;
@property (nonatomic, readwrite) CGFloat centerYOffset;
@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) UIFont *font;
@property (nonatomic, readwrite) PRLElementType type;

@end

@implementation PRLElementView

- (instancetype)initWithImageName:(NSString *)imageName
                          offsetX:(CGFloat)offsetX
                          offsetY:(CGFloat)offsetY
                       pageNumber:(NSInteger)pageNumber
              slippingCoefficient:(CGFloat)slippingCoefficient
                 scaleCoefficient:(CGFloat)scaleCoefficient
                   loggingEnabled:(BOOL)loggingEnabled
{
    UIImage *image = [UIImage imageNamed:imageName];
    if (!image) {
        if (loggingEnabled) {
            NSLog(@"PRLElementView: No image with name %@ loaded",imageName);
        }
        return nil;
    }
    
    CGSize destinationSize = CGSizeMake(image.size.width * scaleCoefficient, image.size.height * scaleCoefficient);
    UIGraphicsBeginImageContextWithOptions(destinationSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:resizedImage];
    
    CGFloat postionX = (SCREEN_WIDTH - resizedImage.size.width) / 2;
    CGFloat postionY = (SCREEN_HEIGHT - kHeightSkipView - resizedImage.size.height) / 2;
    
    if (self = [super initWithFrame:CGRectMake(postionX + offsetX * scaleCoefficient + SCREEN_WIDTH * slippingCoefficient * pageNumber,
                                               postionY + offsetY * scaleCoefficient,
                                               resizedImage.size.width,
                                               resizedImage.size.height)]) {
        self.slippingCoefficient = slippingCoefficient;
        self.offsetX = offsetX;
        self.offsetY = offsetY;
        self.pageNumber = pageNumber;
        self.imageName = imageName;
        self.type = PRLElementTypeImage;
        [self addSubview:imageView];
        
        if (loggingEnabled) {
            NSLog(@"PRLElementView: resized image %@", NSStringFromCGSize(resizedImage.size));
        }
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                         font:(UIFont *)font
                      offsetX:(CGFloat)offsetX
                      offsetY:(CGFloat)offsetY
                   pageNumber:(NSInteger)pageNumber
          slippingCoefficient:(CGFloat)slippingCoefficient
             scaleCoefficient:(CGFloat)scaleCoefficient
               loggingEnabled:(BOOL)loggingEnabled;
{
    if (![title length]) {
        if (loggingEnabled) {
            NSLog(@"PRLElementView: No text provided");
        }
        return nil;
    }
    CGSize destinationSize = [title sizeWithAttributes:@{NSFontAttributeName: LABEL_FONT}];
    
    CGFloat postionX = (SCREEN_WIDTH - destinationSize.width) / 2;
    CGFloat postionY = (SCREEN_HEIGHT - kHeightSkipView - destinationSize.height) / 2;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, destinationSize.width, destinationSize.height)];
    label.text = title;
    label.font = font;
    label.textColor = [UIColor whiteColor];
    
    if (self = [super initWithFrame:CGRectMake(postionX + offsetX * scaleCoefficient + SCREEN_WIDTH * slippingCoefficient * pageNumber,
                                               postionY + offsetY * scaleCoefficient,
                                               destinationSize.width,
                                               destinationSize.height)]) {
        self.slippingCoefficient = slippingCoefficient;
        self.offsetX = offsetX;
        self.offsetY = offsetY;
        self.pageNumber = pageNumber;
        self.title = title;
        self.font = font;
        self.type = PRLElementTypeText;
        [self addSubview:label];
        
        if (loggingEnabled) {
            NSLog(@"PRLElementView: added text %@", title);
        }
    }
    return self;
}

@end
