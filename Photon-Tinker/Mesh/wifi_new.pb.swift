// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: wifi_new.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

///*
/// WiFi security types.
///
/// Note: The values of this enum should match the values defined by the `WifiSecurity` enum in
/// the firmware.
enum Particle_Ctrl_Wifi_Security: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case noSecurity // = 0
  case wep // = 1
  case wpaPsk // = 2
  case wpa2Psk // = 3
  case wpaWpa2Psk // = 4
  case UNRECOGNIZED(Int)

  init() {
    self = .noSecurity
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .noSecurity
    case 1: self = .wep
    case 2: self = .wpaPsk
    case 3: self = .wpa2Psk
    case 4: self = .wpaWpa2Psk
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .noSecurity: return 0
    case .wep: return 1
    case .wpaPsk: return 2
    case .wpa2Psk: return 3
    case .wpaWpa2Psk: return 4
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension Particle_Ctrl_Wifi_Security: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [Particle_Ctrl_Wifi_Security] = [
    .noSecurity,
    .wep,
    .wpaPsk,
    .wpa2Psk,
    .wpaWpa2Psk,
  ]
}

#endif  // swift(>=4.2)

///*
/// Network credential types.
///
/// Note: The values of this enum should match the values defined by the `WiFiCredentials::Type` enum
/// in the firmware.
enum Particle_Ctrl_Wifi_CredentialsType: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case noCredentials // = 0
  case password // = 1
  case UNRECOGNIZED(Int)

  init() {
    self = .noCredentials
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .noCredentials
    case 1: self = .password
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .noCredentials: return 0
    case .password: return 1
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension Particle_Ctrl_Wifi_CredentialsType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [Particle_Ctrl_Wifi_CredentialsType] = [
    .noCredentials,
    .password,
  ]
}

#endif  // swift(>=4.2)

///*
/// Network credentials.
struct Particle_Ctrl_Wifi_Credentials {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var type: Particle_Ctrl_Wifi_CredentialsType = .noCredentials

  var password: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///*
/// Join a new network.
///
/// On success, the network credentials get saved to a persistent storage.
struct Particle_Ctrl_Wifi_JoinNewNetworkRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var ssid: String {
    get {return _storage._ssid}
    set {_uniqueStorage()._ssid = newValue}
  }

  var bssid: Data {
    get {return _storage._bssid}
    set {_uniqueStorage()._bssid = newValue}
  }

  var security: Particle_Ctrl_Wifi_Security {
    get {return _storage._security}
    set {_uniqueStorage()._security = newValue}
  }

