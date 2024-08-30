## Roblox games/places ("experiences") API
## Copyright (C) 2024 Trayambak Rai
import std/[logging, strutils, json]
import ../[cache_calls, http, sugar]
import jsony

type
  PlaceID* = int64
  CreatorID* = int64
  UniverseID* = int64

  Creator* = object
    id*: CreatorID
    name*: string
    `type`*: string
    isRNVAccount*: bool
    hasVerifiedBadge*: bool

  AvatarType* = enum
    MorphToR6 = "MorphToR6"
    PlayerChoice = "PlayerChoice"
    MorphToR15 = "MorphToR15"
  
  StubData*[T] = object
    data*: seq[T]

  GameDetail* = object
    id*, rootPlaceId*: PlaceID
    name*, description*, sourceName*, sourceDescription*: string
    creator*: Creator
    price*: Option[int64]
    allowedGearGenres*: seq[string]
    allowedGearCategories*: seq[string]
    isGenreEnforced*, copyingAllowed*: bool
    playing*, visits*: int64
    maxPlayers*: int32
    created*, updated*: string
    studioAccessToApisAllowed*, createVipServersAllowed*: bool
    avatarType*: AvatarType
    genre*: string
    isAllGenre*, isFavoritedByUser*: bool
    favoritedCount*: int64

  PlaceDetail* = object
    id*: PlaceID
    name*, description*, sourceName*, sourceDescription*, url*, builder*: string
    builderId*: CreatorID
    hasVerifiedBadge*, isPlayable*: bool
    reasonProhibited*: string
    universeId*: UniverseID
    universeRootPlaceId*: PlaceID
    price*: Option[int64]
    imageToken*: string

proc getUniverseFromPlace*(placeId: string): UniverseID {.inline.} =
  httpGet("https://apis.roblox.com/universes/v1/places/$1/universe" % [placeId]).parseJson()["universeId"].getInt().UniverseID()

proc getGameDetail*(id: UniverseID): Option[GameDetail] =
  if (let cached = findCacheSingleParam[GameDetail]("roblox.getGameDetail", $id, 2); *cached):
    return cached

  let
    url = "https://games.roblox.com/v1/games/?universeIds=" & $id
    resp = httpGet(url)
  
  info "getGameDetail($1): $2" % [$id, resp]
  let payload = fromJson(resp, StubData[GameDetail]).data[0]
  cacheSingleParam("roblox.getGameDetail", $id, payload)

  payload.some()
