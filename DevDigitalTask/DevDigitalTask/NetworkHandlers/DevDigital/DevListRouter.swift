//
//  WisdomListRouter.swift
//  WisdomTask
//
//  Created by KOSURU UDAY SAIKUMAR on 09/05/23.
//

import Foundation

enum DevApiRouter {
    case list(page:[String:Any])
}

extension DevApiRouter: NetworkConfiguration {
    var path: String? {
        switch self {
        case .list:
            return APIConstants.list
        default:
            break
        }
    }
    //   let urlString = "\(baseURL)lat=\(lat)&lon=\(lon)&appid=\(appid)&units=\(units)&exclude=\(Dev.Network.minutely)"
    var bodyparameters: [String : Any]? {
        switch self {
        case .list(let urlParams):
            return ["lat":urlParams["lat"],
                    "lon":urlParams["lon"],
                    "appid":urlParams["appid"],
                    "units":urlParams["units"],
                    "eclude":Dev.Network.minutely]
        default:
            break
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .list:
            return ["Content-Type":"application/json"]
        default:
            break
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .list:
            return .post
        }
    }
}
