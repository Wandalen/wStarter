
if( typeof module !== 'undefined' )
{
  require( '..' );
}

let _ = _global_.wTools;

var starter = new _.starter.System();

starter.form();

var o =
{
  basePath : _.path.join( __dirname, '..' ),
  interpreter : 'njs',
  outPath : _.path.join( __dirname, 'out/SingleFileTools.ss' ),
  entryPath : _.path.join( __dirname, '../node_modules/wTools/proto/node_modules/Tools' ),
  withServer : 0
}

o.inPath =
[
  _.path.join( __dirname, '../node_modules/wTools/**.(s|ss)' ),
  _.path.join( __dirname, '../node_modules/wTools/proto/node_modules/*' ),
]

console.log( `Joining files for njs interpreter` );
console.log( `sourcesJoinFiles options:\n${_.entity.exportJs( o )}` )
starter.sourcesJoinFiles( o );
console.log( `Saved out file at:"${o.outPath}"\n` )

//

var o =
{
  basePath : _.path.join( __dirname, '..' ),
  interpreter : 'browser',
  outPath : _.path.join( __dirname, 'out/SingleFileTools.js' ),
  entryPath : _.path.join( __dirname, '../node_modules/wTools/proto/node_modules/Tools' ),
  withServer : 0
}

o.inPath =
[
  _.path.join( __dirname, '../node_modules/wTools/**.(s|ss)' ),
  _.path.join( __dirname, '../node_modules/wTools/proto/node_modules/*' ),
]

console.log( `Joining files for browser` );
console.log( `sourcesJoinFiles options:\n${_.entity.exportJs( o )}` )
starter.sourcesJoinFiles( o );
console.log( `Saved out file at:"${o.outPath}"` )
