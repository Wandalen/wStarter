( function _Ext_test_s_()
{

'use strict';

let Jsdom;

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
  context.appJsPath = _.path.join( __dirname, '../starter/entry/Exec' );

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

  //qqq Vova: probably we should add path resolving into starter
  a.routinePath = _.fileProvider.pathResolveLinkFull( a.routinePath ).filePath;

  a.absNative = function()
  {
    let result = a.abs.apply( a, arguments );
    return _.path.nativize( result )
  }

  return a;
}

// --
// sourcesJoin
// --

function sourcesJoin( test )
{
  let context = this;
  let a = context.assetFor( test, 'several' );
  let outputPath = a.abs( 'Index.js' );

  a.reflect();

  a.appStart( `.sources.join ${a.routinePath}/** entryPath:File2.js` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoin\/Index\.js/ ), 1 )

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './File1.js', './File2.js', './Index.js' ] );

    let read = _.fileProvider.fileRead( outputPath );
    test.identical( _.strCount( read, 'setTimeout( f, 1000 );' ), 2 );

    return op;
  })

  a.fork( _.path.nativize( outputPath ) )
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

  return a.ready;
}

//

function sourcesJoinWithEntry( test )
{
  let context = this;
  let a = context.assetFor( test, 'dep' );
  let outputPath = a.abs( 'out/app0.js' );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'default';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.sources.join app0/** entryPath:app0/File2.js outPath:out/app0.js` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinWithEntry\/out\/app0\.js/ ), 1 );

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './app0', './app0/File1.js', './app0/File2.js', './app2', './app2/File1.js', './app2/File2.js', './ext', './ext/RequireApp2File2.js', './out', './out/app0.js' ] );

    let read = _.fileProvider.fileRead( outputPath );
    test.identical( _.strCount( read, 'setTimeout( f, 1000 );' ), 2 );

    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'base path : .';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.sources.join app0/** entryPath:app0/File2.js outPath:out/app0.js basePath:.` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinWithEntry\/out\/app0\.js/ ), 1 );

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './app0', './app0/File1.js', './app0/File2.js', './app2', './app2/File1.js', './app2/File2.js', './ext', './ext/RequireApp2File2.js', './out', './out/app0.js' ] );

    let read = _.fileProvider.fileRead( outputPath );
    test.identical( _.strCount( read, 'setTimeout( f, 1000 );' ), 2 );

    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'base path : app0';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.sources.join ** entryPath:File2.js outPath:../out/app0.js basePath:app0` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinWithEntry\/out\/app0\.js/ ), 1 );

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './app0', './app0/File1.js', './app0/File2.js', './app2', './app2/File1.js', './app2/File2.js', './ext', './ext/RequireApp2File2.js', './out', './out/app0.js' ] );

    let read = _.fileProvider.fileRead( outputPath );
    test.identical( _.strCount( read, 'setTimeout( f, 1000 );' ), 2 );

    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'bad entry';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStartNonThrowing( `.sources.join app0/** entryPath:File2.js outPath:out/app0.js` )
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'List of source files should have all entry files' ), 1 );

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './app0', './app0/File1.js', './app0/File2.js', './app2', './app2/File1.js', './app2/File2.js', './ext', './ext/RequireApp2File2.js' ] );

    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'bad entry, base path defined';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStartNonThrowing( `.sources.join ** entryPath:app0/File2.js outPath:../out/app0.js basePath:app0` )
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'List of source files should have all entry files' ), 1 );

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './app0', './app0/File1.js', './app0/File2.js', './app2', './app2/File1.js', './app2/File2.js', './ext', './ext/RequireApp2File2.js' ] );

    return op;
  })

  /* */

  return a.ready;
}

//

function sourcesJoinDep( test )
{
  let context = this;
  let a = context.assetFor( test, 'dep' );
  var output =
`
app0/File2.js:begin main:true
app2/File2.js:begin main:false
app0/File1.js:begin main:false
numberIs:true
app0/File1.js:end
app2/File2.js:end
app0/File2.js:end
app0/File1.js:timeout numberIs:true
app0/File1.js:timeout numberIs:true
app0/File1.js:timeout numberIs:true
`;

  /* */

  a.ready.then( () =>
  {
    test.case = 'default';
    a.reflect();
    return null;
  })

  a.shell( `npm i` );
  a.appStart( `.sources.join ** basePath:app2 outPath:../out/app2` );
  a.appStart( `.sources.join ** basePath:app0 outPath:../out/app0 entryPath:File2.js externalBeforePath:../out/app2` );
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinDep\/out\/app0/ ), 1 );

    var files = a.find( a.routinePath );
    var exp =
    [
      '.',
      './app0',
      './app0/File1.js',
      './app0/File2.js',
      './app2',
      './app2/File1.js',
      './app2/File2.js',
      './ext',
      './ext/RequireApp2File2.js',
      './out',
      './out/app0',
      './out/app2'
    ];
    test.identical( files, exp );

    return op;
  })

  a.fork( `out/app0` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `app0/File2.js` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
}

//

function sourcesJoinRequireInternal( test )
{
  let context = this;
  let a = context.assetFor( test, 'dep' );
  var output =
`
app2/File2.js:begin main:false
app0/File1.js:begin main:false
numberIs:true
app0/File1.js:end
app2/File2.js:end
app0/File1.js:timeout numberIs:true
app0/File1.js:timeout numberIs:true
`

  /* */

  a.ready.then( () =>
  {
    test.case = 'default';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.shell( `npm i` )
  a.appStart( `.sources.join ** basePath:app0 outPath:../out/dir/app0` )
  a.appStart( `.sources.join ** basePath:app2 outPath:../out/dir/app2` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinRequireInternal\/out\/dir\/app2/ ), 1 );

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './app0', './app0/File1.js', './app0/File2.js', './app2', './app2/File1.js', './app2/File2.js', './ext', './ext/RequireApp2File2.js', './out', './out/dir', './out/dir/app0', './out/dir/app2' ] );

    return op;
  })

  a.fork( `ext/RequireApp2File2.js` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
}

//

function sourcesJoinComplex( test )
{
  let context = this;
  let a = context.assetFor( test, 'complex' );

  var output =
`
app0/File2.js:begin
app2/File2.js:begin
app0/File1.js:begin
numberIs true
app0/File1.js:end
app1/File2.js:begin
app1/File1.js:begin
app1/File1.js:end
app1/File2.js:end
app2/File2.js:end
app0/File2.js:end
app0/File1.js:timeout true
app1/File1.js:timeout
app1/File2.js:timeout
app1/File2.js:timeout
app0/File1.js:timeout true
app0/File1.js:timeout true
`

  /* */

  a.ready.then( () =>
  {
    test.case = 'default';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect()
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.shell( `npm i` )
  a.appStart( `.sources.join ** basePath:app2 outPath:../out/app2` )
  a.appStart( `.sources.join ** basePath:app1 outPath:../out/app1` )
  a.appStart
  ({
    execPath : `.sources.join **`,
    args :
    [
      `basePath:app0`,
      `outPath:../out/app0`,
      `entryPath:File2.js`,
      `externalBeforePath:[../out/app1,../out/app2]`
    ]
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinComplex\/out\/app0/ ), 1 );

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './app0', './app0/File1.js', './app0/File2.js', './app1', './app1/File1.js', './app1/File2.js', './app2', './app2/File1.js', './app2/File2.js', './out', './out/app0', './out/app1', './out/app2' ] );

    return op;
  })

  a.fork( `out/app0` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `app0/File2.js` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );

    return op;
  })

  /* */

  return a.ready;
}

//

