module XClarityClient
  class Switch
    include XClarityClient::Resource

    BASE_URI = '/switches'.freeze
    LIST_NAME = 'switchList'.freeze

    attr_accessor :properties, :_id, :accessState, :applyPending, :attachedNodes, :cmmDisplayName, :cmmHealthState, :entitleSerialNumber, :fans, :firmware, :hostname, :ipInterfaces,
    :leds, :macAddresses, :machineType, :manufacturer, :manufacturerId, :ports, :productId, :productName, :protectedMode, :serialNumber, :type, :upTime, :uuid, :accessState,
    :cmmHealthState, :excludedHealthState, :memoryUtilization, :model, :overallHealthState, :panicDump, :powerState, :savePending, :slots, :posID, :stackMode, :stackedMode,
    :stackRole, :sysObjectID, :temperatureSensors, :userDescription, :vpdID, :contact, :cpuUtilization, :dataHandle, :description, :dnsHostnames, :domainName, :errorFields,
    :FRU, :fruSerialNumber, :ipv4Addresses, :ipv6Addresses, :ipInterfaces, :manufacturingDate, :name, :resetReason, :uri, :backedBy, :partNumber, :parent, :powerAllocation


    def initialize(attributes)
      build_resource(attributes)
    end

  end
end
