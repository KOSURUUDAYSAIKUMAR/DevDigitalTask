
import Foundation
import Photos
import UIKit

class NetworkHandler {
      
    func makeAPICall(at position: Int = 0, router: NetworkConfiguration,
                     completion: @escaping(Result<[String: Any], APIError>)-> ()) {
        guard Reachability.isNetwrokReachable() else {
            completion(.failure(.noNetwork))
            return
        }
        if let urlRequest = getURLRequest(for: router) {
            URLSession(configuration: URLSessionConfiguration.default).dataTask(with: urlRequest) { (data, response, error) in
                if error != nil {
                    // if server returns error
                    completion(.failure(.serverError))
                    return
                }
                if let data = data {
                    // data decoding to generic dictionary
                    if let dataDictionary: [String: Any] = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                        completion(.success(dataDictionary))
                    } else {
                        completion(.failure(.jsonError))
                    }
                }
            }.resume()
        }
    }
    func makeAPICall<T: Decodable>(at position: Int = 0, router: NetworkConfiguration,
                                   decodingType: T.Type,
                                   decodeKeyValue:Bool = false,
                                   completion: @escaping(Result<Decodable, APIError>)-> ()) {
        guard Reachability.isNetwrokReachable() else {
            completion(.failure(.noNetwork))
            return
        }
        if let urlRequest = getURLRequest(for: router) {
            URLSession(configuration: URLSessionConfiguration.default).dataTask(with: urlRequest) { (data, response, error) in
                if error != nil {
                    // if server returns error
                //    self.delegate?.didFailWithError(error: error!)
                    completion(.failure(.runtimeError(error?.localizedDescription ?? "")))
                    return
                }
                if let data = data {
                    // data decoding to models
                    if decodeKeyValue {
                        print("Do key value seperation. idiot")
                    }else{
                        self.decodeObj(decodingType: T.self, data: data) { (object, err) in
                            guard let object = object else {
                                //  self.delegate?.didFailWithError(error: error!)
                                completion(.failure(.jsonError))
                                return
                            }
                            completion(.success(object))
                        }
                    }
                }
            }.resume()
        }
    }
   
   
    // MARK: - Private Methods
    private func getURLRequest(for router: NetworkConfiguration) -> URLRequest? {
        let urlString = self.getUrlString(for: router)
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = router.method.rawValue
            urlRequest.allHTTPHeaderFields = router.headers
            
            if router.method == .post {
                // retured as GET calls will not have httpBody
                return urlRequest
            }
            else if let jsonData = try? JSONSerialization.data(withJSONObject: router.bodyparameters ?? [:]) {
                urlRequest.httpBody = jsonData
                return urlRequest
            } else {
                return urlRequest
            }
        }
        return nil
    }
    private func getUrlString(for router: NetworkConfiguration)->String{
        let queryString = router.bodyparameters?.queryString ?? ""
        let urlString = router.baseURL + (router.path ?? "") + "?\(queryString)"
        return urlString
    }
    private func decodeObj<T: Decodable>(decodingType: T.Type,
                                         data: Data,
                                         decode: @escaping (Decodable?, APIError?) -> Void)  {
        let jsonString = String(decoding: data, as: UTF8.self)
        do {
       //     print("server response :- \(jsonString)")
            let model = try JSONDecoder().decode(T.self, from: data)
            decode(model, nil)
        } catch {
            decode(nil, .jsonError)
        }
    }
    private func getPostString(params:[String:Any]) -> String
    {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
}

extension Collection {
    var toJson: String? {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: self,
            options: [.prettyPrinted]) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            return theJSONText
        }
        return nil
    }
}
