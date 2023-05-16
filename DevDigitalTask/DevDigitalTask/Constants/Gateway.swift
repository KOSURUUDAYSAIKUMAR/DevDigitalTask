//
//  Gateway.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 09/05/23.
//

import Foundation

class AppGateway: NSObject {
    static var sharedInstance = AppGateway()
    var configs: NSDictionary!
   
    override init() {
        let path = Bundle.main.path(forResource: PathEndPoints.config.rawValue, ofType: PathEndPoints.type.rawValue)!
        configs = NSDictionary(contentsOfFile: path)!.object(forKey: ConfigEndPoint.development.rawValue) as? NSDictionary
    }
}

extension AppGateway {
    func appGatewayEndPoint() -> String {
        return configs.object(forKey: ApplicationGateWayEndPoint.EndPoint.rawValue) as! String
    }
}

enum ApplicationGateWayEndPoint: String {
    case EndPoint = "ApplicationGateWay"
}

enum PathEndPoints :String {
    case config = "AppGateway"
    case type   = "plist"
}

enum ConfigEndPoint : String {
    case development  = "Development"
}
