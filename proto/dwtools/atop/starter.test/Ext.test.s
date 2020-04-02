( function _StarterMaker_test_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  var _ = require( '../../../dwtools/Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wPuppet' );

  require( '../starter/Include.s' );

}

var _global = _global_;
var _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin()
{
  let context = this;

  context.suiteTempPath = _.path.pathDirTempOpen( _.path.join( __dirname, '../..'  ), 'Starter' );
  context.assetsOriginalSuitePath = _.path.join( __dirname, '_asset' );
  context.willbeExecPath = _.module.resolve( 'willbe' );
  context.appJsPath = _.module.resolve( 'wStarter' );

}

//

function onSuiteEnd()
{
  let context = this;
  _.assert( _.strHas( context.suiteTempPath, '/Starter' ) )
  _.path.pathDirTempClose( context.suiteTempPath );
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

  a.anotherStart( _.path.nativize( outputPath ) )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    debugger;
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

  a.shell( `npm i` );
  a.appStart( `.sources.join app2/** outPath:out/app2` );
  a.appStart( `.sources.join app0/** outPath:out/app0 entryPath:app0/File2.js externalBeforePath:out/app2` );
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinDep\/out\/app0/ ), 1 );

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './app0', './app0/File1.js', './app0/File2.js', './app2', './app2/File1.js', './app2/File2.js', './ext', './ext/RequireApp2File2.js', './out', './out/app0', './out/app2' ] );

    return op;
  })

  a.anotherStart( `out/app0` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.anotherStart( `app0/File2.js` )
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
  a.appStart( `.sources.join app0/** outPath:out/dir/app0` )
  a.appStart( `.sources.join app2/** outPath:out/dir/app2` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinRequireInternal\/out\/dir\/app2/ ), 1 );

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './app0', './app0/File1.js', './app0/File2.js', './app2', './app2/File1.js', './app2/File2.js', './ext', './ext/RequireApp2File2.js', './out', './out/dir', './out/dir/app0', './out/dir/app2' ] );

    return op;
  })

  a.anotherStart( `ext/RequireApp2File2.js` )
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
  a.appStart( `.sources.join app2/** outPath:out/app2` )
  a.appStart( `.sources.join app1/** outPath:out/app1` )
  a.appStart( `.sources.join app0/** outPath:out/app0 entryPath:app0/File2.js externalBeforePath:[out/app1, out/app2]` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinComplex\/out\/app0/ ), 1 );

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './app0', './app0/File1.js', './app0/File2.js', './app1', './app1/File1.js', './app1/File2.js', './app2', './app2/File1.js', './app2/File2.js', './out', './out/app0', './out/app1', './out/app2' ] );

    return op;
  })

  a.anotherStart( `out/app0` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.equivalent( op.output, output );
    return op;
  })

  a.anotherStart( `app0/File2.js` )
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

  a.appStart( `.sources.join in/app1/** outPath:out/app1 entryPath:in/app1/dir1/File1.js` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinTree\/out\/app1/ ), 1 );

    var expected = [ '.', './app1' ];
    var files = a.find( outPath );
    test.identical( files, expected );

    return op;
  })

  a.anotherStart( `in/app1/dir1/File1.js` )
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

  a.anotherStart( `out/app1` )
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

  a.appStart( `.sources.join in/app1/** outPath:out/app1 entryPath:in/app1/dir1/dir2/File2.js` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinTree\/out\/app1/ ), 1 );

    var expected = [ '.', './app1' ];
    var files = a.find( outPath );
    test.identical( files, expected );

    return op;
  })

  a.anotherStart( `in/app1/dir1/dir2/File2.js` )
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

  a.anotherStart( `out/app1` )
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

  a.appStart( `.sources.join in/app1/** outPath:out/app1` )
  a.appStart( `.sources.join in/app2/** outPath:out/app2 entryPath:in/app2/File2.js externalBeforePath:out/app1` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ sourcesJoin to .*sourcesJoinTree\/out\/app2/ ), 1 );

    var expected = [ '.', './app1', './app2' ];
    var files = a.find( outPath );
    test.identical( files, expected );

    return op;
  })

  a.anotherStart( `in/app2/File2.js` )
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

  a.anotherStart( `out/app2` )
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

  a.anotherStart( `in/app1/File1.js` )
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

  a.anotherStart( `out/app1` )
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

  a.anotherStart( `in/app1/File2.js` )
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

  a.anotherStart( `out/app1` )
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

  a.anotherStart( `out/app1` )
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

  a.anotherStart( `out/app2` )
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

  a.anotherStart( `out/Out.js` )
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

  a.anotherStart( `F1.js` )
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

// --
// html for
// --

