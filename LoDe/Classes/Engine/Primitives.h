//
//  Primitives.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "Types.h"

class Primitives {
public:
	static void fillRect(float x, float y, float width, float height);
	static void drawRect(float x, float y, float width, float height);
	static void fillPolygon(float *points, int numVertices);
	static void fillPolygon(float *points, float *colors, int numVertices);
	static void drawLine(float *points, float *colors);
	static void fillHorizontalGradient(float x, float y, float width, float height, ColorF leftColor, ColorF rightColor);
	static void fillVerticalGradient(float x, float y, float width, float height, ColorF topColor, ColorF bottomColor);
};