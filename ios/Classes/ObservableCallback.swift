//
//  ObservableCallback.swift
//  rx_method_channel
//
//  Created by Komang Arta Wibawa on 31/01/23.
//

import Foundation

public struct ObservableCallback {
    let requestId: Int
    let value: Any?
    
    func toJson() throws -> String {
        let dict = [
            "requestId": requestId,
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

enum ObservableCallbackError: Error {
    case parsingError
}
