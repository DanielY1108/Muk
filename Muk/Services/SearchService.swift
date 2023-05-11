//
//  SearchService.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/28.
//

import Foundation

enum ServiceError: Error {
    case invaildURL
    case failedResponse
    case failedRequest
    case failedParseJSON
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}

final class SearchService {
    
    static func getLocation(name: String, completion: @escaping (Result<Location, ServiceError>) -> Void) {
        let urlString = "https://dapi.kakao.com/v2/local/search/keyword?query=\(name)"
        
        guard let url = URL(string: urlString.stringByAddingPercentEncoding) else {
            completion(.failure(.invaildURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(Platform.kakao.value, forHTTPHeaderField: Platform.kakao.key)
        request.httpMethod = HttpMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(.failedRequest))
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200..<299) ~= response.statusCode else {
                completion(.failure(.failedResponse))
                return
            }
            
            guard let safeData = data,
                  let jsonData = try? JSONDecoder().decode(Location.self, from: safeData) else {
                completion(.failure(.failedParseJSON))
                return
            }
          
            completion(.success(jsonData))
            
        }.resume()
    }
}

