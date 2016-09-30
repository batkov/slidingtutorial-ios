//
//  PRLElementView.h
//  Parallax
//
//  Created by VLADISLAV KIRIN on 10/5/15.
//  Copyright (c) 2015 Cleveroad Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LABEL_FONT [UIFont systemFontOfSize:28]
#define LABEL_COLOR [UIColor blackColor]

typedef NS_ENUM(NSInteger, PRLElementType) {
    PRLElementTypeImage,
    PRLElementTypeText,
};

@interface PRLElementView : UIView

@property (nonatomic, readonly) CGFloat xSlippingCoefficient;
@property (nonatomic, readonly) CGFloat ySlippingCoefficient;
@property (nonatomic, readonly) CGFloat offsetX;
@property (nonatomic, readonly) CGFloat offsetY;
@property (nonatomic, readonly) NSInteger pageNumber;
@property (nonatomic, readonly) NSString *imageName;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIFont *font;
@property (nonatomic, readonly) UIColor *color;
@property (nonatomic, readonly) PRLElementType type;
@property (nonatomic, readonly) CGRect originalFrame;

- (instancetype)initWithImageName:(NSString *)imageName
                          offsetX:(CGFloat)offsetX
                          offsetY:(CGFloat)offsetY
                             size:(CGSize) size
                       pageNumber:(NSInteger)pageNumber
             xSlippingCoefficient:(CGFloat)xSlippingCoefficient
             ySlippingCoefficient:(CGFloat)ySlippingCoefficient
                 scaleCoefficient:(CGFloat)scaleCoefficient
                   loggingEnabled:(BOOL)loggingEnabled;

- (instancetype)initWithTitle:(NSString *)title
                         font:(UIFont *)font
                        color:(UIColor *)color
                      offsetX:(CGFloat)offsetX
                      offsetY:(CGFloat)offsetY
                         size:(CGSize) size
                   pageNumber:(NSInteger)pageNumber
         xSlippingCoefficient:(CGFloat)xSlippingCoefficient
         ySlippingCoefficient:(CGFloat)ySlippingCoefficient
             scaleCoefficient:(CGFloat)scaleCoefficient
               loggingEnabled:(BOOL)loggingEnabled;

+ (CGFloat) skipViewHeight:(CGFloat) viewHeight;

@end
