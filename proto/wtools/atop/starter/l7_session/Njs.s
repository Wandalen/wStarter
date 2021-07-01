( function _Njs_s_()
{

'use strict';

const _ = _global_.wTools;
const Parent = _.starter.session.Abstract;
const Self = wStarterSessioNjs;
function wStarterSessioNjs( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Njs';

// --
// routine
// --

function _unform()
{
  let session = this;
  let system = session.system;
  let ready = new _.Consequence().take( null );

  // debugger;
  if( session._process )
  {

    if( !session._process.ended && session._process.pnd )
    ready.then( () =>
    {
      if( !session._process.ended && session._process.pnd )
      {
        console.log( 'Terminating process' );
        return _.process.terminate( session._process.pnd );
      }
      return null;
    });

    ready.then( () =>
    {
      // console.log( 'Freezing' );
      // Object.freeze( session._process );
      session._process = null;
      return null;
    });

  }

  return ready;
}

//

function _form()
{
  let session = this;
  let system = session.system;
  let logger = system.logger;
  let ready = new _.Consequence().take( null );

  ready.then( () =>
  {
    session.fieldsForm();
    session.pathsForm();
    session.loggingSessionEventsForm();
    session.timerForm();

    if( session.entryPath )
    session.entryFind();
    if( session.loggingOptions ) /* qqq xxx : cover and move out to session.Abstract */
    logger.log( session.exportString() );

    session._process =
    {
      execPath : session.entryPath,
      currentPath : session.basePath,
      throwingExitCode : 1,
      applyingExitCode : 1,
      inputMirroring : 0,
      mode : 'fork',
    }
    _.process.startNjs( session._process );

    session._process.conTerminate.finally( ( err, arg ) =>
    {
      // debugger;

      // console.log( 'session._process.conTerminate' );

      session.unform();

      if( err )
      {
        // if( err.reason === 'signal' )
        // return null;
        if( !_.numberIs( session._process.exitCode ) )
        _.process.exitCode( -1 )

        throw session.errorEncounterEnd( _.errBrief( err ) );
      }
      return arg;
    });

    return session._process.conStart;
  })

  return ready;
}

// --
// relations
// --

let Composes =
{
}

let InstanceDefaults =
{
  ... Parent.prototype.InstanceDefaults,
  ... Composes,
}

let Associates =
{

  _process : null,

}

let Restricts =
{
}

let Statics =
{
}

let Events =
{
}

let Accessor =
{
}

// --
// prototype
// --

let Proto =
{

  // inter

  _unform,
  _form,

  // relations

  Composes,
  InstanceDefaults,
  Associates,
  Restricts,
  Statics,
  Events,
  Accessor,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;
_.starter.session[ Self.shortName ] = Self;

})();
