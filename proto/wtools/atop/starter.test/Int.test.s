( function _Int_test_s_()
{

'use strict';

let Jsdom;

/* xxx :

- implement option to print diagnostic information of run program: time ...
- add entry file with option to print diagnostic information on

*/

if( typeof module !== 'undefined' )
{

  Jsdom = require( 'jsdom' );
  const _ = require( '../../../node_modules/Tools' );

  _.include( 'wTesting' );
  _.include( 'wPuppet' );
  _.include( 'willbe' );

  require( '../starter/entry/Include.s' );

}

const _global = _global_;
const _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin()
{
  let context = this;

  context.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..' ), 'Starter' );
  context.assetsOriginalPath = _.path.join( __dirname, '_asset' );
  context.willbeExecPath = _.Will.WillPathGet();
  context.appJsPath = _.path.join( __dirname, '../starter/entry/Exec');
}

//

function onSuiteEnd()
{
  let context = this;
  _.assert( _.strHas( context.suiteTempPath, '/Starter' ) )
  _.path.tempClose( context.suiteTempPath );
}

//

function assetFor( test, name )
{
  let context = this;
  let a = test.assetFor( name );

  a.find = _.fileProvider.filesFinder
  ({
    withTerminals : 1,
    withDirs : 1,
    withTransient : 1,
    allowingMissed : 1,
    maskPreset : 0,
    outputFormat : 'relative',
    filter :
    {
      filePath : { 'node_modules' : 0, 'package.json' : 0, 'package-lock.json' : 0 },
      recursive : 2,
    }
  });

  a.will = _.process.starter
  ({
    execPath : context.willbeExecPath,
    currentPath : a.routinePath,
    outputCollecting : 1,
    outputGraying : 1,
    ready : a.ready,
    mode : 'fork',
  })

  let oprogram = a.program;
  program_body.defaults = a.program.defaults;
  a.program = _.routine.uniteCloning_replaceByUnite( a.program.head, program_body );
  return a;

  /* */

  function program_body( o )
  {
    let locals =
    {
      toolsPath : _.module.resolve( 'wTools' ),
    };
    o.locals = o.locals || locals;
    _.props.supplement( o.locals, locals );
    let r = oprogram.body.call( a, o );
    r.filePath/*programPath*/ = a.path.nativize( r.filePath/*programPath*/ );
    return r;
  }
}

// --
// tests
// --

function sourcesJoinWithExternalBeforePath( test )
{
  let context = this;
  let a = context.assetFor( test, 'combined' );
  a.reflect();
  let outPath = a.abs( 'out/Main.s' );

  /* - */

  a.ready.then( () =>
  {
    test.case = 'join files';
    var sourcePath1 = a.abs( 'main/File1.s' );
    var sourcePath2 = a.abs( 'main/File2.s' );
    var starter = new _.starter.Maker();
    // starter.form();
    let filesMap = Object.create( null );
    filesMap[ sourcePath1 ] = a.fileProvider.fileRead( sourcePath1 );
    filesMap[ sourcePath2 ] = a.fileProvider.fileRead( sourcePath2 );

    var o =
    {
      outPath,
      entryPath : sourcePath1,
      basePath  : a.abs( '.' ),
      externalBeforePath : [ a.abs( 'External.s' ) ],
      externalAfterPath : null,
      filesMap,
      removingShellPrologue : 1,
      withServer : 0,
    };
    var got = starter.sourcesJoin( o );
    test.true( _.str.is( got ) );
    a.fileProvider.fileWrite( outPath, got );
    return null;
  });

  a.shell( `node ${ a.path.nativize( outPath ) }` );
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strLinesCount( op.output ), 4 );
    return null;
  });

  /* */

  return a.ready;
}

//

function sourcesJoinFiles( test )
{
  let context = this;
  let a = context.assetFor( test, 'several' );
  let outputPath = _.path.join( a.routinePath, 'Index.js' );
  let ready = new _.Consequence().take( null );
  let starter = new _.starter.System().form();

  a.reflect();

  let js = _.process.starter
  ({
    execPath : 'node',
    currentPath : a.routinePath,
    outputCollecting : 1,
    ready,
  });

  starter.sourcesJoinFiles
  ({
    inPath : '**',
    entryPath : 'File2.js',
    basePath : a.routinePath,
  })

  var files = a.find( a.routinePath );
  test.identical( files, [ '.', './File1.js', './File2.js', './Index.js' ] );

  let read = _.fileProvider.fileRead( outputPath );
  test.identical( _.strCount( read, 'setTimeout( f, 1000 );' ), 2 );

  js( _.path.nativize( outputPath ) )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var output =
    `
    File1.js:0
    File1.js:1
    File1.js:2
    File2.js:0
    File2.js:1
    File2.js:2
    File1.js:timeout
    File2.js:timeout
    `;
    test.equivalent( op.output, output );
    return op;
  });

  return ready;
}

//

