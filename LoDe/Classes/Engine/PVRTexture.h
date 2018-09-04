#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <UIKit/UIKit.h>

//class DataBuffer;

@interface PVRTexture : NSObject {
	NSMutableArray *_imageData;
	GLuint _name;
//	uint32_t _width, _height;
	int _width, _height;
	GLenum _internalFormat;
//	BOOL _hasAlpha;
}

- (id)initWithContentsOfFile:(NSString *)path;

@property (readonly) GLuint name;
//@property (readonly) uint32_t width;
//@property (readonly) uint32_t height;
@property (readonly) int width;
@property (readonly) int height;
@property (readonly) GLenum internalFormat;
//@property (readonly) BOOL hasAlpha;

@end