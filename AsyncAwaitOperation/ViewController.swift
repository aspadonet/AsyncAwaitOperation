//
//  ViewController.swift
//  AsyncAwaitOperation
//
//  Created by Alexander Avdacev on 11.04.22.
//

import UIKit

struct User: Codable {
    let name: String
}

class ViewController: UIViewController, UITableViewDataSource {
    
    let url = URL(string: "https://jsonplaceholder.typicode.com/users")
    
    var users = [User]()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
    
    enum MyError: Error {
        case failedToGetUsers
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        
        Task{
            let result = await fetchUsers()
            
            switch result {

            case .success(let users):
                self.users = users
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func fetchUsers() async -> Result<[User], Error> {
        guard let url = url else { return .failure(MyError.failedToGetUsers) }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let users = try JSONDecoder().decode([User].self, from: data)
            return .success(users)
        }catch{
            return .failure(error)
        }
    }

}

