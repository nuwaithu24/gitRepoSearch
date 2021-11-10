//
//  API.swift
//  GitRepoSearch
//
//  Created by BaganIT on 11/10/21.
//

import Foundation

class API {
    
    var token:String!
    var apiUrl:String!
    let http = Http()
    let source_url = "https://api.github.com"
    
    func getRequest<T:Codable>(apiURL:String,method:String="GET",paramString:[String:String]?=nil,headers:[String:String]? = nil,completion:((T?,Error?,Int?) -> Void)? = nil) {
        
        self.http.apiCall(url: apiURL, method: method,headers: headers, paramString: paramString) { (response) in
            
            if let e = response.error {
                if let callback = completion {
                    callback(nil,e,response.code)
                }
            }
            else if let d = response.data{
                
                do {
                    
                    let datas = try JSONDecoder().decode(T.self, from: d)
                    if let callback = completion {
                        callback(datas,nil,response.code)
                        
                    }
                }catch {
                    if let callback = completion {
                        print(error)
                        callback(nil,error,response.code)
                    }
                }
            }
        }
    }
    
    func getSearchRepo(query:String,page:Int,completion:((searchRepoResponse?,Error?,Int?) -> Void)? = nil){
        
        let apiURL = source_url + "/search/repositories?q=\(query)&page=\(page)"
        
        self.getRequest(apiURL: apiURL,completion: completion)
        
    }

}