function sourcesJoinTree( test )
{
  let context = this;
  let a = context.assetFor( test, 'tree' );
  let outPath = a.abs( 'out' );

  /* */

  a.ready.then( () =>
  {
    test.case = 'app1, entry:File1';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.sources.join ** basePath:in/app1 outPath:../../out/app1 entryPath:dir1/File1.js` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinTree\/out\/app1/ ), 1 );

    var expected = [ '.', './app1' ];
    var files = a.find( outPath );
    test.identical( files, expected );

    return op;
  })

  a.fork( `in/app1/dir1/File1.js` )
  .then( ( op ) =>
  {
    var output =
`
app1/File1.js:begin main:true
External1.js main:false
app1/File1.js:end main:true
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `out/app1` )
  .then( ( op ) =>
  {
    var output =
`
app1/File1.js:begin main:true
External1.js main:false
app1/File1.js:end main:true
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'app1, entry:File2';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.sources.join ** basePath:in/app1 outPath:../../out/app1 entryPath:dir1/dir2/File2.js` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinTree\/out\/app1/ ), 1 );

    var expected = [ '.', './app1' ];
    var files = a.find( outPath );
    test.identical( files, expected );

    return op;
  })

  a.fork( `in/app1/dir1/dir2/File2.js` )
  .then( ( op ) =>
  {
    var output =
`
app1/File2.js:begin main:true
External2.js main:false
app1/File2.js:end main:true
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `out/app1` )
  .then( ( op ) =>
  {
    var output =
`
app1/File2.js:begin main:true
External2.js main:false
app1/File2.js:end main:true
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'app2';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.sources.join ** basePath:in/app1 outPath:../../out/app1` )
  a.appStart( `.sources.join ** basePath:in/app2 outPath:../../out/app2 entryPath:File2.js externalBeforePath:../../out/app1` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinTree\/out\/app2/ ), 1 );

    var expected = [ '.', './app1', './app2' ];
    var files = a.find( outPath );
    test.identical( files, expected );

    return op;
  })

  a.fork( `in/app2/File2.js` )
  .then( ( op ) =>
  {
    var output =
`
app0/File2.js:begin main:true
app2/File1.js:begin main:false
app1/File2.js:begin main:false
External2.js main:false
app1/File2.js:end main:false
app2/File1.js:end main:false
app0/File2.js:end main:true
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `out/app2` )
  .then( ( op ) =>
  {
    var output =
`
app0/File2.js:begin main:true
app2/File1.js:begin main:false
app1/File2.js:begin main:false
External2.js main:false
app1/File2.js:end main:false
app2/File1.js:end main:false
app0/File2.js:end main:true
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
} /* end of sourcesJoinTree */

//

function sourcesJoinCycle( test )
{
  let context = this;
  let a = context.assetFor( test, 'cycle' );
  let outPath = a.abs( 'out' );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'app1, entry:File1';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.sources.join in/app1/** outPath:out/app1 entryPath:in/app1/File1.js` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinCycle\/out\/app1/ ), 1 );

    var expected = [ '.', './app1' ];
    var files = a.find( outPath );
    test.identical( files, expected );

    return op;
  })

  a.fork( `in/app1/File1.js` )
  .then( ( op ) =>
  {
    var output =
`
app1/File1.js:begin main:true
app1/File2.js:begin main:false
app1/File2.js:end main:false
app1/File1.js:end main:true
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `out/app1` )
  .then( ( op ) =>
  {
    var output =
`
app1/File1.js:begin main:true
app1/File2.js:begin main:false
app1/File2.js:end main:false
app1/File1.js:end main:true
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'app1, entry:File2';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.sources.join in/app1/** outPath:out/app1 entryPath:in/app1/File2.js` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinCycle\/out\/app1/ ), 1 );

    var expected = [ '.', './app1' ];
    var files = a.find( outPath );
    test.identical( files, expected );

    return op;
  })

  a.fork( `in/app1/File2.js` )
  .then( ( op ) =>
  {
    var output =
`
app1/File2.js:begin main:true
app1/File1.js:begin main:false
app1/File1.js:end main:false
app1/File2.js:end main:true
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `out/app1` )
  .then( ( op ) =>
  {
    var output =
`
app1/File2.js:begin main:true
app1/File1.js:begin main:false
app1/File1.js:end main:false
app1/File2.js:end main:true
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'cycled-external';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.sources.join in/app1/** outPath:out/app1 entryPath:in/app1/File2.js externalBeforePath:out/app2` )
  a.appStart( `.sources.join in/app2/** outPath:out/app2 entryPath:in/app2/File2.js externalBeforePath:out/app1` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var expected = [ '.', './app1', './app2' ];
    var files = a.find( outPath );
    test.identical( files, expected );

    return op;
  })

  a.fork( `out/app1` )
  .then( ( op ) =>
  {
    var output =
`
app2/File2.js:begin main:true
app2/File1.js:begin main:false
app2/File1.js:end main:false
app2/File2.js:end main:true
app1/File2.js:begin main:true
app1/File1.js:begin main:false
app1/File1.js:end main:false
app1/File2.js:end main:true
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `out/app2` )
  .then( ( op ) =>
  {
    var output =
`
app1/File2.js:begin main:true
app1/File1.js:begin main:false
app1/File1.js:end main:false
app1/File2.js:end main:true
app2/File2.js:begin main:true
app2/File1.js:begin main:false
app2/File1.js:end main:false
app2/File2.js:end main:true
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
} /* end of sourcesJoinCycle */

//

function sourcesJoinRecursion( test )
{
  let context = this;
  let a = context.assetFor( test, 'recursion' );
  let outPath = a.abs( 'out' );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'basic';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.sources.join ** outPath:out/Out.js entryPath:F1.js` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', './F1.js', './F2.js', './out', './out/Out.js' ];
    var files = a.find( a.abs( '.' ) );
    test.identical( files, expected );

    return op;
  })

  a.fork( `out/Out.js` )
  .then( ( op ) =>
  {
    test.description = 'out/Out.js';
    var output =
`
F1:before
F2:before
F2:object
F2:after
F1:string
F1:after
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `F1.js` )
  .then( ( op ) =>
  {
    test.description = 'F1.js';
    var output =
`
F1:before
F2:before
F2:object
F2:after
F1:string
F1:after
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
} /* end of sourcesJoinRecursion */

//

function sourcesJoinOptionInterpreter( test )
{
  let context = this;
  let a = context.assetFor( test, 'depLocal' );
  let outPath = a.abs( 'out' );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'without starter';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.fork( `in/Index.js` )
  .then( ( op ) =>
  {
    test.description = 'in/Index.js';
    var output =
`
Index.js:begin
Dep1.js:begin

Dep1.js
__filename : ${a.absNative( 'in/Dep1.js' )}
__dirname : ${a.absNative( 'in' )}
module : object
module.parent : object
exports : object
require : function
Dep1.js:end

Index.js
__filename : ${a.absNative( 'in/Index.js' )}
__dirname : ${a.absNative( 'in' )}
module : object
module.parent : object
exports : object
require : function

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:njs, run without starter';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.sources.join in/** outPath:out/Out.js entryPath:in/Index.js interpreter:njs` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', './in', './in/Dep1.js', './in/Index.js', './out', './out/Out.js' ];
    var files = a.find( a.abs( '.' ) );
    test.identical( files, expected );

    return op;
  })

  a.fork( `out/Out.js` )
  .then( ( op ) =>
  {
    test.description = 'out/Out.js';
    var output =
`
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : ${a.abs( 'out/Out.js/in/Dep1.js' )}
_dirPath_ : ${a.abs( 'out/Out.js/in' )}
__filename : ${a.abs( 'out/Out.js/in/Dep1.js' )}
__dirname : ${a.abs( 'out/Out.js/in' )}
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : njs

Dep1.js:end

Index.js
_filePath_ : ${a.abs( 'out/Out.js/in/Index.js' )}
_dirPath_ : ${a.abs( 'out/Out.js/in' )}
__filename : ${a.abs( 'out/Out.js/in/Index.js' )}
__dirname : ${a.abs( 'out/Out.js/in' )}
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : njs

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  // xxx : add case of running built version with starter interpreter:njs

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:browser naking:0 withStarter:1';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.sources.join in/** outPath:out/Out.js entryPath:in/Index.js interpreter:browser` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', './in', './in/Dep1.js', './in/Index.js', './out', './out/Out.js' ];
    var files = a.find( a.abs( '.' ) );
    test.identical( files, expected );

    return op;
  })

  a.appStart( `.start out/Out.js timeOut:15000 headless:1 naking:0 withStarter:1` )
  .then( ( op ) =>
  {
    test.description = '.start default';
    var output =
`
Command ".start out/Out.js timeOut:15000 headless:1 naking:0 withStarter:1"
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : /in/Dep1.js
_dirPath_ : /in
__filename : /in/Dep1.js
__dirname : /in
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep1.js:end

Index.js
_filePath_ : /in/Index.js
_dirPath_ : /in
__filename : /in/Index.js
__dirname : /in
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:browser naking:1 withStarter:0';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.sources.join in/** outPath:out/Out.js entryPath:in/Index.js interpreter:browser` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', './in', './in/Dep1.js', './in/Index.js', './out', './out/Out.js' ];
    var files = a.find( a.abs( '.' ) );
    test.identical( files, expected );

    return op;
  })

  a.appStart( `.start out/Out.js naking:1 withStarter:0 timeOut:15000 headless:1` )
  .then( ( op ) =>
  {
    test.description = '.start naking:1 withStarter:0';
    var output =
`
Command ".start out/Out.js naking:1 withStarter:0 timeOut:15000 headless:1"
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : /in/Dep1.js
_dirPath_ : /in
__filename : /in/Dep1.js
__dirname : /in
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep1.js:end

Index.js
_filePath_ : /in/Index.js
_dirPath_ : /in
__filename : /in/Index.js
__dirname : /in
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
} /* end of sourcesJoinOptionInterpreter */

sourcesJoinOptionInterpreter.timeOut = 120000;
sourcesJoinOptionInterpreter.description =
`
- joining sources with option intepreter:browser works like interpreter:njs
`

//

function sourcesJoinOptionInterpreterOptionBasePath( test )
{
  let context = this;
  let a = context.assetFor( test, 'depLocalSubdir' );
  let outPath = a.abs( 'out' );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:njs basePath:default inPath:subject';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out1' );
    return null;
  })

  a.appStart( `.sources.join in/** outPath:out1/out2/Out.js entryPath:in/Index.js interpreter:njs` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', './in', './in/Index.js', './in/dir', './in/dir/Dep1.js', './out1', './out1/out2', './out1/out2/Out.js' ];
    var files = a.find( a.abs( '.' ) );
    test.identical( files, expected );

    return op;
  })

  a.fork( `out1/out2/Out.js` )
  .then( ( op ) =>
  {
    test.description = 'out1/out2/Out.js';
    var output =
`
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : ${a.abs( 'out1/out2/Out.js/in/dir/Dep1.js' )}
_dirPath_ : ${a.abs( 'out1/out2/Out.js/in/dir' )}
__filename : ${a.abs( 'out1/out2/Out.js/in/dir/Dep1.js' )}
__dirname : ${a.abs( 'out1/out2/Out.js/in/dir' )}
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : njs

Dep1.js:end

Index.js
_filePath_ : ${a.abs( 'out1/out2/Out.js/in/Index.js' )}
_dirPath_ : ${a.abs( 'out1/out2/Out.js/in' )}
__filename : ${a.abs( 'out1/out2/Out.js/in/Index.js' )}
__dirname : ${a.abs( 'out1/out2/Out.js/in' )}
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : njs

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `in/Index.js` )
  .then( ( op ) =>
  {
    test.description = 'in/Index.js';
    var output =
`
Index.js:begin
Dep1.js:begin

Dep1.js
__filename : ${a.absNative( 'in/dir/Dep1.js' )}
__dirname : ${a.absNative( 'in/dir' )}
module : object
module.parent : object
exports : object
require : function

Dep1.js:end

Index.js
__filename : ${a.absNative( 'in/Index.js' )}
__dirname : ${a.absNative( 'in' )}
module : object
module.parent : object
exports : object
require : function

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:njs basePath:. inPath:subject';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out1' );
    return null;
  })

  a.appStart( `.sources.join in/** basePath:. outPath:out1/out2/Out.js entryPath:in/Index.js interpreter:njs` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', './in', './in/Index.js', './in/dir', './in/dir/Dep1.js', './out1', './out1/out2', './out1/out2/Out.js' ];
    var files = a.find( a.abs( '.' ) );
    test.identical( files, expected );

    return op;
  })

  a.fork( `out1/out2/Out.js` )
  .then( ( op ) =>
  {
    test.description = 'out1/out2/Out.js';
    var output =
`
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : ${a.abs( 'out1/out2/Out.js/in/dir/Dep1.js' )}
_dirPath_ : ${a.abs( 'out1/out2/Out.js/in/dir' )}
__filename : ${a.abs( 'out1/out2/Out.js/in/dir/Dep1.js' )}
__dirname : ${a.abs( 'out1/out2/Out.js/in/dir' )}
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : njs

Dep1.js:end

Index.js
_filePath_ : ${a.abs( 'out1/out2/Out.js/in/Index.js' )}
_dirPath_ : ${a.abs( 'out1/out2/Out.js/in' )}
__filename : ${a.abs( 'out1/out2/Out.js/in/Index.js' )}
__dirname : ${a.abs( 'out1/out2/Out.js/in' )}
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : njs

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `in/Index.js` )
  .then( ( op ) =>
  {
    test.description = 'in/Index.js';
    var output =
`
Index.js:begin
Dep1.js:begin

Dep1.js
__filename : ${a.absNative( 'in/dir/Dep1.js' )}
__dirname : ${a.absNative( 'in/dir' )}
module : object
module.parent : object
exports : object
require : function

Dep1.js:end

Index.js
__filename : ${a.absNative( 'in/Index.js' )}
__dirname : ${a.absNative( 'in' )}
module : object
module.parent : object
exports : object
require : function

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:njs basePath:. inPath:in/**';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out1' );
    return null;
  })

  a.appStart( `.sources.join inPath:in/** basePath:. outPath:out1/out2/Out.js entryPath:in/Index.js interpreter:njs` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', './in', './in/Index.js', './in/dir', './in/dir/Dep1.js', './out1', './out1/out2', './out1/out2/Out.js' ];
    var files = a.find( a.abs( '.' ) );
    test.identical( files, expected );

    return op;
  })

  a.fork( `out1/out2/Out.js` )
  .then( ( op ) =>
  {
    test.description = 'out1/out2/Out.js';
    var output =
`
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : ${a.routinePath}/out1/out2/Out.js/in/dir/Dep1.js
_dirPath_ : ${a.routinePath}/out1/out2/Out.js/in/dir
__filename : ${a.routinePath}/out1/out2/Out.js/in/dir/Dep1.js
__dirname : ${a.routinePath}/out1/out2/Out.js/in/dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : njs

Dep1.js:end

Index.js
_filePath_ : ${a.routinePath}/out1/out2/Out.js/in/Index.js
_dirPath_ : ${a.routinePath}/out1/out2/Out.js/in
__filename : ${a.routinePath}/out1/out2/Out.js/in/Index.js
__dirname : ${a.routinePath}/out1/out2/Out.js/in
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : njs

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `in/Index.js` )
  .then( ( op ) =>
  {
    test.description = 'in/Index.js';
    var output =
`
Index.js:begin
Dep1.js:begin

Dep1.js
__filename : ${a.absNative( 'in/dir/Dep1.js' )}
__dirname : ${a.absNative( 'in/dir' )}
module : object
module.parent : object
exports : object
require : function

Dep1.js:end

Index.js
__filename : ${a.absNative( 'in/Index.js' )}
__dirname : ${a.absNative( 'in' )}
module : object
module.parent : object
exports : object
require : function

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:njs basePath:in inPath:**';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out1' );
    return null;
  })

  a.appStart( `.sources.join inPath:** basePath:in outPath:../out1/out2/Out.js entryPath:Index.js interpreter:njs` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', './in', './in/Index.js', './in/dir', './in/dir/Dep1.js', './out1', './out1/out2', './out1/out2/Out.js' ];
    var files = a.find( a.abs( '.' ) );
    test.identical( files, expected );

    return op;
  })

  a.fork( `out1/out2/Out.js` )
  .then( ( op ) =>
  {
    test.description = 'out1/out2/Out.js';
    var output =
`
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : ${a.routinePath}/out1/out2/Out.js/dir/Dep1.js
_dirPath_ : ${a.routinePath}/out1/out2/Out.js/dir
__filename : ${a.routinePath}/out1/out2/Out.js/dir/Dep1.js
__dirname : ${a.routinePath}/out1/out2/Out.js/dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : njs

Dep1.js:end

Index.js
_filePath_ : ${a.routinePath}/out1/out2/Out.js/Index.js
_dirPath_ : ${a.routinePath}/out1/out2/Out.js
__filename : ${a.routinePath}/out1/out2/Out.js/Index.js
__dirname : ${a.routinePath}/out1/out2/Out.js
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : njs

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `in/Index.js` )
  .then( ( op ) =>
  {
    test.description = 'in/Index.js';
    var output =
`
Index.js:begin
Dep1.js:begin

Dep1.js
__filename : ${a.absNative( 'in/dir/Dep1.js' )}
__dirname : ${a.absNative( 'in/dir' )}
module : object
module.parent : object
exports : object
require : function

Dep1.js:end

Index.js
__filename : ${a.absNative( 'in/Index.js' )}
__dirname : ${a.absNative( 'in' )}
module : object
module.parent : object
exports : object
require : function

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* - */

  a.ready.then( () =>
  {
    test.case = 'interpreter:browser basePath:default inPath:subject';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out1' );
    return null;
  })

  a.appStart( `.sources.join in/** outPath:out1/out2/Out.js entryPath:in/Index.js interpreter:browser` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', './in', './in/Index.js', './in/dir', './in/dir/Dep1.js', './out1', './out1/out2', './out1/out2/Out.js' ];
    var files = a.find( a.abs( '.' ) );
    test.identical( files, expected );

    return op;
  })

  a.appStart( `.start out1/out2/Out.js naking:1 withStarter:0 timeOut:15000 headless:1` )
  .then( ( op ) =>
  {
    test.description = '.start naking:1 withStarter:0';
    var output =
`
Command ".start out1/out2/Out.js naking:1 withStarter:0 timeOut:15000 headless:1"
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : /in/dir/Dep1.js
_dirPath_ : /in/dir
__filename : /in/dir/Dep1.js
__dirname : /in/dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep1.js:end

Index.js
_filePath_ : /in/Index.js
_dirPath_ : /in
__filename : /in/Index.js
__dirname : /in
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:browser basePath:.';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out1' );
    return null;
  })

  a.appStart( `.sources.join in/** basePath:. outPath:out1/out2/Out.js entryPath:in/Index.js interpreter:browser` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', './in', './in/Index.js', './in/dir', './in/dir/Dep1.js', './out1', './out1/out2', './out1/out2/Out.js' ];
    var files = a.find( a.abs( '.' ) );
    test.identical( files, expected );

    return op;
  })

  a.appStart( `.start out1/out2/Out.js naking:1 withStarter:0 timeOut:15000 headless:1` )
  .then( ( op ) =>
  {
    test.description = '.start naking:1 withStarter:0';
    var output =
`
Command ".start out1/out2/Out.js naking:1 withStarter:0 timeOut:15000 headless:1"
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : /in/dir/Dep1.js
_dirPath_ : /in/dir
__filename : /in/dir/Dep1.js
__dirname : /in/dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep1.js:end

Index.js
_filePath_ : /in/Index.js
_dirPath_ : /in
__filename : /in/Index.js
__dirname : /in
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:browser basePath:. inPath:in/**';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out1' );
    return null;
  })

  a.appStart( `.sources.join inPath:in/** basePath:. outPath:out1/out2/Out.js entryPath:in/Index.js interpreter:browser` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', './in', './in/Index.js', './in/dir', './in/dir/Dep1.js', './out1', './out1/out2', './out1/out2/Out.js' ];
    var files = a.find( a.abs( '.' ) );
    test.identical( files, expected );

    return op;
  })

  a.appStart( `.start out1/out2/Out.js naking:1 withStarter:0 timeOut:15000 headless:1` )
  .then( ( op ) =>
  {
    test.description = '.start naking:1 withStarter:0';
    var output =
`
Command ".start out1/out2/Out.js naking:1 withStarter:0 timeOut:15000 headless:1"
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : /in/dir/Dep1.js
_dirPath_ : /in/dir
__filename : /in/dir/Dep1.js
__dirname : /in/dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep1.js:end

Index.js
_filePath_ : /in/Index.js
_dirPath_ : /in
__filename : /in/Index.js
__dirname : /in
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:browser basePath:in inPath:**';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out1' );
    return null;
  })

  a.appStart( `.sources.join inPath:** basePath:in outPath:../out1/out2/Out.js entryPath:Index.js interpreter:browser` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', './in', './in/Index.js', './in/dir', './in/dir/Dep1.js', './out1', './out1/out2', './out1/out2/Out.js' ];
    var files = a.find( a.abs( '.' ) );
    test.identical( files, expected );

    return op;
  })

  a.appStart( `.start out1/out2/Out.js naking:1 withStarter:0 timeOut:15000 headless:1` )
  .then( ( op ) =>
  {
    test.description = '.start naking:1 withStarter:0';
    var output =
`
Command ".start out1/out2/Out.js naking:1 withStarter:0 timeOut:15000 headless:1"
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : /dir/Dep1.js
_dirPath_ : /dir
__filename : /dir/Dep1.js
__dirname : /dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep1.js:end

Index.js
_filePath_ : /Index.js
_dirPath_ : /
__filename : /Index.js
__dirname : /
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* - */

  return a.ready;
} /* end of sourcesJoinOptionInterpreterOptionBasePath */

sourcesJoinOptionInterpreterOptionBasePath.description =
`
- joining sources with option intepreter:browser works like interpreter:njs
`

sourcesJoinOptionInterpreterOptionBasePath.timeOut = 300000;

//

function sourcesJoinBrowserOptionRedirectingConsole( test )
{
  let context = this;
  let a = context.assetFor( test, 'consoleRedirecting' );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:browser';
    a.fileProvider.filesDelete( a.abs( '.' ) );
    a.reflect();
    return null;
  })

  a.appStart( `.sources.join inPath:**/*.(js|s) outPath:Out.js entryPath:Index.js interpreter:browser redirectingConsole:1` )
  a.appStart( `.start Out.js naking:1 withStarter:0 timeOut:15000 headless:1` )
  .then( ( op ) =>
  {
    test.description = 'out/Out.js';
    var output = 'Message to redirect'

    test.identical( op.exitCode, 0 );
    test.true( _.strHas( op.output, output ) );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:browser';
    a.fileProvider.filesDelete( a.abs( '.' ) );
    a.reflect();
    return null;
  })

  a.appStart( `.sources.join inPath:**/*.(js|s) outPath:Out.js entryPath:Index.js interpreter:browser redirectingConsole:0` )
  a.appStart( `.start Out.js naking:1 withStarter:0 timeOut:15000 headless:1` )
  .then( ( op ) =>
  {
    test.description = 'out/Out.js';
    var output = 'Message to redirect'

    test.identical( op.exitCode, 0 );
    test.true( !_.strHas( op.output, output ) );
    return op;
  })

  return a.ready;

}/* end of sourcesJoinBrowserOptionRedirectingConsole */

//

function sourcesJoinRoutineInclude( test )
{
  let context = this;
  let a = context.assetFor( test, 'depInclude' );
  let outPath = a.abs( 'out' ); /* qqq xxx : remove */
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:njs';
    a.fileProvider.filesDelete( a.abs( '.' ) );
    a.reflect();
    // _.fileProvider.filesDelete( a.routinePath + '/out' ); /* xxx : replace */
    a.fileProvider.filesDelete( a.abs( 'out' ) );
    a.fileProvider.filesDelete( a.abs( 'in/build' ) );
    a.fileProvider.filesDelete( a.abs( 'in/.modules' ) );
    return null;
  })

  a.fork({ execPath : context.willbeExecPath, args : '.build', currentPath : a.abs( 'in' ) })
  var execPath =
  [
    '.sources.join',
    'basePath:in',
    'inPath:[**/*.(js|s),build/node_modules/*]',
    'outPath:../out/Out.js',
    'entryPath:Index.js',
    'interpreter:njs',
  ].join( ' ' );
  a.appStart( execPath )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );
    var expected = [ '.', './Out.js' ];
    var files = a.find( a.abs( 'out' ) );
    test.identical( files, expected );
    return op;
  })

  a.fork( `out/Out.js` )
  .then( ( op ) =>
  {
    test.description = 'out/Out.js';
    var output =
`
Index.js:begin

Index.js
_filePath_ : ${a.routinePath}/out/Out.js/Index.js
_dirPath_ : ${a.routinePath}/out/Out.js
__filename : ${a.routinePath}/out/Out.js/Index.js
__dirname : ${a.routinePath}/out/Out.js
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : njs

Dep1.js:begin

Dep1.js
_filePath_ : ${a.routinePath}/out/Out.js/dep/Dep1.js
_dirPath_ : ${a.routinePath}/out/Out.js/dep
__filename : ${a.routinePath}/out/Out.js/dep/Dep1.js
__dirname : ${a.routinePath}/out/Out.js/dep
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : njs
wTools.blueprint.isDefinitive : function

Dep1.js:end
Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.fork( `in/Index.js` )
  .then( ( op ) =>
  {
    test.description = 'in/Index.js';
    var output =
`
Index.js:begin

Index.js
__filename : ${a.absNative( 'in/Index.js' )}
__dirname : ${a.absNative( 'in' )}
module : object
module.parent : object
exports : object
require : function

Dep1.js:begin

Dep1.js
__filename : ${a.absNative( 'in/dep/Dep1.js' )}
__dirname : ${a.absNative( 'in/dep' )}
module : object
module.parent : object
exports : object
require : function
wTools.blueprint.isDefinitive : function

Dep1.js:end
Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:njs';
    a.fileProvider.filesDelete( a.abs( '.' ) );
    a.reflect();
    a.fileProvider.filesDelete( a.abs( 'out' ) );
    a.fileProvider.filesDelete( a.abs( 'in/build' ) );
    a.fileProvider.filesDelete( a.abs( 'in/.modules' ) );
    return null;
  })

  a.fork({ execPath : context.willbeExecPath, args : '.build', currentPath : a.abs( 'in' ) })
  a.appStart({ execPath : `.sources.join inPath:[**/*.(js|s),build/node_modules/*] outPath:out/Out.js entryPath:Index.js interpreter:browser`, currentPath : a.abs( 'in' ) })

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', './Out.js' ];
    var files = a.find( a.abs( 'in/out' ) );
    test.identical( files, expected );

    return op;
  })

  a.appStart({ execPath : `.start out/Out.js naking:1 withStarter:0 timeOut:15000 headless:1`, currentPath : a.abs( 'in' ) })
  .then( ( op ) =>
  {
    test.description = '.start naking:1 withStarter:0';
    var output =
`
Command ".start out/Out.js naking:1 withStarter:0 timeOut:15000 headless:1"
Index.js:begin

Index.js
_filePath_ : /Index.js
_dirPath_ : /
__filename : /Index.js
__dirname : /
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep1.js:begin

Dep1.js
_filePath_ : /dep/Dep1.js
_dirPath_ : /dep
__filename : /dep/Dep1.js
__dirname : /dep
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser
wTools.blueprint.isDefinitive : function

Dep1.js:end
Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
}

sourcesJoinRoutineInclude.description =
`
- routine _.include works properly for both interpreters
`
sourcesJoinRoutineInclude.timeOut = 300000;

//

function sourcesJoinRequireGlob( test )
{
  let context = this;
  let a = context.assetFor( test, 'depGlob' );
  let starter = new _.starter.System().form();

  /* */

  //   a.ready.then( () =>
  //   {
  //     test.case = 'interpreter:njs entryPath:in/Index.js';
  //     a.fileProvider.filesDelete( a.abs( '.' ) );
  //     a.reflect();
  //     a.fileProvider.filesDelete( a.abs( 'out' ) );
  //     return null;
  //   })
  //
  //   a.appStart( `.start entryPath:in/Index.js interpreter:njs` )
  //   .then( ( op ) =>
  //   {
  //     test.description = '.start entryPath:in/Index.js interpreter:njs';
  //     var output =
  // `
  // Index.js:begin
  //
  // Index.js
  // __filename : ${a.routinePath}/in/Index.js
  // __dirname : ${a.routinePath}/in
  // module : object
  // module.parent : object
  // exports : object
  // require : function
  //
  // Dep1.js:begin
  //
  // Dep1.js
  // __filename : ${a.routinePath}/in/dep/Dep1.js
  // __dirname : ${a.routinePath}/in/dep
  // module : object
  // module.parent : object
  // exports : object
  // require : function
  // wTools.blueprint.isDefinitive : function
  //
  // Dep1.js:end
  // Index.js:end
  // `
  //     test.identical( op.exitCode, 0 );
  //     test.equivalent( op.output, output );
  //     return op;
  //   })
  //
  //   /* */
  //
  //   a.ready.then( () =>
  //   {
  //     test.case = 'interpreter:njs entryPath:out/Out.js';
  //     a.fileProvider.filesDelete( a.abs( '.' ) );
  //     a.reflect();
  //     a.fileProvider.filesDelete( a.abs( 'out' ) );
  //     return null;
  //   })
  //
  //   a.appStart( `.sources.join basePath:in inPath:**/*.(js|s) outPath:../out/Out.js entryPath:Index.js interpreter:njs` )
  //
  //   .then( ( op ) =>
  //   {
  //     test.identical( op.exitCode, 0 );
  //     test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );
  //     var expected = [ '.', './Out.js' ];
  //     var files = a.find( a.abs( 'out' ) );
  //     test.identical( files, expected );
  //     return op;
  //   })
  //
  //   a.fork( `out/Out.js` )
  //   .then( ( op ) =>
  //   {
  //     test.description = 'out/Out.js';
  //     var output =
  // `
  // Index.js:begin
  // Dep1.js:begin
  //
  // Dep1.js
  // _filePath_ : ${a.routinePath}/out/Out.js/dir/Dep1.js
  // _dirPath_ : ${a.routinePath}/out/Out.js/dir
  // __filename : ${a.routinePath}/out/Out.js/dir/Dep1.js
  // __dirname : ${a.routinePath}/out/Out.js/dir
  // module : object
  // module.parent : object
  // exports : object
  // require : function
  // include : function
  // _starter_.interpreter : njs
  //
  // Dep1.js:end
  // Dep2.js:begin
  //
  // Dep2.js
  // _filePath_ : ${a.routinePath}/out/Out.js/dir/Dep2.js
  // _dirPath_ : ${a.routinePath}/out/Out.js/dir
  // __filename : ${a.routinePath}/out/Out.js/dir/Dep2.js
  // __dirname : ${a.routinePath}/out/Out.js/dir
  // module : object
  // module.parent : object
  // exports : object
  // require : function
  // include : function
  // _starter_.interpreter : njs
  //
  // Dep2.js:end
  //
  // dir.length : 2
  // dir[ 0 ] : Dep1
  // dir[ 1 ] : Dep2
  //
  // Index.js
  // _filePath_ : ${a.routinePath}/out/Out.js/Index.js
  // _dirPath_ : ${a.routinePath}/out/Out.js
  // __filename : ${a.routinePath}/out/Out.js/Index.js
  // __dirname : ${a.routinePath}/out/Out.js
  // module : object
  // module.parent : object
  // exports : object
  // require : function
  // include : function
  // _starter_.interpreter : njs
  //
  // Index.js:end
  // `
  //     test.identical( op.exitCode, 0 );
  //     test.equivalent( op.output, output );
  //     return op;
  //   })
  // xxx : implement

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:browser entryPath:in/Index.js';
    a.fileProvider.filesDelete( a.abs( '.' ) );
    a.reflect();
    a.fileProvider.filesDelete( a.abs( 'out' ) );
    return null;
  })

  a.appStart( `.start basePath:in entryPath:Index.js timeOut:15000 headless:1` )
  .then( ( op ) =>
  {
    test.description = 'out/Out.js';
    var output =
`
Command ".start basePath:in entryPath:Index.js timeOut:15000 headless:1"
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : /dir/Dep1.js
_dirPath_ : /dir
__filename : /dir/Dep1.js
__dirname : /dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep1.js:end
Dep2.js:begin

Dep2.js
_filePath_ : /dir/Dep2.js
_dirPath_ : /dir
__filename : /dir/Dep2.js
__dirname : /dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep2.js:end

dir.length : 2
dir[ 0 ] : Dep1
dir[ 1 ] : Dep2

Index.js
_filePath_ : /Index.js
_dirPath_ : /
__filename : /Index.js
__dirname : /
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:browser entryPath:out/Out.js';
    a.fileProvider.filesDelete( a.abs( '.' ) );
    a.reflect();
    a.fileProvider.filesDelete( a.abs( 'out' ) );
    return null;
  })

  a.appStart( `.sources.join basePath:in inPath:**/*.(js|s) outPath:../out/Out.js entryPath:Index.js interpreter:browser` )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );
    var expected = [ '.', './Out.js' ];
    var files = a.find( a.abs( 'out' ) );
    test.identical( files, expected );
    return op;
  })

  a.appStart( `.start entryPath:out/Out.js naking:1 withStarter:0 timeOut:15000 headless:1` ) /* xxx : replace hardcoding */
  .then( ( op ) =>
  {
    test.description = 'out/Out.js';
    var output =
`
Command ".start entryPath:out/Out.js naking:1 withStarter:0 timeOut:15000 headless:1"
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : /dir/Dep1.js
_dirPath_ : /dir
__filename : /dir/Dep1.js
__dirname : /dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep1.js:end
Dep2.js:begin

Dep2.js
_filePath_ : /dir/Dep2.js
_dirPath_ : /dir
__filename : /dir/Dep2.js
__dirname : /dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep2.js:end

dir.length : 2
dir[ 0 ] : Dep1
dir[ 1 ] : Dep2

Index.js
_filePath_ : /Index.js
_dirPath_ : /
__filename : /Index.js
__dirname : /
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
}

sourcesJoinRequireGlob.description =
`
- routine require with glob path finds many files
`

//

function sourcesJoinRequireGlobAnyAny( test )
{
  let context = this;
  let a = context.assetFor( test, 'depGlobAnyAny' );
  let starter = new _.starter.System().form();

  /* xxx : add interpreter:njs cases */

  /* */


  //   a.ready.then( () =>
  //   {
  //     test.case = 'interpreter:browser entryPath:in/Index.js';
  //     a.fileProvider.filesDelete( a.abs( '.' ) );
  //     a.reflect();
  //     a.fileProvider.filesDelete( a.abs( 'out' ) );
  //     return null;
  //   })
  //
  //   a.appStart( `.start basePath:in entryPath:Index.js timeOut:15000 headless:1` )
  //   .then( ( op ) =>
  //   {
  //     test.description = 'out/Out.js';
  //     var output =
  // `
  // Index.js:begin
  // Dep1.js:begin
  //
  // Dep1.js
  // _filePath_ : /dir/Dep1.js
  // _dirPath_ : /dir
  // __filename : /dir/Dep1.js
  // __dirname : /dir
  // module : object
  // module.parent : object
  // exports : object
  // require : function
  // include : function
  // _starter_.interpreter : browser
  //
  // Dep1.js:end
  // Dep2.s:begin
  //
  // Dep2.s
  // _filePath_ : /dir/Dep2.s
  // _dirPath_ : /dir
  // __filename : /dir/Dep2.s
  // __dirname : /dir
  // module : object
  // module.parent : object
  // exports : object
  // require : function
  // include : function
  // _starter_.interpreter : browser
  //
  // Dep2.s:end
  //
  // dir.length : 2
  // dir[ 0 ] : Dep1
  // dir[ 1 ] : Dep2
  //
  // Index.js
  // _filePath_ : /Index.js
  // _dirPath_ : /
  // __filename : /Index.js
  // __dirname : /
  // module : object
  // module.parent : object
  // exports : object
  // require : function
  // include : function
  // _starter_.interpreter : browser
  //
  // Index.js:end
  // `
  //     test.identical( op.exitCode, 0 );
  //     test.equivalent( op.output, output );
  //     return op;
  //   })
  // xxx

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:browser entryPath:out/Out.js';
    a.fileProvider.filesDelete( a.abs( '.' ) );
    a.reflect();
    a.fileProvider.filesDelete( a.abs( 'out' ) );
    return null;
  })

  a.appStart( `.sources.join basePath:in inPath:**/*.(js|s) outPath:../out/Out.js entryPath:Index.js interpreter:browser` )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );
    var expected = [ '.', './Out.js' ];
    var files = a.find( a.abs( 'out' ) );
    test.identical( files, expected );
    return op;
  })

  a.appStart( `.start entryPath:out/Out.js naking:1 withStarter:0 timeOut:15000 headless:1` ) /* xxx : replace hardcoding */
  .then( ( op ) =>
  {
    test.description = 'out/Out.js';
    var output =
`
Command ".start entryPath:out/Out.js naking:1 withStarter:0 timeOut:15000 headless:1"
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : /dir/Dep1.js
_dirPath_ : /dir
__filename : /dir/Dep1.js
__dirname : /dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep1.js:end
Dep2.s:begin

Dep2.s
_filePath_ : /dir/Dep2.s
_dirPath_ : /dir
__filename : /dir/Dep2.s
__dirname : /dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep2.s:end

dir.length : 2
dir[ 0 ] : Dep1
dir[ 1 ] : Dep2

Index.js
_filePath_ : /Index.js
_dirPath_ : /
__filename : /Index.js
__dirname : /
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
}

sourcesJoinRequireGlobAnyAny.description =
`
- routine require with glob **/**.js finds many files
`

//

function sourcesJoinRequireGlobAnyExt( test )
{
  let context = this;
  let a = context.assetFor( test, 'depGlobAnyExt' );
  let starter = new _.starter.System().form();

  /* xxx : add interpreter:njs cases */

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:browser entryPath:in/Index.js';
    a.fileProvider.filesDelete( a.abs( '.' ) );
    a.reflect();
    a.fileProvider.filesDelete( a.abs( 'out' ) );
    return null;
  })

  a.appStart( `.start basePath:in entryPath:Index.js timeOut:15000 headless:1` )
  .then( ( op ) =>
  {
    test.description = 'out/Out.js';
    var output =
`
Command ".start basePath:in entryPath:Index.js timeOut:15000 headless:1"
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : /dir/Dep1.js
_dirPath_ : /dir
__filename : /dir/Dep1.js
__dirname : /dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep1.js:end
Dep2.s:begin

Dep2.s
_filePath_ : /dir/Dep2.s
_dirPath_ : /dir
__filename : /dir/Dep2.s
__dirname : /dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep2.s:end

dir.length : 2
dir[ 0 ] : Dep1
dir[ 1 ] : Dep2

Index.js
_filePath_ : /Index.js
_dirPath_ : /
__filename : /Index.js
__dirname : /
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:browser entryPath:out/Out.js';
    a.fileProvider.filesDelete( a.abs( '.' ) );
    a.reflect();
    a.fileProvider.filesDelete( a.abs( 'out' ) );
    return null;
  })

  a.appStart( `.sources.join basePath:in inPath:**/*.(js|s) outPath:../out/Out.js entryPath:Index.js interpreter:browser` )

  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );
    var expected = [ '.', './Out.js' ];
    var files = a.find( a.abs( 'out' ) );
    test.identical( files, expected );
    return op;
  })

  a.appStart( `.start entryPath:out/Out.js naking:1 withStarter:0 timeOut:15000 headless:1` )
  .then( ( op ) =>
  {
    test.description = 'out/Out.js';
    var output =
`
Command ".start entryPath:out/Out.js naking:1 withStarter:0 timeOut:15000 headless:1"
Index.js:begin
Dep1.js:begin

Dep1.js
_filePath_ : /dir/Dep1.js
_dirPath_ : /dir
__filename : /dir/Dep1.js
__dirname : /dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep1.js:end
Dep2.s:begin

Dep2.s
_filePath_ : /dir/Dep2.s
_dirPath_ : /dir
__filename : /dir/Dep2.s
__dirname : /dir
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Dep2.s:end

dir.length : 2
dir[ 0 ] : Dep1
dir[ 1 ] : Dep2

Index.js
_filePath_ : /Index.js
_dirPath_ : /
__filename : /Index.js
__dirname : /
module : object
module.parent : object
exports : object
require : function
include : function
_starter_.interpreter : browser

Index.js:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
}

sourcesJoinRequireGlobAnyExt.timeOut = 90000;
sourcesJoinRequireGlobAnyExt.description =
`
- routine require with glob **/**.js finds many files
`

//

function sourcesJoinExpressServer( test )
{
  let context = this;
  let a = context.assetFor( test, 'express' );
  let outPath = a.abs( 'out' );
  let starter = new _.starter.System().form();

  /* How to run webpack:
    ## install express
    cd proto/wtools/atop/starter.test/_asset/express
    npm i

    ## install webpack
    cd webpack
    npm i

    ## pack server script
    npm run pack
  */

  a.ready.then( () =>
  {
    test.case = 'basic';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.shell( `npm i` )
  a.appStart( `.sources.join ** outPath:out/server.js entryPath:server.js basePath : . allowPath : [ node_modules ]` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '+ sourcesJoin to' ), 1 );

    var expected = [ '.', 'server.js' ];
    var files = a.find( a.abs( 'out' ) );
    test.identical( files, expected );

    return op;
  })

  a.fork( `out/server.js` )
  .then( ( op ) =>
  {
    test.description = 'out/server.js';
    var output = `Go to http://localhost:4444`;
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
} /* end of sourcesJoinExpressServer */

// --
// html for
// --

function htmlForBasic( test )
{
  let context = this;
  let a = context.assetFor( test, 'several' );
  let outputPath = a.abs( 'Index.html' );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'default';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    return null;
  })

  a.appStart( `.html.for ${a.routinePath}/**` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ html saved to .*\/Index\.html/ ), 1 )

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './File1.js', './File2.js', './Index.html' ] );

    var read = a.fileProvider.fileRead( outputPath );
    var dom = new Jsdom.JSDOM( read );
    var document = dom.window.document;

    test.description = 'scripts';
    var exp = [ '/.starter', './File1.js', './File2.js' ];
    var got = _.select( _.array.from( document.querySelectorAll( 'script' ) ), '*/src' );
    test.identical( got, exp );

    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'empty';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    return null;
  })

  a.appStart( `.html.for []` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ html saved to .*\/Index\.html/ ), 1 );

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './File1.js', './File2.js', './Index.html' ] );

    var read = a.fileProvider.fileRead( outputPath );
    var dom = new Jsdom.JSDOM( read );
    var document = dom.window.document;

    test.description = 'scripts';
    var exp = [ '/.starter' ];
    var got = _.select( _.array.from( document.querySelectorAll( 'script' ) ), '*/src' );
    test.identical( got, exp );

    return op;
  })

  /* */

  return a.ready;
}

