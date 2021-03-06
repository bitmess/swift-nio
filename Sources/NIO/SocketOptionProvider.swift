//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2017-2018 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

/// This protocol defines an object, most commonly a `Channel`, that supports
/// setting and getting socket options (via `setsockopt`/`getsockopt` or similar).
/// It provides a strongly typed API that makes working with larger, less-common
/// socket options easier than the `ChannelOption` API allows.
///
/// The API is divided into two portions. For socket options that NIO has prior
/// knowledge about, the API has strongly and safely typed APIs that only allow
/// users to use the exact correct type for the socket option. This will ensure
/// that the API is safe to use, and these are encouraged where possible.
///
/// These safe APIs are built on top of an "unsafe" API that is also exposed to
/// users as part of this protocol. The "unsafe" API is unsafe in the same way
/// that `UnsafePointer` is: incorrect use of the API allows all kinds of
/// memory-unsafe behaviour. This API is necessary for socket options that NIO
/// does not have prior knowledge of, but wherever possible users are discouraged
/// from using it.
///
/// ### Relationship to SocketOption
///
/// All `Channel` objects that implement this protocol should also support the
/// `SocketOption` `ChannelOption` for simple socket options (those with C `int`
/// values). These are the most common socket option types, and so this `ChannelOption`
/// represents a convenient shorthand for using this protocol where the type allows,
/// as well as avoiding the need to cast to this protocol.
///
/// - note: Like the `Channel` protocol, all methods in this protocol are
///     thread-safe.
public protocol SocketOptionProvider {
    /// The `EventLoop` which is used by this `SocketOptionProvider` for execution.
    var eventLoop: EventLoop { get }

    /// Set a socket option for a given level and name to the specified value.
    ///
    /// This function is not memory-safe: if you set the generic type parameter incorrectly,
    /// this function will still execute, and this can cause you to incorrectly interpret memory
    /// and thereby read uninitialized or invalid memory. If at all possible, please use one of
    /// the safe functions defined by this protocol.
    ///
    /// - parameters:
    ///     - level: The socket option level, e.g. `SOL_SOCKET` or `IPPROTO_IP`.
    ///     - name: The name of the socket option, e.g. `SO_REUSEADDR`.
    ///     - value: The value to set the socket option to.
    /// - returns: An `EventLoopFuture` that fires when the option has been set,
    ///     or if an error has occurred.
    func unsafeSetSocketOption<Value>(level: SocketOptionLevel, name: SocketOptionName, value: Value) -> EventLoopFuture<Void>

    /// Obtain the value of the socket option for the given level and name.
    ///
    /// This function is not memory-safe: if you set the generic type parameter incorrectly,
    /// this function will still execute, and this can cause you to incorrectly interpret memory
    /// and thereby read uninitialized or invalid memory. If at all possible, please use one of
    /// the safe functions defined by this protocol.
    ///
    /// - parameters:
    ///     - level: The socket option level, e.g. `SOL_SOCKET` or `IPPROTO_IP`.
    ///     - name: The name of the socket option, e.g. `SO_REUSEADDR`.
    /// - returns: An `EventLoopFuture` containing the value of the socket option, or
    ///     any error that occurred while retrieving the socket option.
    func unsafeGetSocketOption<Value>(level: SocketOptionLevel, name: SocketOptionName) -> EventLoopFuture<Value>
}


// MARK:- Safe helper methods.
// Hello code reader! All the methods in this extension are "safe" wrapper methods that define the correct
// types for `setSocketOption` and `getSocketOption` and call those methods on behalf of the user. These
// wrapper methods are memory safe. All of these methods are basically identical, and have been copy-pasted
// around. As a result, if you change one, you should probably change them all.
//
// You are welcome to add more helper methods here, but each helper method you add must be tested.
public extension SocketOptionProvider {
    /// Sets the socket option SO_LINGER to `value`.
    ///
    /// - parameters:
    ///     - value: The value to set SO_LINGER to.
    /// - returns: An `EventLoopFuture` that fires when the option has been set,
    ///     or if an error has occurred.
    func setSoLinger(_ value: linger) -> EventLoopFuture<Void> {
        return self.unsafeSetSocketOption(level: SocketOptionLevel(SOL_SOCKET), name: SO_LINGER, value: value)
    }

