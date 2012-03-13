#ifndef _GLM_OSG_CONVERT_
#define _GLM_OSG_CONVERT_

#include <glm/Quat.h>
#include <glm/Vec3.h>
#include <osg/Vec3d>
#include <osg/Quat>

// Converts glm::vec to osg::Vec3d and vice versa
inline glm::Vec3 vecConvert( const osg::Vec3d& vec )
{
	return glm::Vec3( vec[0], vec[1], vec[2] );
}

inline osg::Vec3d vecConvert( const glm::Vec3& vec )
{
	return osg::Vec3d( vec.x, vec.y, vec.z );
}

// Converts glm::Quat to osg::Quat and vice versa
inline glm::Quat quatConvert( const osg::Quat& q )
{
	return glm::Quat( q.w(), q.x(), q.y(), q.z() );
}

inline osg::Quat quatConvert( const glm::Quat& q )
{
	return osg::Quat( q.x, q.y, q.z, q.w );
}

#endif