//

function htmlForOptionTitle( test )
{
  let context = this;
  let a = context.assetFor( test, 'several' );
  let outputPath = a.abs( 'Index.html' );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'default';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    return null;
  })

  a.appStart( `.html.for ${a.routinePath}/**` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ html saved to .*\/Index\.html/ ), 1 )

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './File1.js', './File2.js', './Index.html' ] );

    var read = a.fileProvider.fileRead( outputPath );
    var dom = new Jsdom.JSDOM( read );
    var document = dom.window.document;

    test.description = 'title';
    var exp = [ 'File1.js' ];
    var got = _.select( _.array.from( document.querySelectorAll( 'title' ) ), '*/text' );
    test.identical( got, exp );

    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'with title';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    return null;
  })

  a.appStart( `.html.for ${a.routinePath}/** title:"Html for test"` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ html saved to .*\/Index\.html/ ), 1 )

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './File1.js', './File2.js', './Index.html' ] );

    var read = a.fileProvider.fileRead( outputPath );
    var dom = new Jsdom.JSDOM( read );
    var document = dom.window.document;

    test.description = 'title';
    var exp = [ 'Html for test' ];
    var got = _.select( _.array.from( document.querySelectorAll( 'title' ) ), '*/text' );
    test.identical( got, exp );

    return op;
  })

  /* */

  return a.ready;
}

