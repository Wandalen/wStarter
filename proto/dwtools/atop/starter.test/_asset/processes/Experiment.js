
let _ = require( '../../Tools.s' );

_.include( 'wExternalFundamentals' );
_.include( 'wFiles' );

_.appExitHandlerRepair();

console.log( '1' );

setTimeout( f, 1000 );
for( let i = 0 ; i < 9999 ; i++ )
_.fileProvider.fileRead( __filename );

console.log( '2' );

function f()
{
  console.log( 'f' );
  setTimeout( f, 1000 );
}