function sourcesJoinFilesWithModule( test )
{
  const context = this;
  const a = context.assetFor( test, 'module' );
  a.reflect();

  /* */

  const starter = new _.starter.System().form();
  const options = Object.create( null );
  options.outPath = a.abs( 'out/Compiled.s' );
  options.basePath = a.abs( '.' );
  options.entryPath = a.abs( 'node_modules/wConsequence/proto/wtools/abase/l9/consequence/Namespace.s' );
  options.inPath =
  {
    filePath :
    [
      a.abs( 'node_modules/wConsequence/proto/wtools/abase/l9/consequence/Namespace.s' ),
      a.abs( 'node_modules/wConsequence/proto/node_modules/*' ),
      a.abs( 'node_modules/wConsequence/proto/**/*.(s|ss)' ),
      a.abs( `node_modules/wTools/proto/**/*.(s|ss)` ),
      a.abs( `node_modules/wTools/proto/node_modules/*` ),
      a.abs( `node_modules/wProto/proto/**/*.(s|ss)` ),
      a.abs( `node_modules/wProto/proto/node_modules/*` ),
      a.abs( `node_modules/wblueprint/proto/**/*.(s|ss)` ),
      a.abs( `node_modules/wblueprint/proto/node_modules/*` ),
    ],
    maskDirectory : { excludeAny : /test$/, includeAny : 'testing' },
    maskTransientDirectory : { excludeAny : /test$/, includeAny : 'testing' },
  };

  a.shell( 'npm i' );
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    starter.sourcesJoinFiles( options );
    var files = a.fileProvider.dirRead( a.abs( '.' ) );
    test.identical( files, [ 'node_modules', 'out', 'package-lock.json', 'package.json', 'Sample.s' ] );
    var files = a.fileProvider.dirRead( a.abs( 'out' ) );
    test.identical( files, [ 'Compiled.s' ] );
    return null
  });

  /* */

  a.ready.then( () =>
  {
    debugger;
    return null
  })
  a.shell( 'node Sample.s');
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.output, 'Succefully included compiled file.\n' );
    return null
  });

  /* - */

  return a.ready;
}

//

function sourcesJoinFilesCheckRoutines( test )
{
  let context = this;
  let a = context.assetFor( test, 'several' );
  let filePath/*programPath*/ = a.program( checkRoutines ).filePath/*programPath*/;

  /* */

  a.ready.then( () =>
  {
    test.case = 'join files';
    var starter = new _.starter.System();
    starter.form();
    var o =
    {
      basePath : a.abs( __dirname, '../../../..' ),
      interpreter : 'njs',
      inPath : { filePath : a.abs( __dirname, '../../../../node_modules/wTools/**.(s|ss)' ) },
      outPath : a.abs( 'out/SingleFileTools.ss' ),
      entryPath : a.abs( __dirname, '../../../../node_modules/wTools/**.(s|ss)' ),
      // entryPath : a.abs( __dirname, '../../../../node_modules/wTools/proto/node_modules/Tools' ),
      withServer : 0,
    };
    starter.sourcesJoinFiles( o );
    test.true( _.fileProvider.fileExists( a.abs( 'out/SingleFileTools.ss' ) ) );
    return null;
  });

  a.shell( `node ${ filePath/*programPath*/ }` );
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.ge( op.output.length, 500 );
    return null;
  });

  /* */

  return a.ready;

  /* */

  function checkRoutines()
  {
    require( './out/SingleFileTools.ss' );
    const _ = _global_._starter_;
    // const _ = _global_.wTools;

    console.log( `primitiveIs : ${ _.primitiveIs( 1 ) }` );
    console.log( `set.is : ${ _.set.is( new Set() ) }` );
    console.log( `argumentsArray.is : ${ _.argumentsArray.is( null ) }` );
    console.log( `aux.is : ${ _.aux.is( {} ) }` );
    console.log( `constructible.is : ${ _.constructible.is( {} ) }` );
    console.log( `hashMap.is : ${ _.hashMap.is( {} ) }` );
    console.log( `mapIs : ${ _.aux.is( new Set() ) }` );
    console.log( `strSplit : ${ _.strSplit( 'a b c' ) }` );
    console.log( `strIsolateLeftOrNone : ${ _.strIsolateLeftOrNone( 'a b c', ' ' ) }` );
    console.log( `routineIs _.introspector.stack : ${ _.routineIs( _.introspector.stack ) }` );
    console.log( `_.routineIs _.event.on : ${ _.routineIs( _.event.on ) }` );
    console.log( `_.errAttend( _.err( 'a' ) ) : ${ _.errAttend( _.err( 'a' ) ).message }` );

    console.log( `_.entity.strType : ${ _.entity.strType( new HashMap( [ [] ] ) ) }` );
    console.log( `_.entity.makeUndefined : ${ _.entity.makeUndefined( [] ) }` );

    console.log( `_.path.nativize : ${ _.path.nativize( '/c/abc' ) }` );
    console.log( `_.path.isGlob : ${ _starter_.path.isGlob( '/c/abc' ) }` );
    console.log( `_.path.refine : ${ _.path.refine( '/c/abc' ) }` );

    console.log( `_.number.isFinite : ${ _.number.isFinite( 1 ) }` );
    console.log( `_.number.fromStrMaybe : ${ _.number.fromStrMaybe( '1' ) }` );

    console.log( `_.uri.refine : ${ _starter_.uri.refine( '/c/abc' ) }` );
    console.log( `_.uri.parseConsecutive : ${ _starter_.uri.parseConsecutive( '/c/abc' ).longPath }` );
    console.log( `_.uri.canonizeTolerant : ${ _starter_.uri.canonizeTolerant( '/c/abc' ) }` );
  }
}

