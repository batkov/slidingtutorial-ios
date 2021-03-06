//
//  PRLView.h
//  Parallax
//
//  Created by VLADISLAV KIRIN on 10/9/15.
//  Copyright (c) 2015 Cleveroad Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PRLView;

@protocol PRLViewProtocol <NSObject>

@optional
/**
 This method calls when Skip button action pressed
 */
- (void)skipTutorialTappedOnView:(PRLView *) view;

/**
 This method calls when Done button pressed
 */
- (void)doneTutorialTappedOnView:(PRLView *) view;

/**
 This method calls when -prepareForShow called to customize skip button
 */
- (void)slideView:(PRLView *) view customizeSkipButton:(UIButton *) button;

@end

@interface PRLView : UIView

@property (assign, nonatomic) BOOL loggingEnabled; // Default is NO.

@property (assign, nonatomic) BOOL showBottomPanel; // Default is YES. Panel with skip button and pager

@property (assign, nonatomic) NSTimeInterval autoscrollTime; // Default is 4. Set 0 to disable

@property (weak, nonatomic) id <PRLViewProtocol> delegate;

/**
 Calls for instantiating Slipping Tutorial view
 
 @param pageCount - a count of pages in tutorial and second parameter is a coefficient of scaling images (put 1.0 if you don't need scale and images will displaying in a full size).
 @param scaleCoefficient - is a coefficient of scaling images (put 1.0 if you don't need scale and images will displaying in a full size).
 */
- (instancetype)initWithPageCount:(NSInteger)pageCount
                 scaleCoefficient:(CGFloat)scaleCoefficient;

/**
 Calls for instantiating Slipping Tutorial view
 
 @param pageCount - a count of pages in tutorial and second parameter is a coefficient of scaling images (put 1.0 if you don't need scale and images will displaying in a full size).
 @param scaleCoefficient - is a coefficient of scaling images (put 1.0 if you don't need scale and images will displaying in a full size).
 @param size - size for view.
 */
- (instancetype)initWithPageCount:(NSInteger)pageCount
                 scaleCoefficient:(CGFloat)scaleCoefficient
                             size:(CGSize)size;

/**
 Calls for instantiating Slipping Tutorial view
 
 @param pageCount - a count of pages in tutorial and second parameter is a coefficient of scaling images (put 1.0 if you don't need scale and images will displaying in a full size).
 @param scaleCoefficient - is a coefficient of scaling images (put 1.0 if you don't need scale and images will displaying in a full size).
 @param size - size for view.
 @param loggingEnabled - is a flag to enable or disable logging.
 */
- (instancetype)initWithPageCount:(NSInteger)pageCount
                 scaleCoefficient:(CGFloat)scaleCoefficient
                             size:(CGSize)size
                   loggingEnabled:(BOOL)loggingEnabled;


/**
 Calls for adding images onto sliding page
 
 @param name - image name from your project resources.
 @param offsetX and offsetY - layer offset from the center of the screen. If you send offsetX:0 offsetY:0 your image layer will be placed exactly in the center of the screen. Dot (0,0) in this coords system situated in the center of the screen in all device orientations.
 @param slippingCoefficient - ratio bound to scroll offset in scroll view. For 1 pixel content offset of scroll view layer will be slipping for 1 * slippingCoefficient (so if slippingCoefficient == 0.3, it will be equal 0.3px). Sign determines the direction of slipping - left or right.
 @param pageNum - the page number on which you will add this image layer.
 */
- (void)addElementWithName:(NSString *)elementName
                   offsetX:(CGFloat)offsetX
                   offsetY:(CGFloat)offsetY
       slippingCoefficient:(CGFloat)slippingCoefficient
                   pageNum:(NSInteger)pageNum;

/**
 Calls for adding images onto sliding page
 
 @param name - image name from your project resources.
 @param offsetX and offsetY - layer offset from the center of the screen. If you send offsetX:0 offsetY:0 your image layer will be placed exactly in the center of the screen. Dot (0,0) in this coords system situated in the center of the screen in all device orientations.
 @param xSlippingCoefficient - ratio bound to scroll X offset in scroll view. For 1 pixel content offset of scroll view layer will be slipping for 1 * slippingCoefficient (so if slippingCoefficient == 0.3, it will be equal 0.3px). Sign determines the direction of slipping - left or right.
 @param ySlippingCoefficient - ratio bound to scroll Y offset in scroll view. For 1 pixel content offset of scroll view layer will be slipping for 1 * slippingCoefficient (so if slippingCoefficient == 0.3, it will be equal 0.3px). Sign determines the direction of slipping - left or right.
 @param pageNum - the page number on which you will add this image layer.
 */
