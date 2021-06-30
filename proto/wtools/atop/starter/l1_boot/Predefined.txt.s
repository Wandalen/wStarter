( function _WareCode_s_()
{

'use strict';

const _ = _global_.wTools;

// --
// begin
// --

/* xxx : include while file Global.s */
function _Begin()
{

  'use strict';

  /* */

  let _global = get();
  if( !_global._globals_ )
  {
    _global._globals_ = Object.create( null );
    _global._globals_.real = _global._realGlobal_ || _global;
    _global._realGlobal_ = _global;
    _global._global_ = _global;
  }

  /* */

  function get()
  {
    let _global = undefined;
    if( typeof _global_ !== 'undefined' && _global_._global_ === _global_ )
    _global = _global_;
    else if( typeof globalThis !== 'undefined' && globalThis.globalThis === globalThis )
    _global = globalThis;
    else if( typeof Global !== 'undefined' && Global.Global === Global )
    _global = Global;
    else if( typeof global !== 'undefined' && global.global === global )
    _global = global;
    else if( typeof window !== 'undefined' && window.window === window )
    _global = window;
    else if( typeof self !== 'undefined' && self.self === self )
    _global = self;
    return _global;
  }

  /* */

  if( !_global_.Config )
  _global_.Config = Object.create( null );
  if( _global_.Config.interpreter === undefined )
  _global_.Config.interpreter = ( ( typeof module !== 'undefined' ) && ( typeof process !== 'undefined' ) ) ? 'njs' : 'browser';
  if( _global_.Config.isWorker === undefined )
  _global_.Config.isWorker = !!( typeof self !== 'undefined' && self.self === self && typeof importScripts !== 'undefined' );

  /* */

  if( _global._starter_ && _global._starter_._inited )
  return;

  let _starter_ = _global._starter_ = _global._starter_ || Object.create( null );
  let _ = _starter_;
  const Self = _starter_;

  _realGlobal_.HashMap = Map;
  _realGlobal_.HashMapWeak = WeakMap;

  // special tokens

  Self.def = Symbol.for( 'def' );
  Self.null = Symbol.for( 'null' );
  Self.undefined = Symbol.for( 'undefined' );
  Self.nothing = Symbol.for( 'nothing' );
  Self.anything = Symbol.for( 'anything' );
  Self.maybe = Symbol.for( 'maybe' );
  Self.unknown = Symbol.for( 'unknown' );
  Self.dont = Symbol.for( 'dont' );
  Self.self = Symbol.for( 'self' );
  Self.optional = Symbol.for( 'optional' );

  _realGlobal_.unrollSymbol = Symbol.for( 'unroll' );

}

// --
// end
// --

function _End()
{

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
