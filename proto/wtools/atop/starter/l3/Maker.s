( function _StarterMaker_s_()
{

'use strict';

// console.log( typeof exports ); /* xxx qqq : write test routine for exports. ask how */

//

let Jsdom, Pretty;
const _ = _global_.wTools;
const Parent = null
const Self = wStarterMakerLight;
function wStarterMakerLight( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Maker';

// --
// relations
// --

let LibrarySplits =
{
  prefix : '',
  predefined : '',
  early : '',
  extract : '',
  proceduring : '',
  globing : '',
  interpreter : '',
  starter : '',
  env : '',
  files : '',
  externalBefore : '',
  entry : '',
  externalAfter : '',
  postfix : '',
}

// --
// implementation
// --

function instanceOptions( o )
{
  let maker = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( o )
  for( let k in o )
  {
    if( o[ k ] === null && maker.InstanceDefaults[ k ] !== undefined )
    o[ k ] = maker[ k ];
  }
  else
  for( let k in maker.InstanceDefaults )
  {
    if( maker[ k ] === null && maker.InstanceDefaults[ k ] !== undefined )
    maker[ k ] = maker.InstanceDefaults[ k ];
  }

  return o;
}

// --
// file
// --

function sourceWrapSplits( o )
{
  let maker = this;

  _.routine.options_( sourceWrapSplits, arguments );
  _.assert( arguments.length === 1 );
  _.assert( _.longHas( [ 'njs', 'browser' ], o.interpreter ) );

  let relativeFilePath = _.starter.pathRealToVirtual
  ({
    realPath : o.filePath,
    basePath : o.basePath,
    realToVirtualMap : o.realToVirtualMap,
    verbosity : o.loggingPathTranslations,
  });

  _.assert( !_.path.isDotted( relativeFilePath ) || relativeFilePath === '.', `Path ${o.filePath} is beyond base path` );

  relativeFilePath = _.path.dot( relativeFilePath );
  let relativeDirPath = _.path.dir( relativeFilePath );
  relativeDirPath = _.path.dot( relativeDirPath );

  let fileName = _.strVarNameFor( _.path.fullName( o.filePath ) );
  if( /^\d/.test( fileName ) )
  fileName = `_${ fileName }`;
  let fileNameNaked = fileName + '_naked';

  let prefix1 = `/* */  /* begin of file ${fileName} */ ( function ${fileName}() { `;
  let prefix2 = `function ${fileNameNaked}() { `;

  let postfix2 = `\n/* */    };`;

  let ware = '\n';

  if( o.interpreter === 'browser' )
  ware +=
`/* */  if( typeof _starter_ === 'undefined' && typeof importScripts !== 'undefined' ) /* qqq xxx : ? */
/* */  importScripts( '/.starter' );
/* */  let _filePath_ = _starter_._pathResolveLocal( null, '/', '${relativeFilePath}' );
/* */  let _dirPath_ = _starter_._pathResolveLocal( null, '/', '${relativeDirPath}' );`
  else
  ware +=
`/* */  let _filePath_ = _starter_._pathResolveLocal( null, _libraryFilePath_, '${relativeFilePath}' );
/* */  let _dirPath_ = _starter_._pathResolveLocal( null, _libraryFilePath_, '${relativeDirPath}' );`

  ware +=
`
/* */  let __filename = _filePath_;
/* */  let __dirname = _dirPath_;
/* */  let module = _starter_._sourceMake( _filePath_, _dirPath_, ${fileNameNaked} );
/* */  let exports = module.exports;
/* */  let require = module.include;
/* */  let include = module.include;
`

  if( o.running )
  // ware += `/* */  _starter_._sourceIncludeResolvedCalling( null, module, module.filePath );`;
  ware += `/* */  module.load( module.filePath );`;

  let postfix1 =
`
/* */  /* end of file ${fileName} */ })();
`

  let result = Object.create( null );
  result.prefix1 = prefix1;
  result.prefix2 = prefix2;
  result.ware = ware;
  result.postfix2 = postfix2;
  result.postfix1 = postfix1;
  return result;
}

sourceWrapSplits.defaults =
{
  filePath : null,
  basePath : null,
  running : 0,
  interpreter : 'njs',
  realToVirtualMap : null,
  loggingPathTranslations : null,
}

//

function sourceWrap( o )
{
  let maker = this;
  _.assert( arguments.length === 1 );
  _.routine.options_( sourceWrap, arguments );
  maker.instanceOptions( o );

  if( o.removingShellPrologue )
  o.fileData = maker.sourceRemoveShellPrologue( o.fileData );

  let splits = maker.sourceWrapSplits({ filePath : o.filePath, basePath : o.basePath });
  let result = splits.prefix1 + splits.prefix2 + o.fileData + splits.postfix2 + splits.ware + splits.postfix1;
  return result;
}

var defaults = sourceWrap.defaults = Object.create( sourceWrapSplits.defaults );
defaults.fileData = null;
defaults.removingShellPrologue = null;

//

function sourceWrapSimple( o )
{
  let maker = this;
  _.assert( arguments.length === 1 );
  _.routine.options_( sourceWrapSimple, arguments );
  maker.instanceOptions( o );

  if( o.removingShellPrologue )
  o.fileData = maker.sourceRemoveShellPrologue( o.fileData );

  let fileName = _.strCamelize( _.path.fullName( o.filePath ) );

  let prefix = `( function ${fileName}() { // == begin of file ${fileName}\n`;

  let postfix =
`// == end of file ${fileName}
})();
`

  let result = prefix + o.fileData + postfix;

  return result;
}

sourceWrapSimple.defaults =
{
  filePath : null,
  fileData : null,
  removingShellPrologue : null,
}

//

/*
qqq : investigate and add test case for such case
  if( fileData.charCodeAt( 0 ) === 0xFEFF )
  fileData = fileData.slice(1);
*/

function sourceRemoveShellPrologue( fileData )
{
  let maker = this;
  let splits = _.strSplitFast( fileData, /^\s*\#\![^\n]*\n/ );
  _.assert( arguments.length === 1 );
  if( splits.length > 1 )
  return '// ' + splits[ 1 ] + splits[ 2 ];
  else
  return fileData;
}

// --
// files
// --

function sourcesJoinSplits( o )
{
  let maker = this;
  let r = _.props.extend( null, maker.LibrarySplits );
  Object.preventExtensions( r );

  o = _.routine.options_( sourcesJoinSplits, arguments );
  _.assert( _.longHas( [ 'njs', 'browser' ], o.interpreter ) );
  _.assert( _.boolLike( o.debug ) );
  _.assert( _.boolLike( o.proceduring ) );
  _.assert( _.boolLike( o.globing ) );
  _.assert( _.boolLike( o.catchingUncaughtErrors ) );
  _.assert( _.boolLike( o.withServer ) );
  _.assert( _.boolLike( o.loggingApplication ) );
  _.assert( _.boolLike( o.loggingSourceFiles ) );

  if( o.entryPath )
  {
    _.assert( _.strIs( o.basePath ) );
    _.assert( _.strIs( o.entryPath ) || _.arrayIs( o.entryPath ) )
    o.entryPath = _.array.as( o.entryPath );
    o.entryPath = _.path.s.join( o.basePath, o.entryPath );
  }

  if( o.libraryName === null )
  o.libraryName = _.strVarNameFor( _.path.fullName( o.outPath ) );

  /* prefix */

  r.prefix =
`
/* */  /* begin of library ${o.libraryName} */ ( function _library_() {
`

  /* predefined */

  r.predefined =
`
/* */  /* begin of predefined */ ( function _predefined_() {

  ${_.routineParse( maker.PredefinedCode.begin ).bodyUnwrapped};

/* */  _global_._starter_.debug = ${o.debug};
/* */  _global_._starter_.interpreter = '${o.interpreter}';
/* */  _global_._starter_.proceduring = ${o.proceduring};
/* */  _global_._starter_.globing = ${o.globing};
/* */  _global_._starter_.catchingUncaughtErrors = ${o.catchingUncaughtErrors};
/* */  _global_._starter_.loggingApplication = ${o.loggingApplication};
/* */  _global_._starter_.loggingSourceFiles = ${o.loggingSourceFiles};
/* */  _global_._starter_.withServer = ${o.withServer};
/* */  _global_._starter_.redirectingConsole = ${o.redirectingConsole};
/* */  _global_._starter_.loggingPath = '${o.loggingPath}';

/* */  _global_.Config.debug = ${o.debug};

  ${_.routineParse( maker.PredefinedCode.end ).bodyUnwrapped};

/* */  /* end of predefined */ })();

`

  /* early */

  r.early =
`
/* */  /* begin of early */ ( function _early_() {

  ${_.routineParse( maker.EarlyCode.begin ).bodyUnwrapped};
  ${_.routineParse( maker.EarlyCode.end ).bodyUnwrapped};

/* */  /* end of early */ })();

  `

  /* extract */

  r.extract =
`
/* */  /* begin of extract */ ( function _extract_() {

  ${_.routineParse( maker.ExtractCode.begin ).bodyUnwrapped};

  ${extract()}

  ${_.routineParse( maker.ExtractCode.end ).bodyUnwrapped};

/* */  /* end of extract */ })();

`

  /* proceduring */

  if( o.proceduring )
  r.proceduring =
`
/* */  /* begin of proceduring */ ( function _proceduring_() {

  ${_.routineParse( maker.ProceduringCode.begin ).bodyUnwrapped};

  ${_.routineParse( maker.ProceduringCode.end ).bodyUnwrapped};

/* */  /* end of proceduring */ })();

`

  /* globing */

  if( !o.withServer )
  if( o.globing )
  r.globing =
`
/* */  /* begin of globing */ ( function _proceduring_() {

  ${_.routineParse( maker.GlobingCode.begin ).bodyUnwrapped};

  ${globingExtract()}

  ${_.routineParse( maker.GlobingCode.end ).bodyUnwrapped};

/* */  /* end of globing */ })();

`

  /* bro */

  if( o.interpreter === 'browser' )
  r.interpreter =
`
/* */  /* begin of bro */ ( function _bro_() {

  ${_.routineParse( maker.BroCode.begin ).bodyUnwrapped};
  ${_.routineParse( maker.BroCode.end ).bodyUnwrapped};

/* */  /* end of bro */ })();

`

  if( o.interpreter === 'browser' )
  if( o.redirectingConsole )
  r.interpreter +=
`
/* */  /* begin of broConsole */ ( function _broConsole_() {

  ${_.routineParse( maker.BroConsoleCode.begin ).bodyUnwrapped};
  ${_.routineParse( maker.BroConsoleCode.end ).bodyUnwrapped};

/* */  /* end of broConsole */ })();

`

  if( o.interpreter === 'browser' )
  r.interpreter +=
`
/* */  /* begin of broProcess */ ( function _broProcess_() {

  ${_.routineParse( maker.BroProcessCode.begin ).bodyUnwrapped};
  ${_.routineParse( maker.BroProcessCode.end ).bodyUnwrapped};

/* */  /* end of broProcess */ })();

`


  /* njs */

  if( o.interpreter === 'njs' )
  r.interpreter =
`
/* */  /* begin of njs */ ( function _njs_() {

  ${_.routineParse( maker.NjsCode.begin ).bodyUnwrapped};
  ${_.routineParse( maker.NjsCode.end ).bodyUnwrapped};

/* */  /* end of njs */ })();

`

  /* starter */

  r.starter =
`
/* */  /* begin of starter */ ( function _starter_() {

  ${_.routineParse( maker.StarterCode.begin ).bodyUnwrapped};
  ${_.routineParse( maker.StarterCode.end ).bodyUnwrapped};

/* */  /* end of starter */ })();

`

  /* env */

  r.env = ``;

  if( o.interpreter !== 'browser' )
  r.env +=
`
/* */  let _libraryFilePath_ = _starter_.path.canonizeTolerant( __filename );
/* */  let _libraryDirPath_ = _starter_.path.canonizeTolerant( __dirname );

`

  if( o.interpreter === 'browser' )
  r.env +=
`
/* */  if( !_global_._libraryFilePath_ )
/* */  _global_._libraryFilePath_ = '/';
/* */  if( !_global_._libraryDirPath_ )
/* */  _global_._libraryDirPath_ = '/';
`

  /* code */

  /* ... code goes here ... */

  /* external */

  if( o.externalBeforePath || o.externalAfterPath )
  _.assert( _.strDefined( o.outPath ), 'Expects option::outPath if option::externalBeforePath or option::externalAfterPath defined' );

  r.externalBefore = '\n';
  if( o.externalBeforePath )
  o.externalBeforePath.forEach( ( externalPath ) =>
  {
    if( _.path.isAbsolute( externalPath ) )
    externalPath = _.path.dot( _.path.relative( _.path.dir( o.outPath ), externalPath ) );
    r.externalBefore += `/* */  _starter_._sourceInclude( null, _libraryDirPath_, '${externalPath}' );\n`;
  });

  r.externalAfter = '\n';
  if( o.externalAfterPath )
  o.externalAfterPath.forEach( ( externalPath ) =>
  {
    if( _.path.isAbsolute( externalPath ) )
    externalPath = _.path.dot( _.path.relative( _.path.dir( o.outPath ), externalPath ) );
    r.externalAfter += `/* */  _starter_._sourceInclude( null, _libraryDirPath_, '${externalPath}' );\n`;
  });

  /* entry */

  r.entry = '\n';
  if( o.entryPath )
  o.entryPath.forEach( ( entryPath ) =>
  {
    entryPath = _.path.relative( o.basePath, entryPath );
    if( o.interpreter === 'njs' )
    r.entry += `/* */  module.exports = _starter_._sourceInclude( null, _libraryFilePath_, './${entryPath}' );\n`;
    else
    r.entry += `/* */  _starter_._sourceInclude( null, _libraryFilePath_, './${entryPath}' );\n`;
  });

  /* postfix */

  r.postfix =
`
/* */  /* end of library ${o.libraryName} */ })()
`

  /* */

  return r;

  /* */

  function extract()
  {
    return `
  ${rou( 'strQuote' )}
  ${rou( 'err' )}
  ${rou( '_err' )}
  ${rou( '_errMake' )}
  ${rou( 'errLogged' )}
  ${rou( 'errAttend' )}
  ${rou( 'errProcess' )}
  ${rou( 'assert' )}

  ${rou( 'error', 'isFormed' )}
  ${rou( 'error', 'isAttended' )}
  ${rou( 'error', 'originalMessage' )}
  ${rou( 'error', 'originalStack' )}
  /* ${rou( 'error', 'set' )} // Dmytro : routine does not exist exposedSet and concealedSet are used instead */
  ${rou( 'error', 'is' )}
  ${rou( 'error', '_make' )}
  ${rou( 'error', '_sectionAdd' )}
  ${rou( 'error', '_sectionExposedAdd' )}
  ${rou( 'error', '_messageForm' )}
  ${rou( 'error', '_sectionsJoin' )}
  ${rou( 'error', '_inStr' )}
  ${rou( 'error', 'fromStr' )}
  ${rou( 'error', 'logged' )}
  ${rou( 'error', 'attend' )}
  ${rou( 'error', 'exposedSet' )}
  ${rou( 'error', 'concealedSet' )}
  ${rou( 'error', 'process' )}

  ${fields( 'error' )}

  ${rou( 'date', 'is' )}

  ${rou( 'introspector', 'code' )}
  ${rou( 'introspector', 'stack' )}
  ${rou( 'introspector', 'stackCondense' )}
  ${rou( 'introspector', 'location' )}
  ${rou( 'introspector', 'locationFromStackFrame' )}
  ${rou( 'introspector', 'locationToStack' )}
  ${rou( 'introspector', 'locationNormalize' )}

  ${rou( 'long', '_functor_functor' )}

  ${rou( 'entity', 'strType' )}
  ${rou( 'entity', 'strTypeSecondary' )}
  ${rou( 'entity', 'namespaceOf' )}
  ${rou( 'entity', 'lengthOf' )}
  ${bind( 'lengthOf', 'entity', 'lengthOf' )}
  ${bind( 'strType', 'entity', 'strType' )}
  ${rou( 'entity', 'makeUndefined' )}
  ${field( 'entity', 'TranslatedTypeMap' )}
  ${field( 'entity', 'StandardTypeSet' )}

  ${rou( 'class', 'methodIteratorOf' )}

  ${rou( 'path', 'refine' )}
  ${rou( 'path', '_normalize' )}
  ${rou( 'path', 'normalize' )}
  ${rou( 'path', 'canonize' )}
  ${rou( 'path', 'canonizeTolerant' )}
  ${rou( 'path', '_unescape' )}
  ${rou( 'path', 'unescape' )}
  ${rou( 'path', '_nativizeWindows' )}
  ${rou( 'path', '_nativizeMinimalWindows' )}
  ${rou( 'path', '_nativizePosix' )}
  ${rou( 'path', 'isGlob' )}
  ${rou( 'path', 'isRelative' )}
  ${rou( 'path', 'isAbsolute' )}
  ${rou( 'path', 'ext' )}
  ${rou( 'path', 'isGlobal' )}
  ${fields( 'path' )}

  ${rou( 'long', 'is' )}
  ${rou( 'long', 'like' )}
  ${rou( 'long', '_make' )}
  ${rou( 'long', 'make' )}
  ${rou( 'long', '_makeUndefined' )}
  ${rou( 'long', 'makeUndefined' )}
  ${rou( 'long', '_lengthOf' )}
  ${rou( 'long', 'lengthOf' )}
  ${rou( 'long', '_exportStringDiagnosticShallow' )}
  ${rou( 'long', 'exportStringDiagnosticShallow' )}
  ${bind( 'longIs', 'long', 'is' )}
  ${bind( 'longLike', 'long', 'like' )}

  /* ${rou( 'longIs' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'longLike' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'argumentsArray', 'is' )}
  ${rou( 'argumentsArray', 'like' )}
  ${bind( 'argumentsArrayIs', 'argumentsArray', 'is' )}
  /* ${rou( 'argumentsArrayIs' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'array', 'is' )}
  ${rou( 'array', 'like' )}
  ${rou( 'array', 'isEmpty' )}
  ${rou( 'array', 'likeResizable' )}
  ${rou( 'array', '_make' )}
  ${rou( 'array', 'make' )}
  ${rou( 'array', 'as' )}
  ${bind( 'arrayIs', 'array', 'is' )}
  ${bind( 'arrayLike', 'array', 'like' )}
  ${bind( 'arrayIsEmpty', 'array', 'isEmpty' )}
  ${bind( 'arrayLikeResizable', 'array', 'likeResizable' )}
  /* ${rou( 'arrayIs' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'arrayLike' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'arrayIsEmpty' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'arrayLikeResizable' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'unroll', 'is' )}
  ${rou( 'unroll', 'from' )}
  ${rou( 'unroll', '_make' )}
  ${rou( 'unroll', 'make' )}
  ${rou( 'unroll', 'normalize' )}
  ${rou( 'unroll', 'append' )}
  ${bind( 'unrollAppend', 'unroll', 'append' )}
  ${bind( 'unrollIs', 'unroll', 'is' )}
  /* ${rou( 'unrollIs' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'bufferRaw', 'is' )}
  ${bind( 'bufferRawIs', 'bufferRaw', 'is' )}
  /* ${rou( 'bufferRawIs' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'bufferTyped', 'is' )}
  ${bind( 'bufferTypedIs', 'bufferTyped', 'is' )}
  /* ${rou( 'bufferTypedIs' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'bufferNode', 'is' )}
  ${bind( 'bufferNodeIs', 'bufferNode', 'is' )}
  ${rou( 'bufferNode', 'nodeIs' )}
  /* ${rou( 'bufferNodeIs' )} */ /* Dmytro : binded, source code is not available */


  ${rou( 'buffer', 'like' )}
  ${bind( 'buffer.nodeIs', 'bufferNode', 'nodeIs' )}

  ${rou( 'vector', 'is' )}
  ${rou( 'vector', 'like' )}
  ${bind( 'vectorIs', 'vector', 'is' )}
  ${bind( 'vectorLike', 'vector', 'like' )}
  /* ${rou( 'vectorIs' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'vectorLike' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'primitive', '_is' )}
  ${rou( 'primitive', 'is' )}
  ${bind( '_primitiveIs', 'primitive', '_is' )}
  ${bind( 'primitiveIs', 'primitive', 'is' )}
  /* ${rou( '_primitiveIs' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'primitiveIs' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'number', 'is' )}
  ${rou( 'number', 'isFinite' )}
  ${rou( 'number', 'defined' )}
  ${rou( 'number', 'fromStrMaybe' )}
  ${field( 'number', 's' )}

  ${rou( 'aux', 'is' )}
  ${rou( 'aux', 'isPure' )}
  ${rou( 'aux', 'isPolluted' )}
  ${rou( 'aux', 'isPrototyped' )}
  ${rou( 'aux', 'like' )}
  ${rou( 'aux', '_make' )}
  ${rou( 'aux', 'make' )}
  ${rou( 'aux', '_makeUndefined' )}
  ${rou( 'aux', 'makeUndefined' )}
  ${rou( 'aux', '_keys' )}
  ${rou( 'aux', 'keys' )}
  ${rou( 'aux', 'namespaceOf' )}
  ${rou( 'aux', '_lengthOf' )}
  ${rou( 'aux', 'lengthOf' )}
  ${rou( 'aux', 'supplement' )}
  ${rou( 'aux', '_exportStringDiagnosticShallow' )}
  ${rou( 'aux', 'exportStringDiagnosticShallow' )}
  ${rou( 'constructible', 'is' )}
  ${rou( 'constructibleIs' )}

  ${rou( 'container', '_functor_functor' )}

  ${rou( 'object', 'is' )}
  ${rou( 'object', 'like' )}
  ${bind( 'objectLike', 'object', 'like' )}
  /* ${rou( 'objectLike' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'set', 'is' )}
  ${rou( 'set', 'like' )}
  ${bind( 'setIs', 'set', 'is' )}
  ${bind( 'setLike', 'set', 'like' )}
  /* ${rou( 'setIs' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'setLike' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'map', 'is' )}
  ${rou( 'map', 'isPure' )}
  ${rou( 'map', 'isPolluted' )}
  ${rou( 'map', 'sureHasAll' )}
  ${rou( 'map', 'sureHasOnly' )}
  ${rou( 'map', 'sureHasNoUndefine' )}
  ${rou( 'map', 'assertHasOnly' )}
  ${rou( 'map', 'assertHasNoUndefine' )}
  ${rou( 'map', 'extend' )}
  ${rou( 'map', 'supplement' )}
  ${bind( 'mapIs', 'map', 'is' )}
  ${bind( 'mapIsPure', 'map', 'isPure' )}
  ${bind( 'mapIsPolluted', 'map', 'isPolluted' )}
  ${bind( 'mapExtend', 'map', 'extend' )}
  ${bind( 'mapSupplement', 'map', 'supplement' )}
  /* ${rou( 'mapIs' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'mapExtend' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'mapSupplement' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'hashMap', 'is' )}
  ${rou( 'hashMap', 'like' )}
  ${bind( 'hashMapIs', 'hashMap', 'is' )}
  ${bind( 'hashMapLike', 'hashMap', 'like' )}
  /* ${rou( 'hashMapIs' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'hashMapLike' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'countable', 'is' )}
  ${rou( 'countable', 'like' )}
  ${bind( 'countableIs', 'countable', 'is' )}
  /* ${rou( 'countableIs' )} */

  ${rou( 'symbol', 'is' )}

  ${rou( 'routine', '_is' )}
  ${rou( 'routine', 'is' )}
  ${rou( 'routine', '_like' )}
  ${rou( 'routine', 'like' )}
  ${rou( 'routine', 'optionsWithoutUndefined' )}
  ${rou( 'routine', 'isTrivial' )}
  ${rou( 'routine', 'extend' )}
  ${rou( 'routine', '__mapButKeys' )}
  ${rou( 'routine', '__mapUndefinedKeys' )}
  ${rou( 'routine', '__mapSupplementWithoutUndefined' )}
  ${rou( 'routine', '__mapSupplementWithUndefined' )}
  ${rou( 'routine', '__keysQuote' )}
  ${rou( 'routine', '__strType' )}
  ${rou( 'routine', '__primitiveLike' )}
  ${bind( '_routineIs', 'routine', '_is' )}
  ${bind( 'routineIs', 'routine', 'is' )}
  ${bind( '_routineLike', 'routine', '_like' )}
  ${bind( 'routineLike', 'routine', 'like' )}
  ${bind( 'routineIsTrivial', 'routine', 'isTrivial' )}
  ${bind( 'routineExtend', 'routine', 'extend' )}
  /* ${rou( '_routineIs' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'routineIs' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( '_routineLike' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'routineLike' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'routineIsTrivial' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'routineExtend' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'regexp', 'is' )}
  ${rou( 'regexp', 'like' )}

  ${rou( 'props', 'is' )}
  ${rou( 'props', 'like' )}
  ${rou( 'props', '_ofAct' )}
  ${rou( 'props', 'fields' )}
  ${rou( 'props', '_keys' )}
  ${rou( 'props', 'keys' )}
  ${rou( 'props', 'own' )}
  ${rou( 'props', 'onlyOwnKeys' )}
  ${rou( 'props', '_extendWithProps' )}
  ${rou( 'props', 'extend' )}
  ${rou( 'props', '_supplementWithProps' )}
  ${rou( 'props', 'supplement' )}

  ${rou( 'strIs' )}
  ${rou( 'strDefined' )}
  ${rou( '_strBeginOf' )}
  ${rou( '_strEndOf' )}
  ${rou( '_strRemovedBegin' )}
  ${rou( '_strRemovedEnd' )}
  ${rou( 'strBegins' )}
  ${rou( 'strEnds' )}
  ${rou( 'strRemoveBegin' )}
  ${rou( 'strRemoveEnd' )}
  ${rou( 'regexpIs' )}
  ${rou( 'symbolIs' )}
  ${rou( 'strBegins' )}
  ${rou( 'object.isBasic' )}
  ${rou( 'boolLike' )}
  ${rou( 'bool', 'like' )}
  ${rou( 'boolLikeTrue' )}
  ${rou( 'bool', 'likeTrue' )}
  ${rou( 'numberIsFinite' )}
  ${rou( 'numberIs' )}
  ${rou( 'intIs' )}
  ${rou( 'sure' )}
  ${rou( 'mapBut_' )}
  ${rou( 'mapButOld' )} // xxx : remove
  ${rou( 'mapOwn' )}
  ${rou( 'mapOnly_' )}
  ${rou( '_mapBut_VerifyMapFields' )}
  ${rou( '_mapOnly_VerifyMapFields' )}
  ${rou( 'arrayAs' )}
  ${rou( 'arrayAppend' )}
  ${rou( 'arrayAppendArray' )}
  ${rou( 'arrayAppendArrays' )}
  ${rou( 'arrayAppendedArray' )}
  ${rou( 'arrayAppendedArrays' )}
  ${rou( 'arrayAppended' )}
  ${rou( 'arrayAppendOnceStrictly' )}
  ${rou( 'arrayAppendArrayOnce' )}
  ${rou( 'arrayAppendedArrayOnce' )}
  ${rou( 'arrayAppendedArraysOnce' )}
  ${rou( 'arrayAppendArraysOnce' )}
  ${rou( 'arrayAppendedOnce' )}
  ${rou( 'arrayRemoveOnceStrictly' )}
  ${rou( 'arrayRemoveElementOnceStrictly' )}
  ${rou( 'arrayRemovedElement' )}
  ${rou( 'arrayRemovedElementOnce' )}
  ${rou( 'longLeft' )}
  ${rou( 'longLeftIndex' )}
  ${rou( 'longLeftDefined' )}
  ${rou( 'longHas' )}
  ${rou( 'longGrow_' )}
  ${rou( 'vectorAdapterIs' )}
  ${rou( 'dup' )}
  ${rou( 'routine.unite' )}
  ${rou( 'routine.uniteCloning_replaceByUnite' )}
  ${rou( 'routine._amend' )}
  ${rou( 'routine._is' )}
  ${rou( 'routine.is' )}
  ${rou( 'routine.options' )}
  ${rou( 'routine.options_' )}
  ${rou( 'routine.assertOptions' )}
  ${rou( 'routine.isTrivial' )}
  ${rou( 'routine.extend' )}
  ${rou( 'routine.s.compose' )}
  ${rou( 'routine.s.are' )}
  ${rou( 'errIs' )}
  ${rou( 'regexpLike' )}
  ${rou( 'intervalIs' )}
  ${rou( 'numberDefined' )}
  ${rou( 'numbersAreAll' )}
  ${rou( 'strConcat' )}
  ${rou( 'strHas' )}
  ${rou( 'strHasAny' )}
  ${rou( 'strLinesStrip' )}
  ${rou( 'strLinesNumber' )}
  ${rou( 'strLinesSplit' )}
  ${rou( 'strLinesJoin' )}
  ${rou( 'strSplit' )}
  ${rou( 'strSplitFast' )}
  ${rou( 'strSplitsQuotedRejoin' )}
  ${rou( 'strSplitsDropDelimeters' )}
  ${rou( 'strSplitsStrip' )}
  ${rou( 'strSplitsDropEmpty' )}
  ${rou( 'strStrip' )}
  ${rou( 'strLinesSelect' )}
  ${rou( '_strLeftSingle_' )}
  ${rou( '_strRightSingle_' )}
  ${rou( 'strIsolate' )}
  ${rou( 'strIsolateLeftOrNone' )}
  ${rou( 'strIsolateRightOrNone' )}
  ${rou( 'strIsolateLeftOrAll' )}
  ${rou( 'strIsolateRightOrAll' )}
  ${rou( 'strLinesIndentation' )}
  ${rou( 'strEscape' )}
  ${rou( 'strShort_' )}
  ${rou( 'numberFromStrMaybe' )}

  ${rou( 'path', 'name' )}
  ${rou( 'path', 'fullName' )}

  ${rou( 'str', 'lines', 'split' )}



  ${rou( 'entity', '_exportStringIsVisibleElement' )}
  ${rou( 'entity', '_exportStringIsSimpleElement' )}
  ${rou( 'entity', '_exportStringFromStr' )}
  ${rou( 'entity', '_exportStringFromSymbol' )}
  ${rou( 'entity', '_exportStringFromBufferRaw' )}
  ${rou( 'entity', '_exportStringFromBufferTyped' )}
  ${rou( 'entity', '_exportStringFromBufferNode' )}
  ${rou( 'entity', '_exportStringFromArray' )}
  ${rou( 'entity', '_exportStringFromArrayFiltered' )}
  ${rou( 'entity', '_exportStringFromObject' )}
  ${rou( 'entity', '_exportStringFromObjectKeysFiltered' )}
  ${rou( 'entity', '_exportStringFromHashMap' )}
  ${rou( 'entity', '_exportStringFromSet' )}
  ${rou( 'entity', '_exportStringShortAct' )}
  ${rou( 'entity', '_exportStringFromContainer' )}
  ${rou( 'entity', '_exportStringFromNumber' )}
  ${rou( 'entity', '_exportString' )}
  ${rou( 'entity', 'exportString' )}
  ${rou( 'entity', 'namespaceForExporting' )}
  ${rou( 'entity', '_exportStringShallow' )}
  ${rou( 'entity', '_exportStringDiagnosticShallow' )}
  ${rou( 'entity', 'exportStringDiagnosticShallow' )}
  ${rou( 'entity', '_exportStringFromRoutine' )}

  ${rou( 'error', '_setupUncaughtErrorHandler2' )}
  ${rou( 'error', '_setupUncaughtErrorHandler9' )}
  ${rou( 'error', '_handleUncaughtHead' )}
  ${rou( 'error', '_handleUncaught1' )}
  ${rou( 'error', '_handleUncaughtPromise1' )}
  ${rou( 'error', '_handleUncaught2' )}

  ${rou( 'event', '_chainGenerate' )}
  ${rou( 'event', '_chainToCallback' )}
  ${rou( 'event', '_chainValidate' )}
  ${rou( 'event', '_callbackMapValidate' )}
  ${rou( 'event', 'nameValueFrom' )}
  ${rou( 'event', 'nameIs' )}
  ${rou( 'event', 'chainIs' )}
  ${rou( 'event', 'Name' )}
  ${rou( 'event', 'Chain' )}
  ${rou( 'event', '_on' )}
  ${rou( 'event', 'on' )}
  ${rou( 'event', 'onHead' )}
  ${rou( 'event', 'once' )}
  ${rou( 'event', 'off' )}
  ${rou( 'event', 'eventHasHandler' )}
  ${rou( 'event', 'eventGive' )}
  ${rou( 'event', 'eventGiveHead' )}
  ${fields( 'event' )}

  ${rou( 'each' )}

  /*
  Uri namespace( parseConsecutive ) is required to make _.include working in a browser
  */

  // parseFull maybe?

  ${rou( 'uri', 'isGlobal' )}
  ${rou( 'uri', 'parseConsecutive' )}
  ${rou( 'uri', 'refine' )}
  ${rou( 'uri', '_normalize' )}
  ${rou( 'uri', 'canonize' )}
  ${rou( 'uri', 'canonizeTolerant' )}
  ${fields( 'uri' )}

  ${rou( 'color', 'strFg' )}
  ${rou( 'color', 'strBg' )}
  ${rou( 'color', 'rgbaHtmlFrom' )}
  ${rou( 'color', 'rgbaHtmlFromTry' )}
  ${rou( 'color', 'rgbaHtmlToRgba' )}
  ${rou( 'color.rgba.fromHexStr' )}
  ${rou( 'color', 'hslaToRgba' )}
  ${rou( 'color', '_colorDistance' )}
  ${rou( 'color', '_rgbByBitmask' )}
  ${rou( 'color', '_rgbaFromNotName' )}
  ${rou( 'color', '_colorNameNearest' )}
  ${rou( 'color', 'colorNameNearest' )}
  ${rou( 'color', '_fromTable' )}
  ${rou( 'color', 'fromTable' )}
  ${rou( 'color', 'hexToColor' )}
  ${fields( 'color' )}
  ${field( 'color', 'ColorMap' )}

  ${rou( 'Logger', 'TransformCssStylingToDirectives' )}

`

  }

  /* */

  function globingExtract()
  {

    return `

  ${rou( 'array', 'likeResizable' )}
  ${bind( 'arrayLikeResizable', 'array', 'likeResizable' )}
  /* ${rou( 'arrayLikeResizable' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'map', 'extend' )}
  ${rou( 'map', 'supplement' )}
  ${bind( 'mapExtend', 'map', 'extend' )}
  ${bind( 'mapSupplement', 'map', 'supplement' )}
  /* ${rou( 'mapExtend' )} */ /* Dmytro : binded, source code is not available */
  /* ${rou( 'mapSupplement' )} */ /* Dmytro : binded, source code is not available */

  ${rou( 'vectorize' )}
  ${rou( 'strsAreAll' )}
  ${rou( 'strReplaceAll' )}
  ${rou( 'strFindAll' )}
  ${rou( 'strReverse' )}
  ${rou( 'strCount' )}
  ${rou( 'strLeft_' )}
  ${rou( 'tokensSyntaxFrom' )}
  ${rou( '_strReplaceMapPrepare' )}
  ${rou( 'map', 'assertHasAll' )}
  ${rou( 'map', 'sureHasAll' )}
  ${rou( 'longSlice' )}
  ${rou( 'regexpEscape' )}
  ${rou( 'regexpLike' )}
  ${rou( 'regexpsLikeAll' )}
  ${rou( 'filter_' )}
  ${rou( '_filter_functor' )}
  ${rou( 'entityMakeUndefined' )}
  ${rou( 'props.keys' )}

  ${rou( 'path', 'globShortFilterKeys' )}
  ${rou( 'path', 'globShortSplitsToRegexps' )}
  ${rou( 'path', '_globShortSplitToRegexpSource' )}
  ${rou( 'path', 'is' )}
  ${rou( 'path', 'name' )}
  ${rou( 'path', 'fullName' )}
  ${rou( 'path', 'detrail' )}
  ${rou( 'path', 'reroot' )}
  ${rou( 'path', 'traceToRoot' )}
`

  }

  /* */

  function rou()
  {
    return _.introspector.rou( ... arguments );
  }

  /* */

  function bind( routine, namespace, original )
  {
    return `_.${ routine } = _.${ namespace }.${ original }.bind( _.${ namespace } )`
  }

  /* */

  function fields()
  {
    return _.introspector.fields( ... arguments );
  }

  /* */

  function field()
  {
    return _.introspector.field( ... arguments );
  }

  /* */

}

sourcesJoinSplits.defaults =
{
  basePath : null,
  entryPath : null,
  outPath : null,
  libraryName : null,
  externalBeforePath : null,
  externalAfterPath : null,
  interpreter : 'njs',
  debug : 1,
  proceduring : 0,
  globing : 1,
  catchingUncaughtErrors : 1,
  loggingApplication : 0,
  loggingSourceFiles : 0,
  withServer : null,
  redirectingConsole : 1,
  loggingPath : 'ws://127.0.0.1:15000/.log/'
}

//

function sourcesJoin( o )
{
  let maker = this;

  _.routine.options_( sourcesJoin, arguments );
  maker.instanceOptions( o );

  /* */

  o.filesMap = _.container.map_( null, o.filesMap, ( fileData, filePath ) =>
  {
    return maker.sourceWrap
    ({
      filePath,
      fileData,
      basePath : o.basePath,
      removingShellPrologue : o.removingShellPrologue,
    });
  });

  /* */

  let result = _.props.vals( o.filesMap ).join( '\n' );

  let o2 = _.mapOnly_( null, o, maker.sourcesJoinSplits.defaults );
  let splits = maker.sourcesJoinSplits( o2 );

  splits.files = result;

  result = maker.sourcesSplitsJoin( splits );

  return result;
}

var defaults = sourcesJoin.defaults = Object.create( sourcesJoinSplits.defaults );

defaults.filesMap = null;
defaults.removingShellPrologue = null;

//

function sourcesSplitsJoin( o )
{
  let maker = this;

  _.routine.options_( sourcesSplitsJoin, arguments );

  for( let i in o )
  {
    _.assert( _.strIs( o[ i ] ) );
  }

  let result =
      o.prefix
    + o.predefined
    + o.early
    + o.extract
    + o.proceduring
    + o.globing
    + o.interpreter
    + o.starter
    + o.env
    + o.files
    + o.externalBefore
    + o.entry
    + o.externalAfter
    + o.postfix;

  return result;
}

var defaults = sourcesSplitsJoin.defaults =
{
  ... LibrarySplits,
}

// --
// etc
// --

function htmlSplitsFor( o )
{
  let maker = this;
  let r = Object.create( null );

  _.routine.options_( htmlSplitsFor, arguments );

  if( o.withScripts === null )
  {
    o.withScripts = 'include';
  }
  if( o.withStarter === null )
  {
    if( o.withScripts === 'single' )
    o.withStarter = false;
    else
    o.withStarter = 'include';
  }

  _.assert( _.longHas( [ 'include', 'inline', 0, false ], o.withStarter ), () => `Expects option::withStarter [ include, inline, false ], but got ${o.withStarter}` );
  _.assert( _.longHas( [ 'include', 0, false ], o.withStarter ) );
  _.assert( _.longHas( [ 'single', 'include', 'inline', 0, false ], o.withScripts ) );
  _.assert( _.longHas( [ 'single', 'include' ], o.withScripts ) );
  _.assert( o.withScripts !== 'single' || _.entity.lengthOf( o.srcScriptsMap ) <= 1, 'not implemented' );
  _.assert( o.withScripts !== 'single' || !o.withStarter, 'If option::withScripts is single then option::withStarter should be off' );

  if( o.template === null )
  o.template =
`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
</body>
</html>
`

  r = templateHandle();

  return r;

  /* */

  function templateHandle()
  {
    _.assert( _.strDefined( o.template ) );

    if( !Jsdom )
    Jsdom = require( 'jsdom' );
    if( !Pretty && maker.pretty )
    Pretty = require( 'pretty' );

    let dom = new Jsdom.JSDOM( o.template );
    let document = dom.window.document;

    if( o.title )
    {
      let title = document.head.querySelector( 'title' );
      if( !title )
      {
        title = document.createElement( 'title' );
        document.head.insertBefore( title, document.head.children[ 0 ] )
      }
      title.text = o.title;
    }

    if( o.withStarter === 'include' )
    prependScript( document, '/.starter' );

    for( let filePath in o.srcScriptsMap )
    {
      if( o.withScripts === 'include' )
      appendScript( document, filePath );
      else if( o.withScripts === 'single' )
      appendScript( document, filePath + '?withScripts:single' );
      else _.assert( 0 );
    }

    let result = dom.serialize();

    if( maker.pretty )
    result = Pretty( result );

    return result;
  }

  /* */

  function prependScript( document, filePath )
  {
    let script = document.createElement( 'script' );
    script.type = 'text/javascript';
    script.src = filePath;
    let child = document.head.querySelector( 'script' ) || document.head.children[ 0 ];
    if( child )
    document.head.insertBefore( script, child );
    else
    document.head.append( script )
  }

  /* */

  function appendScript( document, filePath )
  {
    let script = document.createElement( 'script' );
    script.type = 'text/javascript';
    script.src = filePath;
    document.head.append( script )
  }

  /* */

}

htmlSplitsFor.defaults =
{
  srcScriptsMap : null,
  template : null,
  withStarter : null,
  withScripts : null,
  title : null,
}

//

function htmlFor( o )
{
  let maker = this;
  _.routine.options_( htmlFor, arguments );
  let result = maker.htmlSplitsFor( o );
  return result;
}

htmlFor.defaults = Object.create( htmlSplitsFor.defaults );

/*

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Title</title>
  <script src="http://localhost:4444/Starter.js"></script>
  {each::<script src="{::filePath}"></script>}
</head>
<body>
  <script>
    require( '.' )
  </script>
</body>
</html>

*/

// --
// relations
// --

let InstanceDefaults =
{
  removingShellPrologue : 1,
};

let Composes =
{
  removingShellPrologue : 1,
  pretty : 1,
}

let Associates =
{
}

let Restricts =
{
}

let Statics =
{
  LibrarySplits,
  PredefinedCode : require( '../l1_boot/Predefined.txt.s' ),
  EarlyCode : require( '../l1_boot/Early.txt.s' ),
  ExtractCode : require( '../l1_boot/Extract.txt.s' ),
  ProceduringCode : require( '../l1_boot/Proceduring.txt.s' ),
  GlobingCode : require( '../l1_boot/Globing.txt.s' ),
  BroCode : require( '../l1_boot/Bro.txt.s' ),
  BroConsoleCode : require( '../l1_boot/BroConsole.txt.s' ),
  BroProcessCode : require( '../l1_boot/BroProcess.txt.s' ),
  NjsCode : require( '../l1_boot/Njs.txt.s' ),
  StarterCode : require( '../l1_boot/Starter.txt.s' ),
  InstanceDefaults,
}

// --
// prototype
// --

let Proto =
{

  instanceOptions,

  sourceWrapSplits,
  sourceWrap,

  sourceWrapSimple,
  sourceRemoveShellPrologue,

  sourcesJoinSplits,
  sourcesJoin,
  sourcesSplitsJoin,

  htmlSplitsFor,
  htmlFor,

  /* */

  Composes,
  Associates,
  Restricts,
  Statics,

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