//

async function singleFileServerLessBuild( test )
{
  let context = this;
  let a = context.assetFor( test, 'singleFileBuild' );
  let outputPath = a.abs( 'out/Index.js' );
  let starter = new _.starter.System().form();
  var page, window;

  a.reflect();

  await a.will({ args : '.build' })

  starter.sourcesJoinFiles
  ({
    inPath : [ 'build/**.(s|ss|js)', 'build/node_modules/*' ],
    entryPath : 'build/Entry.js',
    outPath : 'out/Out.js',
    basePath : a.abs( '.' ),
    interpreter : 'browser',
    withServer : 0,
  })
  test.true( _.fileProvider.fileExists( a.abs( 'out/Out.js' ) ) );

  try
  {
    window = await _.puppet.windowOpen({ headless : true });
    page = await window.pageOpen();

    await page.goto( `file://${a.fileProvider.path.nativize( a.abs( 'Index.html' ) )}` );

    /* */

    test.case = 'starter.withServer is false'
    var got = await page.eval( () =>
    {
      return _starter_.withServer;
    });
    test.identical( got, 0 );

    /* */

    test.case = 'try to include unknown path'
    var got = await page.eval( () =>
    {
      try
      {
        require( '/unknown' );
        return false;
      }
      catch( err )
      {
        return true;
      }
    });
    test.identical( got, true );

    /* */

    test.case = 'try to include module using it name'
    var got = await page.eval( () =>
    {
      try
      {
        require( 'wTools' );
        return wTools.map.is( wTools );
      }
      catch( err )
      {
        return false;
      }
    })
    test.identical( got, true );

    /* */

    test.case = 'try to include module using path'
    var got = await page.eval( () =>
    {
      try
      {
        require( '/build/wtools/abase/l2/PathBasic.s' );
        return wTools.path.join( '/a', 'b' );
      }
      catch( err )
      {
        return false;
      }
    })
    test.identical( got, '/a/b' );

    /* */

    test.case = 'try to include module via include'
    var got = await page.eval( () =>
    {
      try
      {
        const _ = require( 'wTools' );
        _.include( 'wPathBasic' );
        return _.path.join( '/a', 'b' );
      }
      catch( err )
      {
        return false;
      }
    })
    test.identical( got, '/a/b' );

    /* */

    test.case = 'try to include missing module via include'
    var got = await page.eval( () =>
    {
      try
      {
        const _ = require( 'wTools' );
        _.include( 'wFiles' );
        return true;
      }
      catch( err )
      {
        return false;
      }
    })
    test.identical( got, false );

    /* */

    test.case = 'process.exit sets exit code, but does not close the browser'
    var got = await page.eval( () =>
    {
      try
      {
        process.exit( -1 );
        return process.exitCode;
      }
      catch( err )
      {
        return false;
      }
    })
    test.identical( got, -1 );
    test.identical( page._handle.isClosed(), false );

    /* */

    await window.close();
  }
  catch( err )
  {
    test.exceptionReport({ err });
    await window.close();
  }
}

//

function htmlForFilesBasic( test )
{
  let context = this;
  let a = context.assetFor( test, 'several' );
  let outputPath = _.path.join( a.routinePath, 'Index.html' );
  let ready = new _.Consequence().take( null );
  let starter = new _.starter.System().form();

  /* */

  test.case = 'default';

  a.reflect();

  starter.htmlForFiles
  ({
    inPath : '**',
    basePath : a.routinePath,
  })

  var files = a.find( a.routinePath );
  test.identical( files, [ '.', './File1.js', './File2.js', './Index.html' ] );

  var read = a.fileProvider.fileRead( outputPath );
  var dom = new Jsdom.JSDOM( read );
  var document = dom.window.document;

  test.description = 'scripts';
  var exp = [ '/.starter', './File1.js', './File2.js' ];
  var got = _.select( _.array.from( document.querySelectorAll( 'script' ) ), '*/src' );
  test.identical( got, exp );

  test.description = 'title';
  var exp = [ 'File1.js' ];
  var got = _.select( _.array.from( document.querySelectorAll( 'title' ) ), '*/text' );
  test.identical( got, exp );

  var got = document.querySelectorAll( 'html' );
  test.identical( got.length, 1 );

  /* */

  return ready;
}

//

function htmlForFilesOptionTitle( test )
{
  let context = this;
  let a = context.assetFor( test, 'several' );
  let outputPath = _.path.join( a.routinePath, 'Index.html' );
  let ready = new _.Consequence().take( null );
  let starter = new _.starter.System().form();

  /* */

  test.case = 'default';

  a.reflect();

  starter.htmlForFiles
  ({
    inPath : '**',
    basePath : a.routinePath,
  })

  var read = a.fileProvider.fileRead( outputPath );
  var dom = new Jsdom.JSDOM( read );
  var document = dom.window.document;

  test.description = 'title';
  var exp = [ 'File1.js' ];
  var got = _.select( _.array.from( document.querySelectorAll( 'title' ) ), '*/text' );
  test.identical( got, exp );

  /* */

  test.case = 'explicit';

  a.reflect();

  starter.htmlForFiles
  ({
    inPath : '**',
    basePath : a.routinePath,
    title : 'Explicit Title',
  })

  var read = a.fileProvider.fileRead( outputPath );
  var dom = new Jsdom.JSDOM( read );
  var document = dom.window.document;

  test.description = 'title';
  var exp = [ 'Explicit Title' ];
  var got = _.select( _.array.from( document.querySelectorAll( 'title' ) ), '*/text' );
  test.identical( got, exp );

  /* */

  return ready;
}

