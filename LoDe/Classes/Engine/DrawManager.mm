//
//  DrawManager.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "DrawManager.h"

float DrawManager::red = 0.0f;
float DrawManager::green = 0.0f;
float DrawManager::blue = 0.0f;
float DrawManager::alpha = 0.0f;

BOOL DrawManager::isEnabledTextureCoordArray = NO;
BOOL DrawManager::isEnabledTexture2D = NO;
BOOL DrawManager::isEnabledColorArray = NO;
BOOL DrawManager::isEnabledSrcAlphaOne = NO;

BOOL DrawManager::enableTextureCoordArray = NO;
BOOL DrawManager::enableTexture2D = NO;
BOOL DrawManager::enableColorArray = NO;
BOOL DrawManager::enableSrcAlphaOne = NO;

void DrawManager::setColor(float r, float g, float b, float a) {
	if (r != red || g != green || b != blue || a != alpha) {
		red = r;
		green = g;
		blue = b;
		alpha = a;
		glColor4f(red, green, blue, alpha);
	}
}

void DrawManager::reset() {
	isEnabledTextureCoordArray = YES;
	isEnabledTexture2D = YES;
	isEnabledColorArray = NO;
	isEnabledSrcAlphaOne = NO;

	enableTextureCoordArray = YES;
	enableTexture2D = YES;
	enableColorArray = NO;
	enableSrcAlphaOne = NO;
}

void DrawManager::updateState() {
	if (isEnabledTextureCoordArray && !enableTextureCoordArray) {
		isEnabledTextureCoordArray = NO;
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	} else if (!isEnabledTextureCoordArray && enableTextureCoordArray) {
		isEnabledTextureCoordArray = YES;
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	}

	if (isEnabledTexture2D && !enableTexture2D) {
		isEnabledTexture2D = NO;
		glDisable(GL_TEXTURE_2D);
	} else if (!isEnabledTexture2D && enableTexture2D) {
		isEnabledTexture2D = YES;
		glEnable(GL_TEXTURE_2D);
	}

	if (isEnabledColorArray && !enableColorArray) {
		isEnabledColorArray = NO;
		glDisableClientState(GL_COLOR_ARRAY);
	} else if (!isEnabledColorArray && enableColorArray) {
		isEnabledColorArray = YES;
		glEnableClientState(GL_COLOR_ARRAY);
	}

	if (isEnabledSrcAlphaOne && !enableSrcAlphaOne) {
		isEnabledSrcAlphaOne = NO;
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	} else if (!isEnabledSrcAlphaOne && enableSrcAlphaOne) {
		isEnabledSrcAlphaOne = YES;
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	}
}