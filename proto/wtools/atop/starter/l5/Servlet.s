( function _Servlet_ss_()
{

'use strict';

let Express = null;
let ExpressLogger = null;
let ExpressDir = null;
let Querystring = null;
const _ = _global_.wTools;
const Parent = null;
const Self = wStarterServlet;
function wStarterServlet( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Servlet';

// --
// routine
// --

function finit()
{
  let servlet = this;
  let system = servlet.system;

  servlet.unform();

  return _.Copyable.prototype.finit.call( servlet );
}

//

function instanceOptions( o )
{
  let self = this;

  for( let k in o )
  {
    if( o[ k ] === null && self[ k ] !== null && self[ k ] !== undefined )
    o[ k ] = self[ k ];
  }

  return o;
}

//

function unform()
{
  let servlet = this;
  let system = servlet.system;

  if( !servlet.formed )
  return;

  _.arrayRemoveOnceStrictly( system.servletsArray, servlet );

  if( servlet.serverPath )
  {
    _.assert
    (
      system.servletsMap[ servlet.serverPath ] === servlet,
      `Found no servlet::${servlet.serverPath}`
    );
    delete system.servletsMap[ servlet.serverPath ];
  }

  if( servlet.loggerSocket )
  {
    servlet.loggerSocket.finit();
    servlet.loggerSocket = null;
  }

  if( servlet.httpServer )
  {
    if( servlet.owningHttpServer )
    servlet.httpServer.close();
    servlet.httpServer = null;
  }

  servlet.formed = 0;
}

//

async function form()
{
  let servlet = this;
  let system = servlet.system;

  if( servlet.system === null )
  system = servlet.system = new _.starter.System();

  _.assert( system instanceof _.starter.System );

  _.arrayAppendOnceStrictly( system.servletsArray, servlet );
  servlet.formed = 1;

  await servlet.pathsForm();

  servlet._requestScriptWrapHandler = servlet.scriptWrap_functor();

  if( servlet.serverPath )
  await servlet.serverForm();

  if( servlet.serverPath && servlet.loggingApplication )
  servlet.serverLoggingForm();

  return servlet;
}

//

async function serverForm()
{
  let servlet = this;
  let system = servlet.system;

  _.assert( _.routineIs( servlet._requestScriptWrapHandler ) );

  let parsedServerPath = _.servlet.serverPathParse({ full : servlet.serverPath });

  _.assert
  (
    !system.servletsMap[ servlet.serverPath ] || system.servletsMap[ servlet.serverPath ] === servlet,
    `Servlet at ${servlet.serverPath} is already launched`
  );
  system.servletsMap[ servlet.serverPath ] = servlet;

  /* - */

  if( !servlet.express )
  {
    if( !Express )
    Express = require( 'express' );
    servlet.express = Express();
  }

  let express = servlet.express;

  express.use( ( request, response, next ) => servlet.requestPreHandler({ request, response, next }) );

  if( Config.debug && servlet.loggingRequestsAll )
  {
    if( !ExpressLogger )
    ExpressLogger = require( 'morgan' );
    express.use( ExpressLogger( 'dev' ) );
  }

  express.use( ( request, response, next ) => servlet.requestMidHandler({ request, response, next }) );

  express.use( ( request, response, next ) => servlet._requestScriptWrapHandler({ request, response, next }) );

  express.use( parsedServerPath.resourcePath, Express.static( _.path.nativize( servlet.basePath ) ) );

  if( servlet.servingDirs )
  {
    if( !ExpressDir )
    ExpressDir = require( 'serve-index' );
    let directoryOptions =
    {
      'icons' : true,
      'hidden' : true,
    }
    express.use( parsedServerPath.resourcePath, ExpressDir( _.path.nativize( servlet.basePath ), directoryOptions ) );
  }

  let bodyParser = require( 'body-parser' );
  express.post( '/.process', bodyParser.json(), ( request, response ) =>
  {
    return servlet.processRequestHandle({ request, response })
  })

  express.use( ( request, response, next ) => servlet.requestPostHandler({ request, response, next }) );
  // express.use( ( error, request, response, next ) => servlet.requestErrorHandler({ error, request, response, next }) );
  express.use( function ()
  {
    servlet.requestErrorHandler
    ({
      request : arguments[ 0 ],
      response : arguments[ 1 ],
      next : arguments[ 2 ],
      // error : arguments[ 0 ],
    })
  });

  let o3 = _.servlet.controlExpressStart
  ({
    name : servlet.qualifiedName,
    verbosity : servlet.loggingRequestsAll ? system.verbosity - 1 : 0, /* xxx : use servlet.verbosity? */
    server : servlet.httpServer,
    express : servlet.express,
    serverPath : servlet.serverPath,
  });

  let ready = _.Consequence();

  o3.server.on( 'listening', () =>
  {
    servlet.httpServer = o3.server;
    servlet.express = o3.express;
    servlet.serverPath = o3.serverPath;

    ready.take( servlet );
  })

  /* - */

  return ready;
}

//

function serverLoggingForm()
{
  let servlet = this;

  _.assert( _.strDefined( servlet.serverPath ) );
  _.assert( !!servlet.httpServer );

  _.assert( servlet.loggerSocket === null );
  let loggerServerPath = _.uri.join( servlet.serverPath, '.log/' );
  loggerServerPath = _.uri.parseAtomic( loggerServerPath );
  loggerServerPath.protocol = 'ws';
  delete loggerServerPath.protocols;
  loggerServerPath = _.uri.str( loggerServerPath );
  servlet.loggerSocket = _.LoggerSocketReceiver
  ({
    httpServer : servlet.httpServer,
    owningHttpServer : 0,
    serverPath : loggerServerPath,
  });
  servlet.loggerSocket.form();
  servlet.loggerSocket.outputTo( logger );

}

//

function requestPreHandler( o )
{
  let servlet = this;

  _.servlet.controlRequestPreHandle
  ({
    allowCrossDomain : servlet.allowCrossDomain,
    verbosity : servlet.verbosity-2,
    request : o.request,
    response : o.response,
    next : o.next,
  });

  o.next();
}

//

function requestMidHandler( o )
{
  let servlet = this;
  o.next();
}

//

function requestPostHandler( o )
{
  let servlet = this;

  _.servlet.controlRequestPostHandle
  ({
    verbosity : servlet.verbosity,
    request : o.request,
    response : o.response,
    next : o.next,
  });

  o.next();
}

//

function requestErrorHandler( o )
{
  // debugger;
  if( o.response.headersSent )
  return o.next( o.error );
  o.error = _.err( o.error );

  _.errLogOnce( o.error )

  o.response.status( 500 );
  o.response.send( o.error.message );
  // o.response.write( o.error.message );
  // o.response.end();
  // o.response.render( 'error', { error : o.error } );
}

//

function _verbosityGet()
{
  let servlet = this;
  if( !servlet.system )
  return 9;
  return servlet.system.verbosity;
}

//

function openUriGet()
{
  let servlet = this;

  let parsedServerPath = _.uri.parseAtomic({ full : servlet.serverPath });

  if( parsedServerPath.host === '0.0.0.0' )
  parsedServerPath.host = '127.0.0.1';

  return _.uri.str( parsedServerPath );
}

//

function htmlForHtml( o )
{
  let servlet = this;
  let system = servlet.system;

  _.routine.optionsWithoutUndefined( htmlForHtml, o );

  if( o.realPath === null )
  o.realPath = servlet.pathVirtualToReal( o.resourcePath );

  let o2 = Object.create( null );
  o2.inPath = false;
  o2.outPath = false;
  o2.templatePath = o.realPath;
  o2.allowedPath = servlet.allowedPath;
  o2.withScripts = servlet.withScripts;
  o2.withStarter = servlet.withStarter;

  // debugger;
  let html = system.maker.htmlForFiles( o2 );

  if( o.response )
  {
    o.response.setHeader( 'Content-Type', 'text/html; charset=UTF-8' );
    o.response.write( html );
    o.response.end();
  }

  return html;
}

htmlForHtml.defaults =
{
  resourcePath : null,
  realPath : null,
  response : null,
  next : null,
}

//

function htmlForJs( o )
{
  let servlet = this;
  let system = servlet.system;

  _.routine.optionsWithoutUndefined( htmlForJs, o );

  if( o.realPath === null )
  o.realPath = servlet.pathVirtualToReal( o.resourcePath );

  let o2 = Object.create( null );
  o2.inPath = o.realPath;
  o2.outPath = false;
  o2.templatePath = servlet.templatePath;
  o2.allowedPath = servlet.allowedPath;
  o2.withScripts = servlet.withScripts;
  o2.withStarter = servlet.withStarter;

  let html = system.maker.htmlForFiles( o2 );

  if( o.response )
  {
    o.response.setHeader( 'Content-Type', 'text/html; charset=UTF-8' );
    o.response.write( html );
    o.response.end();
  }

  return html;
}

htmlForJs.defaults =
{
  resourcePath : null,
  realPath : null,
  request : null,
  response : null,
  next : null,
}

//

function jsSingleForJs( o )
{
  let servlet = this;
  let system = servlet.system;
  let maker = servlet.maker;

  o = _.routine.optionsWithoutUndefined( jsSingleForJs, arguments );

  try
  {

    let o2 = _.mapOnly_( null, servlet, system.maker.sourcesJoinFiles.defaults );
    o2.entryPath = o.realPath
    o2.inPath = servlet.basePath + '/**';
    o2.basePath = servlet.basePath;
    o2.interpreter = 'browser';
    o2.libraryName = _.path.fullName( o.realPath );
    o2.outPath = null;

    _.assert( _.strDefined( o2.entryPath ) );
    _.assert( _.strDefined( o2.inPath ) );
    _.assert( _.strDefined( o2.basePath ) );

    // debugger;
    let data = system.maker.sourcesJoinFiles( o2 );
    // debugger;

    if( o.response )
    {
      o.response.write( data );
      o.response.end();
    }

    return data;
  }
  catch( err )
  {
    err = _.err( err );
    if( o.request && o.response )
    {
      return _.servlet.errorHandle
      ({
        request : o.request,
        response : o.response,
        err,
      });
    }
    else
    {
      throw err;
    }
  }

}

jsSingleForJs.defaults =
{
  realPath : null,
  request : null,
  response : null,
}

//

function jsForJs( o )
{
  let servlet = this;
  let system = servlet.system;

  o =_.routine.optionsWithoutUndefined( jsForJs, arguments );

  try
  {

    if( o.realPath === null )
    o.realPath = servlet.pathVirtualToReal( o.resourcePath );

    if( o.withScripts === 'single' )
    return servlet.jsSingleForJs({ realPath, request, response });

    let splits = system.maker.sourceWrapSplits
    ({
      basePath : servlet.basePath,
      realToVirtualMap : servlet.realToVirtualMap,
      filePath : o.realPath,
      running : o.query.running,
      interpreter : 'browser',
      loggingPathTranslations : servlet.loggingPathTranslations,
    });

    let stream = _.fileProvider.streamRead
    ({
      filePath : o.realPath,
      throwing : 0,
    });

    if( !stream )
    return o.next();

    o.response.setHeader( 'Content-Type', 'application/javascript; charset=UTF-8' );

    let state = 0;

    if( servlet.verbosity >= 5 )
    console.log( ' . scriptWrap', o.resourcePath, 'of', o.realPath );

    stream.on( 'open', function()
    {
      state = 1;
      o.response.write( splits.prefix1 );
      o.response.write( splits.prefix2 );
    });

    stream.on( 'data', function( d )
    {
      state = 1;
      o.response.write( d );
    });

    stream.on( 'end', function()
    {
      if( state < 2 )
      {
        o.response.write( splits.postfix2 );
        o.response.write( splits.ware );
        o.response.write( splits.postfix1 );
        o.response.end();
      }
      state = 2;
    });

    stream.on( 'error', function( err )
    {
      if( state )
      {
        return _.servlet.errorHandle
        ({
          err : _.err( err ),
          request : o.request,
          response : o.response,
        });
      }
      else
      {
        o.next();
      }
      state = 2;
    });

  }
  catch( err )
  {
    return _.servlet.errorHandle
    ({
      err : _.err( err ),
      request : o.request,
      response : o.response,
    });
  }

}

jsForJs.defaults =
{
  resourcePath : null,
  realPath : null,
  query : null,
  request : null,
  response : null,
  next : null,
  withScripts : null,
}

//

function remoteResolve( o )
{
  let servlet = this;
  let resolvedFilePath;

  _.routine.optionsWithoutUndefined( remoteResolve, arguments );

  try
  {

    _.assert( _.strBegins( o.resourcePath, '/.resolve/' ) );

    if( o.realPath === null )
    o.realPath = _.strRemoveBegin( o.resourcePath, '/.resolve/' );

    if( _.path.isAbsolute( o.realPath ) || _.path.isDotted( o.realPath ) )
    o.realPath = _.path.reroot( servlet.basePath, o.realPath );

    if( _.path.isGlob( o.realPath ) )
    {

      _.sure( _.path.isAbsolute( o.realPath ) );
      let basePath = _.path.fromGlob( o.realPath );
      servlet.surePathAllowed( basePath );

      if( !servlet.resolvingGlob )
      {
        let err = _.err( `Field {- servlet.resolvingGlob -} is off` );
        throw err;
      }

      let filter = { filePath : o.realPath, basePath : servlet.basePath };

      resolvedFilePath = _.fileProvider.filesFind
      ({
        filter,
        mode : 'distinct',
        mandatory : 0,
        withDirs : 0,
        outputFormat : 'absolute',
      });

    }
    else if( !_.path.isAbsolute( o.realPath ) )
    {
      resolvedFilePath = forRelative();
    }

    resolvedFilePath = end( resolvedFilePath );

    if( o.response )
    o.response.json( resolvedFilePath );

  }
  catch( err )
  {
    err = _.err( err, `\nFailed to resolve ${o.resourcePath}` );
    if( o.request && o.response )
    {
      // return _.servlet.errorHandle
      // ({
      //   request : o.request,
      //   response : o.response,
      //   err
      // });
      o.response.json({ err : `Failed to resolve ${o.resourcePath}` });

    }
    else
    {
      throw err;
    }
  }

  return resolvedFilePath;

  /* */

  function end( resolvedFilePath )
  {
    if( _.arrayIs( resolvedFilePath ) )
    return resolvedFilePath.map( ( p ) => end( p ) );

    // resolvedFilePath = _.array.as( resolvedFilePath );
    // resolvedFilePath.forEach( ( p ) => servlet.surePathAllowed( p ) );

    servlet.surePathAllowed( resolvedFilePath );
    resolvedFilePath = servlet.pathRealToVirtual( resolvedFilePath );
    return resolvedFilePath;
  }

  /* */

  function forRelative()
  {
    if( o.query.dirPath )
    {
      let paths = _.path.traceToRoot( o.query.dirPath );
      for( let i = paths.length - 1; i >= 0; i-- )
      {
        let filePath = _.path.reroot( servlet.basePath, paths[ i ], 'node_modules', o.realPath );
        if( _.fileProvider.fileExists( filePath ) )
        {
          return filePath;
        }
      }
    }

    if( !servlet.resolvingNpm )
    {
      let err = _.err( `Cant resolve npm modules. Field {- servlet.resolvingNpm -} is disabled.` );
      // debugger;
      throw err;
    }

    return _.path.canonize( _.module.resolve( o.realPath ) );
  }

}

remoteResolve.defaults =
{
  resourcePath : null,
  realPath : null,
  request : null,
  response : null,
  query : null
}

//

function statPath( o )
{
  let servlet = this;
  let resolvedFilePath;

  _.routine.optionsWithoutUndefined( statPath, arguments );

  try
  {

    if( o.realPath === null )
    o.realPath = o.resourcePath;

    if( _.starter.pathVirtualIs( o.realPath ) )
    o.realPath = servlet.pathVirtualToReal( o.realPath );
    else if( _.path.isAbsolute( o.realPath ) || _.path.isDotted( o.realPath ) )
    o.realPath = _.path.reroot( servlet.basePath, o.realPath );

    _.assert( _.path.isAbsolute( o.realPath ) )

    let exists = _.fileProvider.fileExists( o.realPath );

    if( o.response )
    o.response.json({ exists });

  }
  catch( err )
  {
    err = _.err( err, `\nFailed to resolve ${o.resourcePath}` );
    if( o.request && o.response )
    {
      return _.servlet.errorHandle
      ({
        request : o.request,
        response : o.response,
        err
      });
    }
    else
    {
      throw err;
    }
  }

  return resolvedFilePath;

  /* */
}

statPath.defaults =
{
  resourcePath : null,
  realPath : null,
  request : null,
  response : null,
}

//

function processRequestHandle( o )
{
  let servlet = this;
  let session = servlet.session;

  _.routine.optionsWithoutUndefined( processRequestHandle, arguments );

  let routine = o.request.body.routine;
  let args = o.request.body.arguments;

  try
  {
    if( routine === 'exit' )
    {
      let result = _.process.exitCode( ... args );
      o.response.json({ result });
      session.unform();
    }
    else if( routine === 'exitCode' )
    {
      let result = _.process.exitCode( ... args );
      o.response.json({ result });
    }
    else
    {
      throw _.err( `Unexpected request ${o.request.body}` );
    }
  }
  catch( err )
  {
    if( o.request && o.response )
    {
      return _.servlet.errorHandle
      ({
        request : o.request,
        response : o.response,
        err
      });
    }
    else
    {
      throw err;
    }
  }
}

processRequestHandle.defaults =
{
  request : null,
  response : null,
}

//

function starterWareReturn( o )
{
  let servlet = this;
  o.response.setHeader( 'Content-Type', 'application/javascript; charset=UTF-8' );
  o.response.write( o.fop.ware );
  o.response.end();
  return null;
}

//

function surePathAllowed( filePath )
{
  let servlet = this;
  return _.sure( _.starter.pathAllowedIs( servlet.allowedPath, filePath ), `Path "${filePath}" is not allowed` );
}

//

function pathRealToVirtual( realPath )
{
  let servlet = this;
  let result = _.starter.pathRealToVirtual
  ({
    realPath,
    basePath : servlet.basePath,
    realToVirtualMap : servlet.realToVirtualMap,
    verbosity : servlet.loggingPathTranslations,
  });
  // debugger;
  return _.path.s.join( '/', result );
}

//

function pathVirtualToReal( virtualPath )
{
  let servlet = this;
  let result = _.starter.pathVirtualToReal
  ({
    virtualPath,
    basePath : servlet.basePath,
    virtualToRealMap : servlet.virtualToRealMap,
    verbosity : servlet.loggingPathTranslations,
  });
  return result;
}

//

async function pathsForm()
{
  let servlet = this;
  let system = servlet.system;

  _.assert( servlet.virtualToRealMap === null );
  _.assert( servlet.realToVirtualMap === null );
  _.assert( _.mapIs( servlet.allowedPath ) );

  servlet.virtualToRealMap = Object.create( null );
  servlet.realToVirtualMap = Object.create( null );

  for( let absolutePath in servlet.allowedPath )
  {
    _.assert( _.path.isAbsolute( absolutePath ) );
    if( !servlet.allowedPath[ absolutePath ] )
    continue;
    let relativePath = _.path.relative( servlet.basePath, absolutePath );
    if( _.path.isDotted( relativePath ) && relativePath !== '.' )
    {
      let virtualPath = '_' + ( _.entity.lengthOf( servlet.realToVirtualMap ) + 1 ) + '_';
      servlet.virtualToRealMap[ virtualPath ] = absolutePath;
      servlet.realToVirtualMap[ absolutePath ] = virtualPath;
    }
  }

  /* serverPath */

  if( servlet.serverPath === null )
  servlet.serverPath = servlet._defaultServerPath;

  let parsedServerPath = _.servlet.serverPathParse({ full : servlet.serverPath });

  _.sure( _.numberIsFinite( parsedServerPath.port ), () => 'Expects number {-port-}, but got ' + _.entity.exportStringDiagnosticShallow( parsedServerPath.port ) );

  if( parsedServerPath.port === 0 )
  {
    parsedServerPath.port = await system._getRandomPort();
    parsedServerPath.full = _.uri.str( parsedServerPath );
  }
  else
  {
    await system._checkIfPortIsOpen( parsedServerPath.port );
  }

  servlet.serverPath = parsedServerPath.full;
}

// --
//
// --

function scriptWrap_functor( fop )
{
  let servlet = this;
  let system = servlet.system;

  fop = _.routine.optionsWithoutUndefined( scriptWrap_functor, arguments );

  _.assert( servlet instanceof _.starter.Servlet );
  _.assert( system instanceof _.starter.System );
  _.assert( system.maker instanceof _.starter.Maker );
  _.assert( _.strDefined( servlet.basePath ) );
  _.assert( _.mapIs( servlet.allowedPath ) );
  _.assert( _.arrayIs( servlet.incudingExts ) );
  _.assert( _.arrayIs( servlet.excludingExts ) );

  if( !Querystring )
  Querystring = require( 'querystring' );

  if( !fop.ware )
  {
    let o2 = _.mapOnly_( null, servlet, system.maker.sourcesJoinSplits.defaults );
    o2.interpreter = 'browser';
    o2.libraryName = 'Starter';
    o2.withServer = 1;

    o2.loggingPath = _.uri.parseConsecutive( servlet.serverPath );
    o2.loggingPath.protocol = 'ws';
    o2.loggingPath.longPath = _.uri.join( o2.loggingPath.longPath, '.log/' );
    o2.loggingPath = _.uri.str( o2.loggingPath );

    let splits = system.maker.sourcesJoinSplits( o2 );
    fop.ware = system.maker.sourcesSplitsJoin( splits );
  }

  scriptWrap.defaults =
  {
    request : null,
    response : null,
    next : null,
  }

  return scriptWrap;

  function _scriptWrap( o )
  {

    _.routine.assertOptions( scriptWrap, arguments );
    o.fop = fop;
    // console.log( 'o.request.url', o.request.url );
    o.request.url = Querystring.unescape( o.request.url );
    o.uri = _.uri.parseFull( o.request.url );
    o.exts = _.uri.exts( o.uri.longPath );
    o.query = o.uri.query ? _.strWebQueryParse( o.uri.query ) : Object.create( null );

    o.query.entry = !!o.query.entry;
    if( o.query.running === undefined )
    // o.query.running = 0; /* yyy */
    o.query.running = 1;
    o.query.running = !!o.query.running;

    if( servlet.loggingRequests )
    logger.log( ` . request ${_.ct.format( _.uri.str( o.uri ), 'path' )} ` );

    if( o.uri.longPath === '/.starter' )
    {
      return servlet.starterWareReturn( o );
    }
    else if( _.strBegins( o.uri.longPath, '/.resolve/' ) )
    {
      return servlet.remoteResolve
      ({
        resourcePath : o.uri.longPath,
        realPath : o.realPath,
        response : o.response,
        request : o.request,
        query : o.query
      });
    }
    else if( o.uri.query && _.strHas( o.uri.query, 'stat' ) )
    {
      return servlet.statPath
      ({
        resourcePath : o.uri.longPath,
        realPath : o.realPath,
        response : o.response,
        request : o.request,
      });
    }

    o.realPath = servlet.pathVirtualToReal( o.uri.longPath );
    o.shortName = _.strVarNameFor( _.path.fullName( o.realPath ) );

    if( o.query.withScripts === 'single' )
    {
      return servlet.jsSingleForJs
      ({
        realPath : o.realPath,
        response : o.response,
        request : o.request,
      });
    }

    if( o.query.entry )
    {
      if( o.query.format === 'html' )
      return servlet.htmlForHtml
      ({
        resourcePath : o.uri.longPath,
        realPath : o.realPath,
        response : o.response,
        next : o.next,
      });
      else
      return servlet.htmlForJs
      ({
        resourcePath : o.uri.longPath,
        realPath : o.realPath,
        response : o.response,
        request : o.request,
        next : o.next,
      });
    }

    if( _.longHasAny( servlet.excludingExts, o.exts ) )
    return o.next();

    if( !_.fileProvider.isTerminal( o.realPath ) )
    return o.next();

    if( _.longHasAny( o.exts, [ 'html', 'htm' ] ) )
    return servlet.htmlForHtml
    ({
      resourcePath : o.uri.longPath,
      realPath : o.realPath,
      response : o.response,
      next : o.next,
    });

    if( servlet.naking )
    return o.next();

    if( !_.longHasAny( servlet.incudingExts, o.exts ) )
    if( !isModuleDeclarationFile( o.realPath ) )
    return o.next();

    servlet.surePathAllowed( o.realPath );

    return servlet.jsForJs
    ({
      resourcePath : o.uri.longPath,
      realPath : o.realPath,
      query : o.query,
      response : o.response,
      request : o.request,
    });

  }

  /* - */

  function scriptWrap( o )
  {
    try
    {
      return _scriptWrap.apply( this, arguments );
    }
    catch( err )
    {
      throw _.err( err );
    }
  }

  /* - */

  function isModuleDeclarationFile( realPath )
  {
    let parentDir = _.path.name( _.path.dir( realPath ) );
    return parentDir === 'node_modules';
  }

}

var defaults = scriptWrap_functor.defaults = Object.create( null );

//

function ScriptWrap_functor( o )
{
  o = _.routine.optionsWithoutUndefined( ScriptWrap_functor, arguments );

  if( o.servlet === null )
  {
    delete o.servlet;
    o.servlet = new _.Servlet( o );
  }

  let result = o.servlet.scriptWrap_functor();

  return result;
}

var defaults = ScriptWrap_functor.defaults = Object.create( null );

defaults.servlet = null;
defaults.system = null;
defaults.basePath = null;
defaults.allowedPath = '/';
defaults.verbosity = 0;
defaults.incudingExts = null;
defaults.excludingExts = null;
defaults.templatePath = null;
defaults.resolvingGlob = 1;
defaults.resolvingNpm = 1;
defaults.proceduring = 0;
defaults.loggingApplication = 0;
defaults.loggingSourceFiles = 0;
defaults.loggingPathTranslations = 1;

// --
// relations
// --

let Composes =
{

  servingDirs : 0,
  loggingApplication : 1,
  loggingSourceFiles : 0,
  loggingRequestsAll : 0,
  loggingRequests : 0,
  loggingPathTranslations : 0,
  proceduring : 0,
  catchingUncaughtErrors : 1,
  naking : 0,
  withScripts : 'include',
  withStarter : 'include',

  resolvingGlob : 1,
  resolvingNpm : 1,

  owningHttpServer : 1,

  serverPath : null,
  // serverPath : 'http://0.0.0.0:15000',
  basePath : null,
  virtualToRealMap : null,
  realToVirtualMap : null,
  allowedPath : '/',
  templatePath : null,

  incudingExts : _.define.own([ 's', 'js', 'ss' ]),
  excludingExts : _.define.own([ 'raw', 'usefile' ]),

}

let Associates =
{
  system : null, /* xxx : remove? */
  httpServer : null,
  express : null,
  loggerSocket : null,
  session : null
}

let Restricts =
{
  formed : 0,
  _requestScriptWrapHandler : null,
  _defaultServerPath : 'http://127.0.0.1:15000'
}

let Statics =
{
  ScriptWrap_functor,
}

let Accessors =
{
  verbosity : { get : _verbosityGet, writable : 0 },
}

let Forbids =
{
  server : 'server',
}

// --
// prototype
// --

let Proto =
{

  finit,
  instanceOptions,
  unform,
  form,
  serverForm,
  serverLoggingForm,

  requestPreHandler,
  requestMidHandler,
  requestPostHandler,
  requestErrorHandler,

  _verbosityGet,
  openUriGet,

  htmlForHtml,
  htmlForJs,
  jsSingleForJs,
  jsForJs,
  remoteResolve,
  statPath,
  processRequestHandle,
  starterWareReturn,

  surePathAllowed,
  pathRealToVirtual,
  pathVirtualToReal,
  pathsForm,

  scriptWrap_functor,
  ScriptWrap_functor,

  /* */

  Composes,
  Associates,
  Restricts,
  Statics,
  Accessors,

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

})();
