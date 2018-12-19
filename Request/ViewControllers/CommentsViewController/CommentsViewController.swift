//
//  CommentsViewController.swift
//  Request
//
//  Created by Álvaro Sanz Rodrigo on 14/11/18.
//  Copyright © 2018 Álvaro Sanz Rodrigo. All rights reserved.
//

import UIKit
import Alamofire

class CommentsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var commentsArray: [Comment] = []
    var postId: Int?
    
    convenience init(postId: Int){
        self.init()
        self.postId = postId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCommentAlamofire(post: postId!)
        registerCells()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func registerCells(){
        let identifier = "CommentTableViewCell"
        let cellNib = UINib(nibName: identifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: identifier)
    }
    
    internal func getCommentAlamofire(post: Int) {
        Alamofire.request("https://jsonplaceholder.typicode.com/comments", method: HTTPMethod.get, parameters: ["postId" : post], encoding: URLEncoding.default, headers: nil).responseData { (response) in
            if let jsonData = response.data {
                let decoder = JSONDecoder()
                do {
                    let comments = try decoder.decode([Comment].self, from: jsonData)
                    self.commentsArray = comments
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
extension CommentsViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CommentTableViewCell = (tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell)!
        let comment = commentsArray[indexPath.row]
        cell.lblTitle.text = comment.name
        return cell
    }
}
