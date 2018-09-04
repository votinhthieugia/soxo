//
//  EAGLView.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Director.h"
#import "EAGLView.h"
#import "Touch.h"

@implementation EAGLView

#define MAX_TOUCHES (64)

@synthesize surfaceSize=_size;
@synthesize framebuffer = _framebuffer;
@synthesize pixelFormat = _format;
@synthesize context = _context;
@synthesize activeTouches;

+ (Class)layerClass {
	return [CAEAGLLayer class];
}

- (BOOL)_createSurface {
	CAEAGLLayer*	eaglLayer = (CAEAGLLayer*)[self layer];
	CGSize			newSize;
	GLuint			oldRenderbuffer;
	GLuint			oldFramebuffer;
	
	if(![EAGLContext setCurrentContext:_context]) {
		return NO;
	}
	
	newSize = [eaglLayer bounds].size;
	newSize.width = roundf(newSize.width);
	newSize.height = roundf(newSize.height);
	
	glGetIntegerv(GL_RENDERBUFFER_BINDING_OES, (GLint *) &oldRenderbuffer);
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, (GLint *) &oldFramebuffer);
	
	glGenRenderbuffersOES(1, &_renderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderbuffer);
	
	if(![_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:eaglLayer]) {
		glDeleteRenderbuffersOES(1, &_renderbuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_BINDING_OES, oldRenderbuffer);
		return NO;
	}

	glGenFramebuffersOES(1, &_framebuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, _framebuffer);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _renderbuffer);

	_size = newSize;
	if(!_hasBeenCurrent) {
		glViewport(0, 0, newSize.width, newSize.height);
		glScissor(0, 0, newSize.width, newSize.height);
		_hasBeenCurrent = YES;
	}
	else {
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFramebuffer);
	}
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, oldRenderbuffer);

	return YES;
}

- (void)_destroySurface {
	EAGLContext *oldContext = [EAGLContext currentContext];
	
	if (oldContext != _context) {
		[EAGLContext setCurrentContext:_context];
	}

	glDeleteRenderbuffersOES(1, &_renderbuffer);
	_renderbuffer = 0;

	glDeleteFramebuffersOES(1, &_framebuffer);
	_framebuffer = 0;
	
	if (oldContext != _context) {
		[EAGLContext setCurrentContext:oldContext];
	} else {
		[EAGLContext setCurrentContext:nil];
	}
}

- (id)initWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained {
	if ((self = [super initWithFrame:frame])) {
		[self setOpaque:YES];
		
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*)[self layer];

		[eaglLayer setDrawableProperties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:retained], kEAGLDrawablePropertyRetainedBacking, format, kEAGLDrawablePropertyColorFormat, nil]];
		_format = format;
		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		[self _createSurface];

		touches = new map<UITouch *, Touch *>();
		inactiveTouches = new vector<Touch *>();
		activeTouches = new vector<Touch *>();
		for (int i = 0; i < MAX_TOUCHES; i++) {
			Touch *touch = new Touch();
			inactiveTouches->push_back(touch);

			// Preset the capacity to remove future reallocations.
			activeTouches->push_back(touch);
		}
		for (int i = 0; i < MAX_TOUCHES; i++) {
			activeTouches->pop_back();
		}

		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0f / 30.0f)];
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];

		switch ([[UIApplication sharedApplication] statusBarOrientation]) {
			case UIInterfaceOrientationPortrait:
				offsetX = 0.0f;
				offsetY = 0.0f;
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				offsetX = 0.0f;
				offsetY = -10.0f;
				break;
			case UIInterfaceOrientationLandscapeLeft:
				offsetX = 9.0f;
				offsetY = 0.0f;
				break;
			case UIInterfaceOrientationLandscapeRight:
				offsetX = -9.0f;
				offsetY = 0.0f;
				break;
			default:
				offsetX = 0.0f;
				offsetY = 0.0f;
				break;
		}
	}

	return self;
}

