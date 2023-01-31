//
//  ObservableCallback.swift
//  rx_method_channel
//
//  Created by Komang Arta Wibawa on 31/01/23.
//

import Foundation

public enum ObservableCallbackType: String {
    case onNext = "onNext"
    case onComplete = "onComplete"
    case onError = "onError"
}

public struct ObservableCallback {
    let requestId: Int
    let type: ObservableCallbackType
    let value: Any?
    
    func toJson() throws -> String {
        let dict = [
            "requestId": requestId,
            "type": type.rawValue,
            "value": value
        ];
        
        do {
            let jsonObject = try JSONSerialization.data(withJSONObject: dict,  options: [])
            return String(data: jsonObject, encoding: .utf8)!
        } catch {
            throw ObservableCallbackError.parsingError
        }
    }
}

enum ObservableCallbackError:Error {
    case parsingError
}
