
if( typeof module !== 'undefined' )
require('./out/SingleFileTools.ss' );

let _ = wTools;

console.log( _.strSplit( 'a b c' ) );

/* log : ["a", "", "b", "", "c"] */
