//
//  DrawManager.h
//  Copyright 2009 Friends Group. All rights reserved.
//

class DrawManager {
private:
	static float red;
	static float green;
	static float blue;
	static float alpha;

	static BOOL isEnabledTextureCoordArray;
	static BOOL isEnabledTexture2D;
	static BOOL isEnabledColorArray;
	static BOOL isEnabledSrcAlphaOne;

public:
	static BOOL enableTextureCoordArray;
	static BOOL enableTexture2D;
	static BOOL enableColorArray;
	static BOOL enableSrcAlphaOne;

public:
	static void setColor(float r, float g, float b, float a);

	static void reset();
	static void updateState();
};