//
//  Texture.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <OpenGLES/ES1/glext.h>
#import "PVRTexture.h"
#import "Texture.h"
#import "Utilities.h"

#define kMaxTextureSize (512)

typedef enum {
	kTexture2DPixelFormat_Automatic = 0,
	kTexture2DPixelFormat_RGBA8888,
	kTexture2DPixelFormat_RGB565,
	kTexture2DPixelFormat_A8,
} Texture2DPixelFormat;

Texture::Texture(NSString *filename, int numFrameColumns, int numFrameRows) :
	numFrameColumns(numFrameColumns),
	numFrameRows(numFrameRows) {
	if ([filename hasSuffix:@"pvr"]) {
		PVRTexture *pvr = [[PVRTexture alloc] initWithContentsOfFile:Utilities::fullPath(filename)];
		name = pvr.name;
		maxS = 1.0f;
		maxT = 1.0f;
		width = pvr.width;
		height = pvr.height;
		originalWidth = width;
		originalHeight = height;
		[pvr release];
	} else {
		loadImage([UIImage imageNamed:filename]);
	}

	textureCoordinates[0] = 0.0f;
	textureCoordinates[1] = 0.0f;
	textureCoordinates[2] = maxS;
	textureCoordinates[3] = 0.0f;
	textureCoordinates[4] = 0.0f;
	textureCoordinates[5] = maxT;
	textureCoordinates[6] = maxS;
	textureCoordinates[7] = maxT;

	columnMultiplier = 1.0f / numFrameColumns;
	rowMultiplier = 1.0f / numFrameRows;
}

Texture::~Texture() {
	if (name) {
		glDeleteTextures(1, &name);
	}
}

