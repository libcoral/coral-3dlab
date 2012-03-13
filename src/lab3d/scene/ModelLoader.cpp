#include "ModelLoader_Base.h"

#include <coOsg/NodePtr.h>

#include <osgDB/ReadFile>

namespace lab3d {
namespace scene {

class ModelLoader : public ModelLoader_Base
{
public:
    ModelLoader()
    {
        // empty constructor
    }
    
    virtual ~ModelLoader()
    {
        // empty destructor
    }
    
    void load( const std::string& filename, coOsg::NodePtr& model )
    {
        model = osgDB::readNodeFile( filename );
    }
    
private:
    // member variables
};

CORAL_EXPORT_COMPONENT( ModelLoader, ModelLoader );

} // namespace scene
} // namespace lab3d
