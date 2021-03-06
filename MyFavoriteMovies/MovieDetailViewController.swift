//
//  MovieDetailViewController.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: MovieDetailViewController: UIViewController

class MovieDetailViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var unFavoriteButton: UIButton!

    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var movie: Movie?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
                
        if let movie = movie {
            
            /* Setting some defaults ... */
            posterImageView.image = UIImage(named: "film342.png")
            titleLabel.text = movie.title
            unFavoriteButton.hidden = true
            
            /* TASK A: Get favorite movies, then update the favorite buttons */
            /* 1A. Set the parameters */
            let methodParameters = [
                "api_key": appDelegate.apiKey,
                "session_id": appDelegate.sessionID!
            ]
            
            /* 2A. Build the URL */
            let urlString = appDelegate.baseURLSecureString + "account/\(appDelegate.userID!)/favorite/movies" + appDelegate.escapedParameters(methodParameters)
            let url = NSURL(string: urlString)!
            
            /* 3A. Configure the request */
            let request = NSMutableURLRequest(URL: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            /* 4A. Make the request */
            let task = session.dataTaskWithRequest(request) { (data, response, error) in
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    print("There was an error with your request: \(error)")
                    return
                }
                
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    if let response = response as? NSHTTPURLResponse {
                        print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    } else if let response = response {
                        print("Your request returned an invalid response! Response: \(response)!")
                    } else {
                        print("Your request returned an invalid response!")
                    }
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    print("No data was returned by the request!")
                    return
                }
                
                /* 5A. Parse the data */
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                } catch {
                    parsedResult = nil
                    print("Could not parse the data as JSON: '\(data)'")
                    return
                }
                
                /* GUARD: Did TheMovieDB return an error? */
                guard (parsedResult.objectForKey("status_code") == nil) else {
                    print("TheMovieDB returned an error. See the status_code and status_message in \(parsedResult)")
                    return
                }
                
                /* GUARD: Is the "results" key in parsedResult? */
                guard let results = parsedResult["results"] as? [[String : AnyObject]] else {
                    print("Cannot find key 'results' in \(parsedResult)")
                    return
                }
                
                /* 6A. Use the data! */
                var isFavorite = false
                let movies = Movie.moviesFromResults(results)
                
                for movie in movies {
                    if movie.id == self.movie!.id {
                        isFavorite = true
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    if isFavorite {
                        self.favoriteButton.hidden = true
                        self.unFavoriteButton.hidden = false
                    } else {
                        self.favoriteButton.hidden = false
                        self.unFavoriteButton.hidden = true
                    }
                }
            }
            
            /* 7A. Start the request */
            task.resume()
        
            /* TASK B: Get the poster image, then populate the image view */
            if let posterPath = movie.posterPath {
                
                /* 1B. Set the parameters */
                // There are none...
                
                /* 2B. Build the URL */
                let baseURL = NSURL(string: appDelegate.config.baseImageURLString)!
                let url = baseURL.URLByAppendingPathComponent("w342").URLByAppendingPathComponent(posterPath)
                
                /* 3B. Configure the request */
                let request = NSURLRequest(URL: url)
                
                /* 4B. Make the request */
                let task = session.dataTaskWithRequest(request) { (data, response, error) in
                    
                    /* GUARD: Was there an error? */
                    guard (error == nil) else {
                        print("There was an error with your request: \(error)")
                        return
                    }
                    
                    /* GUARD: Did we get a successful 2XX response? */
                    guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                        if let response = response as? NSHTTPURLResponse {
                            print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                        } else if let response = response {
                            print("Your request returned an invalid response! Response: \(response)!")
                        } else {
                            print("Your request returned an invalid response!")
                        }
                        return
                    }
                    
                    /* GUARD: Was there any data returned? */
                    guard let data = data else {
                        print("No data was returned by the request!")
                        return
                    }
                    
                    /* 5B. Parse the data */
                    // No need, the data is already raw image data.
                    
                    /* 6B. Use the data! */
                    if let image = UIImage(data: data) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.posterImageView!.image = image
                        }
                    } else {
                        print("Could not create image from \(data)")
                    }
                }
                
                /* 7B. Start the request */
                task.resume()
            }
        }
    }
    
    // MARK: Favorite Actions
    
    @IBAction func unFavoriteButtonTouchUpInside(sender: AnyObject) {
        
        
        /* TASK: Remove movie as favorite, then update favorite buttons */
        
        
        
        /* 1. Set the parameters */
        let methodParameters = [
            "api_key": appDelegate.apiKey,
            "session_id": appDelegate.sessionID!
        ]
        
        /* 2. Build the URL */
        
        let urlString = appDelegate.baseURLSecureString + "account/\(appDelegate.userID!)/favorite" + appDelegate.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"media_type\": \"movie\",\"media_id\": \(self.movie!.id), \"favorite\": false }".dataUsingEncoding(NSUTF8StringEncoding)

        
        
        
        /* 4. Make the request */
        
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
        
            //GUARD: Error
            guard (error == nil) else {
                print("error received in un-favoriting a movie")
                return
            }
            
            //GUARD: Non 200x response
            
            guard let statusCode =  (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode < 300 else {
                
                if let response = (response as? NSHTTPURLResponse) {
                    print("ERROR #1: Respnse in un-favoriting a movie: \(response.statusCode)")
                } else if let response = response {
                    print("ERROR #2: Response in un-favoriting a movie: \(response)")
                } else {
                    print("ERROR #3: Problem un-favoriting a movie")
                }
                return
            }
            
            //GUARD: No data received
            guard let data = data else {
                print("ERROR: No data received after un-favoriting a movie")
                return
            }
            
            
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String:AnyObject]
            } catch {
                parsedResult = nil
                print("Data after un-favoriting a movie could not be parsed to JSON")
                return
            }
            print(parsedResult)
            
            /* 6. Use the data! */
            
            if let result = parsedResult["status_code"] as? Int {
                
                if result == 13 {
                    print("movie unfavorited")
                    
                    //change the favorite button attributes
                    dispatch_async(dispatch_get_main_queue(), {
                    
                        self.favoriteButton.hidden = false
                        self.unFavoriteButton.hidden = true
                    
                    })
                    
                    
                } else {
                    print("ERROR: status code: \(result). Could not un-favorite a movie")
                }
                
            }
            
            

        
        }
        
               /* 7. Start the request */
        task.resume()
    }
    
    @IBAction func favoriteButtonTouchUpInside(sender: AnyObject) {
        
        
        /* TASK: Add movie as favorite, then update favorite buttons */
        
        //use the /account/id/favorite method
        
       
        /* 1. Set the parameters */
        
        let methodParameters = [
            "api_key": appDelegate.apiKey,
            "session_id": appDelegate.sessionID!
        ]
        
        
        /* 2. Build the URL */
        let urlString = appDelegate.baseURLSecureString + "account/\(appDelegate.userID!)/favorite" + appDelegate.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{ \"media_type\": \"movie\", \"media_id\": \"\(self.movie!.id)\", \"favorite\": \"true\"}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            //GUARD: Error returned
            guard (error == nil) else {
                print("error returned in posting favorite")
                return
            }
            
            //GUARD: Non 200x response
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode < 300 else {
                
                if let response = (response as? NSHTTPURLResponse) {
                    print("ERROR: Response in favoriting a movie: \(response.statusCode)")
                } else if let response = response {
                    print("ERROR: Response in favoriting a movie: \(response)")
                } else {
                    print("ERROR: Response in favoriting a movie")
                }
                return
            }
            
            //GUARD: No data received
            guard let data = data else {
                print("No data received")
                return
            }
            
            /* 5. Parse the data */
            
            let parsedResult: AnyObject!
            
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("ERROR: Unable to convert the data from Favoriting a Movie into JSON")
                return
            }
            
            /* 6. Use the data! */
            
            //if the response was a success, change the Favorite button hidden attributes
            if let result = parsedResult["status_code"] as? Int {
                
                if result == 1 || result == 12 {
                    //change the button attributes
                    print("Movie favorited!")
                    dispatch_async(dispatch_get_main_queue(), {
                    
                        self.favoriteButton.hidden = true
                        self.unFavoriteButton.hidden = false
                        
                    })
                } else {
                    print("Unable to favorite the movie")
                }
            }
            
            
        }
        
     
        /* 7. Start the request */
        task.resume()
    }
}
