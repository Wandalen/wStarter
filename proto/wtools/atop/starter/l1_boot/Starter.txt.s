( function _StarterCode_s_()
{

'use strict';

const _ = _global_.wTools;

// let wasPrepareStackTrace = Error.prepareStackTrace;
// Error.prepareStackTrace = function( err, stack )
// {
// }

// --
// begin
// --

function _Begin()
{

  'use strict';

  const _global = _global_;
  if( _global._starter_ && _global._starter_._inited )
  return;

  let _starter_ = _global_._starter_;
  let _ = _starter_;
  let path = _starter_.path;
  let sourcesMap = _starter_.sourcesMap;

  //

  function SourceFile( o )
  {
    let starter = _starter_;
    let sourceFile = this;

    if( !( sourceFile instanceof SourceFile ) )
    return new SourceFile( o );

    if( o.isScript === undefined )
    o.isScript = true;

    o.filePath = starter.path.canonizeTolerant( o.filePath );
    if( !o.dirPath )
    o.dirPath = starter.path.dir( o.filePath );
    o.dirPath = starter.path.canonizeTolerant( o.dirPath );

    sourceFile.filePath = o.filePath;
    sourceFile.dirPath = o.dirPath;
    sourceFile.nakedCall = o.nakedCall;
    sourceFile.isScript = o.isScript;

    sourceFile.filename = o.filePath;
    sourceFile.exports = Object.create( null );
    sourceFile.parent = null;
    sourceFile.children = [];
    sourceFile.njsModule = o.njsModule;
    sourceFile.error = null;
    sourceFile.state = o.nakedCall ? 'preloaded' : 'created';

    sourceFile.starter = starter;
    // sourceFile.include = starter._sourceInclude.bind( starter, sourceFile, sourceFile.dirPath );
    sourceFile.include = include.bind( sourceFile );
    sourceFile.resolve = starter._sourceResolve.bind( starter, sourceFile, sourceFile.dirPath );
    sourceFile.include.resolve = sourceFile.resolve;
    sourceFile.include.sourceFile = sourceFile;
    sourceFile.isModuleDeclareFile = starter.path.name( sourceFile.dirPath ) === 'node_modules';

    /* njs compatibility */

    sourceFile.path = [ '/' ];
    getter( 'id', idGet );
    getter( 'loaded', loadedGet );

    /* interpreter-specific */

    if( starter.interpreter === 'browser' )
    starter._broSourceFile( sourceFile, o );
    else
    starter._njsSourceFile( sourceFile, o );

    /* */

    if( starter.loggingSourceFiles )
    console.log( ` . SourceFile ${o.filePath}` );


    starter.sourcesMap[ _.path.nativize( o.filePath ) ] = sourceFile;
    if( sourceFile.isModuleDeclareFile )
    starter.moduleMainFilesMap[ starter.path.fullName( o.filePath ) ] = sourceFile;
    // starter.sourcesMap[ o.filePath ] = sourceFile;
    // if( sourceFile.isModuleDeclareFile )
    // starter.moduleMainFilesMap[ starter.path.fullName( o.filePath ) ] = sourceFile;
    // Object.preventExtensions( sourceFile );
    return sourceFile;

    /* - */

    function idGet()
    {
      return this.filePath;
    }

    function loadedGet()
    {
      return this.state === 'opened';
    }

    function getter( propName, onGet )
    {
      let property =
      {
        enumerable : true,
        configurable : true,
        get : onGet,
      }
      Object.defineProperty( sourceFile, propName, property );
    }

    function include( id )
    {
      let sourceFile = this;
      return SourceFile._load( id, sourceFile, false );
    }
  }

  SourceFile._load = function _load( request, parent, isMain )
  {
    return _starter_._sourceInclude( parent, parent.dirPath, request );
  }

  SourceFile._resolveFilename = function _resolveFilename( request, parent/*, isMain, options*/ )
  {
    return _starter_._sourceResolveAct( parent, parent.dirPath, request );
  }

  SourceFile.prototype = Object.create( null );

  SourceFile.prototype.load = function load( filename )
  {
    let module = this;
    return _starter_._sourceIncludeResolvedCalling( null, module, module.filePath )
  }

  //

  function _sourceMake( filePath, dirPath, nakedCall )
  {
    let r = SourceFile({ filePath, dirPath, nakedCall });
    return r;
  }

  //

  function _sourceIncludeResolvedCalling( parentSource, childSource, sourcePath )
  {
    let starter = this;

    try
    {

      if( !childSource )
      throw _._err({ args : [ `Found no source file ${sourcePath}` ], level : 4 });

      if( childSource.state === 'errored' || childSource.state === 'opening' || childSource.state === 'opened' )
      return end();

      childSource.parent = parentSource || null;

      childSource.state = 'opening';
      childSource.nakedCall();
      childSource.state = 'opened';

      if( Config.interpreter === 'njs' )
      starter._njsModuleFromSource( childSource );

    }
    catch( err )
    {
      err = _.err( err, `\nError including source file ${ childSource ? childSource.filePath : sourcePath }` );
      if( childSource )
      {
        childSource.error = err;
        childSource.state = 'errored';
      }
      throw err;
    }

    return end();

    function end()
    {
      if( !starter.requireCache[ childSource.filePath ] )
      starter.requireCache[ childSource.filePath ] = childSource;

      return childSource.exports;
    }
  }

  //

  function _sourceInclude( parentSource, basePath, filePath )
  {
    let starter = this;

    try
    {

      if( _.arrayIs( filePath ) )
      {
        let result = [];
        for( let f = 0 ; f < filePath.length ; f++ )
        {
          let r = starter._sourceInclude( parentSource, basePath, filePath[ f ] );
          if( r === undefined )
          result.push( r );
          else
          _.arrayAppendArrays( result, r );
        }
        return result;
      }

      if( !_starter_.withServer && _.path.isGlob( filePath ) ) /* xxx : workaround */
      {
        let resolvedFilePath = starter._pathResolveLocal( parentSource, basePath, filePath );
        let filtered = _.props.keys( _.path.globShortFilterKeys( starter.sourcesMap, resolvedFilePath ) );
        if( filtered.length )
        return starter._sourceInclude( parentSource, basePath, filtered );
      }
      else
      {
        let resolvedFilePath = this._pathResolveLocal( parentSource, basePath, filePath );
        let chachedSource = this.requireCache[ resolvedFilePath ];
        if( chachedSource )
        {
          _.assert( chachedSource.state === 'errored' || chachedSource.state === 'opening' || chachedSource.state === 'opened' )
          return chachedSource.exports;
        }
        // let childSource = starter._sourceForInclude.apply( starter, arguments );
        let childSource = this.sourcesMap[ resolvedFilePath ];
        if( childSource )
        return starter._sourceIncludeResolvedCalling( parentSource, childSource, filePath );
      }

      return starter._includeAct( parentSource, basePath, filePath );
    }
    catch( err )
    {
      err = _.err( err, `\nError including source file ${ filePath }` );
      throw err;
    }

  }

  //

  function _sourceResolve( parentSource, basePath, filePath )
  {
    let starter = this;
    let result = starter._sourceOwnResolve( parentSource, basePath, filePath );
    if( result !== null )
    return result;

    return starter._sourceResolveAct( parentSource, basePath, filePath );
  }

  //

  function _sourceOwnResolve( parentSource, basePath, filePath )
  {
    let starter = this;
    let childSource = starter._sourceForInclude.apply( starter, arguments );
    if( !childSource )
    return null;
    return childSource.filePath;
  }

  //

  function _sourceForPathGet( filePath )
  {
    filePath = this.path.canonizeTolerant( filePath );
    let childSource = this.sourcesMap[ filePath ];
    if( childSource )
    return childSource;
    return null;
  }

  //

  function _sourceForInclude( sourceFile, basePath, filePath )
  {
    let resolvedFilePath = this._pathResolveLocal( sourceFile, basePath, filePath );
    let childSource = this.sourcesMap[ resolvedFilePath ];
    if( childSource )
    return childSource;
    return null;
  }

  //

  function _pathResolveLocal( sourceFile, basePath, filePath )
  {
    let starter = this;

    if( sourceFile && !basePath )
    basePath = sourceFile.dirPath;

    if( !basePath && !sourceFile )
    throw _.err( 'Base path is not specified, neither script file' );

    let isAbsolute = filePath[ 0 ] === '/';
    let isDotted = _.strBegins( filePath, './' ) || _.strBegins( filePath, '../' ) || filePath === '.' || filePath === '..';

    if( !isDotted )
    filePath = starter.path.canonizeTolerant( filePath );

    if( isDotted && !isAbsolute )
    {
      filePath = starter.path.canonizeTolerant( basePath + '/' + filePath );
      if( filePath[ 0 ] !== '/' )
      filePath = './' + filePath;
    }

    if( !isDotted && !isAbsolute )
    {
      if( starter.moduleMainFilesMap[ filePath ] )
      {
        filePath = starter.moduleMainFilesMap[ filePath ].filePath;
      }
      else
      {
        let filePathLower = filePath.toLowerCase();
        if( starter.moduleMainFilesMap[ filePathLower ] )
        filePath = starter.moduleMainFilesMap[ filePathLower ].filePath;
      }
    }

    return _.path.nativize( filePath );
  }

  //

  function _Setup()
  {

    if( this._inited )
    {
      return;
    }

    if( _starter_.catchingUncaughtErrors )
    {
      _starter_.error._setupUncaughtErrorHandler2();
      _starter_.error._setupUncaughtErrorHandler9();
    }

    this._SetupAct();

    this._inited = 1;
  }

}

// --
// end
// --

function _End()
{

  let Extension =
  {

    SourceFile,

    _sourceMake,
    _sourceIncludeResolvedCalling,
    _includeAct : null,
    _sourceInclude,
    _sourceResolveAct : null,
    _sourceResolve,
    _sourceOwnResolve,
    _sourceForPathGet,
    _sourceForInclude,

    _pathResolveLocal,

    _Setup,

    // fields

    redirectingConsole : null,
    _inited : false,

  }

  for( let k in Extension )
  if( _starter_[ k ] === undefined )
  _starter_[ k ] = Extension[ k ];

  _starter_._Setup();

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