function htmlFor( test )
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
    test.identical( _.strCount( op.output, /\+ html saved to .*htmlFor\/Index\.html/ ), 1 )

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './File1.js', './File2.js', './Index.html' ] );

    var read = _.fileProvider.fileRead( outputPath );
    test.identical( _.strCount( read, '<html' ), 1 );
    test.identical( _.strCount( read, 'src="/.starter"' ), 1 );
    test.identical( _.strCount( read, 'src="./File1.js"' ), 1 );
    test.identical( _.strCount( read, 'src="./File2.js"' ), 1 );
    test.identical( _.strCount( read, '<title>' ), 1 );
    test.identical( _.strCount( read, '<script src' ), 3 );

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
    test.identical( _.strCount( op.output, /\+ html saved to .*htmlFor\/Index\.html/ ), 1 )

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './File1.js', './File2.js', './Index.html' ] );

    var read = _.fileProvider.fileRead( outputPath );
    test.identical( _.strCount( read, '<html' ), 1 );
    test.identical( _.strCount( read, 'src="/.starter"' ), 1 );
    test.identical( _.strCount( read, 'src="./File1.js"' ), 1 );
    test.identical( _.strCount( read, 'src="./File2.js"' ), 1 );
    test.identical( _.strCount( read, '<title>Html for test</title>' ), 1 );
    test.identical( _.strCount( read, '<title>' ), 1 );
    test.identical( _.strCount( read, '<script src' ), 3 );

    return op;
  })

  /* */

  a.ready.then( () =>
  {
    test.case = 'without starter';
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    return null;
  })

  a.appStart( `.html.for ${a.routinePath}/** title:"Html for test" starterIncluding:0` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, /\+ html saved to .*htmlFor\/Index\.html/ ), 1 )

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './File1.js', './File2.js', './Index.html' ] );

    var read = _.fileProvider.fileRead( outputPath );
    test.identical( _.strCount( read, '<html' ), 1 );
    test.identical( _.strCount( read, 'src="/.starter"' ), 0 );
    test.identical( _.strCount( read, 'src="./File1.js"' ), 1 );
    test.identical( _.strCount( read, 'src="./File2.js"' ), 1 );
    test.identical( _.strCount( read, '<title>Html for test</title>' ), 1 );
    test.identical( _.strCount( read, '<script src' ), 2 );

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
    test.identical( _.strCount( op.output, /\+ html saved to .*htmlFor\/Index\.html/ ), 1 )

    var files = a.find( a.routinePath );
    test.identical( files, [ '.', './File1.js', './File2.js', './Index.html' ] );

    var read = _.fileProvider.fileRead( outputPath );
    test.identical( _.strCount( read, '<html' ), 1 );
    test.identical( _.strCount( read, 'src="/.starter"' ), 1 );
    test.identical( _.strCount( read, './src="File1.js"' ), 0 );
    test.identical( _.strCount( read, './src="File2.js"' ), 0 );
    test.identical( _.strCount( read, '<script src' ), 1 );

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

function startTestSuite( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let starter = new _.starter.System().form();

  let appStart = a.process.starter
  ({
    execPath : context.appJsPath,
    currentPath : context.assetsOriginalSuitePath,
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
    _.fileProvider.filesDelete( a.routinePath );
    a.reflect();
    _.fileProvider.filesDelete( a.routinePath + '/out' );
    return null;
  })

  /* xxx : use several values feature */
  appStart( `.start tsuite/Suite1.js timeOut:${context.deltaTime3}0 loggingSessionEvents:0 headless:0 withModule:[ ../../../../dwtools/Tools.s wTesting ]` )
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
  - xxx
`

// --
// etc
// --

async function logging( test )
{
  let context = this;
  let a = context.assetFor( test, 'asyncError' );

  a.reflect();

  a.appStart( `.start F1.js timeOut:${context.deltaTime3} headless:1` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'F1:begin' ), 1 );
    test.identical( _.strCount( op.output, 'F1:end' ), 1 );
    test.identical( _.strCount( op.output, 'uncaught error' ), 2 );
    test.identical( _.strCount( op.output, 'Some Error!' ), 1 );
    return op;
  })

  return a.ready;
}

logging.description =
`
  - Client-side log appears on server-side.
  - Client-side uncaught errors appears on server side.
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
    test.is( _.strHas( op.output, /Current version:.*\..*\..*/ ) );
    test.is( _.strHas( op.output, /Available version:.*\..*\..*/ ) );
    return op;
  })

  return a.ready;
}

// --
// declare
// --

var Self =
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
    assetsOriginalSuitePath : null,
    appJsPath : null,

    willbeExecPath : null,
    find : null,

    deltaTime1 : 250,
    deltaTime2 : 3000,
    deltaTime3 : 15000,

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

    // html for

    htmlFor,

    // start

    startRecursion,
    // startTestSuite,
    startHtml,

    // etc

    logging,
    version,

  }

}

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();