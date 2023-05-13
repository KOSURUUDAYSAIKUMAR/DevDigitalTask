//
//  NetworkConfiguration.swift
//  WisdomTask
//
//  Created by  Keerthana G on 15/12/22.
//

import Foundation

enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
}

protocol NetworkConfiguration {
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var path: String? { get }
    var bodyparameters: [String: Any]? { get }
    var headers: [String : String]? { get }
}

extension NetworkConfiguration {
    var baseURL: String {
        return APIConstants.baseUrl
    }
    var oAuthToken: String {
        return ""
    }
    var timeoutInterval: TimeInterval {
        return 60.0
    }
}
