//
//  Primitives.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import "Primitives.h"

void Primitives::fillRect(float x, float y, float width, float height) {
	GLushort indices[6] = { 0, 1, 2, 3, 2, 1 };
	float vertices[8] = {
		x, y,
		x + width, y,
		x, y + height,
		x + width, y + height
	};

	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);

	glVertexPointer(2, GL_FLOAT, 0, &vertices);
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, &indices);

	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

void Primitives::drawRect(float x, float y, float width, float height) {
	float vertices[8] = {
		x, y,
		x + width, y,
		x + width, y + height,
		x, y + height
	};

	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);

	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_LINE_LOOP, 0, 4);

	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

void Primitives::fillPolygon(float *points, int numVertices) {
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);

	glVertexPointer(2, GL_FLOAT, 0, points);
	glDrawArrays(GL_TRIANGLE_FAN, 0, numVertices);

	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

void Primitives::fillPolygon(float *points, float *colors, int numVertices) {
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);

	glVertexPointer(2, GL_FLOAT, 0, points);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glDrawArrays(GL_TRIANGLE_FAN, 0, numVertices);

	glDisableClientState(GL_COLOR_ARRAY);
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

void Primitives::drawLine(float *points, float *colors) {
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);

	glVertexPointer(3, GL_FLOAT, 0, points);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glDrawArrays(GL_LINES, 0, 2);

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisableClientState(GL_COLOR_ARRAY);
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

void Primitives::fillHorizontalGradient(float x, float y, float width, float height, ColorF leftColor, ColorF rightColor) {
	GLushort indices[6] = { 0, 1, 2, 3, 2, 1 };
	float vertices[8] = {
		x, y,
		x + width, y,
		x, y + height,
		x + width, y + height
	};
	float colors[16] = {
		leftColor.r, leftColor.g, leftColor.b, leftColor.a,
		rightColor.r, rightColor.g, rightColor.b, rightColor.a,
		leftColor.r, leftColor.g, leftColor.b, leftColor.a,
		rightColor.r, rightColor.g, rightColor.b, rightColor.a,
	};

	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);

	glVertexPointer(2, GL_FLOAT, 0, &vertices);
	glColorPointer(4, GL_FLOAT, 0, &colors);
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, &indices);

	glDisableClientState(GL_COLOR_ARRAY);
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

void Primitives::fillVerticalGradient(float x, float y, float width, float height, ColorF topColor, ColorF bottomColor) {
	GLushort indices[6] = { 0, 1, 2, 3, 2, 1 };
	float vertices[8] = {
		x, y,
		x + width, y,
		x, y + height,
		x + width, y + height
	};
	float colors[16] = {
		topColor.r, topColor.g, topColor.b, topColor.a,
		topColor.r, topColor.g, topColor.b, topColor.a,
		bottomColor.r, bottomColor.g, bottomColor.b, bottomColor.a,
		bottomColor.r, bottomColor.g, bottomColor.b, bottomColor.a,
	};

	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);

	glVertexPointer(2, GL_FLOAT, 0, &vertices);
	glColorPointer(4, GL_FLOAT, 0, &colors);
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, &indices);

	glDisableClientState(GL_COLOR_ARRAY);
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}