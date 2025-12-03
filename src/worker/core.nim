## Core worker thread logic
##
## Copyright (C) 2025 Trayambak Rai (xtrayambak@disroot.org)
import ./types
import pkg/[curly, chronicles]

logScope:
  topics = "worker/thread"

proc fetchPatchIndexImpl() =
  discard

proc workerThread*(comm: Comm) {.thread.} =
  info "Worker thread has started"

  while true:
    let op = comm[].recv()

    debug "Received operation command", op = op

    case op
    of WorkerOp.FetchPatchIndex:
      fetchPatchIndexImpl()
    of WorkerOp.Exit:
      break
