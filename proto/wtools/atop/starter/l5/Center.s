( function _Center_ss_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../include/Mid.s' );
  module.exports = _;
}

//

const _ = _global_.wTools;
const Parent = null;
const Self = wStarterCenter;
function wStarterCenter( o )
{
  // debugger;
  // if( !( context instanceof cls ) )
  // if( o instanceof cls )
  // {
  //   _.assert( args.length === 1 );
  //
  //   let handlers =
  //   {
  //     get : _.Remote.CenterProxyGet,
  //     set : _.Remote.CenterProxySet,
  //   };
  //
  //   let proxy = new Proxy( o, handlers );
  //
  //   return proxy;
  // }
  // else
  // {
  return _.workpiece.construct( Self, this, arguments );
  // }
}

Self.shortName = 'Center';

// --
// routine
// --

function unform()
{
  let center = this;

  _.assert( 0, 'not implemented' );

  /*
  qqq : implement please
  */

}

unform.operation =
{
  remote : 0,
}

//

function form()
{
  let center = this;

  center.remote = _.Remote
  ({
    object : center,
    entryPath : __filename,
  });

  return center.remote.form()
  .then( ( arg ) =>
  {
    // debugger;
    return center.remote.workerOpen();
  })
  .then( ( slave ) =>
  {
    // debugger;
    center._slave = slave;
    return center._slave.execImmediate();
  });

}

form.operation =
{
  remote : 0,
}

//

function Exec()
{
  let center = new this.Self();
  return center.exec();
}

Exec.operation =
{
  remote : 0,
}

//

function exec()
{
  let center = this;
  if( center.immediate )
  return center.execImmediate();
  else
  return center.execCenter();
}

exec.operation =
{
  remote : 0,
}

//

function execCenter()
{
  let center = this;
  return center.form()
  // if( center.center === null )
  // center.center = new _.starter.Center();
  // return center.center.exec();
}

execCenter.operation =
{
  remote : 0,
}

//

function execImmediate()
{
  let center = this;

  require( '../include/Top.s' );

  if( center.cui === null )
  center.cui = new _.starter.Cui();
  return center.cui.exec();
}

execImmediate.operation =
{
  remote : 1,
}

// --
// relations
// --

let Composes =
{
  immediate : 1,
}

let Associates =
{
  remote : null,
  cui : null,
}

let Restricts =
{
}

let Statics =
{
  Exec,
}

let Accessor =
{
}

// --
// prototype
// --

let Proto =
{

  unform,
  form,

  Exec,
  exec,
  execCenter,
  execImmediate,

  /* */

  Composes,
  Associates,
  Restricts,
  Statics,
  Accessor,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

_.starter[ Self.shortName ] = Self;

if( !module.parent )
Self.Exec();

})();