//

function htmlForFilesOptionWithStarter( test )
{
  let context = this;
  let a = context.assetFor( test, 'several' );
  let outputPath = _.path.join( a.routinePath, 'Index.html' );
  let ready = new _.Consequence().take( null );
  let starter = new _.starter.System().form();

  /* */

  test.case = 'without starter';

  a.reflect();

  starter.htmlForFiles
  ({
    inPath : '**',
    basePath : a.routinePath,
    title : 'Html for test',
    withStarter : 0,
  })

  var files = a.find( a.routinePath );
  test.identical( files, [ '.', './File1.js', './File2.js', './Index.html' ] );

  var read = a.fileProvider.fileRead( outputPath );
  var dom = new Jsdom.JSDOM( read );
  var document = dom.window.document;

  test.description = 'scripts';
  var exp = [ './File1.js', './File2.js' ];
  var got = _.select( _.array.from( document.querySelectorAll( 'script' ) ), '*/src' );
  test.identical( got, exp );

  /* */

  return ready;
}

//

async function includeCss( test )
{
  let context = this;
  let a = context.assetFor( test, 'includeCss' );
  let starter = new _.starter.System({ verbosity : test.suite.verbosity >= 7 ? 3 : 0 }).form();
  var page, window;

  a.reflect();

  let session = await starter.start
  ({
    basePath : a.routinePath,
    entryPath : 'Index.js',
    curating : 0
  })

  var parsed = _.uri.parse( session.entryWithQueryUri );

  try
  {
    window = await _.puppet.windowOpen({ headless : true });
    page = await window.pageOpen();

    await page.goto( session.entryWithQueryUri );

    var got = await page.selectEval( 'script', ( scripts ) => scripts.map( ( s ) => s.src ) );
    test.identical( got, [ `${parsed.origin}/.starter`, `${parsed.origin}/Index.js` ] );

    var got = await page.eval( () =>
    {
      var style = window.getComputedStyle( document.querySelector( 'body') );
      return style.getPropertyValue( 'background' )
    });
    test.true( _.strHas( got, 'rgb(192, 192, 192)' ) );
    await window.close();
  }
  catch( err )
  {
    test.exceptionReport({ err });
    await window.close();
  }

  return starter.close();
}

//

async function includeExcludingManual( test )
{
  let context = this;
  let a = context.assetFor( test, 'exclude' );
  let starter = new _.starter.System({ verbosity : test.suite.verbosity >= 7 ? 3 : 0 }).form();
  let window, page;

  a.reflect();

  let session = await starter.start
  ({
    basePath : a.routinePath,
    entryPath : 'Index.js',
    curating : 0,
  })

  var parsed = _.uri.parse( session.entryWithQueryUri );

  try
  {
    window = await _.puppet.windowOpen({ headless : true });
    page = await window.pageOpen();

    await page.goto( session.entryWithQueryUri );

    var scripts = await page.selectEval( 'script', ( scripts ) => scripts.map( ( s ) => s.innerHTML || s.src ) )
    test.identical( scripts.length, 3 );
    test.identical( scripts[ 0 ], `${parsed.origin}/.starter` );
    test.identical( scripts[ 1 ], `${parsed.origin}/Index.js` );
    test.true( _.strHas( scripts[ 2 ], './src/File.js' ) );

    await window.close();
  }
  catch( err )
  {
    test.exceptionReport({ err });
    await window.close();
  }

  return starter.close();
}

//

async function includeModule( test )
{
  let context = this;
  let a = context.assetFor( test, 'includeModule' );
  let starter = new _.starter.System({ verbosity : test.suite.verbosity >= 7 ? 3 : 0 }).form();
  let window, page;

  a.reflect();

  await a.will({ args : '.build' })

  let session = await starter.start
  ({
    basePath : _.path.join( a.routinePath, 'build' ),
    entryPath : 'Index.js',
    curating : 0,
  })

  var parsed = _.uri.parse( session.entryWithQueryUri );

  try
  {
    window = await _.puppet.windowOpen({ headless : true });
    page = await window.pageOpen();

    await page.goto( session.entryWithQueryUri );

    var result = await page.eval( () =>
    {
      const _ = _global_.wTools;
      _.include( 'wPathBasic' );
      return _.path.join( '/a', 'b' );
    })
    test.identical( result, '/a/b' )

    await window.close();
  }
  catch( err )
  {
    test.exceptionReport({ err });
    await window.close();
  }

  return starter.close();
}

includeModule.timeOut = 300000;

// --
// worker
// --

