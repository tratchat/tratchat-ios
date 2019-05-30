//
//  ViewController.swift
//  Unregulated Chaos
//
//  Created by Ryan Trattner on 5/24/19.
//  Copyright © 2019 Ryan Trattner. All rights reserved.
//
import UIKit
import WebKit

class ViewController: UIViewController {
    var webView: WKWebView!
    var bridges = ["https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat"]
    var bridges2 = ["https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat","https://web.trat.chat"]
    let defaults = UserDefaults.standard
    var devicetoken = "none";

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tripleTap))
        tap.numberOfTapsRequired = 3
        view.addGestureRecognizer(tap)
        if #available(iOS 9.0, *)
        {
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            let date = NSDate(timeIntervalSince1970: 0)
            
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        }
        else
        {
            var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
            libraryPath += "/Cookies"
            
            do {
                try FileManager.default.removeItem(atPath: libraryPath)
            } catch {
                print("error")
            }
            URLCache.shared.removeAllCachedResponses()
        }
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // Add script message handlers that, when run, will make the function
        // window.webkit.messageHandlers.test.postMessage() available in all frames.
        userContentController.add(self, name: "dataChannel")
        
        config.userContentController = userContentController

        
        // Inject JavaScript into the webpage. You can specify when your script will be injected and for
        // which frames–all frames or the main frame only.
        
        

         webView = WKWebView(frame: .zero, configuration: config)

        view.addSubview(webView)
        
        let layoutGuide = view.safeAreaLayoutGuide
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        // Make sure in Info.plist you set `NSAllowsArbitraryLoads` to `YES` to load
        // URLs with an HTTP connection. You can run a local server easily with services
        // such as MAMP.
        let url = Bundle.main.url(forResource: "index2", withExtension: "html", subdirectory: "website")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request);

    }
    func getBridge() -> String {
        if bridges.isEmpty == false {
            let randomBridge = bridges.randomElement()!
            if let index = bridges.firstIndex(of:randomBridge) {
                bridges.remove(at: index)
            }
            return randomBridge;
        }else{
            return "No Bridges Left";
        }
    }

    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .left) {
            webView.evaluateJavaScript("swipeEvent('Right')") { (result, error) in
                print(result ?? error  ?? "swipeEventLeft")
            }
            
        }
        
        if (sender.direction == .right) {
            webView.evaluateJavaScript("swipeEvent('Left')") { (result, error) in
                print(result ?? error  ?? "swipeEventRight")
            }
            
        }
    }
    @objc func tripleTap() {
        print("triple tap")
        webView.evaluateJavaScript("tripleTap()") { (result, error) in
            print(result ?? error  ?? "swipeEventRight")
        }
    }
    func doToken(token: String) -> Bool {
        print(token)
        devicetoken = token;
        return true;
    }
    
}


