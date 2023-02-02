//
//  RxMethodChannel.swift
//  rx_method_channel
//
//  Created by Komang Arta Wibawa on 31/01/23.
//

import Foundation
import RxSwift
import FlutterMacOS

public typealias Argument = [String: Any]
public typealias SingleSource = (Argument) -> Single<Any>
public typealias CompletableSource = (Argument) -> Completable
public typealias ObservableSource = (Argument) -> Observable<Any>

let METHOD_NOT_FOUND = "1"
let OPERATION_ERROR = "2"
let INVALID_OPERATION = "3"

enum OperationType: String{
    case cancel
    case subscribe
}

enum MethodType: String {
    case single
    case completable
    case observable
}

public class RxMethodChannel {
    private let channel: FlutterMethodChannel
    private let channelName: String
    
    private var registeredSingle : [String: SingleSource] = [:]
    private var registeredCompletable : [String: CompletableSource] = [:]
    private var registeredObservable: [String: ObservableSource] = [:]
    
    private var subscriptions: [Int:Disposable] = [:]
    
    public init(channelName: String, binaryMessenger: FlutterBinaryMessenger) {
        self.channelName = channelName
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)
        channel.setMethodCallHandler(handle(_:result:))
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Invoking: \(call.method), args: \(String(describing: call.arguments))")
        
        let args = call.arguments as! Argument
        let requestId = args["requestId"] as! Int
        let operationType = OperationType(rawValue: call.method)
        
        switch(operationType) {
        case .cancel:
            removeSubscription(requestId: requestId)
        case .subscribe:
            let methodName = args["methodName"] as! String
            let methodType = args["methodType"] as! String
            let arguments = args["arguments"] as! Argument
            
            let type = MethodType(rawValue: methodType)
            switch(type) {
            case .single:
                if registeredSingle[methodName] == nil {
                    result(
                        FlutterError(
                            code: METHOD_NOT_FOUND,
                            message: "Method \(methodName) not registered.",
                            details: nil
                        )
                    )
                    break
                }
                
                let source = registeredSingle[methodName]!
                subscriptions[requestId] = source(arguments)
                    .subscribe { (data: Any) in
                        result(data)
                        self.removeSubscription(requestId: requestId)
                    } onError: { (error: Error) in
                        result(
                            FlutterError(
                                code: OPERATION_ERROR,
                                message: error.localizedDescription,
                                details: nil
                            )
                        )
                        self.removeSubscription(requestId: requestId)
                    }
                break
            case .completable:
                if registeredCompletable[methodName] == nil {
                    result(
                        FlutterError(
                            code: METHOD_NOT_FOUND,
                            message: "Method \(methodName) not registered.",
                            details: nil
                        )
                    )
                    break
                }
                
                let source = registeredCompletable[methodName]!
                subscriptions[requestId] = source(arguments)
                    .subscribe(onCompleted: {
                        result(nil)
                        self.removeSubscription(requestId: requestId)
                    },onError: { (error: Error) in
                        result(
                            FlutterError(
                                code: OPERATION_ERROR,
                                message: error.localizedDescription,
                                details: nil
                            )
                        )
                        self.removeSubscription(requestId: requestId)
                    })
                break
            case .observable:
                guard registeredObservable[methodName] != nil else {
                    result(
                        FlutterError(
                            code: METHOD_NOT_FOUND,
                            message: "Method \(methodName) not registered.",
                            details: nil
                        )
                    )
                    break
                }
                
                let source = registeredObservable[methodName]!
                subscriptions[requestId] = source(arguments)
                    .observeOn(MainScheduler.instance)
                    .do(
                        onCompleted: {
                            result(nil)
                            self.removeSubscription(requestId: requestId)
                        }
                    )
                    .subscribe { (data: Any) in
                        let payload = ObservableCallback(
                            requestId: requestId,
                            value: data
                        )
                        
                        do {
                            self.channel.invokeMethod(
                                "observableCallback",
                                arguments: try payload.toJson()
                            )
                        } catch {
                            print(error.localizedDescription)
                        }
                    } onError: { (error: Error) in
                        result(
                            FlutterError(
                                code: OPERATION_ERROR,
                                message: error.localizedDescription,
                                details: nil
                            )
                        )
                        self.removeSubscription(requestId: requestId)
                    }
                break
            default:
                result(
                    FlutterError(
                        code: INVALID_OPERATION,
                        message: "Invalid method type \(methodType).",
                        details: nil
                    )
                )
            }
            break
        default:
            result(
                FlutterError(
                    code: INVALID_OPERATION,
                    message: "Invalid operation \(call.method).",
                    details: nil
                )
            )
            break
        }
    }
    
    public func registerSingle(_ methodName: String, call:@escaping SingleSource) {
        print("Registered single: \(methodName)")
        registeredSingle[methodName] = call
    }
    
    public func registerCompletable(_ methodName: String, call:@escaping CompletableSource) {
        print("Registered completable: \(methodName)")
        registeredCompletable[methodName] = call
    }
    
    public func registerObservable(_ methodName: String, call:@escaping ObservableSource) {
        print("Registered observable: \(methodName)")
        registeredObservable[methodName] = call
    }
    
    func removeSubscription(requestId: Int) {
        print("Disposing subscription with requestID: \(requestId)")
        subscriptions[requestId]?.dispose()
        subscriptions.removeValue(forKey: requestId)
    }
    
}