async function workerWithInclude( test )
{
  let context = this;
  let a = context.assetFor( test, 'workerUsingTheSameInclude' );
  let starter = new _.starter.System({ verbosity : test.suite.verbosity >= 7 ? 3 : 0 }).form();
  let window, page;

  a.reflect();

  // var files = a.fileProvider.dirRead( a.routinePath );
  // logger.log( `files : ${files}` );

  let session = await starter.start
  ({
    basePath : a.routinePath,
    entryPath : 'Index.js',
    curating : 0,
  })

  var parsed = _.uri.parse( session.entryWithQueryUri );

  try
  {
    window = await _.puppet.windowOpen({ headless : true });
    page = await window.pageOpen();
    let output = '';

    page.on( 'console', ( msg ) => output += msg.text() + '\n' );

    await page.goto( session.entryWithQueryUri );
    await _.time.out( context.deltaTime2 );

    test.true( _.strHas( output, 'Global : Window' ) )
    test.true( _.strHas( output, 'Global : DedicatedWorkerGlobalScope' ) )

    await window.close();
  }
  catch( err )
  {
    test.exceptionReport({ err });
    await window.close();
  }

  return starter.close();
}

workerWithInclude.timeOut = 300000;

//

async function includeModuleInWorker( test )
{
  let context = this;
  let a = context.assetFor( test, 'includeModuleInWorker' );
  let starter = new _.starter.System({ verbosity : test.suite.verbosity >= 7 ? 3 : 0 }).form();
  let window, page;

  test.description = 'include module two times, second time module cache should be used'

  a.reflect();

  await a.will({ args : '.build' })

  let session = await starter.start
  ({
    basePath : _.path.join( a.routinePath, 'build' ),
    entryPath : 'Index.js',
    curating : 0,
  })

  var parsed = _.uri.parse( session.entryWithQueryUri );

  try
  {
    window = await _.puppet.windowOpen({ headless : true });
    page = await window.pageOpen();
    let output = '';

    page.on( 'console', ( msg ) => output += msg.text() + '\n' );

    await page.goto( session.entryWithQueryUri );

    await _.time.out( context.deltaTime2 );

    console.log( output )

    test.case = 'module was exported and returned object is same as global namespace created in module'
    test.true( _.strHas( output, `Module was exported: true` ) );
    test.case = 'two includes return same object'
    test.true( _.strHas( output, `Both includes have same export: true` ) );

    await window.close();
  }
  catch( err )
  {
    test.exceptionReport({ err });
    await window.close();
  }

  return starter.close();
}

includeModuleInWorker.timeOut = 300000;

//

async function includeModuleInWorkerThrowing( test )
{
  let context = this;
  let a = context.assetFor( test, 'includeModuleInWorkerThrowing' );
  let starter = new _.starter.System({ verbosity : test.suite.verbosity >= 7 ? 3 : 0 }).form();
  let window, page;

  test.description = 'module throws an error during include process, error should be catched in try/catch block'

  a.reflect();

  await a.will({ args : '.build' })

  let session = await starter.start
  ({
    basePath : _.path.join( a.routinePath, 'build' ), /* xxx : replace */
    entryPath : 'Index.js',
    curating : 0,
  })

  var parsed = _.uri.parse( session.entryWithQueryUri );

  try
  {
    window = await _.puppet.windowOpen({ headless : true });
    page = await window.pageOpen();
    let output = '';

    page.on( 'console', ( msg ) => output += msg.text() + '\n' );

    await page.goto( session.entryWithQueryUri );

    await _.time.out( context.deltaTime2 );

    // console.log( '!' + output + '!' );

    test.true( !_.strHas( output, `Module was included` ) );
    test.true( _.strHas( output, `Module error` ) );
    test.true( _.strHas( output, `Error including source file /Module.js` ) );

    await window.close();
  }
  catch( err )
  {
    test.exceptionReport({ err });
    await window.close();
  }

  return starter.close();
}

includeModuleInWorkerThrowing.timeOut = 300000;

// --
// curated run
// --

async function curatedRunWindowOpenCloseAutomatic( test )
{
  let context = this;
  let a = context.assetFor( test, 'minute' );
  let starter = new _.starter.System({ verbosity : test.suite.verbosity >= 7 ? 3 : 0 }).form();
  let session;

  try
  {

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, false );

    // await _.time.out( context.deltaTime3 ); /* xxx : remove later and find fix working for linux */

    session = await starter.start
    ({
      entryPath : a.originalAbs( './F1.js' ),
      headless : 1,
      cleanupAfterStarterDeath : 0
    })

    test.identical( session.curratedRunState, 'launching' );

    await _.time.out( context.deltaTime2 ); /* xxx : remove later and find fix working for linux */

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, true );

    await _.time.out( context.deltaTime2 );

    test.identical( session.curratedRunState, 'launched' );

    await session.unform();

    test.identical( session.curratedRunState, 'terminated' );
    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, false );
    test.identical( session.curratedRunState, 'terminated' );

  }
  catch( err )
  {
    if( session )
    await session.unform();
  }

}

curatedRunWindowOpenCloseAutomatic.timeOut = 300000;

//

