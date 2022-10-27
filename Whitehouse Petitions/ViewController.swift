//
//  ViewController.swift
//  Whitehouse Petitions
//
//  Created by Melis Yazıcı on 22.10.22.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var filterKeyword: String = "" // empty string for no filter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "White House Petitions"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(askFilter))
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }
    
    @objc func fetchJSON() {
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
        
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    @objc func askFilter() {
        let ac = UIAlertController(title: "Filter", message: "Filter the petitions", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) {
            [weak self, weak ac] _ in
            self?.filterKeyword = ac?.textFields?[0].text ?? ""
            self?.performSelector(inBackground: #selector(ViewController.filterData), with: nil)
        })
        
        present(ac, animated: true)
    }
    
    @objc func filterData() {
        
        var filterTitle: String
        
        if filterKeyword.isEmpty {
            filterTitle = "Filter"
            
            filteredPetitions = petitions
        } else {
            filterTitle = "Filter (current: \(filterKeyword)"
            
            filteredPetitions = petitions.filter() { petition in
                if let _ = petition.title.range(of: filterKeyword, options: .caseInsensitive) {
                    return true
                }
                if let _ = petition.body.range(of: filterKeyword, options: .caseInsensitive) {
                    return true
                }
                return false
            }
        }
        performSelector(onMainThread: #selector(filterDataGuiUpdate), with: filterTitle, waitUntilDone: false)
    }
    
    @objc func filterDataGuiUpdate(filterTitle: String) {
        navigationItem.leftBarButtonItem?.title = filterTitle
        tableView.reloadData()
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "Petitions from WE the PEOPLE at petitions.whitehouse.gov", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func showError() {
        let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.result
            //            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            filterData()
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

