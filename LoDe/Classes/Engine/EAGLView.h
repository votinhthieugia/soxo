//
//  EAGLView.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <map>
#import <vector>
using namespace std;

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <UIKit/UIKit.h>
#import "Touch.h"

/** EAGLView Class
 * This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
 * The view content is basically an EAGL surface you render your OpenGL scene into.
 * Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
 */
@interface EAGLView : UIView <UIAccelerometerDelegate> {
@private
	NSString*				_format;
	EAGLContext				*_context;
	GLuint					_framebuffer;
	GLuint					_renderbuffer;
	CGSize					_size;
	BOOL					_hasBeenCurrent;
	map<UITouch *, Touch *> *touches;
	vector<Touch *> *inactiveTouches;
	vector<Touch *> *activeTouches;
	float offsetX;
	float offsetY;
}

- (id)initWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained;

@property(readonly) GLuint framebuffer;
@property(readonly) NSString* pixelFormat;
@property(readonly) EAGLContext *context;
@property(readonly, nonatomic) CGSize surfaceSize;
@property(readonly, nonatomic) vector<Touch *> *activeTouches;

- (void)setCurrentContext;
- (BOOL)isCurrentContext;
- (void)clearCurrentContext;
- (void)swapBuffers; //This also checks the current OpenGL error and logs an error if needed
- (void)handleAndClearEndedTouches;

@end