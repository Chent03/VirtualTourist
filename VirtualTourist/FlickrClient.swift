//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Tony Chen on 7/14/17.
//  Copyright © 2017 Tony Chen. All rights reserved.
//

import Foundation

class FlickrClient: NSObject{
    
    func searchFlickr(latitude: Double, longitude: Double){
        
        let methodParameters = [
            FlickrParameterKeys.Method: FlickrParameterValues.SearchMethod,
            FlickrParameterKeys.APIKey: FlickrParameterValues.APIKey,
            FlickrParameterKeys.BoundingBox: bboxString(lat: latitude, lng: longitude),
            FlickrParameterKeys.SafeSearch: FlickrParameterValues.UseSafeSearch,
            FlickrParameterKeys.Extras: FlickrParameterValues.MediumURL,
            FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback
        ]
        
        getImagesFromFlickrBySearch(methodParameters as [String: AnyObject]) { (success, error, results) in
            
            func sendError(_ error: String) {
                print(error)
            }
            
            guard error == nil else {
                sendError("Error in getting photos")
                return
            }
            
            guard success else {
                sendError("Not successful")
                return
            }
            
            if results?.count == 0 {
                sendError("No Photos Found")
                return
            } else {
                
                print(results?.count)
                
                for photo in results! {
                    let photoTitle = photo[FlickrResponseKeys.Title] as? String
                    
                    guard let imageUrlString = photo[FlickrResponseKeys.MediumURL] as? String else {
                        sendError("Cannot find key '\(FlickrResponseKeys.MediumURL)' in \(photo)")
                        return
                    }
                    
                    print(imageUrlString)
                }
            }
            
        }
        
    }
    
    func getImagesFromFlickrBySearch(_ methodParameters: [String: AnyObject], completionHandlerForImages: @escaping(_ success: Bool, _ errorString: NSError?, _ results: [[String:AnyObject]]?) -> Void){
        
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForImages(false, NSError(domain: "getImages", code: 1, userInfo: userInfo), nil)
            }
            
            guard error == nil else {
                sendError("Error in retrieving data")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("status code other than 2xx")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let parsedResult : [String: AnyObject]!
            do{
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            }catch {
                sendError("Could not parse the data as JSON")
                return
            }
            
            guard let stat = parsedResult[FlickrResponseKeys.Status] as? String, stat == FlickrResponseValues.OKStatus else {
                sendError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            guard let photosDictionary = parsedResult[FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                sendError("Cannot find key '\(FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            guard let photosArray = photosDictionary[FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                sendError("Cannot find key '\(FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            completionHandlerForImages(true, nil, photosArray)
            
        }
        task.resume()
        
    }
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Flickr.APIScheme
        components.host = Flickr.APIHost
        components.path = Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    
    
    private func bboxString(lat: Double, lng: Double) -> String {
        
        let latitude = lat
        let longitude = lng
        let minimumLon = max(longitude - Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"

    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }

}
