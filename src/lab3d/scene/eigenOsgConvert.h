#ifndef _GLM_OSG_CONVERT_
#define _GLM_OSG_CONVERT_

#include <eigen/Quat.h>
#include <eigen/Vec3.h>
#include <osg/Vec3d>
#include <osg/Quat>

// Converts eigen::vec to osg::Vec3d and vice versa
inline eigen::Vec3 vecConvert( const osg::Vec3d& vec )
{
	return eigen::Vec3( vec[0], vec[1], vec[2] );
}

inline osg::Vec3d vecConvert( const eigen::Vec3& vec )
{
	return osg::Vec3d( vec.x(), vec.y(), vec.z() );
}

// Converts eigen::Quat to osg::Quat and vice versa
inline eigen::Quat quatConvert( const osg::Quat& q )
{
	return eigen::Quat( q.w(), q.x(), q.y(), q.z() );
}

inline osg::Quat quatConvert( const eigen::Quat& q )
{
	return osg::Quat( q.x(), q.y(), q.z(), q.w() );
}

#endif