//

function htmlForOptionWithStarter( test )
{
  let context = this;
  let a = context.assetFor( test, 'several' );
  let outputPath = a.abs( 'Index.html' );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'withStarter:include';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    return null;
  })

  a.appStart( `.html.for ${a.routinePath}/** withStarter:include` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ html saved to .*\/Index\.html/ ), 1 )

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './File1.js', './File2.js', './Index.html' ] );

    var read = a.fileProvider.fileRead( outputPath );
    var dom = new Jsdom.JSDOM( read );
    var document = dom.window.document;

    test.description = 'scripts';
    var exp = [ '/.starter', './File1.js', './File2.js' ];
    var got = _.select( _.array.from( document.querySelectorAll( 'script' ) ), '*/src' );
    test.identical( got, exp );

    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'withStarter:0';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    return null;
  })

  a.appStart( `.html.for ${a.routinePath}/** withStarter:0` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ html saved to .*\/Index\.html/ ), 1 )

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './File1.js', './File2.js', './Index.html' ] );

    var read = a.fileProvider.fileRead( outputPath );
    var dom = new Jsdom.JSDOM( read );
    var document = dom.window.document;

    test.description = 'scripts';
    var exp = [ './File1.js', './File2.js' ];
    var got = _.select( _.array.from( document.querySelectorAll( 'script' ) ), '*/src' );
    test.identical( got, exp );

    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'empty';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    return null;
  })

  a.appStart( `.html.for [] withStarter:0` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ html saved to .*\/Index\.html/ ), 1 );

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './File1.js', './File2.js', './Index.html' ] );

    var read = a.fileProvider.fileRead( outputPath );
    var dom = new Jsdom.JSDOM( read );
    var document = dom.window.document;

    test.description = 'scripts';
    var exp = [];
    var got = _.select( _.array.from( document.querySelectorAll( 'script' ) ), '*/src' );
    test.identical( got, exp );

    return op;
  })

  /* */

  return a.ready;
}

