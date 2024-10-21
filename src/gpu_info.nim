## Gather information about the GPU that will be used to render Rob lock
## Copyright (C) 2024 Trayambak Rai
import std/[logging]
import nimgl/vulkan

type GPU* = string

proc getAllGPUs*(instance: VkInstance): seq[GPU] =
  debug "lucem: checking GPU devices"

  var deviceCount: uint32
  let enumRes = $vkEnumeratePhysicalDevices(instance, deviceCount.addr, nil)
  debug "lucem: vkEnumeratePhysicalDevices(): " & enumRes
  debug "lucem: found " & $deviceCount & " GPU(s) in this system that support Vulkan"

  var devices = newSeq[VkPhysicalDevice](deviceCount)
  discard vkEnumeratePhysicalDevices(instance, deviceCount.addr, devices[0].addr)

  for pDevice in devices:
    var props: VkPhysicalDeviceProperties
    vkGetPhysicalDeviceProperties(pDevice, props.addr)

    var name = newStringOfCap(VK_MAX_PHYSICAL_DEVICE_NAME_SIZE)
    for i, value in props.deviceName:
      name &= value

    debug "lucem: found GPU \"" & name & '"'

    result &= move(name)

proc deinitVulkan*(instance: VkInstance) =
  info "lucem: destroying Vulkan instance"
  vkDestroyInstance(instance, nil)

proc initVulkan*(): VkInstance =
  info "lucem: trying to initialize Vulkan..."

  if not vkInit():
    error "lucem: failed to initialize Vulkan!"
    error "lucem: this probably means that your GPU does not support Vulkan, or your drivers are too old."
    error "lucem: Sober probably won't run either."
    error "lucem: if Lucem worked fine for you prior to this, file a bug report. You can pass `--dont-check-vulkan` to bypass this check for now."
    quit(1)

  info "lucem: successfully initialized Vulkan! This GPU is ready for Sober!"
  info "lucem: initializing Vulkan instance..."

  var appInfo = newVkApplicationInfo(
    pApplicationName = "Lucem",
    pEngineName = "Lucem",
    apiVersion = vkApiVersion1_2,
    applicationVersion = vkMakeVersion(0, 1, 0),
    engineVersion = vkMakeVersion(0, 1, 0),
  )

  var instanceCreateInfo = newVkInstanceCreateInfo(
    pApplicationInfo = appInfo.addr,
    enabledLayerCount = 0,
    ppEnabledLayerNames = nil,
    enabledExtensionCount = 0,
    ppEnabledExtensionNames = nil,
  )

  if vkCreateInstance(instanceCreateInfo.addr, nil, result.addr) != VkSuccess:
    error "lucem: failed to create Vulkan instance!"
    error "lucem: this means that your system's Vulkan drivers are malfunctioning."
    error "lucem: this might not affect Sober. To check that, pass `--dont-check-vulkan` to bypass this check for now."
    quit(1)