extension ViewController: WKScriptMessageHandler {
    // Capture postMessage() calls inside loaded JavaScript from the webpage. Note that a Boolean
    // will be parsed as a 0 for false and 1 for true in the message's body. See WebKit documentation:
    // https://developer.apple.com/documentation/webkit/wkscriptmessage/1417901-body.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody = message.body as? String {
            print(messageBody)
            if(messageBody == "locked"){
                if let privateKey = defaults.string(forKey: "privateKey") {
                    webView.evaluateJavaScript("setData('privateKey', `"+privateKey+"`);") { (result, error) in
                        print(result ?? error ?? "hello")
                    }
                }
                if let publicKey = defaults.string(forKey: "publicKey") {
                    webView.evaluateJavaScript("setData('publicKey', `"+publicKey+"`);") { (result, error) in
                        print(result ?? error ?? "hello")
                    }
                }
                if let bridge = defaults.string(forKey: "bridge") {
                    webView.evaluateJavaScript("setData('bridge', `"+bridge+"`);") { (result, error) in
                        print(result ?? error ?? "hello")
                    }
                }
                    if let token = defaults.string(forKey: "token") {
                        webView.evaluateJavaScript("setData('token', `"+token+"`);") { (result, error) in
                            print(result ?? error ?? "settingtoken")
                        }
                    }
                webView.evaluateJavaScript("update()") { (result, error) in
                    print("updating locked")
                }
            }
            if(messageBody == "start"){
                if(exists(key: "privateKey")){
                    if(exists(key: "publicKey")){
                        if let privateKey = defaults.string(forKey: "privateKey") {
                            webView.evaluateJavaScript("setData('privateKey', `"+privateKey+"`);") { (result, error) in
                                print(result ?? error ?? "hello")
                                print(privateKey)
                            }
                        }
                        if let publicKey = defaults.string(forKey: "publicKey") {
                            webView.evaluateJavaScript("setData('publicKey', `"+publicKey+"`);") { (result, error) in
                                print(result ?? error ?? "hello")
                                print(publicKey)
                            }
                        }
                        webView.evaluateJavaScript("setUpBridge('"+getBridge()+"')") { (result, error) in
                            print("gave bridge")
                        }
                        
                    }else{
                        webView.evaluateJavaScript("genKeys()") { (result, error) in
                            print("generating Keys")
                        }
                    }
                    
                }else{
                    webView.evaluateJavaScript("genKeys()") { (result, error) in
                        print("generating Keys")

                    }
                }


            }
            if(messageBody.hasPrefix("setPrivateKey")){
                let privateKey = String(messageBody.dropFirst(13))
                defaults.set(privateKey, forKey: "privateKey")
                print("set Private key")
                
            }
            if(messageBody.hasPrefix("setPublicKey")){
                let publicKey = String(messageBody.dropFirst(12))
                defaults.set(publicKey, forKey: "publicKey")
                print("set Public key")
            }
            if(messageBody.hasPrefix("getDeviceToken")){
                webView.evaluateJavaScript("doDeviceToken('"+devicetoken+"')") { (result, error) in
                    print("gave device token")
                }
            }
            if(messageBody.hasPrefix("setUserPrivate")){
                let privateKey = String(messageBody.dropFirst(14))
                defaults.set(privateKey, forKey: "userPrivate")
                print(privateKey)
            }
            if(messageBody.hasPrefix("setUserPublic")){
                let publicKey2 = String(messageBody.dropFirst(13))
                defaults.set(publicKey2, forKey: "userPublic")
                print(publicKey2)
            }
            if(messageBody == "getBridge"){
                webView.evaluateJavaScript("setUpBridge('"+getBridge()+"')") { (result, error) in
                    print("gave bridge")
                }
            }
            if(messageBody.hasPrefix("setBridge")){
                let bridge = String(messageBody.dropFirst(9))
                defaults.set(bridge, forKey: "bridge")
                print("set bridge")
              //  let url = Bundle.main.url(forResource: "index2", withExtension: "html", subdirectory: "website")!
             //   webView.loadFileURL(url, allowingReadAccessTo: url)
             //   let request = URLRequest(url: url)
             //   webView.load(request)
   

            }
            if(messageBody.hasPrefix("setToken")){
                let token = String(messageBody.dropFirst(8))
                defaults.set(token, forKey: "token")
                print("set token")
                
            }
            if(messageBody.hasPrefix("unsetToken")){
                defaults.removeObject(forKey: "token")
                defaults.removeObject(forKey: "bridge")
                defaults.removeObject(forKey: "userPrivate")
                defaults.removeObject(forKey: "publicKey")
                defaults.removeObject(forKey: "privateKey")
                bridges = bridges2;
                
                if #available(iOS 9.0, *)
                {
                    let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
                    let date = NSDate(timeIntervalSince1970: 0)
                    
                    WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
                }
                else
                {
                    var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
                    libraryPath += "/Cookies"
                    
                    do {
                        try FileManager.default.removeItem(atPath: libraryPath)
                    } catch {
                        print("error")
                    }
                    URLCache.shared.removeAllCachedResponses()
                }
                let url = Bundle.main.url(forResource: "index2", withExtension: "html", subdirectory: "website")!
                webView.loadFileURL(url, allowingReadAccessTo: url)
                let request = URLRequest(url: url)
                webView.load(request)

                print("unset")
                
            }
            if(messageBody == "startIndex"){
                if let privateKey = defaults.string(forKey: "privateKey") {
                    webView.evaluateJavaScript("setData('privateKey', `"+privateKey+"`);") { (result, error) in
                        print(result ?? error ?? "hello")
                    }
                }
                if let publicKey = defaults.string(forKey: "publicKey") {
                    webView.evaluateJavaScript("setData('publicKey', `"+publicKey+"`);") { (result, error) in
                        print(result ?? error ?? "hello")
                    }
                }
                if let bridge = defaults.string(forKey: "bridge") {
                    webView.evaluateJavaScript("setData('bridge', `"+bridge+"`);") { (result, error) in
                        print(result ?? error ?? "hello")
                    }
                }
                if(exists(key: "token")){
                    if let token = defaults.string(forKey: "token") {
                        webView.evaluateJavaScript("setData('token', `"+token+"`);") { (result, error) in
                            print(result ?? error ?? "hello")
                        }
                        webView.evaluateJavaScript("setSocketToken(`"+token+"`);") { (result, error) in
                            print(result ?? error ?? "xxQ")
                            print("set user 11!")

                        }
                    }
                    if let userPrivate1 = defaults.string(forKey: "userPrivate") {
                        webView.evaluateJavaScript("setData('userPrivate', `"+userPrivate1+"`);") { (result, error) in
                            print(result ?? error ?? "gb")
                            print("set user private")
                        }
                    }
                    if let userPublic1 = defaults.string(forKey: "userPublic") {
                        webView.evaluateJavaScript("setData('userPublic', `"+userPublic1+"`);") { (result, error) in
                            print(result ?? error ?? "gb")
                            print("set user public")
                        }
                    }
                    webView.evaluateJavaScript("doChats()") { (result, error) in
                    print(result ?? error ?? "hello")
                        self.webView.evaluateJavaScript("go('chatsPage')") { (result, error) in
                            print(result ?? error ?? "hello")
                            
                        }
                }
                   
                }else{
                    webView.evaluateJavaScript("go('welcomePage');") { (result, error) in
                        print(result ?? error  ?? "hello")
                        
                    }
                }
            }
  
        }
        
    }
    
}
func exists(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}
