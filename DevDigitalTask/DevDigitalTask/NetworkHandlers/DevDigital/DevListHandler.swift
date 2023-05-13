//
//  DevListHandler.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 09/05/23.
//

import Foundation
import UIKit

class DevListHandler {
    func fetchWisdomeList(page:[String:Any], perPage:Int,completion: @escaping (WeatherData?, APIError?) ->Void){
        let devListRouter = DevApiRouter.list(page: page)
        NetworkHandler().makeAPICall(router: devListRouter, decodingType: WeatherData.self) { (result) in
            switch result {
            case .success(let model):
                completion(model as? WeatherData, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
