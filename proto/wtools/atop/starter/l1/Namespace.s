( function _Namespace_s_( )
{

'use strict';

const _ = _global_.wTools;
_.starter = _.starter || Object.create( null );
_.starter.session = _.starter.session || Object.create( null );

let vectorizeDefaults = { vectorizingContainerAdapter : 1, unwrapingContainerAdapter : 0 };
let vectorize = _.routineDefaults( null, _.vectorize, vectorizeDefaults );
let vectorizeAll = _.routineDefaults( null, _.vectorizeAll, vectorizeDefaults );
let vectorizeAny = _.routineDefaults( null, _.vectorizeAny, vectorizeDefaults );
let vectorizeNone = _.routineDefaults( null, _.vectorizeNone, vectorizeDefaults );

// --
// inter
// --

async function launch()
{
  let center = _.starter.System.Center();
  return center.form();
}

//

function pathAllowedNormalize( allowedPath )
{

  allowedPath = _.path.mapExtend( null, allowedPath, true );

  if( Config.debug )
  {
    _.assert( _.mapIs( allowedPath ) );
    for( let p in allowedPath )
    _.assert( _.boolLike( allowedPath[ p ] ) );
  }

  return allowedPath
}

//

function pathAllowedIs( allowedPath, filePath )
{
  let filtered = this.pathAllowedFilter( ... arguments );
  return _.entity.lengthOf( filtered ) === _.entity.lengthOf( filePath );
}

//

function pathAllowedFilter( allowedPath, filePath )
{

  _.assert( _.mapIs( allowedPath ) );
  _.assert( _.strIs( filePath ) || _.arrayIs( filePath ) );
  _.assert( arguments.length === 2 );

  let result = _.filter_( null, filePath, ( filePath ) => _pathAllowedIs( filePath ) );
  return result;

  function _pathAllowedIs( filePath )
  {
    let included = 0;
    let totalIncludes = 0;

    _.assert( _.strIs( filePath ) );

    for( let a in allowedPath )
    {
      let including = allowedPath[ a ];
      if( _.path.begins( filePath, a ) )
      {
        if( including )
        {
          included += 1;
          totalIncludes += 1;
        }
        else
        {
          return;
        }
      }
      else
      {
        if( including )
        totalIncludes += 1;
      }
    }

    if( !totalIncludes || included )
    return filePath;
    return;
  }

}

//

function pathRealToVirtual( o )
{

  _.assert( arguments.length === 1 );

  if( _.arrayIs( o.realPath ) )
  return o.realPath.map( ( realPath ) => this.pathRealToVirtual({ ... o, realPath }) );

  _.routine.options_( pathRealToVirtual, arguments );
  _.assert( _.strIs( o.realPath ) );

  let relativePath = _.path.relative( o.basePath, o.realPath );
  if( _.path.isDotted( relativePath ) && relativePath !== '.' )
  {
    if( !o.realToVirtualMap )
    {
      // debugger;
      throw _.err( `Cant convet real path "${o.realPath}" to virtual path` );
    }
    for( let basePath in o.realToVirtualMap )
    {
      relativePath = _.path.relative( basePath, o.realPath );
      if( !_.path.isDotted( relativePath ) || relativePath === '.' )
      {
        relativePath = _.path.join( o.realToVirtualMap[ basePath ], relativePath );
        break;
      }
    }
  }

  if( o.verbosity )
  logger.log( ` . pathRealToVirtual ${o.realPath} -> ${relativePath}` );

  return relativePath;
}

pathRealToVirtual.defaults =
{
  realPath : null,
  basePath : null,
  realToVirtualMap : null,
  verbosity : 0,
}

//

function pathVirtualToReal( o )
{
  let servlet = this;
  let realPath;
  let regexp = /^(\/?(_\d+_)\/)/;
  let virtualPath = o.virtualPath;
  let parsed = regexp.exec( virtualPath );

  _.routine.options_( pathVirtualToReal, arguments );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( virtualPath ) );

  // debugger;

  if( parsed )
  {
    virtualPath = _.strRemoveBegin( virtualPath, parsed[ 1 ] );
    let basePath = o.virtualToRealMap[ parsed[ 2 ] ];
    _.sure( !!basePath, () => `Cant resolve virtual path ${ virtualPath }` );
    realPath = _.path.canonize( _.path.reroot( basePath, virtualPath ) );
  }
  else
  {
    realPath = _.path.canonize( _.path.reroot( o.basePath, virtualPath ) );
  }

  if( o.verbosity )
  logger.log( ` . pathVirtualToReal ${o.virtualPath} -> ${realPath}` );

  return realPath;
}

pathVirtualToReal.defaults =
{
  virtualPath : null,
  basePath : null,
  virtualToRealMap : null,
  verbosity : 0,
}

//

function pathVirtualIs( virtualPath )
{
  let regexp = /^(\/?(_\d+_)\/)/;

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( virtualPath ) );

  let parsed = regexp.exec( virtualPath );
  return !!parsed;
}

// //
//
// function pathExcludeNotAllowed( filePath, allowedPath )
// {
//
//   _.assert( _.arrayIs( filePath ) );
//   _.assert( _.strIs( allowedPath ) );
//
//   if( filePath && allowedPath )
//   {
//     filePath = filePath.filter( ( filePath ) =>
//     {
//       if( _.path.begins( filePath, allowedPath ) )
//       return filePath;
//     });
//   }
//
//   return filePath;
// }

// --
// declare
// --

let Restricts =
{

  vectorize,
  vectorizeAll,
  vectorizeAny,
  vectorizeNone,

}

let Extension =
{

  launch,
  pathAllowedNormalize,
  pathAllowedIs,
  pathAllowedFilter,

  pathRealToVirtual,
  pathVirtualToReal,
  pathVirtualIs,

  // pathExcludeNotAllowed,

  _ : Restricts,

}

/* _.props.extend */Object.assign( _.starter, Extension );

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = _global_.wTools;

})();
