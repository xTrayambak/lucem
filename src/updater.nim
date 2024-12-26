## Lucem auto-updater
## Copyright (C) 2024 Trayambak Rai
import std/[logging]
import pkg/[semver, jsony]
import ./[http, argparser, config, sugar, meta, notifications]

type
  ReleaseAuthor* = object
    login*: string
    id*: uint32
    node_id*, avatar_url*, gravatar_id*, url*, html_url*, followers_url*, following_url*, gists_url*, starred_url*, subscriptions_url*, organizations_url*, repos_url*, events_url*, received_events_url*, `type`*, user_view_type*: string
    site_admin*: bool

  LucemRelease* = object
    url*, assets_url*, upload_url*, html_url*: string
    id*: uint64
    author*: ReleaseAuthor
    node_id*, tag_name*, target_commitish*, name*: string
    draft*, prerelease*: bool
    created_at*, published_at*: string
    assets*: seq[string]
    tarball_url*, zipball_url*: string

const
  LucemReleaseUrl {.strdefine.} = "https://api.github.com/repos/xTrayambak/lucem/releases/latest"

proc getLatestRelease*(): Option[LucemRelease] {.inline.} =
  debug "lucem: auto-updater: fetching latest release"
  try:
    return httpGet(
      LucemReleaseUrl
    ).fromJson(
      LucemRelease
    ).some()
  except JsonError as exc:
    warn "lucem: auto-updater: cannot parse release data: " & exc.msg
  except CatchableError as exc:
    warn "lucem: auto-updater: cannot get latest release: " & exc.msg & " (" & $exc.name & ')'

proc runUpdateChecker*(config: Config) =
  if not config.lucem.autoUpdater:
    debug "lucem: auto-updater: skipping update checks as auto-updater is disabled in config"
    return

  when defined(lucemDisableAutoUpdater):
    debug "lucem: auto-updater: skipping update checks as auto-updater is disabled by a compile-time flag (--define:lucemDisableAutoUpdater)"
    return

  debug "lucem: auto-updater: running update checks"
  let release = getLatestRelease()

  if !release:
    warn "lucem: auto-updater: cannot get release, skipping checks."
    return

  let data = &release
  let newVersion = try:
    parseVersion(data.tagName).some()
  except semver.ParseError as exc:
    warn "lucem: auto-updater: cannot parse new semver: " & exc.msg & " (" & data.tagName & ')'
    none(Version)

  if !newVersion:
    return

  let currVersion = parseVersion(meta.Version)

  debug "lucem: auto-updater: new version: " & $(&newVersion)
  debug "lucem: auto-updater: current version: " & $currVersion

  let newVer = &newVersion

  if newVer > currVersion:
    info "lucem: found a new release! (" & $newVer & ')'
    presentUpdateAlert(
      "Lucem " & $newVer & " is out!",
      "A new version of Lucem is out. You are strongly advised to update to this release for bug fixes and other improvements."
    )
  elif newVer == currVersion:
    debug "lucem: user is on the latest version of lucem"
  elif newVer < currVersion:
    warn "lucem: version mismatch (newest release: " & $newVer & ", version this binary was tagged as: " & $currVersion & ')'
    warn "lucem: are you using a development version? :P"
