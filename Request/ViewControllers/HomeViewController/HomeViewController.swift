//
//  HomeViewController.swift
//  Request
//
//  Created by Álvaro Sanz Rodrigo on 7/11/18.
//  Copyright © 2018 Álvaro Sanz Rodrigo. All rights reserved.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController {
    
    var postsArray: [Post] = []

    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var txtUserIde: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    internal var filteredPost: [Post] = []
    let searchController = UISearchController(searchResultsController: nil)
    internal var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        setupBarButtonsItems()
        loadingView.isHidden = true
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    internal func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    internal func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    internal func filterContentForSearch(_ searchText: String){
        
        if let userID = Int(searchText){
            filteredPost = postsArray.filter({ (aPost: Post) -> Bool in
                return aPost.id == userID || aPost.title.lowercased().contains(searchText.lowercased())
            })
        }else {
            filteredPost = postsArray.filter({ (aPost: Post) -> Bool in
                return aPost.title.lowercased().contains(searchText.lowercased())
            })
        }
        
        tableView.reloadData()
    }
    
    @objc private func refreshControlPulled(){
        if let userID = Int(txtUserIde.text!){
            getPostAlamofire(userId: userID)
        }else{
            showAlertViewWithTitle("Error", message: "S olo puedes introducir numeros")
        }
    }
    
    private func setupBarButtonsItems(){
        let usersBarButton = UIBarButtonItem(title: "Users", style: .plain, target: self, action: #selector(usersPressed))
        navigationItem.setRightBarButton(usersBarButton, animated: false)
    }
    
    @objc private func usersPressed(){
        let usersVC = UsersViewController()
        navigationController?.pushViewController(usersVC, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func getPost(for userId: Int) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "jsonplaceholder.typicode.com"
        urlComponents.path = "/posts"
        
        let userIdItem = URLQueryItem(name: "userId", value: "\(userId)")
        urlComponents.queryItems = [userIdItem]
        guard let url = urlComponents.url else { fatalError("Could not create URL")}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData: Data?, response: URLResponse?, error: Error?) in
            if let errorResponse = error {
                print("Error:",errorResponse.localizedDescription)
            }
            else if let jsonData = responseData {
                let decoder = JSONDecoder()
                do {
                    let post = try decoder.decode([Post].self, from: jsonData)
                    print("total Items: ", post.count)
                }
                catch let error{
                    print("Error:",error.localizedDescription)
                }
            }
        }
        task.resume()
        
    }
    
    internal func getPostAlamofire(userId: Int) {
        self.loadingView.isHidden = true
        loadingView.startAnimating()
        Alamofire.request("https://jsonplaceholder.typicode.com/posts", method: HTTPMethod.get, parameters: ["userId" : userId], encoding: URLEncoding.default, headers: nil).responseData { (response) in
            if let jsonData = response.data {
            let decoder = JSONDecoder()
            do {
                let posts = try decoder.decode([Post].self, from: jsonData)
                self.postsArray = posts
                print("Total post using Alamofire:", posts.count)
            }
            catch let error {
                self.loadingView.isHidden = true
                self.loadingView.stopAnimating()
                self.refreshControl.endRefreshing()
                print("Error:", error.localizedDescription)
                }
            
            }
            self.loadingView.isHidden = true
            self.loadingView.stopAnimating()
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
        
    }
    @IBAction func AlamofireButton(_ sender: Any) {

        if let userID = Int(txtUserIde.text!){
            getPostAlamofire(userId: userID)
        }else{
            showAlertViewWithTitle("Error", message: "S olo puedes introducir numeros")
        }
        
    }
    
    internal func showAlertViewWithTitle(_ title: String, message: String){
        let  alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func registerCells(){
        let identifier = "PostTableViewCell"
        let cellNib = UINib(nibName: identifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: identifier)
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected ", indexPath.row)
        print(postsArray[indexPath.row].id!)
        let commentsVC = CommentsViewController(postId: postsArray[indexPath.row].id!)
        self.show(commentsVC, sender: true)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering(){
            return filteredPost.count
        }
        return postsArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell: PostTableViewCell = (tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as? PostTableViewCell)!
        if isFiltering() {
            let post = filteredPost[indexPath.row]
            cell.lblTitle.text = post.title
        }else{
            let post = postsArray[indexPath.row]
            cell.lblTitle.text = post.title
        }
        
        
            return cell
    }
}
extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchController.searchBar.text!)
    }
}