async function curatedRunWindowOpenCloseWindowManually( test )
{
  let context = this;
  let a = context.assetFor( test, 'minute' );
  let starter = new _.starter.System({ verbosity : test.suite.verbosity >= 7 ? 3 : 0 }).form();
  let session;

  try
  {

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, false );

    session = await starter.start
    ({
      entryPath : a.originalAbs( './F1.js' ),
      headless : 1,
      cleanupAfterStarterDeath : 0
    })

    test.identical( session.curratedRunState, 'launching' );

    await _.time.out( context.deltaTime2 );

    test.identical( session.curratedRunState, 'launched' );

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, true );

    await session._curratedRunWindowClose();

    await _.time.out( context.deltaTime3 );

    test.identical( session.curratedRunState, 'terminated' );
    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, false );
    test.identical( session.curratedRunState, 'terminated' );

  }
  catch( err )
  {
    if( session )
    await session.unform();
  }

}

curatedRunWindowOpenCloseWindowManually.timeOut = 300000;

//

async function curatedRunWindowOpenClosePageManually( test )
{
  let context = this;
  let a = context.assetFor( test, 'minute' );
  let starter = new _.starter.System({ verbosity : test.suite.verbosity >= 7 ? 3 : 0 }).form();
  let session;

  try
  {

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, false );

    session = await starter.start
    ({
      entryPath : a.originalAbs( './F1.js' ),
      headless : 1,
      cleanupAfterStarterDeath : 0
    })

    test.identical( session.curratedRunState, 'launching' );

    await _.time.out( context.deltaTime2 ); /* xxx : remove later and find fix working for linux */

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, true );

    await _.time.out( context.deltaTime2 );

    test.identical( session.curratedRunState, 'launched' );

    await session._curratedRunPageEmptyOpen();
    await session._curratedRunPageClose();

    await _.time.out( context.deltaTime3 );

    test.identical( session.curratedRunState, 'terminated' );
    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, false );
    test.identical( session.curratedRunState, 'terminated' );

  }
  catch( err )
  {
    if( session )
    await session.unform();
  }

}

curatedRunWindowOpenClosePageManually.timeOut = 300000;

//

async function curatedRunEventsCloseAutomatic( test )
{
  let context = this;
  let a = context.assetFor( test, 'minute' );
  let system = new _.starter.System({ verbosity : test.suite.verbosity >= 7 ? 3 : 0 }).form();
  let encountered = Object.create( null );
  let session;

  try
  {

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, false );

    let opts =
    {
      system,
      entryPath : a.originalAbs( './F1.js' ),
      headless : 1,
      cleanupAfterStarterDeath : 0
    }
    session = new _.starter.session.BrowserCdp( opts );

    session.on( [ 'curatedRunLaunchBegin', 'curatedRunLaunchEnd', 'curatedRunTerminateEnd' ], ( e ) =>
    {
      encountered[ e.kind ] = encountered[ e.kind ] || 0;
      encountered[ e.kind ] += 1;
    });

    test.identical( session.curratedRunState, null );

    await session.form();

    test.identical( session.curratedRunState, 'launching' );
    await session.eventWaitFor( 'curatedRunLaunchEnd' );
    test.identical( session.curratedRunState, 'launched' );

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, true );
    test.identical( session.curratedRunState, 'launched' );

    await session.unform();

    test.identical( session.curratedRunState, 'terminated' );
    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, false );
    test.identical( session.curratedRunState, 'terminated' );

    var exp =
    {
      curatedRunLaunchBegin : 1,
      curatedRunLaunchEnd : 1,
      curatedRunTerminateEnd : 1,
    }
    test.identical( encountered, exp );

  }
  catch( err )
  {
    if( session )
    await session.unform();
  }

}

curatedRunEventsCloseAutomatic.timeOut = 300000;

//

async function curatedRunEventsCloseWindowManually( test )
{
  let context = this;
  let a = context.assetFor( test, 'minute' );
  let system = new _.starter.System({ verbosity : test.suite.verbosity >= 7 ? 3 : 0 }).form();
  let encountered = Object.create( null );
  let session;

  try
  {

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, false );

    let opts =
    {
      system,
      entryPath : a.originalAbs( './F1.js' ),
      headless : 1,
      cleanupAfterStarterDeath : 0
    }
    session = new _.starter.session.BrowserCdp( opts );

    session.on( [ 'curatedRunLaunchBegin', 'curatedRunLaunchEnd', 'curatedRunTerminateEnd' ], ( e ) =>
    {
      encountered[ e.kind ] = encountered[ e.kind ] || 0;
      encountered[ e.kind ] += 1;
    });

    test.identical( session.curratedRunState, null );

    await session.form();

    test.identical( session.curratedRunState, 'launching' );
    await session.eventWaitFor( 'curatedRunLaunchEnd' );
    test.identical( session.curratedRunState, 'launched' );

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, true );
    test.identical( session.curratedRunState, 'launched' );

    await session._curratedRunWindowClose();

    await session.eventWaitFor( 'curatedRunTerminateEnd' );

    test.identical( session.curratedRunState, 'terminated' );
    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, false );
    test.identical( session.curratedRunState, 'terminated' );

    var exp =
    {
      curatedRunLaunchBegin : 1,
      curatedRunLaunchEnd : 1,
      curatedRunTerminateEnd : 1,
    }
    test.identical( encountered, exp );

    await session.eventWaitFor( 'unformed' );

  }
  catch( err )
  {
    if( session )
    await session.unform();
  }

}

curatedRunEventsCloseWindowManually.timeOut = 300000;

