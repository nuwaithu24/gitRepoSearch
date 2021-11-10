//
//  SearchRepoViewController.swift
//  GitRepoSearch
//
//  Created by BaganIT on 11/10/21.
//

import UIKit

class SearchRepoViewController: UIViewController {

    @IBOutlet weak var mainTB: UITableView!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var searchDatas = [Items]()
    
    var searchBar = UISearchBar()
    
    var currentPage = 1
    
    var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //forLoading
        self.indicatorView.hidesWhenStopped = true
        self.indicatorView.isHidden = true
        
        //connectTableViewDelegate&DataSource
        self.mainTB.delegate = self
        self.mainTB.dataSource = self
        
        setUpNavBar()
        
        hideKeyboardWhenTappedAround()
    }
    
    func setUpNavBar(){
        
        //addSearchBarInNavigationBar
        self.searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
    }
    
    func fetchSearchDatas(searchText:String,page:Int){
        print(searchText,"T")
        API().getSearchRepo(query: searchText, page: page) { (response, error, code) in
            
            DispatchQueue.main.async {
                if error == nil {
                    
                    if code == 200 {
                        
                        if let res = response, let items = res.items {
                            if items.count > 0 {
                                self.searchDatas.append(contentsOf: items)
                                self.mainTB.reloadData()
                                self.indicatorView.stopAnimating()
                            }
                            else {
                                self.indicatorView.stopAnimating()
                            }
                        }
                        
                    }
                    else {
                        switch code {
                        case 304:
                            self.showErrorMessageAlert(message: "Not Modified")
                        case 422:
                            self.showErrorMessageAlert(message: "Unprocessable Entity")
                        case 503:
                            self.showErrorMessageAlert(message: "Service Unavailable")
                        default:
                            break
                        }
                    }
                    
                }
                else {
                    self.showErrorMessageAlert(message: "Fail")
                }
            }
           
        }
    }
    
    
    func showErrorMessageAlert(message:String){
        self.indicatorView.stopAnimating()
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func goWebView(urlString:String,title:String){
        
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let destinationVC = mainStoryBoard.instantiateViewController(withIdentifier: "webVC") as! WebViewController
        destinationVC.passUrl = urlString
        destinationVC.passTitle = title
        self.navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    

}

//MARK: - SearchBarDelegate
extension SearchRepoViewController :UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        
        if Reachability.isConnectedToNetwork(){
            if searchText != ""{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            
                        //clearSearchData
                        self.searchDatas.removeAll()
                        self.indicatorView.startAnimating()
                        self.searchText = searchText
                        self.fetchSearchDatas(searchText: searchText, page: 1)
                
        }
        }
        }
        else {
            self.showErrorMessageAlert(message: "No Internet Connection")
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.searchTextField.resignFirstResponder()
        if Reachability.isConnectedToNetwork(){
        if let text = searchBar.text, text != "" {
            //clearSearchData
            self.searchDatas.removeAll()
            self.indicatorView.startAnimating()
            self.searchText = text
            self.fetchSearchDatas(searchText: text, page: 1)
        }
        }
        else {
            self.showErrorMessageAlert(message: "No Internet Connection")
        }
        
    }
    
    
}


//MARK: - TableViewDataSource
extension SearchRepoViewController :UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        
        if self.searchDatas.count > 0 {
            if let name = self.searchDatas[indexPath.row].full_name {
                cell.textLabel?.text = name
            }
            else {
                cell.textLabel?.text = ""
            }
            if let language = self.searchDatas[indexPath.row].language {
                cell.detailTextLabel?.text = language
            }
            else {
                cell.detailTextLabel?.text = ""
            }
            
            if let starCount = self.searchDatas[indexPath.row].stargazers_count {
                let starLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
                starLabel.text = "\(starCount) Stars"
                starLabel.textAlignment = .left
                starLabel.sizeToFit()
                cell.accessoryView = starLabel
            }
            
            
           
        }
        
        return cell
    }
    
    
}

//MARK: - TableViewDelegate
extension SearchRepoViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == self.searchDatas.count - 2 {
            self.currentPage += 1
            self.indicatorView.startAnimating()
            self.fetchSearchDatas(searchText: searchText, page: self.currentPage)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let name = self.searchDatas[indexPath.row].full_name, let url = self.searchDatas[indexPath.row].html_url {
            self.goWebView(urlString: url, title: name)
        }
    }
}
