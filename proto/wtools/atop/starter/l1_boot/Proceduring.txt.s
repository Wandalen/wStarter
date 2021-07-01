( function _Proceduring_txt_s_()
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
  let _starter_ = _global._starter_ = _global._starter_ || Object.create( null );
  let _ = _starter_;
  let Procedure = _global._starter_.Procedure = _global._starter_.Procedure || Object.create( null );

  //

  function Init( procedure )
  {
    procedure._stack = _.Procedure.Stack( procedure._stack, 1 );
    _.arrayAppendOnceStrictly( _.Procedure.InstancesArray, procedure );
    console._original.log( `Procedure.Init : ${procedure._stack} : ${_.Procedure.InstancesArray.length}` );
    return procedure;
  }

  //

  function Finit( procedure )
  {
    _.arrayRemoveOnceStrictly( _.Procedure.InstancesArray, procedure );
    console._original.log( `Procedure.Finit : ${procedure._stack} : ${_.Procedure.InstancesArray.length}` );
    // debugger;
    return procedure;
  }

  //

  function Filter( o )
  {
    let result = [];
    for( let i = 0 ; i < _.Procedure.InstancesArray ; i++ )
    {
      let procedure = _.Procedure.InstancesArray[ i ];
      let fits = true;
      for( let k in o )
      if( procedure[ k ] !== o[ k ] )
      {
        fits = false;
        break;
      }
      result.push( procedure );
    }
    return result;
  }

  //

  function Stack( stack, delta )
  {

    if( !Config.debug || !_.Procedure.UsingStack )
    return '';

    _.assert( delta === undefined || _.numberIs( delta ) );
    _.assert( stack === undefined || stack === null || _.numberIs( stack ) || _.strIs( stack ) );
    _.assert( arguments.length === 0 || arguments.length === 1 || arguments.length === 2 );

    if( _.strIs( stack ) )
    return stack;

    if( stack === undefined || stack === null )
    stack = 1;
    if( _.numberIs( stack ) )
    stack += 1;
    if( delta )
    stack += delta;
    if( _.numberIs( stack ) )
    stack = _.introspector.stack([ stack, Infinity ]);

    _.assert( _.strIs( stack ) );

    return stack;
  }

  //

  function NativeWatchingEnable( o )
  {

    o = _.routine.options_( NativeWatchingEnable, o );
    _.assert( !!o.enable );

    let original = _.Procedure._OriginalTimeRoutines = _.Procedure._OriginalTimeRoutines || Object.create( null );

    if( o.enable )
    {
      _.assert( _.entity.lengthOf( original ) === 0 );

      original.setTimeout = _global_.setTimeout;
      original.clearTimeout = _global_.clearTimeout;
      original.setInterval = _global_.setInterval;
      original.clearInterval = _global_.clearInterval;
      if( _global_.requestAnimationFrame )
      original.requestAnimationFrame = _global_.requestAnimationFrame;
      if( _global_.cancelAnimationFrame )
      original.cancelAnimationFrame = _global_.cancelAnimationFrame;

      _global_.setTimeout = setTimeout;
      _global_.clearTimeout = clearTimeout;
      _global_.setInterval = setInterval;
      _global_.clearInterval = clearInterval;
      if( _global_.requestAnimationFrame )
      _global_.requestAnimationFrame = requestAnimationFrame;
      if( _global_.cancelAnimationFrame )
      _global_.cancelAnimationFrame = cancelAnimationFrame;

    }
    else
    {

      for( let k in original )
      {
        _.assert( _.routineIs( original[ k ] ) );
        _global_[ k ] = original[ k ];
        delete original[ k ];
      }

    }

    /* */

    function setTimeout( onTime, ... args )
    {
      let object = original.setTimeout.call( _global_, onTime2, ... args );
      let procedure = procedureMake({ _object : object });
      return object;
      function onTime2()
      {
        procedureRemove( procedure );
        return onTime( ... arguments );
      }
    }

    /* */

    function clearTimeout( timer )
    {
      let result = original.clearTimeout.call( _global_, ... arguments );
      let procedures = _.Procedure.Find({ _object : timer })
      if( procedures.length )
      procedureRemove( procedures[ 0 ] );
      return result;
    }

    /* */

    function setInterval( onTime, ... args )
    {
      let object = original.setInterval.call( _global_, onTime, ... args );
      let procedure = procedureMake({ _object : object });
      return object;
    }

    /* */

    function clearInterval( timer )
    {
      let result = original.clearInterval.call( _global_, ... arguments );
      let procedures = _.Procedure.Find({ _object : timer })
      if( procedures.length )
      procedureRemove( procedures[ 0 ] );
      return result;
    }

    /* */

    function requestAnimationFrame( onTime, ... args )
    {
      let object = original.requestAnimationFrame.call( _global_, onTime, ... args );
      let procedure = procedureMake({ _object : object });
      return object;
    }

    /* */

    function cancelAnimationFrame( timer )
    {
      let result = original.cancelAnimationFrame.call( _global_, ... arguments );
      let procedures = _.Procedure.Find({ _object : timer })
      if( procedures.length )
      procedureRemove( procedures[ 0 ] );
      return result;
    }

    /* */

    function procedureMake( o )
    {
      let procedure = _.Procedure.Init
      ({
        _waitTimer : false,
        _stack : 2,
        ... o,
      });
      return procedure;
    }

    /* */

    function procedureRemove( procedure )
    {
      _.Procedure.Finit( procedure );
    }

    /* */

  }

  NativeWatchingEnable.defaults =
  {
    enable : 1,
  }

  //

}

// --
// end
// --

function _End()
{

  let ProcedureExtension =
  {

    Init,
    Finit,
    Filter,
    Stack,
    NativeWatchingEnable,

    UsingStack : 1,
    InstancesArray : [],
    _OriginalTimeRoutines : Object.create( null ),

  }

  Object.assign( _starter_.Procedure, ProcedureExtension );

}

// --
//
// --

const Self =
{
  begin : _Begin,
  end : _End,
}

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
