//
//  ViewController.m
//  ios_core_animation-OC
//
//  Created by ma c on 2018/9/11.
//  Copyright © 2018年 ma c. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKit.h>
#import "UIView+DHTransform3D.h"
#import "DHVector.h"
#import <objc/runtime.h>
#define LIGHT_DIRECTION 1, 0, 0
#define AMBIENT_LIGHT 0.5
@interface ViewController ()
//@property (nonatomic, strong) UIView * transformView;

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *face;

@end

@implementation ViewController
- (void)applyLightingToFace:(CALayer *)face
{
    //add lighting layer
    CALayer *layer = [CALayer layer];
    layer.frame = face.bounds;
    [face addSublayer:layer];
    //convert the face transform to matrix
    //(GLKMatrix4 has the same structure as CATransform3D)
    CATransform3D transform = face.transform;
    GLKMatrix4 matrix4 = *(GLKMatrix4 *)&transform;
    GLKMatrix3 matrix3 = GLKMatrix4GetMatrix3(matrix4);
    //get face normal
    GLKVector3 normal = GLKVector3Make(1, 0, 0);
    normal = GLKMatrix3MultiplyVector3(matrix3, normal);
    normal = GLKVector3Normalize(normal);
    //get dot product with light direction
    GLKVector3 light = GLKVector3Normalize(GLKVector3Make(LIGHT_DIRECTION));
    float dotProduct = GLKVector3DotProduct(light, normal);
    //set lighting layer opacity
    CGFloat shadow = 1 + dotProduct - AMBIENT_LIGHT;
    UIColor *color = [UIColor colorWithWhite:0 alpha:shadow];
    layer.backgroundColor = color.CGColor;
}

- (void)addFace:(NSInteger)index withTransform:(CATransform3D)transform
{
    //get the face view and add it to the container
    UIView *face = self.face[index];

//    [face setUserInteractionEnabled:YES];
    face.tag = index;
    [self.containerView addSubview:face];
    //center the face view within the container
    CGSize containerSize = self.containerView.bounds.size;
    face.center = CGPointMake(containerSize.width / 2.0, containerSize.height / 2.0);
    // apply the transform
    face.layer.transform = transform;
    face.layer.contentsScale = [[UIScreen mainScreen] scale];
    //apply lighting
//    [self applyLightingToFace:face.layer];
    
    [face addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceonPanGesture:)]];
}


- (void)faceonPanGesture:(UITapGestureRecognizer *)sender
{
    
    [self performSelector:@selector(fooFirstInput:) withObject:sender.view];
}

-(void)fooFirstInput:(UIView*)view{
    NSLog(@"%d",view.tag);
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.containerView.transformUnit = 2.5;
//    self.containerView.center = self.view.center;
    self.containerView.backgroundColor = [UIColor clearColor];
//    self.containerView.layer.contents = (__bridge id)[UIImage imageNamed:@"1.jpg"].CGImage;
    [self.containerView prepareForTransform3D];
    
    //set up the container sublayer transform
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / 1000.0;
//    perspective = CATransform3DRotate(perspective, -M_PI_4, 1, 0, 0);
//    perspective = CATransform3DRotate(perspective, -M_PI_4, 0, 1, 0);
//    perspective = CATransform3DTranslate(perspective, 0, 200, 0);
    self.containerView.layer.sublayerTransform = perspective;
    self.containerView.layer.contentsScale = [[UIScreen mainScreen] scale];
    //add cube face 1
    CATransform3D transform = CATransform3DMakeTranslation(0, 0, 100);
    [self addFace:0 withTransform:transform];
    //add cube face 2
    transform = CATransform3DMakeTranslation(100, 0, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
    [self addFace:1 withTransform:transform];
    //add cube face 3
    transform = CATransform3DMakeTranslation(0, -100, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 1, 0, 0);
    [self addFace:2 withTransform:transform];
    //add cube face 4
    transform = CATransform3DMakeTranslation(0, 100, 0);
    transform = CATransform3DRotate(transform, -M_PI_2, 1, 0, 0);
    [self addFace:3 withTransform:transform];
    //add cube face 5
    transform = CATransform3DMakeTranslation(-100, 0, 0);
    transform = CATransform3DRotate(transform, -M_PI_2, 0, 1, 0);
    [self addFace:4 withTransform:transform];
    //add cube face 6
    transform = CATransform3DMakeTranslation(0, 0, -100);
    transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
    [self addFace:5 withTransform:transform];

    [self addAnimation];
    
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)]];
    
//    [self.view setUserInteractionEnabled:YES];
//    [self.containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPinchGesture:)]];
   
}
- (void)addAnimation
{
    self.containerView.layer.sublayerTransform = CATransform3DRotate(self.containerView.layer.sublayerTransform, M_PI/9.0, 0.5, 0.5, 0.5);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.rotation.y"];
    animation.toValue = @(MAXFLOAT);
    animation.duration = MAXFLOAT;
    [self.containerView.layer addAnimation:animation forKey:@"rotation"];
}

#pragma mark - callback
- (void)onPanGesture:(UIPanGestureRecognizer *)sender
{
    static CGPoint start;
    if (sender.state == UIGestureRecognizerStateBegan) {
        start = [sender locationInView:self.containerView];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        

        [self.containerView setTransform3DWithPanTranslation:[sender translationInView:sender.view] withView:self.containerView];
        
        
    } else if (sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateEnded) {
        
    }
}
- (void)onPinchGesture:(UITapGestureRecognizer *)gesture
{
    static CGPoint start;
    start = [gesture locationInView:self.containerView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
