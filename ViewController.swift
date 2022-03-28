//
//  ViewController.swift
//  NewsApp
//
//  Created by Eclectics on 18/03/2022.
//

import UIKit
import SafariServices

//Tableview to show news
//Custom cell
//Api caller
//Open the news story
//Search for the news story
class ViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsTableViewCell.self,
                       forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()
    
    private let searchVC = UISearchController(searchResultsController: nil)
    
    private var viewModels = [NewsTableViewCellViewModel]()
    private var articles = [Article]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
        
        fetchTopStories()
        createSearchBar()
    }
    
    private func createSearchBar(){
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
        
    }
    
    private func fetchTopStories(){
        
        APICaller.shared.getTopStories{[weak self] result in
            switch result{
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(
                        title: $0.title,
                        subtitle: $0.description ?? "No description", //subtitle is an optional with a default value of "no description"
                        imageURL: URL(string: $0.urlToImage ?? ""))
                    
                })
                
                //refresh tableview
                DispatchQueue.main.async{
                    self?.tableView.reloadData()
                }
                break
            case .failure(let error):
                print(error)
                break
            default:
                break
            }
            
        }
        
    }
    
    
    //give cell a frame
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //Table view functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsTableViewCell.identifier,
            for:indexPath) as? NewsTableViewCell else {
                fatalError()
            }
//        cell.textLabel?.text = "Something"
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,animated: true)
        //get the article that a user clicked on
        let article = articles[indexPath.row]
        
        //get the article url
        guard let url = URL(string: article.url ?? "") else{return}
        //if we get the article use safari controller to present the news article
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    //make cells taller than their standard height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    //Search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //get text in the search bar
        guard let text = searchBar.text, !text.isEmpty else{ return }
        //print out what the user typed in search bar
        print(text)
        
        //make API call
         
        APICaller.shared.search(with: text){[weak self] result in
            switch result{
            case .success(let articles):
                //hold on to articles
                self?.articles = articles
                //create viewmodels out of the articles
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(
                        title: $0.title,
                        subtitle: $0.description ?? "No description", //subtitle is an optional with a default value of "no description"
                        imageURL: URL(string: $0.urlToImage ?? ""))
                    
                })
                
                //refresh tableview
                DispatchQueue.main.async{
                    self?.tableView.reloadData()
                    self?.searchVC.dismiss(animated: true, completion: nil)
                    
                }
                break
                //print error incase of failure
            case .failure(let error):
                print(error)
                break
            default:
                break
            }
            
        }
    }

}

