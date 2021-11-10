//
//  WebViewController.swift
//  GitRepoSearch
//
//  Created by BaganIT on 11/10/21.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var webView:WKWebView!
    
    var passUrl:String!
    var passTitle:String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = passTitle
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.openInSafari))
        
        self.loadWebView()
    }
    
    func loadWebView(){
        
        webView = WKWebView()
        view = webView
        
        let url = URL(string: passUrl)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        
        
    }
    
    @objc func openInSafari() {
        
        guard let url = URL(string: passUrl) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
