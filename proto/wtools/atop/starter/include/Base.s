( function _Base_s_( )
{

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../../wtools/Tools.s' );

  require( 'express' );

  _.include( 'wCopyable' );
  _.include( 'wVerbal' );
  _.include( 'wFiles' );
  _.include( 'wTemplateTreeEnvironment' );
  _.include( 'wServletTools' );
  _.include( 'wLoggerSocket' );

  module.exports = _;
}

})();
