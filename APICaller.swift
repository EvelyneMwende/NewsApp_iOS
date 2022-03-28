//
//  APICaller.swift
//  NewsApp
//
//  Created by Eclectics on 18/03/2022.
//

import Foundation

final class APICaller{
    //Creating a singleton
    //.shared->These objects can all be considered shared instances, or globally available instances.
    static let shared = APICaller()
    
    struct Constants{
        static let topHeadlinesURL = URL(string:
        "https://newsapi.org/v2/top-headlines?country=US&apiKey=78fbf85ea9904df8bd92f78546094349")
        
        //when user is searching for a certain news topic
        //q= is added to the end to represent user query
        static let searchUrlString = "https://newsapi.org/v2/everything?sortedBy=popularity&apiKey=78fbf85ea9904df8bd92f78546094349&q="
    }
    private init(){}
    
    //A completion handler in Swift is a function that calls back when a task completes.
    //This is why it is also called a callback function.
    //A callback function is passed as an argument into another function.
    //When this function completes running a task, it executes the callback function.
    
    //An escaping closure is a closure that's called after the function it was passed to returns.
    //In other words, it outlives the function it was passed to. A non-escaping closure is a closure
    //that's called within the function it was passed into, i.e. before it returns
    
    public func getTopStories(completion: @escaping (Result<[Article], Error>)->Void){
        //perfom api call
        //umwrap the const topHeadlinesURL
        //make sure the URL returns something else stop
        guard let url = Constants.topHeadlinesURL else{
            return
        }
        
        let task = URLSession.shared.dataTask(with: url){data, _, error in
            if let error = error{
                completion(.failure(error))
            }
            else if let data = data {
                do{
                    //try to decode using a json decoder
                    let result  = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                catch{
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    //Searching for articles on a particular topic
    
    public func search(with query:String, completion: @escaping (Result<[Article], Error>)->Void){
        //perfom api call
        //umwrap the const topHeadlinesURL
        //make sure the URL returns something else stop
        //removing white spaces from query if there is nothing just return
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else{
            return
        }
        let urlString = Constants.searchUrlString + query
        guard let url = URL(string: urlString) else{
            return
        }
        
        let task = URLSession.shared.dataTask(with: url){data, _, error in
            if let error = error{
                completion(.failure(error))
            }
            else if let data = data {
                do{
                    //try to decode using a json decoder
                    let result  = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                catch{
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

//Models
struct APIResponse: Codable {
    let articles: [Article]
}

//structure what we want to fetch from the api
struct Article: Codable {
    //In the API source is a dictionary
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
}

struct Source: Codable{
    //getting name only for the source dictionary
    let name: String
}
