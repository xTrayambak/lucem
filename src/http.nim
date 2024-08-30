## Reducing code clutter when making HTTP requests
import std/[logging, httpclient, monotimes]
import ./meta

proc httpGet*(url: string): string =
  debug "http: making HTTP/GET request to " & url & "; allocating HttpClient"
  let
    client = newHttpClient(userAgent = when not defined(lucemMasqueradeAsCurl): "lucem/" & Version else: "curl/8.8.0")
    startReq = getMonoTime()
    req = client.get(url)
    endReq = getMonoTime()

  debug "http: HTTP/GET request to " & url & " took " & $(endReq - startReq)

  req.body
