( function _BroProcessCode_s_()
{

'use strict';

const _ = _global_.wTools;

// --
// begin
// --

function _Begin()
{

  'use strict';

  const _global = _global_;
  let _starter_ = _global_._starter_;
  let _ = _starter_;
  let path = _starter_.path;
  let sourcesMap = _starter_.sourcesMap;

  if( _global._starter_ && _global._starter_._inited )
  return;

  let _process = _global.process = Object.create( null );

  //

  function exit( exitCode )
  {
    _process.exitCode = exitCode;

    if( !_starter_.withServer )
    return;

    let body = { routine : 'exit', arguments : [ _process._exitCode ] };
    let op =
    {
      method : 'post',
      headers : { 'Content-Type' : 'application/json' },
      body : JSON.stringify( body )
    }
    fetch( '/.process', op );
  }

  /* */

  function nextTick( h )
  {
    return setTimeout( h, 0 )
  }

  /* */

  function exitCodeSet( code )
  {
    _.assert( _.numberIs( code ) );
    _process._exitCode = code;

    if( !_starter_.withServer )
    return;

    let op =
    {
      method : 'post',
      headers : { 'Content-Type' : 'application/json' },
      body : JSON.stringify({ routine : 'exitCode', arguments : [ _process._exitCode ] })
    }
    fetch( '/.process', op );
  }

  function exitCodeGet()
  {
    return _process._exitCode;
  }

  Object.defineProperty
  (
    _process,
    'exitCode',
    {
      set : exitCodeSet,
      get : exitCodeGet,
    }
  );

  /* */

  function on( o )
  {
    o = _.event.onHead( _.event.on, arguments );
    return _.event.on( _process._edispatcher, o );
  }

  on.defaults =
  {
    callbackMap : null,
  };

  /* */

  function once( o )
  {
    o = _.event.onHead( _.event.once, arguments );
    return _.event.once( _process._edispatcher, o );
  }

  once.defaults =
  {
    callbackMap : null,
  };

  /* */

  function off( o )
  {
    o = _.event.offHead( _.event.off, arguments );
    return _.event.off( _process._edispatcher, o );
  }

  off.defaults =
  {
    callbackMap : null,
  };

  /* */

  function eventHasHandler( o )
  {
    o = _.event.eventHasHandlerHead( _.event.eventHasHandler, arguments );
    return _.event.eventHasHandler( _process._edispatcher, o );
  }

  eventHasHandler.defaults =
  {
    eventName : null,
    eventHandler : null,
  }

  function eventGive( o )
  {
    // let o = _.event.eventGiveHead( this._edispatcher, eventGive, arguments );
    return _.event.eventGive( this._edispatcher, o );
    // return _.event.eventGive( _process._edispatcher, ... arguments );
  }

  eventGive.defaults =
  {
    ... _.event.eventGive.defaults,
  }

  /* */

  _realGlobal_.onerror = function onerror()
  {
    _process.eventGive({ event : 'uncaughtException', args : arguments });
  }

  _realGlobal_.onunhandledrejection = function onunhandledrejection( e )
  {
    _process.eventGive({ event : 'unhandledRejection', args : [ e.reason, e.promise ] });
  }

}

// --
// end
// --

function _End()
{

  let Events =
  {
    'uncaughtError' : [],
    'uncaughtException' : [],
    'unhandledRejection' : [],

    'SIGHUP' : [],
    'SIGQUIT' : [],
    'SIGINT' : [],
    'SIGTERM' : [],
    'SIGUSR1' : [],
    'SIGUSR2' : [],

    'exit' : [],
    'beforeExit' : [],
  }

  let _edispatcher =
  {
    events : Events,
  }

  let Extension =
  {
    _edispatcher,

    exit,

    on,
    once,
    off,
    eventHasHandler,
    eventGive,

    nextTick,

    // fields

    env : Object.create( null ),
    execArgv : [],

    _exitCode : 0

  }

  Object.assign( _global.process, Extension );

}

// --
// export
// --

const Self =
{
  begin : _Begin,
  end : _End,
}

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
