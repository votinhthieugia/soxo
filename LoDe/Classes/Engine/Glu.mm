//
// cocos2d (incomplete) GLU implementation
//
// gluLookAt and gluPerspective from:
// http://jet.ro/creations (San Angeles Observation)
// 
// 

#import <OpenGLES/ES1/gl.h>
#import <math.h>
#import "Glu.h"

void gluLookAt(GLfloat eyex,
			   GLfloat eyey,
			   GLfloat eyez,
			   GLfloat centerx, 
			   GLfloat centery,
			   GLfloat centerz,
			   GLfloat upx,
			   GLfloat upy,
			   GLfloat upz) {
    GLfloat m[16];
    GLfloat x[3], y[3], z[3];
    GLfloat mag;

    /* Make rotation matrix */

    /* Z vector */
    z[0] = eyex - centerx;
    z[1] = eyey - centery;
    z[2] = eyez - centerz;
    mag = (float)sqrtf(z[0] * z[0] + z[1] * z[1] + z[2] * z[2]);
    if (mag) {
        z[0] /= mag;
        z[1] /= mag;
        z[2] /= mag;
    }
	
    /* Y vector */
    y[0] = upx;
    y[1] = upy;
    y[2] = upz;
	
    /* X vector = Y cross Z */
    x[0] = y[1] * z[2] - y[2] * z[1];
    x[1] = -y[0] * z[2] + y[2] * z[0];
    x[2] = y[0] * z[1] - y[1] * z[0];
	
    /* Recompute Y = Z cross X */
    y[0] = z[1] * x[2] - z[2] * x[1];
    y[1] = -z[0] * x[2] + z[2] * x[0];
    y[2] = z[0] * x[1] - z[1] * x[0];
	
    /* cross product gives area of parallelogram, which is < 1.0 for
     * non-perpendicular unit-length vectors; so normalize x, y here
     */
	
    mag = (float)sqrtf(x[0] * x[0] + x[1] * x[1] + x[2] * x[2]);
    if (mag) {
        x[0] /= mag;
        x[1] /= mag;
        x[2] /= mag;
    }
	
    mag = (float)sqrtf(y[0] * y[0] + y[1] * y[1] + y[2] * y[2]);
    if (mag) {
        y[0] /= mag;
        y[1] /= mag;
        y[2] /= mag;
    }
	
#define M(row,col)  m[col*4+row]
    M(0, 0) = x[0];
    M(0, 1) = x[1];
    M(0, 2) = x[2];
    M(0, 3) = 0.0f;
    M(1, 0) = y[0];
    M(1, 1) = y[1];
    M(1, 2) = y[2];
    M(1, 3) = 0.0f;
    M(2, 0) = z[0];
    M(2, 1) = z[1];
    M(2, 2) = z[2];
    M(2, 3) = 0.0f;
    M(3, 0) = 0.0f;
    M(3, 1) = 0.0f;
    M(3, 2) = 0.0f;
    M(3, 3) = 1.0f;
#undef M
    {
        int a;
        GLfloat fixedM[16];
        for (a = 0; a < 16; ++a) {
            fixedM[a] = m[a];
		}
        glMultMatrixf(fixedM);
    }
	
    // Translate Eye to Origin
    glTranslatef(-eyex, -eyey, -eyez);
}

void gluPerspective(GLfloat fovy,
					GLfloat aspect,
					GLfloat zNear,
					GLfloat zFar) {	
	GLfloat xmin, xmax, ymin, ymax;

	ymax = zNear * (GLfloat)tanf(fovy * (float)M_PI / 360);
	ymin = -ymax;
	xmin = ymin * aspect;
	xmax = ymax * aspect;

	/*
	{
		GLfloat temp;
		temp = ymax;
		ymax = ymin;
		ymin = temp;

		temp = xmax;
		xmax = xmin;
		xmin = temp;
	}
	 */

	glFrustumf(xmin, xmax, ymin, ymax, zNear, zFar);	
}

void gluMultMatrixVecf(const GLfloat matrix[16], const GLfloat in[4], GLfloat out[4]) {
	for (int i = 0; i < 4; i++) {
		out[i] = in[0] * matrix[0 * 4 + i] +
		in[1] * matrix[1 * 4 + i] +
		in[2] * matrix[2 * 4 + i] +
		in[3] * matrix[3 * 4 + i];
	}
}

void gluProject(GLfloat objx,
				GLfloat objy,
				GLfloat objz,
				const GLfloat modelMatrix[16],
				const GLfloat projMatrix[16],
				const GLint viewport[4],
				GLfloat *winx,
				GLfloat *winy,
				GLfloat *winz) {
	float in[4];
	float out[4];
	in[0] = objx;
	in[1] = objy;
	in[2] = objz;
	in[3] = 1.0;

	gluMultMatrixVecf(modelMatrix, in, out);
	gluMultMatrixVecf(projMatrix, out, in);

	if (in[3] == 0.0) {
		return;
	}
	in[0] /= in[3];
	in[1] /= in[3];
	in[2] /= in[3];

	/* Map x, y and z to range 0-1 */
	in[0] = in[0] * 0.5 + 0.5;
	in[1] = in[1] * 0.5 + 0.5;
	in[2] = in[2] * 0.5 + 0.5;

	/* Map x,y to viewport */
	in[0] = in[0] * viewport[2] + viewport[0];
	in[1] = in[1] * viewport[3] + viewport[1];

	*winx = in[0];
	*winy = in[1];
	*winz = in[2];
}