// --
// start
// --

function startRecursion( test )
{
  let context = this;
  let a = context.assetFor( test, 'recursion' );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'basic';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.start F1.js timeOut:${context.deltaTime3} loggingSessionEvents:0 headless:1` )
  .then( ( op ) =>
  {
    var output =
`
Command ".start F1.js timeOut:15000 loggingSessionEvents:0 headless:1"
F1:before
F2:before
F2:object
F2:after
F1:string
F1:after
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
}

startRecursion.description =
`
  - Recursive "require" works the same way it does under nodejs.
`

//

function startRecursionSingle( test )
{
  let context = this;
  let a = context.assetFor( test, 'recursion' );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'basic';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.start F1.js timeOut:${context.deltaTime3} loggingSessionEvents:0 headless:1 withScripts:single` )
  .then( ( op ) =>
  {
    var output =
`
Command ".start F1.js timeOut:15000 loggingSessionEvents:0 headless:1 withScripts:single"
F1:before
F2:before
F2:object
F2:after
F1:string
F1:after
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
}

startRecursionSingle.description =
`
  - Recursive "require" works the same way it does under nodejs.
`

//

function startBaseDeducingFromAllowed( test )
{
  let context = this;
  let a = context.assetFor( test );
  let starter = new _.starter.System().form();

  let appStart = a.process.starter
  ({
    execPath : context.appJsPath,
    currentPath : a.originalAbs( '.' ),
    outputCollecting : 1,
    throwingExitCode : 1,
    outputGraying : 1,
    detaching : 0,
    ready : a.ready,
    mode : 'fork',
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'basic';
    return null;
  })

  appStart( `.start File1.js timeOut:${context.deltaTime3} loggingOptions:1 headless:1 allowedPath:../../../../..` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    test.identical( _.strCount( op.output, '/node_modules : true' ), 1 );
    test.identical( _.strCount( op.output, 'File1.js object object' ), 1 );

    test.identical( _.strCount( op.output, 'catchingUncaughtErrors : 1' ), 1 );
    test.identical( _.strCount( op.output, 'ncaught' ), 1 );
    test.identical( _.strCount( op.output, 'error' ), 0 );
    test.identical( _.strCount( op.output, 'Error' ), 1 );

    return op;
  })

  /* */

  return a.ready;
}

