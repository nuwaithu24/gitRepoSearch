//
//  Http.swift
//  GitRepoSearch
//
//  Created by BaganIT on 11/10/21.
//

import Foundation
import UIKit

typealias header = Dictionary<String,String>
struct responseData {
    var data: Data?
    var error: Error?
    var code: Int?
}



struct Http {
    func apiCall(url: String,method: String,headers: header? = nil ,paramString: [String:Any]? = nil,completion:((responseData) -> Void)? = nil) {
        
        guard let sendURL = URL(string: url) else {
            return
        }
        let session = URLSession.shared
        
        //createUriRequest
        var request = URLRequest(url: sendURL)
        
        //setUpRequestMethod
        request.httpMethod = method
        
        //addHeaders
        if let headers = headers {
            for key in headers.keys {
                request.setValue(headers[key], forHTTPHeaderField: key)
            }
        }
        
        //addquery
        if let p = paramString {
            let jsonData = try? JSONSerialization.data(withJSONObject: p)
            request.httpBody = jsonData
        }
        
        //callURLSession
        let task = session.dataTask(with: request) { (data, response, error) in
            
            let httpresponse = response as? HTTPURLResponse
            let statusCode = httpresponse?.statusCode
            if let e = error,let callback = completion {
                callback(responseData(data: nil, error: e,code:statusCode))
            }
            else if let callback = completion {
                callback(responseData(data: data, error: nil,code:statusCode))
            }
            return
            
        }
        
        task.resume()
        
    }
    
   
    
   
    
}
