( function _Cui_s_( )
{

'use strict';

//

const _ = _global_.wTools;
const Parent = null;
const Self = wStarterCui;
function wStarterCui( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Cui';

// --
// inter
// --

function init( o )
{
  let cui = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  _.workpiece.initFields( cui );
  Object.preventExtensions( cui );

  if( o )
  cui.copy( o );

  if( cui.starter === null )
  cui.starter = new _.starter.System();

}

//

function Exec()
{
  let cui = new this.Self();
  return cui.exec();
}

//

function exec()
{
  let cui = this;
  let starter = cui.starter;

  if( !starter.formed )
  starter.form();

  _.assert( _.instanceIs( starter ) );
  _.assert( arguments.length === 0 );

  let logger = starter.logger;
  let fileProvider = starter.fileProvider;
  let appArgs = _.process.input();
  let aggregator = cui._commandsMake();

  return _.Consequence
  .Try( () =>
  {
    return aggregator.programPerform({ program : appArgs.original });
    // return aggregator.appArgsPerform({ appArgs });
  })
  .catch( ( err ) =>
  {
    _.process.exitCode( -1 );
    logger.error( _.errOnce( err ) );
    _.procedure.terminationBegin();
    _.process.exit();
    return err;
  });
}

// --
// commands
// --

function _commandsMake()
{
  let cui = this;
  let starter = cui.starter;
  let logger = starter.logger;
  let fileProvider = starter.fileProvider;
  let appArgs = _.process.input();

  _.assert( _.instanceIs( cui ) );
  _.assert( _.instanceIs( starter ) );
  _.assert( arguments.length === 0 );

  let commands =
  {
    'help' :              { ro : _.routineJoin( cui, cui.commandHelp ) },
    'version' :           { ro : _.routineJoin( cui, cui.commandVersion ) },
    'imply' :             { ro : _.routineJoin( cui, cui.commandImply ) }, /* qqq : remove. ask how */
    'html for' :          { ro : _.routineJoin( cui, cui.commandHtmlFor ) },
    'sources join' :      { ro : _.routineJoin( cui, cui.commandSourcesJoin ) },
    'http open' :         { ro : _.routineJoin( cui, cui.commandHttpOpen ) },
    'start' :             { ro : _.routineJoin( cui, cui.commandStart ) }
  }

  let aggregator = _.CommandsAggregator
  ({
    basePath : fileProvider.path.current(),
    commands,
    commandPrefix : 'node ',
  })

  aggregator.form();

  return aggregator;
}

//

function commandHelp( e )
{
  let cui = this;
  let starter = cui.starter;
  let aggregator = e.aggregator;
  let fileProvider = starter.fileProvider;
  let logger = starter.logger;

  aggregator._commandHelp( e );

  return cui;
}

var command = commandHelp.command = Object.create( null );
command.hint = 'Get help.';

//

function commandVersion( e )
{
  let cui = this;
  return _.npm.versionLog
  ({
    localPath : _.path.join( __dirname, '../../../../..' ),
    remotePath : 'wstarter',
    tags : [ 'alpha' ],
  });
}

var command = commandVersion.command = Object.create( null );
command.hint = 'Get information about version.';

// function commandVersion( e ) /* xxx qqq : move to NpmTools */
// {
//   let cui = this;
//   let starter = cui.starter;
//
//   starter.form();
//
//   let fileProvider = starter.fileProvider;
//   let path = starter.fileProvider.path;
//   let logger = starter.logger;
//
//   let packageJsonPath = path.join( __dirname, '../../../../../package.json' );
//   let packageJson =  fileProvider.fileRead({ filePath : packageJsonPath, encoding : 'json', throwing : 0 });
//
//   return _.process.start
//   ({
//     execPath : 'npm view wstarter@latest version',
//     outputCollecting : 1,
//     outputPiping : 0,
//     inputMirroring : 0,
//     throwingExitCode : 0,
//   })
//   .then( ( got ) =>
//   {
//     let current = packageJson ? packageJson.version : 'unknown';
//     let latest = _.strStrip( got.output );
//
//     if( got.exitCode || !latest )
//     latest = 'unknown'
//
//     logger.log( 'Current version:', current );
//     logger.log( 'Available version:', latest );
//
//     return null;
//   })
//
// }
//
// var command = commandVersion.command = Object.create( null );
// command.hint = 'Get information about version.';

//

function commandImply( e )
{
  let cui = this;
  let starter = cui.starter;

  let aggregator = e.aggregator;
  let logger = starter.logger;

  let namesMap =
  {
    v : 'verbosity',
    verbosity : 'verbosity',
  }

  let request = _.strRequestParse( e.instructionArgument );

  _.process.inputReadTo
  ({
    dst : starter,
    propertiesMap : request.map,
    namesMap
  });

}

var command = commandImply.command = Object.create( null );
command.hint = 'Change state or imply value of a variable.';

//

function commandHtmlFor( e )
{
  let cui = this;
  let starter = cui.starter;

  starter.form();

  let aggregator = e.aggregator;
  let fileProvider = starter.fileProvider;
  let path = starter.fileProvider.path;
  let logger = starter.logger;
  let request = _.strRequestParse( e.instructionArgument );

  logger.log( e.propertiesMap )

  request.subject = _.strStructureParse
  ({
    src : request.subject,
    parsingArrays : 1,
    defaultStructure : 'string',
  })

  let o2 = _.props.extend( null, e.propertiesMap );
  o2.inPath = o2.inPath || request.subject;

  let html = starter.htmlForFiles( o2 );

  if( starter.verbosity > 3 )
  logger.log( html );

  if( starter.verbosity )
  logger.log( ' + html saved to ' + _.color.strFormat( o2.outPath, 'path' ) )

  return null;
}

var command = commandHtmlFor.command = Object.create( null );
command.hint = 'Generate HTML for specified files.';
command.properties =
{
  inPath : 'Path to files to include into HTML file to generate.',
  outPath : 'Path to save generated HTML file.',
}

//

function commandSourcesJoin( e )
{
  let cui = this;
  let starter = cui.starter;

  starter.form();

  let aggregator = e.aggregator;
  let fileProvider = starter.fileProvider;
  let path = starter.fileProvider.path;
  let logger = starter.logger;
  let request = _.strRequestParse( e.instructionArgument );

  let o2 = _.props.extend( null, e.propertiesMap );
  o2.inPath = o2.inPath || request.subject;

  if( !o2.inPath )
  throw _.errBriefly
  (
    'Please specify where to look for source file.\nFor example: '
    + _.color.strFormat( 'starter .files.wrap ./proto', 'code' )
  );

  let r = starter.sourcesJoinFiles( o2 );

  if( starter.verbosity )
  logger.log( ' + sourcesJoin to ' + _.color.strFormat( o2.outPath, 'path' ) )

  return r;
}

var command = commandSourcesJoin.command = Object.create( null );
command.hint = 'Join source files found at specified directory.';
command.properties =
{
  inPath : 'Path to files to use for merging and wrapping.',
  outPath : 'Path to save merged file.',
}

//

function commandHttpOpen( e )
{
  let cui = this;
  let starter = cui.starter;

  starter.form();

  let aggregator = e.aggregator;
  let fileProvider = starter.fileProvider;
  let path = starter.fileProvider.path;
  let logger = starter.logger;
  let request = _.strRequestParse({ src : e.instructionArgument, severalValues : 1 });

  let o2 = _.props.extend( null, e.propertiesMap );
  o2.basePath = o2.basePath || request.subject;

  /* xxx qqq : write option-less test routine */

  if( request.subject && request.subject !== o2.basePath )
  throw _.errBrief
  (
    'Subject if specified should be option::basePath, but option::basePath specified too!'
  );

  if( !o2.basePath )
  o2.basePath = '.';

  if( !o2.basePath )
  throw _.errBrief
  (
    'Please specify what directory to serve.\nFor example: '
    + _.color.strFormat( 'starter .http.open ./proto', 'code' )
  );

  starter.httpOpen( o2 );

  return null;
}

var command = commandHttpOpen.command = Object.create( null );
command.hint = 'Run HTTP server to serve files in a specified directory.';
command.properties =
{
  basePath : 'Path to make available over HTTP.',
  allowedPath : 'Restrict access of client-side to files in specified directory. Default : same as basePath.',
  templatePath : 'Path to HTML file to use as a template.',
  format : 'Explicitly specified format of entry file. Could be: js / html.',
  withModule : 'Specify one or several modules to include extending basePath. If basePath is specified explicitly then option::withModule has no effect.',
  withNpm : 'Include npm paths into the list of allowed paths and enable npm packages to be available. Default : true',
  loggingApplication : 'Enable printing of application output. Default : false.',
  loggingRequestsAll : 'Enable logging of request to the server. Default : true.',
  loggingRequests : 'Enable printing requests to the servlet. Default : false.',
  loggingSessionEvents : 'Enable logging of events of session. Default : false.',
  loggingOptions : 'Enable logging of options of session. Default : false.',
  loggingSourceFiles : 'Enable logging of constructing source files. Default : false',
  loggingPathTranslations : 'Enable logging of path translations. Default : false',
  proceduring : 'Watching asynchronous procedures to terminate the application when all will run out. Default : true.',
  catchingUncaughtErrors : 'Catching uncaught errors and handling them properly. Default : true.',
  naking : 'Disable wrapping of scripts. Default : false.',
  withScripts : 'How to ship scripts. Alternatives : [ include, inline, single, 0 ]. Default : include.',
  withStarter : 'Run-time environment. Alternatives : [ include, inline, 0 ]. Default : include.',
  interpreter : 'Interpreter to use. Alternatives [ browser, njs ]. Default : browser'
}

//

function commandStart( e )
{
  let cui = this;
  let starter = cui.starter;

  starter.form();

  let aggregator = e.aggregator;
  let logger = starter.logger;
  let request = _.strRequestParse({ src : e.instructionArgument, severalValues : 1 });

  let o2 = _.props.extend( null, e.propertiesMap );
  o2.entryPath = o2.entryPath || request.subject;

  if( request.subject && request.subject !== o2.entryPath )
  throw _.errBrief
  (
    'Subject if specified should be option::entryPath, but option::entryPath specified too!'
  );

  if( !o2.entryPath )
  throw _.errBriefly
  (
    'Please specify where to look for source file.\nFor example: '
    + _.color.strFormat( 'starter .start Index.js', 'code' )
  );

  starter.start( o2 );

  return null;
}

var command = commandStart.command = Object.create( null );
command.hint = 'Run executable file. By default in browser.';
command.properties =
{
  ... commandHttpOpen.command.properties,
  loggingApplication : 'Enable printing of application output. Default : true',
  loggingRequestsAll : 'Enable logging of request to the server. Default : false',
  loggingConnectionAttemtps : 'Enable logging of connection attempts to chrome instance. Default : false',
  curating : 'Automatic opening of the application in curated window. Default : true',
  headless : 'Headless mode. Default : false',
}

// --
// relations
// --

let Composes =
{
}

let Aggregates =
{
}

let Associates =
{
  starter : null,
}

let Restricts =
{
}

let Statics =
{
  Exec,
}

let Forbids =
{
}

// --
// declare
// --

let Extension =
{

  // inter

  init,
  Exec,
  exec,

  // commands

  _commandsMake,
  commandHelp,
  commandVersion,

  commandImply,
  commandHtmlFor,
  commandSourcesJoin,
  commandHttpOpen,
  commandStart,

  // relations

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
  Forbids,

}

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extension,
});

_.Copyable.mixin( Self );

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;
_.starter[ Self.shortName ] = Self;

if( !module.parent )
Self.Exec();

})();
