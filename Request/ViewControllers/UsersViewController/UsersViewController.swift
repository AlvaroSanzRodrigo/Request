//
//  UsersViewController.swift
//  Request
//
//  Created by Álvaro Sanz Rodrigo on 14/11/18.
//  Copyright © 2018 Álvaro Sanz Rodrigo. All rights reserved.
//

import UIKit
import Alamofire
class UsersViewController: UIViewController {
    var usersArray: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        getCommentAlamofire()
        registerCells()
    }
    @IBOutlet weak var tableView: UITableView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    private func registerCells(){
        let identifier = "PostTableViewCell"
        let cellNib = UINib(nibName: identifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: identifier)
    }
    
    internal func getCommentAlamofire() {
        Alamofire.request("https://jsonplaceholder.typicode.com/users", method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseData { (response) in
            if let jsonData = response.data {
                let decoder = JSONDecoder()
                do {
                    let comments = try decoder.decode([User].self, from: jsonData)
                    self.usersArray = comments
                    print("Total post using Alamofire:", comments.count)
                }
                catch let error {
                    print("Error:", error.localizedDescription)
                }
                
            }
            self.tableView.reloadData()
        }
    }

}
extension UsersViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let user = usersArray[indexPath.row]
        let lat = Double(user.address.geo.lat)
        let lng = Double(user.address.geo.lng)
        let mapVC = MapViewController(lat: lat, lng: lng)
        navigationController?.pushViewController(mapVC, animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PostTableViewCell = (tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as? PostTableViewCell)!
        let user = usersArray[indexPath.row]
        cell.lblTitle.text = user.name + " " + user.email
        return cell
    }
}


