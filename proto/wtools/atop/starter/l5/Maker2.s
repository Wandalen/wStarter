( function _Maker2_s_()
{

'use strict';

const _ = _global_.wTools;
const Parent = _.starter.Maker;
const Self = wStarterMaker2;
function wStarterMaker2( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Maker2';

// --
// implementation
// --

function sourcesJoinFiles( o )
{
  let maker = this;
  const fileProvider = maker.fileProvider;
  let path = maker.fileProvider.path;
  let logger = maker.logger;

  o = _.routine.options_( sourcesJoinFiles, arguments );

  /* */

  o.inPath = fileProvider.recordFilter( o.inPath );

  if( o.basePath === null )
  o.basePath = o.inPath.basePathSimplest()
  if( o.basePath === null )
  o.basePath = path.current();
  if( o.inPath.prefixPath && path.s.areRelative( o.inPath.prefixPath ) )
  o.basePath = path.resolve( o.basePath );

  o.inPath.basePathUse( o.basePath );

  o.inPath = fileProvider.filesFind
  ({
    filter : o.inPath,
    mode : 'distinct',
    outputFormat : 'absolute',
  });

  /* */

  if( o.inPath && o.allowedPath )
  o.inPath = _.starter.pathAllowedFilter( o.allowedPath, o.inPath );

  /* */

  if( o.outPath )
  {
    o.outPath = o.outPath || sourcesJoinFiles.defaults.outPath;
    o.outPath = path.resolve( o.basePath, o.outPath );
  }

  /* */

  if( o.entryPath )
  {
    o.entryPath = fileProvider.recordFilter( o.entryPath );
    o.entryPath.basePath = path.resolve( o.entryPath.basePath || o.basePath || '.' );
    o.entryPath = fileProvider.filesFind
    ({
      filter : o.entryPath,
      mode : 'distinct',
      outputFormat : 'absolute',
    });

    if( o.entryPath && o.allowedPath )
    o.entryPath = _.starter.pathAllowedFilter( o.allowedPath, o.entryPath );

    if( !_.longHasAll( o.inPath, o.entryPath ) )
    {
      // debugger;
      throw _.errBrief
      (
        'List of source files should have all entry files'
        + '\nSource files\n' + _.entity.exportStringNice( o.inPath, { levels : 2 } )
        + '\nEntry files\n' + _.entity.exportStringNice( o.entryPath, { levels : 2 } )
      );
    }
  }

  /* */

  if( o.externalBeforePath )
  {
    o.externalBeforePath = fileProvider.recordFilter( o.externalBeforePath );
    o.externalBeforePath.basePath = path.resolve( o.externalBeforePath.basePath || o.basePath || '.' );
    o.externalBeforePath = fileProvider.filesFind
    ({
      filter : o.externalBeforePath,
      mode : 'distinct',
      outputFormat : 'absolute',
    });
    if( o.externalBeforePath && o.allowedPath )
    o.externalBeforePath = _.starter.pathAllowedFilter( o.allowedPath, o.externalBeforePath );
  }

  /* */

  if( o.externalAfterPath )
  {
    o.externalAfterPath = fileProvider.recordFilter( o.externalAfterPath );
    o.externalAfterPath.basePath = path.resolve( o.externalAfterPath.basePath || o.basePath || '.' );
    o.externalAfterPath = fileProvider.filesFind
    ({
      filter : o.externalAfterPath,
      mode : 'distinct',
      outputFormat : 'absolute',
    });
    if( o.externalAfterPath && o.allowedPath )
    o.externalAfterPath = _.starter.pathAllowedFilter( o.allowedPath, o.externalAfterPath );
  }

  /* */

  o.basePath = path.resolve( o.basePath || '.' );

  /* */

  let srcScriptsMap = Object.create( null );
  o.inPath = o.inPath.map( ( inPath ) =>
  {
    let srcRelativePath = inPath;
    srcScriptsMap[ srcRelativePath ] = fileProvider.fileRead( inPath );
  });

  let o2 = _.props.extend( null, o )
  delete o2.inPath;
  o2.filesMap = srcScriptsMap;
  let data = maker.sourcesJoin( o2 )

  if( o.outPath )
  {
    _.sure( !fileProvider.isDir( o.outPath ), () => 'Can rewrite directory ' + _.color.strFormat( o.outPath, 'path' ) );

    fileProvider.fileWrite
    ({
      filePath : o.outPath,
      data
    });
  }

  return data;
}

var defaults = sourcesJoinFiles.defaults = _.mapBut_( null, _.starter.Maker.prototype.sourcesJoin.defaults, { filesMap : null } );
defaults.inPath = null;
defaults.outPath = 'Index.js';
defaults.withServer = 0;

//

function htmlForFiles( o )
{
  let maker = this;
  const fileProvider = maker.fileProvider;
  let path = maker.fileProvider.path;
  let logger = maker.logger;

  o = _.routine.options_( htmlForFiles, arguments );

  /* */

  if( o.inPath !== false )
  if( !_.arrayIs( o.inPath ) || o.inPath.length ) /* if not empty array */
  {
    o.inPath = fileProvider.recordFilter( o.inPath );
    o.inPath.basePathUse( o.basePath );

    if( o.basePath === null )
    o.basePath = o.inPath.basePathSimplest()
    if( o.basePath === null )
    o.basePath = path.current();
    if( o.inPath.prefixPath && path.isRelative( o.inPath.prefixPath ) )
    o.basePath = path.resolve( o.basePath );

    if( o.basePath === o.inPath.filePath )
    o.basePath = path.dir( o.basePath );

    o.inPath = fileProvider.filesFind
    ({
      filter : o.inPath,
      mode : 'distinct',
      outputFormat : 'absolute',
    });
  }

  /* */

  if( o.inPath && o.allowedPath )
  o.inPath = _.starter.pathAllowedFilter( o.allowedPath, o.inPath );

  /* */

  o.basePath = path.resolve( o.basePath || '.' );

  if( o.outPath )
  {
    o.outPath = o.outPath || sourcesJoin.defaults.outPath;
    o.outPath = path.resolve( o.basePath, o.outPath );
  }

  /* */

  if( o.templatePath && o.template === null )
  o.template = fileProvider.fileRead( path.resolve( o.basePath, o.templatePath ) );

  /* */

  let srcScriptsMap = Object.create( null );
  if( o.inPath )
  o.inPath = o.inPath.map( ( inPath ) =>
  {
    let srcRelativePath = inPath;
    if( o.relative && o.basePath )
    srcRelativePath = path.dot( path.relative( o.basePath, srcRelativePath ) );
    if( o.nativize )
    srcRelativePath = path.nativize( srcRelativePath );
    if( o.withStarter === 'inline' )
    srcScriptsMap[ srcRelativePath ] = fileProvider.fileRead( inPath );
    else
    srcScriptsMap[ srcRelativePath ] = null;
  });

  if( o.title === null )
  if( _.entity.lengthOf( srcScriptsMap ) > 0 )
  o.title = path.fullName( _.props.keys( srcScriptsMap )[ 0 ] );

  let o2 = _.mapOnly_( null, o, maker.htmlFor.defaults );
  o2.srcScriptsMap = srcScriptsMap;
  let data = maker.htmlFor( o2 );

  if( o.outPath )
  {
    _.sure( !fileProvider.isDir( o.outPath ), () => 'Can rewrite directory ' + _.color.strFormat( o.outPath, 'path' ) );
    fileProvider.fileWrite
    ({
      filePath : o.outPath,
      data
    });
  }

  return data;
}

var defaults = htmlForFiles.defaults = _.mapBut_( null, _.starter.Maker.prototype.htmlFor.defaults, { srcScriptsMap : null } );
defaults.inPath = null;
defaults.outPath = 'Index.html';
defaults.basePath = null;
defaults.templatePath = null;
defaults.allowedPath = null;
defaults.relative = 1;
defaults.nativize = 0;

// --
// relations
// --

let Composes =
{
}

let Associates =
{
  fileProvider : null,
  logger : null,
}

let Restricts =
{
}

let Statics =
{
}

// --
// prototype
// --

let Proto =
{

  /* */

  sourcesJoinFiles,
  htmlForFiles,

  /* */

  Composes,
  Associates,
  Restricts,
  Statics,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;
_.starter[ Self.shortName ] = Self;

})();
