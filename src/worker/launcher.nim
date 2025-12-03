## Code to launch/start the worker thread
##
## Copyright (C) 2025 Trayambak Rai (xtrayambak@disroot.org)
import pkg/chronicles
import ./[core, types]

logScope:
  topics = "worker/launcher"

type LaunchedWorker* = ref object
  thread*: Thread[types.Comm]
  comm*: types.Comm

proc startWorkerThread*(): LaunchedWorker =
  info "Starting worker thread"

  debug "Initializing and opening channel"
  var comm = Comm()
  comm[].open()

  var state = LaunchedWorker()

  debug "Initializing worker thread"
  createThread(state.thread, core.workerThread, comm)
  state.comm = comm

  debug "Worker thread init done"
  ensureMove(state)
