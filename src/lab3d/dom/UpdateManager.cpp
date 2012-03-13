#include "UpdateManager_Base.h"
#include <qt/ISystem.h>
#include <qt/ITimerCallback.h>

#include <lab3d/dom/IUpdateCallback.h>
#include <co/RefVector.h>

#include <co/Coral.h>
#include <co/ISystem.h>
#include <co/IServiceManager.h>

namespace {
    const double UPDATE_TIMER_FREQUENCY = 60.0; // frequency in Hertz
}

namespace lab3d {
namespace dom {

class UpdateManager : public UpdateManager_Base
{
public:
    UpdateManager()
    {
        _qtSystem = co::getService<qt::ISystem>();
        _qtTimerCookie = _qtSystem->addTimer( this );
    }
    
    virtual ~UpdateManager()
    {
        // empty
    }
    
    void addObserver( IUpdateCallback* observer )
    {
        if( _observers.empty() )
            start( 1000.0 / UPDATE_TIMER_FREQUENCY );
        
        _observers.push_back( observer );
    }
	
	void removeObserver( IUpdateCallback* observer )
    {
        for( ObserverList::iterator it= _observers.begin(); it != _observers.end(); ++it )
        {
            if( (*it).get() == observer )
            {
                _observers.erase( it );
                break;
            }
        }
        
        if( _observers.empty() )
            stop();
    }
    
    void timeUpdate( double dt )
    {
        for( ObserverList::iterator it = _observers.begin(); it != _observers.end(); ++it )
        {
            IUpdateCallback* observer = (*it).get();
            observer->timeUpdate( dt );
        }
    }
	
	void start( double milliseconds )
    {
        _qtSystem->startTimer( _qtTimerCookie, milliseconds );
    }
	
	void stop()
    {
        _qtSystem->stopTimer( _qtTimerCookie );

    }
    
private:
    int _qtTimerCookie;
    co::RefPtr<qt::ISystem> _qtSystem;
    typedef co::RefVector<IUpdateCallback> ObserverList;
    ObserverList _observers;
};

CORAL_EXPORT_COMPONENT( UpdateManager, UpdateManager );
    
} // namespace dom
} // namespace lab3d