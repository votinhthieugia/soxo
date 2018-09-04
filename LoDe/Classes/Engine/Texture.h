//
//  Texture.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import <UIKit/UIKit.h>

//class DataBuffer;

//typedef enum {
//	kTexture2DPixelFormat_Automatic = 0,
//	kTexture2DPixelFormat_RGBA8888,
//	kTexture2DPixelFormat_RGB565,
//	kTexture2DPixelFormat_A8,
//} TexturePixelFormat;

// Texture2D class
// This class allows to easily create OpenGL 2D textures from images, text or raw data.
// The created Texture2D object will always have power-of-two dimensions. 
// Depending on how you create the Texture2D object, the actual image area of the texture might be smaller than the texture dimensions i.e. "contentSize" != (pixelsWide, pixelsHigh) and (maxS, maxT) != (1.0, 1.0).
// Be aware that the content of the generated textures will be upside-down!
class Texture {
private:
	GLfloat maxS;
	GLfloat maxT;
	GLfloat textureCoordinates[8];
	float columnMultiplier;
	float rowMultiplier;

public:
	GLuint name;
	NSUInteger width;
	NSUInteger height;
	int originalWidth;
	int originalHeight;
	int numFrameColumns;
	int numFrameRows;

public:
	Texture(NSString *filename, int numFrameColumns = 1, int numFrameRows = 1);
//	Texture(NSString* string, NSString* fontName, CGFloat fontSize);
//	Texture(NSString* string, CGSize dimensions, UITextAlignment alignment, NSString *fontName, CGFloat fontSize);
	Texture(NSString* string, NSUInteger cWidth, NSUInteger cHeight, UITextAlignment alignment, NSString* fontName, CGFloat fontSize);
	virtual ~Texture();

public:
	void draw(float x, float y, float scale = 1.0f);
	void drawMirror(float x, float y, float scale = 1.0f);

private:
	void loadImage(UIImage *uiImage);
};