void Texture::loadImage(UIImage *uiImage) {
	NSUInteger w;
	NSUInteger h;
	NSUInteger i;
	CGContextRef context = nil;
	void *data = nil;
	CGColorSpaceRef colorSpace;
	//void *tempData;
	//unsigned int *inPixel32;
	//unsigned short *outPixel16;
	BOOL hasAlpha;
	CGImageAlphaInfo info;
	CGAffineTransform transform;
	CGSize imageSize;
	Texture2DPixelFormat pixelFormat;
	CGImageRef image;
//	BOOL sizeToFit = NO;

	image = [uiImage CGImage];
	info = CGImageGetAlphaInfo(image);
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
	size_t bpp = CGImageGetBitsPerComponent(image);
	if (CGImageGetColorSpace(image)) {
		if (hasAlpha || bpp >= 8) {
			pixelFormat = kTexture2DPixelFormat_RGBA8888;
		} else {
			pixelFormat = kTexture2DPixelFormat_RGB565;
		}
	} else {  //NOTE: No colorspace means a mask image
		pixelFormat = kTexture2DPixelFormat_A8;
	}

	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	transform = CGAffineTransformIdentity;

	originalWidth = imageSize.width;
	originalHeight = imageSize.height;

	w = imageSize.width;
	if ((w != 1) && (w & (w - 1))) {
		i = 1;
		while(i < w) {
		//while((sizeToFit ? 2 * i : i) < w) {
			i *= 2;
		}
		w = i;
	}
	h = imageSize.height;
	if ((h != 1) && (h & (h - 1))) {
		i = 1;
		while(i < h) {
		//while((sizeToFit ? 2 * i : i) < h) {
			i *= 2;
		}
		h = i;
	}
	while ((w > kMaxTextureSize) || (h > kMaxTextureSize)) {
		w /= 2;
		h /= 2;
		transform = CGAffineTransformScale(transform, 0.5f, 0.5f);
		imageSize.width *= 0.5f;
		imageSize.height *= 0.5f;
	}
	
	switch (pixelFormat) {		
		case kTexture2DPixelFormat_RGBA8888:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(h * w * 4);
			context = CGBitmapContextCreate(data, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
//		case kTexture2DPixelFormat_RGB565:
//			colorSpace = CGColorSpaceCreateDeviceRGB();
//			data = malloc(h * w * 4);
//			context = CGBitmapContextCreate(data, w, h, 8, 4 * w, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
//			CGColorSpaceRelease(colorSpace);
//			break;
//		case kTexture2DPixelFormat_A8:
//			data = malloc(h * w);
//			context = CGBitmapContextCreate(data, w, h, 8, width, NULL, kCGImageAlphaOnly);
//			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}

	CGContextClearRect(context, CGRectMake(0, 0, w, h));
	CGContextTranslateCTM(context, 0, h - imageSize.height);
	
	if (!CGAffineTransformIsIdentity(transform)) {
		CGContextConcatCTM(context, transform);
	}

	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
//	if (pixelFormat == kTexture2DPixelFormat_RGB565) {
//		tempData = malloc(h * w * 2);
//		inPixel32 = (unsigned int *)data;
//		outPixel16 = (unsigned short *)tempData;
//		for(i = 0; i < w * h; ++i, ++inPixel32) {
//			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
//		}
//		free(data);
//		data = tempData;
//	}

	//self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:width pixelsHigh:height contentSize:imageSize];
	GLint saveName;
	glGenTextures(1, &name);
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
	glBindTexture(GL_TEXTURE_2D, name);

	//[Texture2D applyTexParameters];
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	switch (pixelFormat) {
		case kTexture2DPixelFormat_RGBA8888:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
			break;
		default:
			break;
//		case kTexture2DPixelFormat_RGB565:
//			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, w, h, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
//			break;
//		case kTexture2DPixelFormat_A8:
//			glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, w, h, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
//			break;
	}

	glBindTexture(GL_TEXTURE_2D, saveName);

	width = w;
	height = h;
	maxS = imageSize.width / (float)width;
	maxT = imageSize.height / (float)height;

	CGContextRelease(context);
	free(data);
}

void Texture::draw(float x, float y, float scale) {
	GLfloat textureWidth = (GLfloat)width * maxS * scale;
	GLfloat textureHeight = (GLfloat)height * maxT * scale;

	GLfloat vertices[] = {
		x, y,
		textureWidth + x, y,
		x, textureHeight + y,
		textureWidth + x, textureHeight + y
	};

	glBindTexture(GL_TEXTURE_2D, name);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, textureCoordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

void Texture::drawMirror(float x, float y, float scale) {
	GLfloat textureWidth = (GLfloat)width * maxS * scale;
	GLfloat textureHeight = (GLfloat)height * maxT * scale;
	
	GLfloat vertices[] = {
		x, y,
		textureWidth + x, y,
		x, textureHeight + y,
		textureWidth + x, textureHeight + y
	};
	
	GLfloat coordinates[] = {
		0.0f, maxT,
		maxS, maxT,
		0.0f, 0.0f,
		maxS, 0.0f,
	};
	
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBindTexture(GL_TEXTURE_2D, name);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
}

//Texture::Texture(NSString* string, NSString* fontName, CGFloat fontSize) {
//	CGSize dimensions = [string sizeWithFont: [UIFont fontWithName:fontName size:fontSize]];
//	UITextAlignment alignment = UITextAlignmentCenter;
////	Texture(string, dim, UITextAlignmentCenter, fontName, fontSize);
//	NSUInteger				i;
//	CGContextRef			context;
//	void*					data;
//	CGColorSpaceRef			colorSpace;
//	UIFont *				font;
//	
//	font = [UIFont fontWithName:fontName size:fontSize];
//	
//	width = dimensions.width;
//	if((width != 1) && (width & (width - 1))) {
//		i = 1;
//		while(i < width)
//			i *= 2;
//		width = i;
//	}
//	height = dimensions.height;
//	if((height != 1) && (height & (height - 1))) {
//		i = 1;
//		while(i < height)
//			i *= 2;
//		height = i;
//	}
//	
//	colorSpace = CGColorSpaceCreateDeviceGray();
//	data = calloc(height, width);
//	context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
//	CGColorSpaceRelease(colorSpace);
//	
//	
//	CGContextSetGrayFillColor(context, 1.0f, 1.0f);
//	CGContextTranslateCTM(context, 0.0f, height);
//	CGContextScaleCTM(context, 1.0f, -1.0f); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
//	UIGraphicsPushContext(context);
//	[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
//	UIGraphicsPopContext();
//	
//	GLint saveName;
//	glGenTextures(1, &name);
//	glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
//	glBindTexture(GL_TEXTURE_2D, name);
//	
//	glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
//	glBindTexture(GL_TEXTURE_2D, saveName);
//	
//	maxS = dimensions.width / (float)width;
//	maxT = dimensions.height / (float)height;
//	
//	CGContextRelease(context);
//	free(data);
//}

//Texture::Texture(NSString* string, CGSize dimensions, UITextAlignment alignment, NSString *fontName, CGFloat fontSize) {
//	NSUInteger				i;
//	CGContextRef			context;
//	void*					data;
//	CGColorSpaceRef			colorSpace;
//	UIFont *				font;
//	
//	font = [UIFont fontWithName:fontName size:fontSize];
//
//	width = dimensions.width;
//	if((width != 1) && (width & (width - 1))) {
//		i = 1;
//		while(i < width)
//		i *= 2;
//		width = i;
//	}
//	height = dimensions.height;
//	if((height != 1) && (height & (height - 1))) {
//		i = 1;
//		while(i < height)
//		i *= 2;
//		height = i;
//	}
//	
//	colorSpace = CGColorSpaceCreateDeviceGray();
//	data = calloc(height, width);
//	context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
//	CGColorSpaceRelease(colorSpace);
//	
//	
//	CGContextSetGrayFillColor(context, 1.0f, 1.0f);
//	CGContextTranslateCTM(context, 0.0f, height);
//	CGContextScaleCTM(context, 1.0f, -1.0f); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
//	UIGraphicsPushContext(context);
//		[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
//	UIGraphicsPopContext();
//	
//	GLint saveName;
//	glGenTextures(1, &name);
//	glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
//	glBindTexture(GL_TEXTURE_2D, name);
//
//	glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
//	glBindTexture(GL_TEXTURE_2D, saveName);
//
//	maxS = dimensions.width / (float)width;
//	maxT = dimensions.height / (float)height;
//
//	CGContextRelease(context);
//	free(data);
//}

Texture::Texture(NSString *string, NSUInteger cWidth, NSUInteger cHeight, UITextAlignment alignment, NSString *fontName, CGFloat fontSize) {
	NSUInteger width;
	NSUInteger height;
	NSUInteger i;
	CGContextRef context;
	void *data;
	CGColorSpaceRef	colorSpace;
	UIFont *font;
	
	font = [UIFont fontWithName:fontName size:fontSize];
	
	width = cWidth;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while(i < width) {
			i *= 2;
		}
		width = i;
	}
	height = cHeight;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while(i < height) {
			i *= 2;
		}
		height = i;
	}
	
	colorSpace = CGColorSpaceCreateDeviceGray();
	data = calloc(height, width);
	context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	
	CGContextSetGrayFillColor(context, 1.0, 1.0);
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0); 
	UIGraphicsPushContext(context);
	[string drawInRect:CGRectMake(0, 0, width, height) withFont:font lineBreakMode:UILineBreakModeClip alignment:alignment];
	UIGraphicsPopContext();
	
	GLint saveName;
	glGenTextures(1, &name);
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
	glBindTexture(GL_TEXTURE_2D, name);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
	glBindTexture(GL_TEXTURE_2D, saveName);
	
	this->width = width;
	this->height = height;
	maxS = cWidth / (float)width;
	maxT = cHeight / (float)height;
	
	CGContextRelease(context);
	free(data);
	
	textureCoordinates[0] = 0.0f;
	textureCoordinates[1] = 0.0f;
	textureCoordinates[2] = maxS;
	textureCoordinates[3] = 0.0f;
	textureCoordinates[4] = 0.0f;
	textureCoordinates[5] = maxT;
	textureCoordinates[6] = maxS;
	textureCoordinates[7] = maxT;
}