  var credentials: Particle_Ctrl_Wifi_Credentials {
    get {return _storage._credentials ?? Particle_Ctrl_Wifi_Credentials()}
    set {_uniqueStorage()._credentials = newValue}
  }
  /// Returns true if `credentials` has been explicitly set.
  var hasCredentials: Bool {return _storage._credentials != nil}
  /// Clears the value of `credentials`. Subsequent reads from it will return its default value.
  mutating func clearCredentials() {_uniqueStorage()._credentials = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

struct Particle_Ctrl_Wifi_JoinNewNetworkReply {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///*
/// Join a known network.
struct Particle_Ctrl_Wifi_JoinKnownNetworkRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var ssid: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Particle_Ctrl_Wifi_JoinKnownNetworkReply {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///*
/// Get the list of known networks.
struct Particle_Ctrl_Wifi_GetKnownNetworksRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Particle_Ctrl_Wifi_GetKnownNetworksReply {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var networks: [Particle_Ctrl_Wifi_GetKnownNetworksReply.Network] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  struct Network {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    var ssid: String = String()

    var security: Particle_Ctrl_Wifi_Security = .noSecurity

    var credentialsType: Particle_Ctrl_Wifi_CredentialsType = .noCredentials

    var unknownFields = SwiftProtobuf.UnknownStorage()

    init() {}
  }

  init() {}
}

///*
/// Remove the network from the list of known networks.
struct Particle_Ctrl_Wifi_RemoveKnownNetworkRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var ssid: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Particle_Ctrl_Wifi_RemoveKnownNetworkReply {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///*
/// Remove all known networks.
struct Particle_Ctrl_Wifi_ClearKnownNetworksRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Particle_Ctrl_Wifi_ClearKnownNetworksReply {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///*
/// Get the current network.
///
/// This request gets the network which the device is currently connected to.
struct Particle_Ctrl_Wifi_GetCurrentNetworkRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Particle_Ctrl_Wifi_GetCurrentNetworkReply {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var ssid: String = String()

  var bssid: Data = SwiftProtobuf.Internal.emptyData

  var channel: Int32 = 0

  var rssi: Int32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///*
/// Scan for networks.
struct Particle_Ctrl_Wifi_ScanNetworksRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Particle_Ctrl_Wifi_ScanNetworksReply {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var networks: [Particle_Ctrl_Wifi_ScanNetworksReply.Network] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  struct Network {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    var ssid: String = String()

    var bssid: Data = SwiftProtobuf.Internal.emptyData

    var security: Particle_Ctrl_Wifi_Security = .noSecurity

    var channel: Int32 = 0

    var rssi: Int32 = 0

    var unknownFields = SwiftProtobuf.UnknownStorage()

    init() {}
  }

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "particle.ctrl.wifi"

extension Particle_Ctrl_Wifi_Security: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "NO_SECURITY"),
    1: .same(proto: "WEP"),
    2: .same(proto: "WPA_PSK"),
    3: .same(proto: "WPA2_PSK"),
    4: .same(proto: "WPA_WPA2_PSK"),
  ]
}

extension Particle_Ctrl_Wifi_CredentialsType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "NO_CREDENTIALS"),
    1: .same(proto: "PASSWORD"),
  ]
}

extension Particle_Ctrl_Wifi_Credentials: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Credentials"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "type"),
    2: .same(proto: "password"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularEnumField(value: &self.type)
      case 2: try decoder.decodeSingularStringField(value: &self.password)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.type != .noCredentials {
      try visitor.visitSingularEnumField(value: self.type, fieldNumber: 1)
    }
    if !self.password.isEmpty {
      try visitor.visitSingularStringField(value: self.password, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_Credentials, rhs: Particle_Ctrl_Wifi_Credentials) -> Bool {
    if lhs.type != rhs.type {return false}
    if lhs.password != rhs.password {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_JoinNewNetworkRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".JoinNewNetworkRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "ssid"),
    2: .same(proto: "bssid"),
    3: .same(proto: "security"),
    4: .same(proto: "credentials"),
  ]

  fileprivate class _StorageClass {
    var _ssid: String = String()
    var _bssid: Data = SwiftProtobuf.Internal.emptyData
    var _security: Particle_Ctrl_Wifi_Security = .noSecurity
    var _credentials: Particle_Ctrl_Wifi_Credentials? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _ssid = source._ssid
      _bssid = source._bssid
      _security = source._security
      _credentials = source._credentials
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1: try decoder.decodeSingularStringField(value: &_storage._ssid)
        case 2: try decoder.decodeSingularBytesField(value: &_storage._bssid)
        case 3: try decoder.decodeSingularEnumField(value: &_storage._security)
        case 4: try decoder.decodeSingularMessageField(value: &_storage._credentials)
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if !_storage._ssid.isEmpty {
        try visitor.visitSingularStringField(value: _storage._ssid, fieldNumber: 1)
      }
      if !_storage._bssid.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._bssid, fieldNumber: 2)
      }
      if _storage._security != .noSecurity {
        try visitor.visitSingularEnumField(value: _storage._security, fieldNumber: 3)
      }
      if let v = _storage._credentials {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_JoinNewNetworkRequest, rhs: Particle_Ctrl_Wifi_JoinNewNetworkRequest) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._ssid != rhs_storage._ssid {return false}
        if _storage._bssid != rhs_storage._bssid {return false}
        if _storage._security != rhs_storage._security {return false}
        if _storage._credentials != rhs_storage._credentials {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_JoinNewNetworkReply: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".JoinNewNetworkReply"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_JoinNewNetworkReply, rhs: Particle_Ctrl_Wifi_JoinNewNetworkReply) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_JoinKnownNetworkRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".JoinKnownNetworkRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "ssid"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.ssid)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.ssid.isEmpty {
      try visitor.visitSingularStringField(value: self.ssid, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_JoinKnownNetworkRequest, rhs: Particle_Ctrl_Wifi_JoinKnownNetworkRequest) -> Bool {
    if lhs.ssid != rhs.ssid {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_JoinKnownNetworkReply: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".JoinKnownNetworkReply"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_JoinKnownNetworkReply, rhs: Particle_Ctrl_Wifi_JoinKnownNetworkReply) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_GetKnownNetworksRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".GetKnownNetworksRequest"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_GetKnownNetworksRequest, rhs: Particle_Ctrl_Wifi_GetKnownNetworksRequest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_GetKnownNetworksReply: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".GetKnownNetworksReply"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "networks"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeRepeatedMessageField(value: &self.networks)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.networks.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.networks, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_GetKnownNetworksReply, rhs: Particle_Ctrl_Wifi_GetKnownNetworksReply) -> Bool {
    if lhs.networks != rhs.networks {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_GetKnownNetworksReply.Network: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = Particle_Ctrl_Wifi_GetKnownNetworksReply.protoMessageName + ".Network"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "ssid"),
    2: .same(proto: "security"),
    3: .standard(proto: "credentials_type"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.ssid)
      case 2: try decoder.decodeSingularEnumField(value: &self.security)
      case 3: try decoder.decodeSingularEnumField(value: &self.credentialsType)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.ssid.isEmpty {
      try visitor.visitSingularStringField(value: self.ssid, fieldNumber: 1)
    }
    if self.security != .noSecurity {
      try visitor.visitSingularEnumField(value: self.security, fieldNumber: 2)
    }
    if self.credentialsType != .noCredentials {
      try visitor.visitSingularEnumField(value: self.credentialsType, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_GetKnownNetworksReply.Network, rhs: Particle_Ctrl_Wifi_GetKnownNetworksReply.Network) -> Bool {
    if lhs.ssid != rhs.ssid {return false}
    if lhs.security != rhs.security {return false}
    if lhs.credentialsType != rhs.credentialsType {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_RemoveKnownNetworkRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".RemoveKnownNetworkRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "ssid"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.ssid)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.ssid.isEmpty {
      try visitor.visitSingularStringField(value: self.ssid, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_RemoveKnownNetworkRequest, rhs: Particle_Ctrl_Wifi_RemoveKnownNetworkRequest) -> Bool {
    if lhs.ssid != rhs.ssid {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_RemoveKnownNetworkReply: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".RemoveKnownNetworkReply"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_RemoveKnownNetworkReply, rhs: Particle_Ctrl_Wifi_RemoveKnownNetworkReply) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_ClearKnownNetworksRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ClearKnownNetworksRequest"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_ClearKnownNetworksRequest, rhs: Particle_Ctrl_Wifi_ClearKnownNetworksRequest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_ClearKnownNetworksReply: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ClearKnownNetworksReply"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_ClearKnownNetworksReply, rhs: Particle_Ctrl_Wifi_ClearKnownNetworksReply) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_GetCurrentNetworkRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".GetCurrentNetworkRequest"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_GetCurrentNetworkRequest, rhs: Particle_Ctrl_Wifi_GetCurrentNetworkRequest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_GetCurrentNetworkReply: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".GetCurrentNetworkReply"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "ssid"),
    2: .same(proto: "bssid"),
    3: .same(proto: "channel"),
    4: .same(proto: "rssi"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.ssid)
      case 2: try decoder.decodeSingularBytesField(value: &self.bssid)
      case 3: try decoder.decodeSingularInt32Field(value: &self.channel)
      case 4: try decoder.decodeSingularInt32Field(value: &self.rssi)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.ssid.isEmpty {
      try visitor.visitSingularStringField(value: self.ssid, fieldNumber: 1)
    }
    if !self.bssid.isEmpty {
      try visitor.visitSingularBytesField(value: self.bssid, fieldNumber: 2)
    }
    if self.channel != 0 {
      try visitor.visitSingularInt32Field(value: self.channel, fieldNumber: 3)
    }
    if self.rssi != 0 {
      try visitor.visitSingularInt32Field(value: self.rssi, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_GetCurrentNetworkReply, rhs: Particle_Ctrl_Wifi_GetCurrentNetworkReply) -> Bool {
    if lhs.ssid != rhs.ssid {return false}
    if lhs.bssid != rhs.bssid {return false}
    if lhs.channel != rhs.channel {return false}
    if lhs.rssi != rhs.rssi {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_ScanNetworksRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ScanNetworksRequest"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_ScanNetworksRequest, rhs: Particle_Ctrl_Wifi_ScanNetworksRequest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_ScanNetworksReply: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ScanNetworksReply"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "networks"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeRepeatedMessageField(value: &self.networks)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.networks.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.networks, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_ScanNetworksReply, rhs: Particle_Ctrl_Wifi_ScanNetworksReply) -> Bool {
    if lhs.networks != rhs.networks {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Particle_Ctrl_Wifi_ScanNetworksReply.Network: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = Particle_Ctrl_Wifi_ScanNetworksReply.protoMessageName + ".Network"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "ssid"),
    2: .same(proto: "bssid"),
    3: .same(proto: "security"),
    4: .same(proto: "channel"),
    5: .same(proto: "rssi"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.ssid)
      case 2: try decoder.decodeSingularBytesField(value: &self.bssid)
      case 3: try decoder.decodeSingularEnumField(value: &self.security)
      case 4: try decoder.decodeSingularInt32Field(value: &self.channel)
      case 5: try decoder.decodeSingularInt32Field(value: &self.rssi)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.ssid.isEmpty {
      try visitor.visitSingularStringField(value: self.ssid, fieldNumber: 1)
    }
    if !self.bssid.isEmpty {
      try visitor.visitSingularBytesField(value: self.bssid, fieldNumber: 2)
    }
    if self.security != .noSecurity {
      try visitor.visitSingularEnumField(value: self.security, fieldNumber: 3)
    }
    if self.channel != 0 {
      try visitor.visitSingularInt32Field(value: self.channel, fieldNumber: 4)
    }
    if self.rssi != 0 {
      try visitor.visitSingularInt32Field(value: self.rssi, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Particle_Ctrl_Wifi_ScanNetworksReply.Network, rhs: Particle_Ctrl_Wifi_ScanNetworksReply.Network) -> Bool {
    if lhs.ssid != rhs.ssid {return false}
    if lhs.bssid != rhs.bssid {return false}
    if lhs.security != rhs.security {return false}
    if lhs.channel != rhs.channel {return false}
    if lhs.rssi != rhs.rssi {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
