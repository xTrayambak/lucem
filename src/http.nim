## Reducing code clutter when making HTTP requests
import std/[logging, monotimes]
import pkg/[curly, webby]
import ./meta

{.passC: gorge("pkg-config --cflags libcurl").}
{.passL: gorge("pkg-config --libs libcurl").}

var curl = newCurly()
proc httpGet*(url: string): string =
  debug "http: making HTTP/GET request to " & url & "; allocating HttpClient"
  let
    headers = toWebby(@[
      ("User-Agent", "lucem/" & Version)
    ])
    startReq = getMonoTime()
    req = curl.get(url, headers)
    endReq = getMonoTime()

  debug "http: HTTP/GET request to " & url & " took " & $(endReq - startReq)
  debug "http: response body:\n" & req.body

  req.body