startBaseDeducingFromAllowed.description =
`
- basePath is deduced form allowedPath
- application run
`

//

function startOptionWithModule( test )
{
  let context = this;
  let a = context.assetFor( test );
  let starter = new _.starter.System().form();

  let appStart = a.process.starter
  ({
    execPath : context.appJsPath,
    currentPath : a.originalAbs( '.' ),
    outputCollecting : 1,
    throwingExitCode : 1,
    outputGraying : 1,
    detaching : 0,
    ready : a.ready,
    mode : 'fork',
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'basic';
    // _.fileProvider.filesDelete( a.routinePath );
    // a.reflect();
    // _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  // appStart( `.start startOptionWithModule/File1.js timeOut:${context.deltaTime3}0 loggingSessionEvents:1 headless:1 withModule:../../../../node_modules/Tools withModule:wCopyable` )
  appStart
  ({
    execPath : `.start`,
    args :
    [
      `startOptionWithModule/File1.js`,
      `timeOut:${context.deltaTime3}0`,
      `loggingSessionEvents:1`,
      `headless:1`,
      `withModule:wTools`,
      `withModule:wCopyable`
    ]
  })
  .then( ( op ) =>
  {
    var output =
`
xxx
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
}

startOptionWithModule.description =
`
- xxx
`

//

function startWithNpmPackage( test )
{
  let context = this;
  let a = context.assetFor( test );
  let starter = new _.starter.System().form();

  let appStart = a.process.starter
  ({
    execPath : context.appJsPath,
    currentPath : a.originalAbs( '.' ),
    outputCollecting : 1,
    throwingExitCode : 1,
    outputGraying : 1,
    detaching : 0,
    ready : a.ready,
    mode : 'fork',
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'basic';
    return null;
  })

  appStart( `.start File1.js timeOut:${context.deltaTime3} loggingOptions:1 headless:1` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    test.identical( _.strCount( op.output, '/node_modules : true' ), 1 );
    test.identical( _.strCount( op.output, 'File1.js object 9' ), 1 );

    test.identical( _.strCount( op.output, 'catchingUncaughtErrors : 1' ), 1 );
    test.identical( _.strCount( op.output, 'ncaught' ), 1 );
    test.identical( _.strCount( op.output, 'error' ), 0 );
    test.identical( _.strCount( op.output, 'Error' ), 1 );

    return op;
  })

  /* */

  return a.ready;
}

startWithNpmPackage.description =
`
- resolving of npm package works
`

//

function startChangeModuleCache( test )
{
  let context = this;
  let a = context.assetFor( test );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'basic';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    return null;
  })

  a.appStart( `.start Main.js timeOut:${context.deltaTime3} loggingSessionEvents:0 headless:1` )
  .then( ( op ) =>
  {
    var output =
`
Command ".start Main.js timeOut:15000 loggingSessionEvents:0 headless:1"
F1.js
F1.js
F2.js
F2.js
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
}

startChangeModuleCache.description =
`
  - Require of 'module' works.
  - Replacing Module._cache works.
`

//

function startModuleParent( test )
{
  let context = this;
  let a = context.assetFor( test );
  let starter = new _.starter.System().form();

  /* */

  // xxx
  //   a.ready.then( () =>
  //   {
  //     test.case = 'native njs';
  //     _.fileProvider.filesDelete( a.routinePath );
  //     a.reflect();
  //     return null;
  //   })
  //
  //   a.shell( `node Main.js` )
  //   .then( ( op ) =>
  //   {
  //     var output =
  // `
  // Main.js: false
  // F1.js: ${ a.abs( 'F1.js' ) }
  // F2.js: ${ a.abs( 'F2.js' ) }
  // F3.js: ${ a.abs( 'F3.js' ) }
  // `
  //     test.identical( op.exitCode, 0 );
  //     test.equivalent( op.output, output );
  //     return op;
  //   })

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:njs';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    return null;
  })

  a.appStart( `.start Main.js timeOut:${context.deltaTime3} loggingSessionEvents:0 headless:1 interpreter:njs` )
  .then( ( op ) =>
  {
    var output =
`
Command ".start Main.js timeOut:15000 loggingSessionEvents:0 headless:1 interpreter:njs"
Main.js: false
F1.js: ${ a.path.nativize( a.abs( 'F1.js' ) ) }
F2.js: ${ a.path.nativize( a.abs( 'F2.js' ) ) }
F3.js: ${ a.path.nativize( a.abs( 'F3.js' ) ) }
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  //   a.ready.then( () =>
  //   {
  //     test.case = 'browser';
  //     _.fileProvider.filesDelete( a.routinePath );
  //     a.reflect();
  //     return null;
  //   })
  //
  //   a.appStart( `.start Main.js timeOut:${context.deltaTime3} loggingSessionEvents:0 headless:1` )
  //   .then( ( op ) =>
  //   {
  //     var output =
  // `
  // xxx
  // `
  //     test.identical( op.exitCode, 0 );
  //     test.equivalent( op.output, output );
  //     return op;
  //   })

  /* */

  return a.ready;
}

startModuleParent.description =
`
  - Field module.parent has proper value
`

//

function startOptionTimeOutImmediateChild( test )
{
  let context = this;
  let a = context.assetFor( test );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'interpreter:njs';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    return null;
  })

  a.appStartNonThrowing( `.start Main.js timeOut:${context.deltaTime3} loggingSessionEvents:0 headless:1 interpreter:njs` )
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Main.js:begin' ), 1 );
    test.identical( _.strCount( op.output, `F1.js: ${ a.path.nativize( a.abs( 'F1.js' ) ) }` ), 1 );
    test.identical( _.strCount( op.output, `F2.js: ${ a.path.nativize( a.abs( 'F2.js' ) ) }` ), 1 );
    test.identical( _.strCount( op.output, `F3.js: ${ a.path.nativize( a.abs( 'F3.js' ) ) }` ), 1 );
    test.identical( _.strCount( op.output, 'Terminating process' ), 1 );
    test.identical( _.strCount( op.output, 'Main.js:end' ), 0 );

    return op;
  })

  /* */

  return a.ready;
}

