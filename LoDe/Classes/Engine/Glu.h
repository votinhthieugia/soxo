//
// cocos2d GLU implementation
//
// implementation of GLU functions
//

#import <OpenGLES/ES1/gl.h>

void gluLookAt(float eyeX,
			   float eyeY,
			   float eyeZ,
			   float lookAtX,
			   float lookAtY,
			   float lookAtZ,
			   float upX,
			   float upY,
			   float upZ);

void gluPerspective(GLfloat fovy,
					GLfloat aspect,
					GLfloat zNear,
					GLfloat zFar);

void gluProject(GLfloat objX,
				GLfloat objY,
				GLfloat objZ,
				const GLfloat modelMatrix[16],
				const GLfloat projMatrix[16],
				const GLint viewport[4],
				GLfloat *winX,
				GLfloat *winY,
				GLfloat *winZ);