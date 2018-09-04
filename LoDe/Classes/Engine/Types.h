//
//  Types.h
//  Copyright 2009 Friends Group. All rights reserved.
//

#define cpVect CGPoint

typedef struct {
	float x;
	float y;
} V2;

typedef struct {
	float x;
	float y;
	float z;
} V3;

typedef struct {
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
} Color;

typedef struct {
	float r;
	float g;
	float b;
	float a;
} ColorF;

typedef struct {
	float x;
	float y;
	float size;
} PointSprite2D;

typedef struct {
	short x;
	short y;
	float size;
} PointSpriteShort2D;

typedef struct {
	float x;
	float y;
	float z;
	float size;
} PointSprite;

typedef struct {
	float topLeftX, topLeftY;
	float topRightX, topRightY;
	float bottomLeftX, bottomLeftY;
	float bottomRightX, bottomRightY;
} Quad2;

typedef struct {
	float topLeftX, topLeftY, topLeftZ;
	float topRightX, topRightY, topRightZ;
	float bottomLeftX, bottomLeftY, bottomLeftZ;
	float bottomRightX, bottomRightY, bottomRightZ;
} Quad3;

typedef struct {
	float x;
	float y;
	float width;
	float height;
} Rectangle;