//

async function curatedRunEventsClosePageManually( test )
{
  let context = this;
  let a = context.assetFor( test, 'minute' );
  let system = new _.starter.System({ verbosity : test.suite.verbosity >= 7 ? 3 : 0 }).form();
  let encountered = Object.create( null );
  let session;

  try
  {

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, false );

    let opts =
    {
      system,
      entryPath : a.originalAbs( './F1.js' ),
      headless : 1,
      cleanupAfterStarterDeath : 0
    }
    session = new _.starter.session.BrowserCdp( opts );

    session.on( [ 'curatedRunLaunchBegin', 'curatedRunLaunchEnd', 'curatedRunTerminateEnd' ], ( e ) =>
    {
      encountered[ e.kind ] = encountered[ e.kind ] || 0;
      encountered[ e.kind ] += 1;
    });

    test.identical( session.curratedRunState, null );

    await session.form();

    test.identical( session.curratedRunState, 'launching' );
    await session.eventWaitFor( 'curatedRunLaunchEnd' );
    test.identical( session.curratedRunState, 'launched' );

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, true );
    test.identical( session.curratedRunState, 'launched' );

    await session._curratedRunPageEmptyOpen();
    await session._curratedRunPageClose();

    /* event curatedRunTerminateEnd can come before return of _curratedRunPageClose! */
    await session.eventWaitFor( 'curatedRunTerminateEnd' );

    test.identical( session.curratedRunState, 'terminated' );
    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, false );
    test.identical( session.curratedRunState, 'terminated' );

    var exp =
    {
      curatedRunLaunchBegin : 1,
      curatedRunLaunchEnd : 1,
      curatedRunTerminateEnd : 1,
    }
    test.identical( encountered, exp );

    await session.eventWaitFor( 'unformed' );

  }
  catch( err )
  {
    if( session )
    await session.unform();
  }

}

curatedRunEventsClosePageManually.timeOut = 300000;

//

async function curatedRunRandomPort( test )
{
  let context = this;
  let a = context.assetFor( test, 'minute' );
  let starter = new _.starter.System({ verbosity : test.suite.verbosity >= 7 ? 3 : 0 }).form();
  let session;

  try
  {

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened();
    test.identical( !!cdp, false );

    // await _.time.out( context.deltaTime3 ); /* xxx : remove later and find fix working for linux */

    session = await starter.start
    ({
      entryPath : a.originalAbs( './F1.js' ),
      headless : 1,
      cleanupAfterStarterDeath : 0,
      sessionPort : 0,
      serverPath : 'http://127.0.0.1:0'
    })

    test.identical( session.curratedRunState, 'launching' );

    await _.time.out( context.deltaTime2 ); /* xxx : remove later and find fix working for linux */

    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened( session );
    test.identical( !!cdp, true );

    await _.time.out( context.deltaTime2 );

    test.identical( session.curratedRunState, 'launched' );

    test.notIdentical( session.sessionPort, 0 );
    let servletPathParsed = _.servlet.serverPathParse({ full : session.servlet.serverPath });
    test.notIdentical( servletPathParsed.port, 0 );
    test.identical( session.servlet.httpServer.address().port, servletPathParsed.port );

    await session.unform();

    test.identical( session.curratedRunState, 'terminated' );
    var cdp = await _.starter.session.BrowserCdp._CurratedRunWindowIsOpened( session );
    test.identical( !!cdp, false );
    test.identical( session.curratedRunState, 'terminated' );

  }
  catch( err )
  {
    if( session )
    await session.unform();
  }

}

curatedRunRandomPort.timeOut = 300000;

//

function browserUserTempDirCleanup( test )
{
  let context = this;
  let a = context.assetFor( test, 'minute' );

  a.reflect();

  let locals =
  {
    toolsPath : _.module.resolve( 'wTools' ),
    starterPath : a.path.nativize( a.path.join( __dirname, '../starter/entry/Include.s' ) ),
    context : { deltaTime3 : context.deltaTime3 },
    opts :
    {
      entryPath : a.abs( './F1.js' ),
      basePath : a.abs( '.'),
      headless : 1
    }
  }

  let execPath = a.program({ entry : program, locals }).filePath/*programPath*/;

  let op = { execPath };
  let ready = _.Consequence();
  let ready2 = _.Consequence();
  let tempDirPath, secondaryProcessPid;

  a.fork( op );

  op.pnd.on( 'message', ( data ) =>
  {
    if( data.field === 'tempDirPath' )
    ready.take( data.val )
    if( data.field === 'secondaryProcessPid' )
    ready2.take( data.val )
  });

  ready.then( ( got ) =>
  {
    tempDirPath = got;
    test.true( a.fileProvider.fileExists( tempDirPath ) );
    return null;
  })

  ready2.then( ( got ) =>
  {
    secondaryProcessPid = got;
    test.true( _.process.isAlive( secondaryProcessPid ) );
    return null;
  })

  op.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    return _.time.out( context.deltaTime2 * 2 ) /* 6000 */
    .then( () =>
    {
      test.true( !a.fileProvider.fileExists( tempDirPath ) );
      test.true( !_.process.isAlive( secondaryProcessPid ) );
      return null;
    })
  })

  return _.Consequence.And( op.ready, ready, ready2 );

  /* */

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wStarter')

    let starter = new _.starter.System({ verbosity : 7 }).form();
    let session;

    main();

    async function main()
    {
      try
      {
        session = await starter.start( opts );
        process.send({ field : 'tempDirPath', val : session._tempDir });
        await _.time.out( context.deltaTime3 );
        await session.unform();
        process.send({ field : 'secondaryProcessPid', val : session._tempDirCleanProcess.pnd.pid });
      }
      catch( err )
      {
        if( session )
        await session.unform();
        throw _.err( err );
      }
    }
  }


}

