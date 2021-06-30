( function _Extract_txt_s_()
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

  let stackSymbol = Symbol.for( 'stack' );
  let _diagnosticCodeExecuting = 0;
  // let notLongSymbol = Symbol.for( 'notLong' );
  let iteratorSymbol = Symbol.iterator;

  // let _errorCounter = 0;
  // let _errorMaking = false;
  let _ArrayIndexOf = Array.prototype.indexOf;
  let _ArrayIncludes = Array.prototype.includes;
  if( !_ArrayIncludes )
  _ArrayIncludes = function( e ){ _ArrayIndexOf.call( this, e ) }

}

// --
// end
// --

function _End()
{

  let StarterExtension =
  {

    debuggerEnabled : _starter_.debug,

  }

  Object.assign( _starter_, StarterExtension );

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
