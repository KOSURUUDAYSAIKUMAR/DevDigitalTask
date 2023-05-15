//
//  DevListHandler.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 09/05/23.
//

import Foundation
import UIKit

class DevListHandler {
    func fetchWisdomeList(index: Int, page:[String:Any], completion: @escaping (WeatherModel?, APIError?) ->Void){
        let devListRouter = DevApiRouter.list(page: page)
        NetworkHandler().makeAPICall(at: index, router: devListRouter, decodingType: WeatherData.self) { (result) in
            switch result {
            case .success(let model):
                if let weather = self.parseJSON(model as! WeatherData) {
                    completion(weather, nil)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    private func parseJSON(_ decodedData: WeatherData) -> WeatherModel? {
        let result = WeatherModel(lat: decodedData.lat,
                                  lon: decodedData.lon,
                                  conditionId: decodedData.current.weather[0].id,
                                  cityName: Dev.Misc.defaultSityName,
                                  temperature: decodedData.current.temp,
                                  timezone: decodedData.timezone_offset,
                                  feelsLike: decodedData.current.feels_like,
                                  description: decodedData.current.weather[0].description,
                                  humidity: decodedData.current.humidity,
                                  uviIndex: decodedData.current.uvi,
                                  wind: decodedData.current.wind_speed,
                                  cloudiness: decodedData.current.clouds,
                                  pressure: decodedData.current.pressure,
                                  visibility: decodedData.current.visibility,
                                  sunrise: decodedData.current.sunrise,
                                  sunset: decodedData.current.sunset,
                                  daily: decodedData.daily,
                                  hourly: decodedData.hourly)
        return result
    }
}