    /// Gets the value of the socket option SO_LINGER.
    ///
    /// - returns: An `EventLoopFuture` containing the value of the socket option, or
    ///     any error that occurred while retrieving the socket option.
    func getSoLinger() -> EventLoopFuture<linger> {
        return self.unsafeGetSocketOption(level: SocketOptionLevel(SOL_SOCKET), name: SO_LINGER)
    }

    /// Sets the socket option IP_MULTICAST_IF to `value`.
    ///
    /// - parameters:
    ///     - value: The value to set IP_MULTICAST_IF to.
    /// - returns: An `EventLoopFuture` that fires when the option has been set,
    ///     or if an error has occurred.
    func setIPMulticastIF(_ value: in_addr) -> EventLoopFuture<Void> {
        return self.unsafeSetSocketOption(level: IPPROTO_IP, name: IP_MULTICAST_IF, value: value)
    }

    /// Gets the value of the socket option IP_MULTICAST_IF.
    ///
    /// - returns: An `EventLoopFuture` containing the value of the socket option, or
    ///     any error that occurred while retrieving the socket option.
    func getIPMulticastIF() -> EventLoopFuture<in_addr> {
        return self.unsafeGetSocketOption(level: IPPROTO_IP, name: IP_MULTICAST_IF)
    }

    /// Sets the socket option IP_MULTICAST_TTL to `value`.
    ///
    /// - parameters:
    ///     - value: The value to set IP_MULTICAST_TTL to.
    /// - returns: An `EventLoopFuture` that fires when the option has been set,
    ///     or if an error has occurred.
    func setIPMulticastTTL(_ value: CUnsignedChar) -> EventLoopFuture<Void> {
        return self.unsafeSetSocketOption(level: IPPROTO_IP, name: IP_MULTICAST_TTL, value: value)
    }

    /// Gets the value of the socket option IP_MULTICAST_TTL.
    ///
    /// - returns: An `EventLoopFuture` containing the value of the socket option, or
    ///     any error that occurred while retrieving the socket option.
    func getIPMulticastTTL() -> EventLoopFuture<CUnsignedChar> {
        return self.unsafeGetSocketOption(level: IPPROTO_IP, name: IP_MULTICAST_TTL)
    }

    /// Sets the socket option IP_MULTICAST_LOOP to `value`.
    ///
    /// - parameters:
    ///     - value: The value to set IP_MULTICAST_LOOP to.
    /// - returns: An `EventLoopFuture` that fires when the option has been set,
    ///     or if an error has occurred.
    func setIPMulticastLoop(_ value: CUnsignedChar) -> EventLoopFuture<Void> {
        return self.unsafeSetSocketOption(level: IPPROTO_IP, name: IP_MULTICAST_LOOP, value: value)
    }

    /// Gets the value of the socket option IP_MULTICAST_LOOP.
    ///
    /// - returns: An `EventLoopFuture` containing the value of the socket option, or
    ///     any error that occurred while retrieving the socket option.
    func getIPMulticastLoop() -> EventLoopFuture<CUnsignedChar> {
        return self.unsafeGetSocketOption(level: IPPROTO_IP, name: IP_MULTICAST_LOOP)
    }

    /// Sets the socket option IPV6_MULTICAST_IF to `value`.
    ///
    /// - parameters:
    ///     - value: The value to set IPV6_MULTICAST_IF to.
    /// - returns: An `EventLoopFuture` that fires when the option has been set,
    ///     or if an error has occurred.
    func setIPv6MulticastIF(_ value: CUnsignedInt) -> EventLoopFuture<Void> {
        return self.unsafeSetSocketOption(level: IPPROTO_IPV6, name: IPV6_MULTICAST_IF, value: value)
    }