//

async function servletRemoteResolve( test )
{
  let context = this;
  let a = context.assetFor( test, 'servlet' );

  a.reflect();

  let system = new _.starter.System({ verbosity : 7 }).form();

  let servlet = new _.starter.Servlet({ basePath : a.routinePath, allowedPath : { '/' : true }, system });
  await servlet.form();

  let Needle = require( 'needle' );

  test.case = 'glob for existing file'
  var response = await Needle( 'get', servlet.serverPath + '/.resolve/./*.js', { json : 1 });
  test.identical( response.body, [ '/F1.js' ] );

  test.case = 'glob for not existing file'
  var response = await Needle( 'get', servlet.serverPath + '/.resolve/./*.txt', { json : 1 });
  test.identical( response.body, [] );

  test.case = 'module'
  var response = await Needle( 'get', servlet.serverPath + '/.resolve/wTools', { json : 1 });
  test.true( _.strEnds( response.body, 'node_modules/Tools' ) );

  test.case = 'fail'
  var response = await Needle( 'get', servlet.serverPath + '/.resolve/unknown', { json : 1 });
  test.true( _.strIs( response.body.err ) );

  test.case = 'resolvingNpm disabled'
  servlet.resolvingNpm = false;
  var response = await Needle( 'get', servlet.serverPath + '/.resolve/wTools', { json : 1 });
  test.true( _.strIs( response.body.err ) );
  servlet.resolvingNpm = true;

  test.case = 'resolvingGlob disabled'
  servlet.resolvingGlob = false;
  var response = await Needle( 'get', servlet.serverPath + '/.resolve/./*.js', { json : 1 });
  test.true( _.strIs( response.body.err ) );
  servlet.resolvingGlob = true;

  return servlet.finit();
}

//

async function servletRemoteStat( test )
{
  let context = this;
  let a = context.assetFor( test, 'servlet' );

  a.reflect();

  let system = new _.starter.System({ verbosity : 7 }).form();

  let servlet = new _.starter.Servlet({ basePath : a.routinePath, allowedPath : { '/' : true }, system });
  await servlet.form();

  let Needle = require( 'needle' );

  test.case = 'absolute exists'
  var response = await Needle( 'get', servlet.serverPath + '/F1.js?stat=1', { json : 1 });
  test.identical( response.body, { exists : true } );

  test.case = 'absolute missing'
  var response = await Needle( 'get', servlet.serverPath + '/F2.js?stat=1', { json : 1 });
  test.identical( response.body, { exists : false } );

  test.case = 'relative'
  var dirName = a.fileProvider.path.name( a.routinePath )
  var response = await Needle( 'get', servlet.serverPath + `/../${dirName}/F1.js?stat=1`, { json : 1 });
  test.identical( response.body, { exists : true } );

  test.case = 'relative missing'
  var dirName = a.fileProvider.path.name( a.routinePath )
  var response = await Needle( 'get', servlet.serverPath + `/../${dirName}/F2.js?stat=1`, { json : 1 });
  test.identical( response.body, { exists : false } );

  return servlet.finit();

}

// --
// declare
// --

const Proto =
{

  name : 'Tools.Starter.Int',
  silencing : 1,
  enabled : 1,
  routineTimeOut : 60000,
  onSuiteBegin,
  onSuiteEnd,

  context :
  {

    assetFor,

    suiteTempPath : null,
    assetsOriginalPath : null,
    appJsPath : null,
    willbeExecPath : null,
    find : null,

    deltaTime1 : 250,
    deltaTime2 : 3000,
    deltaTime3 : 15000,

  },

  tests :
  {

    // sourcesJoinFiles

    sourcesJoinWithExternalBeforePath,
    sourcesJoinFiles,
    sourcesJoinFilesWithModule,
    sourcesJoinFilesCheckRoutines,
    singleFileServerLessBuild,

    // html for

    htmlForFilesBasic,
    htmlForFilesOptionTitle,
    htmlForFilesOptionWithStarter,

    // include

    includeCss,
    includeExcludingManual,
    includeModule,

    // worker

    workerWithInclude,
    includeModuleInWorker,
    includeModuleInWorkerThrowing,

    // curated run

    curatedRunWindowOpenCloseAutomatic,
    curatedRunWindowOpenCloseWindowManually,
    curatedRunWindowOpenClosePageManually,

    curatedRunEventsCloseAutomatic,
    curatedRunEventsCloseWindowManually,
    curatedRunEventsClosePageManually,

    // port

    curatedRunRandomPort,

    // etc

    browserUserTempDirCleanup,

    //servlet

    servletRemoteResolve,
    servletRemoteStat

  }

}

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
