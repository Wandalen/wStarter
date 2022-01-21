
const _ = require( './out/Compiled.s' );

_.Consequence().take( null ).then( () =>
{
  console.log( 'Succefully included compiled file.' );
  return null
});