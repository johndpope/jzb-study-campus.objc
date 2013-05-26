#import "DPAnnotationView.h"

NSString *const DPAnnotationViewDidFinishDrag = @"DPAnnotationViewDidFinishDrag";
NSString *const DPAnnotationViewKey = @"DPAnnotationView";

// Estimate a finger size
// This is the amount of pixels I consider
// that the finger will block when the user
// is dragging the pin.
// We will use this to lift the pin even higher during dragging

#define kFingerSize 20.0

@interface DPAnnotationView()
@property (nonatomic, assign) CGPoint fingerPoint;
@property (nonatomic, strong) UIImage *prevImage;

@end

@implementation DPAnnotationView
//@synthesize dragState, fingerPoint, mapView;

- (void)setDragState:(MKAnnotationViewDragState)newDragState animated:(BOOL)animated
{
    
    UIImage *crosshairImg = [self _crosshairImage];

    // Calculate how much to lift the pin, so that it's over the finger, no under.
    CGFloat liftValue = self.frame.size.height - self.fingerPoint.y + kFingerSize + crosshairImg.size.height;

    
    // Do depending on new drag state
    switch (newDragState) {
            
        case MKAnnotationViewDragStateStarting:
        {
            // lift the pin with an animation to let the user see it while moving.
            self.prevImage = self.image;
            [UIView animateWithDuration:0.2
                             animations:^{
                                 // New view center
                                 CGPoint endPoint = CGPointMake(self.center.x, self.center.y-liftValue);
                                 
                                 // Sets image and center
                                 self.image = [self _createDraggingImage];
                                 self.center = endPoint;
                             }
                             completion:^(BOOL finished){
                                 self.dragState = MKAnnotationViewDragStateDragging;
                             }];
        } break;
            
        case MKAnnotationViewDragStateEnding:
        {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 // lift the pin again, and drop it to current placement with faster animation.
                                 CGPoint endPoint = CGPointMake(self.center.x, self.center.y - liftValue);
                                 self.center = endPoint;
                             }
                             completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      CGPoint endPoint = CGPointMake(self.center.x,self.center.y + liftValue);
                                                      self.image = self.prevImage;
                                                      self.prevImage = nil;
                                                      self.center = endPoint;
                                                  }
                                                  completion:^(BOOL finished){
                                                      self.dragState = MKAnnotationViewDragStateNone;
                                                  }];
                             }];
        } break;
            
        case MKAnnotationViewDragStateCanceling:
        {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 // drop the pin and set the state to none
                                 CGPoint endPoint = CGPointMake(self.center.x,self.center.y+liftValue);
                                 self.image = self.prevImage;
                                 self.prevImage = nil;
                                 self.center = endPoint;
                             }
                             completion:^(BOOL finished){
                                 self.dragState = MKAnnotationViewDragStateNone;
                             }];
        } break;
            
        case MKAnnotationViewDragStateNone:
        case MKAnnotationViewDragStateDragging:
            // No se hace nada para estos casos
            self.dragState = newDragState;
            break;

    }
    
    
}

- (id) initWithAnnotation: (id <MKAnnotation>) annotation reuseIdentifier: (NSString *) reuseIdentifier
{
    self = [super initWithAnnotation: annotation reuseIdentifier: reuseIdentifier];
    if (self != nil)
    {
        self.frame = CGRectMake(0, 0, 30, 30);
        self.opaque = NO;
    }
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    // When the user touches the view, we need his point so we can calculate by how
    // much we should life the annotation, this is so that we don't hide any part of
    // the pin when the finger is down.
    
    self.fingerPoint = point;
    return [super hitTest:point withEvent:event];
}

- (void)setSelected:(BOOL)selected {
    NSLog(@"----> setSetelected 1");
    [super setSelected:selected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    NSLog(@"----> setSetelected 2");
    [super setSelected:selected animated:animated];
}


- (void) drawRect:(CGRect)rect {
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
    CGContextSetStrokeColor(c, red);
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, 5.0f, 5.0f);
    CGContextAddLineToPoint(c, 50.0f, 50.0f);
    CGContextMoveToPoint(c, 5.0f, 50.0f);
    CGContextAddLineToPoint(c, 50.0f, 5.0f);
    CGContextStrokePath(c);
    
    /*
     
     
    UIGraphicsBeginImageContext(rect.size);
    [drawImage.image drawInRect:CGRectMake(0, 0, self.drawImage.frame.size.width, self.drawImage.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.5, 0.6, 1.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     */
}

- (UIImage *) _crosshairImage {
    
    static __strong UIImage *__crosshairImg = nil;
    
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        __crosshairImg = [UIImage imageNamed:@"crosshair.png"];
    });
    return __crosshairImg;
}

- (UIImage *) _createDraggingImage {
    
    UIImage *crosshair = [self _crosshairImage];

    CGSize imgSize = CGSizeMake(self.image.size.width, self.image.size.height + crosshair.size.height);
    
	UIGraphicsBeginImageContext(imgSize);
    
	[self.image drawAtPoint:CGPointZero];
    [crosshair drawAtPoint:CGPointMake((self.image.size.width-crosshair.size.width)/2, self.image.size.height)];
    
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
    return retImage;
}

@end