    /// Gets the value of the socket option IPV6_MULTICAST_IF.
    ///
    /// - returns: An `EventLoopFuture` containing the value of the socket option, or
    ///     any error that occurred while retrieving the socket option.
    func getIPv6MulticastIF() -> EventLoopFuture<CUnsignedInt> {
        return self.unsafeGetSocketOption(level: IPPROTO_IPV6, name: IPV6_MULTICAST_IF)
    }

    /// Sets the socket option IPV6_MULTICAST_HOPS to `value`.
    ///
    /// - parameters:
    ///     - value: The value to set IPV6_MULTICAST_HOPS to.
    /// - returns: An `EventLoopFuture` that fires when the option has been set,
    ///     or if an error has occurred.
    func setIPv6MulticastHops(_ value: CInt) -> EventLoopFuture<Void> {
        return self.unsafeSetSocketOption(level: IPPROTO_IPV6, name: IPV6_MULTICAST_HOPS, value: value)
    }

    /// Gets the value of the socket option IPV6_MULTICAST_HOPS.
    ///
    /// - returns: An `EventLoopFuture` containing the value of the socket option, or
    ///     any error that occurred while retrieving the socket option.
    func getIPv6MulticastHops() -> EventLoopFuture<CInt> {
        return self.unsafeGetSocketOption(level: IPPROTO_IPV6, name: IPV6_MULTICAST_HOPS)
    }

    /// Sets the socket option IPV6_MULTICAST_LOOP to `value`.
    ///
    /// - parameters:
    ///     - value: The value to set IPV6_MULTICAST_LOOP to.
    /// - returns: An `EventLoopFuture` that fires when the option has been set,
    ///     or if an error has occurred.
    func setIPv6MulticastLoop(_ value: CUnsignedInt) -> EventLoopFuture<Void> {
        return self.unsafeSetSocketOption(level: IPPROTO_IPV6, name: IPV6_MULTICAST_LOOP, value: value)
    }

    /// Gets the value of the socket option IPV6_MULTICAST_LOOP.
    ///
    /// - returns: An `EventLoopFuture` containing the value of the socket option, or
    ///     any error that occurred while retrieving the socket option.
    func getIPv6MulticastLoop() -> EventLoopFuture<CUnsignedInt> {
        return self.unsafeGetSocketOption(level: IPPROTO_IPV6, name: IPV6_MULTICAST_LOOP)
    }
}


extension BaseSocketChannel: SocketOptionProvider {
    public func unsafeSetSocketOption<Value>(level: SocketOptionLevel, name: SocketOptionName, value: Value) -> EventLoopFuture<Void> {
        if eventLoop.inEventLoop {
            let promise: EventLoopPromise<Void> = eventLoop.newPromise()
            executeAndComplete(promise) {
                try setSocketOption0(level: level, name: name, value: value)
            }
            return promise.futureResult
        } else {
            return eventLoop.submit {
                try self.setSocketOption0(level: level, name: name, value: value)
            }
        }
    }

    public func unsafeGetSocketOption<Value>(level: SocketOptionLevel, name: SocketOptionName) -> EventLoopFuture<Value> {
        if eventLoop.inEventLoop {
            let promise: EventLoopPromise<Value> = eventLoop.newPromise()
            executeAndComplete(promise) {
                try getSocketOption0(level: level, name: name)
            }
            return promise.futureResult
        } else {
            return eventLoop.submit {
                try self.getSocketOption0(level: level, name: name)
            }
        }
    }

    func setSocketOption0<Value>(level: SocketOptionLevel, name: SocketOptionName, value: Value) throws {
        try self.socket.setOption(level: Int32(level), name: name, value: value)
    }

    func getSocketOption0<Value>(level: SocketOptionLevel, name: SocketOptionName) throws -> Value {
        return try self.socket.getOption(level: Int32(level), name: name)
    }
}
