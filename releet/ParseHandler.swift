import Foundation
import Parse
import Alamofire

class ParseHandler{
    
    static func register(gamertag: String, email: String, password: String, completion: (success: Bool, message: String) -> Void) {
        
        let query = PFUser.query()
        query!.whereKey("canonical", equalTo: gamertag.uppercaseString)
        query!.getFirstObjectInBackgroundWithBlock { (obj: PFObject?, error: NSError?) -> Void in
            
            if (obj != nil && error == nil) {
                completion(success: false, message: "The email or gamertag entered has been taken.")
                return;
            }
            
            let headers = ["X-AUTH": Common.XBOX_API_API_KEY]
            
            Alamofire.request(.GET, "https://xboxapi.com/v2/xuid/\(gamertag)", headers: headers)
                .responseJSON { response in
                    
                    guard let xuid = response.result.value where response.result.value!["success"] == nil else {
                        completion(success: false, message: "Gamertag not found.")
                        return
                    }
                    
                    Alamofire.request(.GET, "https://xboxapi.com/v2/\(xuid)/profile", headers: headers)
                        .responseJSON { response in
                            
                            guard let gamerpic = response.result.value!["GameDisplayPicRaw"]! else {
                                completion(success: false, message: "No gamer picture found")
                                return
                            }
                            
                            let user = PFUser()
                            user.username = email
                            user.email = email
                            user.password = password
                            user["gamertag"] = gamertag
                            user["postCount"] = 0
                            user["canonical"] = gamertag.uppercaseString
                            user["xuid"] = "\(xuid)"
                            user["gamerpic"] = gamerpic
                            
                            user.signUpInBackgroundWithBlock {
                                (succeeded: Bool, error: NSError?) -> Void in
                                if let error = error {
                                    completion(success: false, message: (error.userInfo["error"] as? String)!)
                                } else {
                                    let queryRole = PFRole.query()
                                    queryRole?.whereKey("name", equalTo:"User")
                                    queryRole?.getFirstObjectInBackgroundWithBlock({ (role: PFObject?, error: NSError?) -> Void in
                                        if error == nil {
                                            let roleToAddUser = role as! PFRole
                                            
                                            roleToAddUser.users.addObject(PFUser.currentUser()!)
                                            roleToAddUser.saveInBackground()
                                            
                                            completion(success: true, message: "")
                                        }
                                    })
                                }
                            }
                    }
            }
        }
    }
    
    static func login(email: String, password: String, completion: (success: Bool) -> Void) {
        
        PFUser.logInWithUsernameInBackground(email, password: password) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                completion(success: true)
            } else {
                completion(success: false)
            }
        }
    }
    
    static func getLatestGames(completion: (games: [PFObject]!, error: NSError?, success: Bool) -> Void) {
        let query = PFQuery(className:"Game")
        query.orderByDescending("updatedAt")
        query.limit = 26
        query.whereKey("show", equalTo: true)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                completion(games: objects!, error: nil, success: true)
            } else {
                completion(games: nil, error: error, success: false)
            }
        }
    }
    
    static func getGames(alphabetLetter: String, completion: (games: [PFObject]!, error: NSError?, success: Bool) -> Void) {
        let query = PFQuery(className:"Game")
        query.whereKey("title", hasPrefix: alphabetLetter)
        query.limit = 1000
        query.whereKey("show", equalTo: true)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                completion(games: objects!, error: nil, success: true)
            } else {
                completion(games: nil, error: error, success: false)
            }
        }
    }
    
    static func getGameAchievements(gameId: String, completion: (achievements: [PFObject]!, error: NSError?, success: Bool) -> Void) {
        
        let query = PFQuery(className:"Achievement")
        query.whereKey("gameId", equalTo: gameId)
        query.limit = 1000
        query.orderByAscending("title")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                completion(achievements: objects, error: nil, success: true)
            } else {
                completion(achievements: nil, error: error, success: false)
            }
        }
    }
    
    static func getUserInfo(xuid: String, completion: (user: PFObject!, error: NSError?, success: Bool) -> Void) {
        
        let query = PFQuery(className:"_User")
        query.whereKey("xuid", equalTo: xuid)
        query.limit = 1
        query.getFirstObjectInBackgroundWithBlock { (user: PFObject?, error: NSError?) -> Void in
            if error == nil {
                completion(user: user, error: nil, success: true)
            } else {
                completion(user: nil, error: error, success: false)
            }
        }
    }
}
