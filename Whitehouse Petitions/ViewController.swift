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
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        
        title = "White House Petitions"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(askFilter))
        
        // push code to a background thread - it's OK to parse the JSON on a background thread
        // by downloading data from the internet in viewDidLoad() will lock up until all the data has been transferred so it's gonna block the UI therefore i am using here one of the GCD functions, which allows me to fetch the data without locking up the UI
        DispatchQueue.global(qos: .userInitiated).async { // userInitiated: this will execute tasks requested by the user that they are now waiting for in order to continue using the app
            [weak self] in // "[weak self] in" it isn't necessary here because Grand Central Dispatch (GCD) runs the code once then throws it away but I wrote it anyway
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) { // Data's contentsOf to download data from the internet, which is what's known as a blocking call. It blocks execution of any further code in the method until it has connected to the server and fully downloaded all the data, that's why i am using above DispatchQueue.global(qos: .userInitiated).async
                    self?.parse(json: data)
                    return // because it's returning from the closure that was being executed asynchronously, it effectively does nothing, therefore regardless of whether the download succeeds or fails, the showError() down below will be called. And if the download succeeds, the JSON will be parsed on the background thread and the table view's reloadData() will be called on the background thread (which is absolutely NOT OK) and the error will be shown regardless
                }
            }
            // it will no longer blocks the main thread while the JSON downloads from the internet but therefore now I am pushing work to the background thread and any further code called in that work ( which is func parse(json: Data) and func showError() ) will also be on the background thread so I fixed those too
            
            // to stop showError() being called regardless of the result of fetch call I moved the showError here in DispatchQueue.global() in viewDidLoad()
                self?.showError() // and because it is inside a closure now, I added "self." to make capturing clear
            // Now the showError runs in the background thread but inside showError() method there is UIAlertController that means now UI work happening on a background thread which is NOT OK so I fixed the method too down there
            
            // I moved the showError right above
        }
    }
    
    @objc func askFilter() {
        let ac = UIAlertController(title: "Filter", message: "Filter the petitions", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) {
            [weak self, weak ac] _ in
            self?.filterKeyword = ac?.textFields?[0].text ?? ""
            self?.filterData()
            self?.tableView.reloadData()
        })
        
        present(ac, animated: true)
    }
    
    func filterData() {
        if filterKeyword.isEmpty {
            filteredPetitions = petitions
            navigationItem.leftBarButtonItem?.title = "Filter"
            return
        }
        
        navigationItem.leftBarButtonItem?.title = "Filter (current: \(filterKeyword)"
        
        filteredPetitions = petitions.filter({ petition in
            if let _ = petition.title.range(of: filterKeyword, options: .caseInsensitive) {
                return true
            }
            if let _ = petition.body.range(of: filterKeyword, options: .caseInsensitive) {
                return true
            }
            return false
        })
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "Petitions from WE the PEOPLE at petitions.whitehouse.gov", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func showError() {
        // because I moved showError() inside DispatchQueue.global() in viewDidLoad() the UI work happening on a background so I had to modify showError() to push that work back to the main thread
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true) // now it is inside a closure, I added "self." to make capturing clear
        }
        
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.result
            
            // push code back to the main thread - update the UI safely on the main thread
            // Here the table view reloaded and because of it's never OK to do UI work on the background thread i place the async() here so the code execute on the main thread
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
            
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