- (void)dealloc {
	for (int i = 0; i < MAX_TOUCHES; i++) {
		delete(activeTouches->back());
		activeTouches->pop_back();
	}
	delete(activeTouches);
	for (int i = 0; i < MAX_TOUCHES; i++) {
		delete(inactiveTouches->back());
		inactiveTouches->pop_back();
	}
	delete(inactiveTouches);
	delete(touches);
	[self _destroySurface];
	[_context release];
	[super dealloc];
}

- (void)setCurrentContext {
	if(![EAGLContext setCurrentContext:_context]) {
		printf("Failed to set current context %p in %s\n", _context, __FUNCTION__);
	}
}

- (BOOL)isCurrentContext {
	return ([EAGLContext currentContext] == _context);
}

- (void)clearCurrentContext {
	if(![EAGLContext setCurrentContext:nil])
		printf("Failed to clear current context in %s\n", __FUNCTION__);
}

- (void)swapBuffers {
//	EAGLContext *oldContext = [EAGLContext currentContext];
	//GLuint oldRenderbuffer;
	
//	if (oldContext != _context) {
//		[EAGLContext setCurrentContext:_context];
//	}

	//glGetIntegerv(GL_RENDERBUFFER_BINDING_OES, (GLint *) &oldRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderbuffer);
	//glBindRenderbufferOES(GL_RENDERBUFFER_OES, _framebuffer);
	
//	if(![_context presentRenderbuffer:GL_RENDERBUFFER_OES])
//		printf("Failed to swap renderbuffer in %s\n", __FUNCTION__);
	[_context presentRenderbuffer:GL_RENDERBUFFER_OES];

//	if (oldContext != _context) {
//		[EAGLContext setCurrentContext:oldContext];
//	}
}

- (void)touchesBegan:(NSSet *)touchSet withEvent:(UIEvent *)event {
	[self touchesMoved:touchSet withEvent:event];
}

- (void)touchesMoved:(NSSet *)touchSet withEvent:(UIEvent *)event {
	for (UITouch *uiTouch in touchSet) {
		CGPoint location = [uiTouch locationInView:self];

		float tempLocationX = location.x + offsetX;
		float tempLocationY = location.y + offsetY;
		location.x = tempLocationY;
		location.y = 320.0f - tempLocationX;

		map<UITouch *, Touch *>::const_iterator touchPair = touches->find(uiTouch);
		if (touchPair == touches->end()) {
			Touch *touch = inactiveTouches->back();
			inactiveTouches->pop_back();
			touch->startX = location.x;
			touch->startY = location.y;
			touch->x = touch->startX;
			touch->y = touch->startY;
			touch->isHandled = NO;
			touch->isEnded = NO;
			touch->uiTouch = uiTouch;
			touches->insert(pair<UITouch *, Touch *>(uiTouch, touch));
			activeTouches->push_back(touch);
		} else {
			Touch *touch = touchPair->second;
			touch->x = location.x;
			touch->y = location.y;
		}
	}
}

- (void)touchesEnded:(NSSet *)touchSet withEvent:(UIEvent *)event {
	for (UITouch *uiTouch in touchSet) {
		map<UITouch *, Touch *>::const_iterator touchPair = touches->find(uiTouch);
		if (touchPair != touches->end()) {
			if (touchPair->second->isHandled) {
				inactiveTouches->push_back(touchPair->second);
				touches->erase(uiTouch);
				for (vector<Touch *>::iterator touch = activeTouches->begin(); touch != activeTouches->end(); touch++) {
					if ((*touch) == touchPair->second) {
						activeTouches->erase(touch);
						break;
					}
				}
			} else {
				touchPair->second->isEnded = YES;
			}
		}
	}
}

- (void)touchesCancelled:(NSSet *)touchSet withEvent:(UIEvent *)event {
	[self touchesEnded:touchSet withEvent:event];
}

- (void)handleAndClearEndedTouches {
	vector<Touch *>::iterator activeTouch = activeTouches->begin();
	while (activeTouch != activeTouches->end()) {
		if ((*activeTouch)->isEnded) {
			inactiveTouches->push_back(*activeTouch);
			touches->erase((*activeTouch)->uiTouch);
			activeTouch = activeTouches->erase(activeTouch);
		} else {
			(*activeTouch)->isHandled = YES;
			activeTouch++;
		}
	}
}

@end