startOptionTimeOutImmediateChild.description =
`
  - Time out in immdeiate child works.
`

//

function startTestSuite( test )
{
  let context = this;
  let a = context.assetFor( test );
  let starter = new _.starter.System().form();

  let appStart = a.process.starter
  ({
    execPath : context.appJsPath,
    currentPath : a.originalAbs( '.' ),
    outputCollecting : 1,
    throwingExitCode : 0,
    outputGraying : 1,
    detaching : 0,
    ready : a.ready,
    mode : 'fork',
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'basic';
    // _.fileProvider.filesDelete( a.routinePath );
    // a.reflect();
    // _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  appStart
  ({
    execPath : `.start`,
    args :
    [
      `wtools/atop/starter.test/_asset/startTestSuite/Suite1.js`,
      `basePath:../../../../..`,
      // `timeOut:${context.deltaTime3}`,
      `loggingSessionEvents:0`,
      `headless:1`,
      `loggingOptions:1`
    ]
  })
  .then( ( op ) =>
  {
    var output =
`
xxx
`
    test.notIdentical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
}

startTestSuite.experimental = 1;
startTestSuite.description =
`
  - Running test suite in browser works.
`

//

function startHtml( test )
{
  let context = this;
  let a = context.assetFor( test, 'html' );
  let starter = new _.starter.System().form();

  /* */

  a.ready.then( () =>
  {
    test.case = 'basic';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  a.appStart( `.start F1.html timeOut:${context.deltaTime3} loggingSessionEvents:0 headless:1` )
  .then( ( op ) =>
  {
    var output =
`
Command ".start F1.html timeOut:15000 loggingSessionEvents:0 headless:1"
F1:begin
F1:end
`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
}

startHtml.description =
`
- cui accept html file
- cui launch html file
`

// --
// worker
// --

function startWorkerUsingTheSameInclude( test )
{
  let context = this;
  let a = context.assetFor( test, 'workerUsingTheSameInclude' );

  a.reflect();

  a.appStart( `.start Index.js timeOut:${context.deltaTime3} headless:1 loggingSessionEvents:1 loggingRequests:1` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    test.identical( _.strCount( op.output, 'ncaught' ), 0 );
    test.identical( _.strCount( op.output, 'error' ), 0 );
    test.identical( _.strCount( op.output, 'Error' ), 0 );

    var exp =
`
Index.js : scriptPath : /Script.js
Script.js : Global : Window
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    var exp =
`
Worker.js : scriptPath : /Script.js
Script.js : Global : DedicatedWorkerGlobalScope
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    var exp = `. request /.starter`;
    test.identical( _.strCount( op.output, exp ), 2 );
    var exp = `. request /Index.js?entry:1`;
    test.identical( _.strCount( op.output, exp ), 1 );
    var exp = `. request /Index.js`;
    test.identical( _.strCount( op.output, exp ), 2 );
    var exp = `. request /Script.js`;
    test.identical( _.strCount( op.output, exp ), 4 );
    var exp = `. request /Worker.js`;
    test.identical( _.strCount( op.output, exp ), 1 );

    return op;
  })

  return a.ready;
}

//

function startWorkerUsingTheSameIncludeSubDir( test )
{
  let context = this;
  let a = context.assetFor( test, 'workerUsingTheSameIncludeSubDir' );

  a.reflect();

  a.appStart( `.start proto/Index.js timeOut:${context.deltaTime3} headless:1 loggingSessionEvents:1 loggingRequests:1` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    test.identical( _.strCount( op.output, 'ncaught' ), 0 );
    test.identical( _.strCount( op.output, 'error' ), 0 );
    test.identical( _.strCount( op.output, 'Error' ), 0 );

    var exp =
`
Index.js : scriptPath : /proto/Script.js
Script.js : Global : Window
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    var exp =
`
Worker.js : scriptPath : /proto/Script.js
Script.js : Global : DedicatedWorkerGlobalScope
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    var exp = `. request /.starter`;
    test.identical( _.strCount( op.output, exp ), 2 );
    var exp = `. request /proto/Index.js?entry:1`;
    test.identical( _.strCount( op.output, exp ), 1 );
    var exp = `. request /proto/Index.js`;
    test.identical( _.strCount( op.output, exp ), 2 );
    var exp = `. request /proto/Script.js`;
    test.identical( _.strCount( op.output, exp ), 4 );
    var exp = `. request /proto/Worker.js`;
    test.identical( _.strCount( op.output, exp ), 1 );

    return op;
  })

  return a.ready;
}

//

function startWorkerUsingDifferentInclude( test )
{
  let context = this;
  let a = context.assetFor( test, 'workerUsingDifferentInclude' );

  a.reflect();

  a.appStart( `.start Index.js timeOut:${context.deltaTime3} headless:1 loggingSessionEvents:1 loggingRequests:1` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    test.identical( _.strCount( op.output, 'ncaught' ), 0 );
    test.identical( _.strCount( op.output, 'error' ), 0 );
    test.identical( _.strCount( op.output, 'Error' ), 0 );

    var exp =
`
Index.js : begin
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    var exp =
`
Worker.js : scriptPath : /Script.js
Script.js : Global : DedicatedWorkerGlobalScope
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    var exp = `. request /.starter`;
    test.identical( _.strCount( op.output, exp ), 2 );
    var exp = `. request /Index.js?entry:1`;
    test.identical( _.strCount( op.output, exp ), 1 );
    var exp = `. request /Index.js`;
    test.identical( _.strCount( op.output, exp ), 2 );
    var exp = `. request /Script.js`;
    test.identical( _.strCount( op.output, exp ), 2 );
    var exp = `. request /Worker.js`;
    test.identical( _.strCount( op.output, exp ), 1 );

    return op;
  })

  return a.ready;
}

//

function startWorkerUsingDifferentIncludeSubDir( test )
{
  let context = this;
  let a = context.assetFor( test, 'workerUsingDifferentIncludeSubDir' );

  a.reflect();

  a.appStart( `.start proto/Index.js timeOut:${context.deltaTime3} headless:1 loggingSessionEvents:1 loggingRequests:1` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    test.identical( _.strCount( op.output, 'ncaught' ), 0 );
    test.identical( _.strCount( op.output, 'error' ), 0 );
    test.identical( _.strCount( op.output, 'Error' ), 0 );

    var exp =
`
Index.js : begin
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    var exp =
`
Worker.js : scriptPath : /proto/Script.js
Script.js : Global : DedicatedWorkerGlobalScope
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    var exp = `. request /.starter`;
    test.identical( _.strCount( op.output, exp ), 2 );
    var exp = `. request /proto/Index.js?entry:1`;
    test.identical( _.strCount( op.output, exp ), 1 );
    var exp = `. request /proto/Index.js`;
    test.identical( _.strCount( op.output, exp ), 2 );
    var exp = `. request /proto/Script.js`;
    test.identical( _.strCount( op.output, exp ), 2 );
    var exp = `. request /proto/Worker.js`;
    test.identical( _.strCount( op.output, exp ), 1 );

    return op;
  })

  return a.ready;
}

//

async function workerEnvironment( test )
{
  let context = this;
  let a = context.assetFor( test );

  a.reflect();

  a.appStart( `.start Index.js timeOut:${context.deltaTime3} headless:1 loggingSessionEvents:1 loggingRequests:1` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var exp =
`
Index.js
_filePath_ : /Index.js
_dirPath_ : /
__filename : /Index.js
__dirname : /
module : object
exports : object
require : function
include : function
_starter_.interpreter : browser
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    var exp =
`
Worker.js
_filePath_ : /Worker.js
_dirPath_ : /
__filename : /Worker.js
__dirname : /
module : object
exports : object
require : function
include : function
_starter_.interpreter : browser
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    test.identical( _.strCount( op.output, 'error' ), 0 );
    test.identical( _.strCount( op.output, 'Error' ), 0 );

    var exp =
`
W1.js
_filePath_ : /W1.js
_dirPath_ : /
__filename : /W1.js
__dirname : /
module : object
exports : object
require : function
include : function
_starter_.interpreter : browser
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    var exp = `. request /.starter`;
    test.identical( _.strCount( op.output, exp ), 2 );
    var exp = `. request /Index.js?entry:1`;
    test.identical( _.strCount( op.output, exp ), 1 );
    var exp = `. request /Index.js`;
    test.identical( _.strCount( op.output, exp ), 2 );
    var exp = `. request /Worker.js`;
    test.identical( _.strCount( op.output, exp ), 1 );
    var exp = `. request /W1.js`;
    test.identical( _.strCount( op.output, exp ), 2 );

    return op;
  })

  return a.ready;
}

workerEnvironment.description =
`
- envioronment in worker set properly
`

//

function startExitCode( test )
{
  let context = this;
  let a = context.assetFor( test );
  let starter = new _.starter.System().form();

  let appStart = a.process.starter
  ({
    execPath : context.appJsPath,
    currentPath : a.originalAbs( '.' ),
    outputCollecting : 1,
    throwingExitCode : 0,
    outputGraying : 1,
    detaching : 0,
    ready : a.ready,
    mode : 'fork',
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'basic';
    // _.fileProvider.filesDelete( a.routinePath );
    // a.reflect();
    // _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  appStart
  ({
    execPath : `.start`,
    args :
    [
      `File1.js`,
      `loggingSessionEvents:0`,
      `headless:1`,
      `loggingOptions:1`
    ]
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 123 );
    return op;
  })

  /* */

  return a.ready;
}

startExitCode.description =
`
  - Starter exits with code specified in the browser.
`

//

function startStyledConsoleOutput( test )
{
  let context = this;
  let a = context.assetFor( test );
  let starter = new _.starter.System().form();

  let appStart = a.process.starter
  ({
    execPath : context.appJsPath,
    currentPath : a.originalAbs( '.' ),
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0,
    outputGraying : 1,
    detaching : 0,
    ready : a.ready,
    mode : 'fork',
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'basic';
    // _.fileProvider.filesDelete( a.routinePath );
    // a.reflect();
    // _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  appStart
  ({
    execPath : `.start`,
    args :
    [
      `wtools/atop/starter.test/_asset/startStyledConsoleOutput/File1.js`,
      `basePath:../../../../..`,
      `loggingSessionEvents:0`,
      `timeOut:${context.deltaTime3}`,
      `headless:1`,
      `loggingOptions:0`
    ]
  })
  .then( ( op ) =>
  {
    var output =
`a
a b c
ab
a
%c
a %b
a
a %cb yyy`
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  /* */

  return a.ready;
}

startStyledConsoleOutput.experimental = 1;
startStyledConsoleOutput.description =
`
- Client-side browser colorful log works on server-side.
`

// --
// etc
// --

async function loggingError( test )
{
  let context = this;
  let a = context.assetFor( test, 'asyncError' );

  a.reflect();

  a.appStart({ execPath : `.start F1.js timeOut:${context.deltaTime3} headless:1`, throwingExitCode : 0 })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'F1:begin' ), 1 );
    test.identical( _.strCount( op.output, 'F1:end' ), 1 );
    test.identical( _.strCount( op.output, 'uncaught error' ), 2 );
    test.identical( _.strCount( op.output, 'uncaught promise error' ), 2 );
    test.identical( _.strCount( op.output, 'Some Error!' ), 1 );
    test.identical( _.strCount( op.output, 'Promise Error!' ), 1 );
    return op;
  })

  return a.ready;
}

loggingError.description =
`
- Client-side log appears on server-side.
- Client-side uncaught errors appears on server side.
- Client-side unhandled promise rejection error appears on server side.
`

//

async function loggingErrorInWorker( test )
{
  let context = this;
  let a = context.assetFor( test, 'errorInWorker' );

  a.reflect();

  a.appStart( `.start Index.js timeOut:${context.deltaTime3} headless:1 loggingSessionEvents:1` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    var exp =
`
 . event::curatedRunLaunchBegin
Index:begin
Index:end
Worker:begin
W1:begin
err:begin
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    test.identical( _.strCount( op.output, 'Some error' ), 1 );
    test.identical( _.strCount( op.output, 'Error including source file /W1.js' ), 1 );

    var exp =
`
err:end
Worker:end
 . event::curatedRunLaunchEnd
 . event::timeOut
 . event::curatedRunTerminateEnd
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    return op;
  })

  return a.ready;
}

loggingErrorInWorker.description =
`
- throwen error in included from worker file shows up in the log
`

//

async function loggingErrorInWorkerNoFile( test )
{
  let context = this;
  let a = context.assetFor( test, 'errorInWorkerNoFile' );

  a.reflect();

  a.appStart( `.start Index.js timeOut:${context.deltaTime3} headless:1 loggingSessionEvents:1` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    test.identical( _.strCount( op.output, '. event::curatedRunLaunchBegin' ), 1 );
    test.identical( _.strCount( op.output, '. event::curatedRunLaunchEnd' ), 1 );
    test.identical( _.strCount( op.output, 'Index:begin' ), 1 );
    test.identical( _.strCount( op.output, 'Index:end' ), 1 );
    test.identical( _.strCount( op.output, 'Worker:begin' ), 1 );
    test.identical( _.strCount( op.output, 'err:begin' ), 1 );
    test.identical( _.strCount( op.output, 'err:end' ), 1 );
    test.identical( _.strCount( op.output, 'Worker:end' ), 1 );

    test.identical( _.strCount( op.output, 'nhandled' ), 0 );
    test.identical( _.strCount( op.output, 'ncaught' ), 0 );
    test.identical( _.strCount( op.output, '= Message of Error' ), 1 );
    test.identical( _.strCount( op.output, `Failed to execute 'importScripts' on 'WorkerGlobalScope': The script at 'http://127.0.0.1:15000/W1.js' failed to load.` ), 2 );

    //     var exp =
    // `
    // err:end
    // Worker:end
    //  . event::timeOut
    //  . event::curatedRunTerminateEnd
    // `
    //     test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );
    // xxx : investigate difference on different OS's

    //     var exp =
    // `
    // Worker:end
    //  . event::timeOut
    //  . event::curatedRunTerminateEnd
    // `
    //     test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    var exp =
`
 . event::curatedRunLaunchEnd
 . event::timeOut
 . event::curatedRunTerminateEnd
`
    test.identical( _.strCount( _.str.lines.strip( op.output ), _.str.lines.strip( exp ) ), 1 );

    return op;
  })

  return a.ready;
}

loggingErrorInWorkerNoFile.description =
`
- starter ware catch error and print information about it
`

//

function version( test )
{
  let context = this;
  let a = context.assetFor( test, false );

  _.fileProvider.dirMake( a.abs( '.' ) );

  /* */

  a.appStart({ execPath : '.version' })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.true( _.strHas( op.output, /Current version : .*\..*\..*/ ) );
    test.true( _.strHas( op.output, /alpha version of wstarter : .*\..*\..*/ ) );
    return op;
  })

  return a.ready;
}

// --
// declare
// --

const Proto =
{

  name : 'Tools.Starter.Ext',
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
    deltaTime3 : ( _.process.isDebugged() && 0 ) ? 150000 : 15000,

  },

  tests :
  {

    // sourcesJoin

    sourcesJoin,
    sourcesJoinWithEntry,
    sourcesJoinDep,
    sourcesJoinRequireInternal,
    sourcesJoinComplex,
    sourcesJoinTree,
    sourcesJoinCycle,
    sourcesJoinRecursion,
    sourcesJoinOptionInterpreter,
    sourcesJoinOptionInterpreterOptionBasePath,
    sourcesJoinBrowserOptionRedirectingConsole,
    sourcesJoinRoutineInclude,
    sourcesJoinRequireGlob,
    sourcesJoinRequireGlobAnyAny, /* xxx : implement */
    sourcesJoinRequireGlobAnyExt,
    // sourcesJoinExpressServer, /* xxx : implement */

    // html for

    htmlForBasic,
    htmlForOptionTitle,
    htmlForOptionWithStarter, /* qqq : extend */

    // start

    startRecursion,
    startRecursionSingle,
    // startBaseDeducingFromAllowed,/* xxx : fix */
    // startOptionWithModule, /* xxx : implement */
    // startWithNpmPackage,/* xxx : implement */
    startChangeModuleCache,
    startModuleParent,
    startOptionTimeOutImmediateChild,
    startTestSuite, /* xxx : implement */
    startHtml,

    // worker

    startWorkerUsingTheSameInclude,
    startWorkerUsingTheSameIncludeSubDir,
    startWorkerUsingDifferentInclude,
    startWorkerUsingDifferentIncludeSubDir,
    workerEnvironment,

    startExitCode,
    startStyledConsoleOutput,

    // logging

    loggingError,
    // loggingErrorInWorker,/* xxx : investigate */
    // loggingErrorInWorkerNoFile,/* xxx : investigate */

    // etc

    version,

  }

}

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
