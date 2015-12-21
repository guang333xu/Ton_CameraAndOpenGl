//
//  ModelViewController.m
//  Ton_CameraAndOpenGl
//
//  Created by wang on 15/12/21.
//  Copyright © 2015年 wang. All rights reserved.
//

#import "ModelViewController.h"
#import "Ton_Transformations.h"

@interface ModelViewController ()
{
    float	angleA, angleB;
    float   cos, sin;
    float	r1, r2;
    float	h1, h2;
    GLfloat round[15768];
    float _rotation;
  
}

@property (strong, nonatomic) EAGLContext* context;

@property (strong, nonatomic) GLKBaseEffect* effect;

@property (strong, nonatomic) NSMutableArray* array;

@property (strong, nonatomic) Ton_Transformations *transformations;

@property (strong, nonatomic) UIPanGestureRecognizer *panGR;

@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGR;

@property (strong, nonatomic) UIRotationGestureRecognizer *rotationGR;

@end

@implementation ModelViewController

-(UIPanGestureRecognizer *)panGR{
    if (!_panGR) {
        _panGR = [[UIPanGestureRecognizer alloc] init];
        [_panGR addTarget:self action:@selector(panGR:)];
    }
    return _panGR;
}

-(UIPinchGestureRecognizer *)pinchGR{
    if (!_pinchGR) {
        _pinchGR = [[UIPinchGestureRecognizer alloc] init];
        [_pinchGR addTarget:self action:@selector(pinchGR:)];
    }
    return _pinchGR;
    
}

-(UIRotationGestureRecognizer *)rotationGR{
    if (!_rotationGR) {
        _rotationGR = [[UIRotationGestureRecognizer alloc] init];
        [_rotationGR addTarget:self action:@selector(rotationGR:)];
    }
    return _rotationGR;
}

-(NSMutableArray *)array{
    if (!_array) {
        _array = [NSMutableArray array];
    }
    return _array;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

//画球 完整函数
-(void)drawSphere{
    
    float	step = 5.0f;
    for (angleA = -90.0f; angleA < 90.0f; angleA += step) {
        
        r1 = cosf(angleA * M_PI / 180);
        r2 = cosf((angleA + step) * M_PI / 180);
        h1 = sinf(angleA * M_PI / 180);
        h2 = sinf((angleA + step) * M_PI / 180);
        
        for (angleB = 0.0f; angleB <= 360.0f; angleB += step) {
            cos = cosf(angleB * M_PI / 180);
            sin = - sinf(angleB * M_PI / 180);
            
            GLfloat x = (r2 * cos);
            GLfloat y = (h2);
            GLfloat z = (r2 * sin);
            GLfloat x1 = (r1 * cos);
            GLfloat y1 = (h1);
            GLfloat z1 = (r1 * sin);
            
            [self.array addObject:@(x)];
            [self.array addObject:@(y)];
            [self.array addObject:@(z)];
            [self.array addObject:@(x1)];
            [self.array addObject:@(y1)];
            [self.array addObject:@(z1)];
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self.view addGestureRecognizer:self.panGR];
    [self.view addGestureRecognizer:self.pinchGR];
    [self.view addGestureRecognizer:self.rotationGR];
    
    [self drawSphere];
        
    NSLog(@"%lu", (unsigned long)self.array.count);
    
    for (int i = 0; i < 15768; i++) {
        round[i] = [self.array[i] floatValue];
    }
    
    self.transformations = [[Ton_Transformations alloc] initWithDepth:5.0f Scale:2.0f Translation:GLKVector2Make(0.0f, 0.0f) Rotation:GLKVector3Make(0.0f, 0.0f, 0.0f)];
    
    [self createContext];
    
    [self createEffect];
    
}

-(void)createContext{
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // 将“view”的context设置为这个“EAGLContext”实例的引用。并且设置颜色格式和深度格式
    GLKView *view = (GLKView *)self.view;
    
    view.backgroundColor = [UIColor clearColor];
    
    view.context = self.context;
    
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    // 将此“EAGLContext”实例设置为OpenGL的“当前激活”的“Context”。这样，以后所有“GL”的指令均作用在这个“Context”上。随后，发送第一个“GL”指令：激活“深度检测”。
    [EAGLContext setCurrentContext:view.context];
    
    glEnable(GL_DEPTH_TEST);
}

-(void)createEffect{
    self.effect = [[GLKBaseEffect alloc] init];
    
    self.effect.light0.enabled = GL_TRUE;
    
    //灯光颜色，照射颜色
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f);
    self.effect.light0.ambientColor = GLKVector4Make(1.0f, 1.0f, 0.0f, 1.0f);
    self.effect.light0.specularColor = GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f);
    
    //声明一个缓冲区的标识（GLuint类型）
    GLuint buffer;
    
    // OpenGL自动分配一个缓冲区并且返回这个标识的值.绑定这个缓冲区到当前“Context”.最后，将我们前面预先定义的顶点数据“squareVertexData”复制进这个缓冲区中。
    glGenBuffers(1, &buffer);
    
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    
    // 注：参数“GL_STATIC_DRAW”，它表示此缓冲区内容只能被修改一次，但可以无限次读取。
    glBufferData(GL_ARRAY_BUFFER, sizeof(round), round, GL_STATIC_DRAW);
    
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 12,
                          (char*)NULL + 0);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    //    //将法线的数据复制进能用顶点属性
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 12,
                          (char *)NULL + 12);
    //
    //    //将纹理坐标的数据复制进能用顶点属性,因为纹理坐标只有两个（S和T），所以上面参数是“2”
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE,
                          12, (char *)NULL + 24);
    
    
}

- (void)glkView:(GLKView*)view drawInRect:(CGRect)rect
{
    
    //背景色
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    
    //表示要清除颜色缓冲以及深度缓冲
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    
    [self setMatrices];
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 5256);
}

- (void)setMatrices
{
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(
                                                            GLKMathDegreesToRadians(90.0f), aspect, 0.1f, 10.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
    //    _rotation += 90 * self.timeSinceLastUpdate;
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(25), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(
                                       modelViewMatrix, GLKMathDegreesToRadians(90), 1, 1, 0);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    GLKMatrix4 modelViewMatrix1 = [self.transformations getModelViewMatrix];
    
    self.effect.transform.modelviewMatrix = modelViewMatrix1;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Begin transformations
    [self.transformations start];
}

-(void)panGR:(UIPanGestureRecognizer *)sender{
    if (sender.numberOfTouches == 1) {
        const float m = GLKMathDegreesToRadians(0.5f);
        CGPoint rotation = [sender translationInView:sender.view];
        [self.transformations rotate:GLKVector3Make(rotation.x, rotation.y, 0.0f) withMultiplier:m];
        NSLog(@"1手拖动");
    }else if (sender.numberOfTouches == 2) {
        
        CGPoint translation = [sender translationInView:sender.view];
        float x = translation.x/sender.view.frame.size.width;
        float y = translation.y/sender.view.frame.size.height;
        [self.transformations translate:GLKVector2Make(x, y) withMultiplier:5.0f];
        NSLog(@"2手拖动");
    }

}

-(void)pinchGR:(UIPinchGestureRecognizer *)sender{
    NSLog(@"缩放");
    float scale = [sender scale];
    [self.transformations scale:scale];
}

-(void)rotationGR:(UIRotationGestureRecognizer *)sender{
    NSLog(@"旋转");
    float rotation = [sender rotation];
    [self.transformations rotate:GLKVector3Make(0.0f, 0.0f, rotation) withMultiplier:1.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