- (void)addElementWithName:(NSString *)elementName
                   offsetX:(CGFloat)offsetX
                   offsetY:(CGFloat)offsetY
      xSlippingCoefficient:(CGFloat)xSlippingCoefficient
      ySlippingCoefficient:(CGFloat)ySlippingCoefficient
                   pageNum:(NSInteger)pageNum;

/**
 Calls for adding text onto sliding page
 
 @param title - text to display.
 @param offsetX and offsetY - layer offset from the center of the screen. If you send offsetX:0 offsetY:0 your text layer will be placed exactly in the center of the screen. Dot (0,0) in this coords system situated in the center of the screen in all device orientations.
 @param slippingCoefficient - ratio bound to scroll offset in scroll view. For 1 pixel content offset of scroll view layer will be slipping for 1 * slippingCoefficient (so if slippingCoefficient == 0.3, it will be equal 0.3px). Sign determines the direction of slipping - left or right.
 @param pageNum - the page number on which you will add this text layer.
 */
- (void)addElementWithTitle:(NSString *)title
                    offsetX:(CGFloat)offsetX
                    offsetY:(CGFloat)offsetY
        slippingCoefficient:(CGFloat)slippingCoefficient
                    pageNum:(NSInteger)pageNum;

/**
 Calls for adding text onto sliding page
 
 @param title - text to display.
 @param font - UIFont for text to display.
 @param color - UIColor for text to display.
 @param offsetX and offsetY - layer offset from the center of the screen. If you send offsetX:0 offsetY:0 your text layer will be placed exactly in the center of the screen. Dot (0,0) in this coords system situated in the center of the screen in all device orientations.
 @param slippingCoefficient - ratio bound to scroll offset in scroll view. For 1 pixel content offset of scroll view layer will be slipping for 1 * slippingCoefficient (so if slippingCoefficient == 0.3, it will be equal 0.3px). Sign determines the direction of slipping - left or right.
 @param pageNum - the page number on which you will add this text layer.
 */
- (void)addElementWithTitle:(NSString *)title
                       font:(UIFont *)font
                      color:(UIColor *)color
                    offsetX:(CGFloat)offsetX
                    offsetY:(CGFloat)offsetY
        slippingCoefficient:(CGFloat)slippingCoefficient
                    pageNum:(NSInteger)pageNum;

/**
 Calls for adding text onto sliding page
 
 @param title - text to display.
 @param font - UIFont for text to display.
 @param color - UIColor for text to display.
 @param offsetX and offsetY - layer offset from the center of the screen. If you send offsetX:0 offsetY:0 your text layer will be placed exactly in the center of the screen. Dot (0,0) in this coords system situated in the center of the screen in all device orientations.
 @param slippingCoefficient - ratio bound to scroll offset in scroll view. For 1 pixel content offset of scroll view layer will be slipping for 1 * slippingCoefficient (so if slippingCoefficient == 0.3, it will be equal 0.3px). Sign determines the direction of slipping - left or right.
 @param pageNum - the page number on which you will add this text layer.
 */
- (void)addElementWithTitle:(NSString *)title
                       font:(UIFont *)font
                      color:(UIColor *)color
                    offsetX:(CGFloat)offsetX
                    offsetY:(CGFloat)offsetY
       xSlippingCoefficient:(CGFloat)xSlippingCoefficient
       ySlippingCoefficient:(CGFloat)ySlippingCoefficient
                    pageNum:(NSInteger)pageNum;
/**
 Calls for adding done button onto last page
 
 @param title - text to display on done button.
 @param offsetX and offsetY - layer offset from the center of the screen. If you send offsetX:0 offsetY:0 your text layer will be placed exactly in the center of the screen. Dot (0,0) in this coords system situated in the center of the screen in all device orientations.
 */
- (void)addDoneWithTitle:(NSString *)title
                 offsetX:(CGFloat)offsetX
                 offsetY:(CGFloat)offsetY;


/**
 Calls for adding background colors for all your tutorial pages
 The colors follow the order they are added. All missing colors will be replaced with white color.
 */
- (void)addBackgroundColor:(UIColor *)color;


/**
 Call this method after you finished preparing Sliding Tutorial view.
 */
- (void)prepareForShow;


@end
