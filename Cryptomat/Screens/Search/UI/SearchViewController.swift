//
//  SearchViewController.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 08.08.2021..
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var sharedVM: SearchViewModel
    
    var isSelectScreen: Bool = false
    var type: CryptoPick?
    weak var pickDelegate: PickCryptoDelegate?
    
    init(viewModel: SearchViewModel,
         isSelectScreen: Bool = false,
         type: CryptoPick? = nil,
         pickDelegate: PickCryptoDelegate? = nil) {
        
        self.sharedVM = viewModel
        self.isSelectScreen = isSelectScreen
        self.pickDelegate = pickDelegate
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let progressView: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .large)
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViewModel()
        loadData()
    }
    
}

extension SearchViewController {
    
    func loadData() {
        sharedVM.loadCryptosSubject.onNext(SearchQuery(text: nil, type: .All))
    }
    
}

extension SearchViewController{
    
    func setupViewModel(){
        sharedVM.reloadTableDelegate = self
        
        disposeBag.insert(sharedVM.initializeObservables())
        initializeCryptoDataObservable(subject: sharedVM.cryptosDataRelay).disposed(by: disposeBag)
        initializeLoaderObservable(subject: sharedVM.loaderSubject).disposed(by: disposeBag)
    }
    
    
    func initializeCryptoDataObservable(subject: BehaviorRelay<[Crypto]>) -> Disposable {
        return subject
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .subscribe(onNext: { [unowned self] (items) in
                if !items.isEmpty {
                    self.tableView.reloadData()
                }
            }, onError: { error in
                print("error: \(error)")
            })
            
    }
    func initializeLoaderObservable(subject: ReplaySubject<Bool>) -> Disposable {
        return subject
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .subscribe(onNext: { [unowned self] (status) in
                if status {
                    showLoader()
                } else {
                    hideLoader()
                }
            })
    }
    
}

extension SearchViewController {
    
    func setupUI(){
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(progressView)
        setupConstraints()
        setupTableView()
    }
    
    func setupConstraints(){
        let safeLayout = view.layoutMarginsGuide
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(safeLayout)
        }
        
        progressView.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }
    }
    
}


private extension SearchViewController {
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        registerCells()
        setupSearch()
    }
    
    private func registerCells(){
        tableView.register(CryptoCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupSearch(){
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search cryptocurrencies"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = CryptoType.allCases.map { type in type.rawValue}
        searchController.searchBar.delegate = self
    }
    
}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchBar = searchController.searchBar
        let type = CryptoType(rawValue: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]) ?? .All
        
        sharedVM.loadCryptosSubject.onNext(SearchQuery(text: searchController.searchBar.text, type: type))
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        let type = CryptoType(rawValue: searchBar.scopeButtonTitles![selectedScope]) ?? .All
        
        sharedVM.loadCryptosSubject.onNext(SearchQuery(text: searchBar.text, type: type))
        
      }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedVM.cryptosDataRelay.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CryptoCell else {
            return UITableViewCell()
        }
        
        let crypto = sharedVM.cryptosDataRelay.value[indexPath.row]
        
        
        cell.configureCell(crypto: crypto)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (isSelectScreen) {
            switch type! {
                case .TO:
                    pickDelegate?.setToCrypto(toCrypto: sharedVM.cryptosDataRelay.value[indexPath.row])
                case .FROM:
                    pickDelegate?.setFromCrypto(fromCrypto: sharedVM.cryptosDataRelay.value[indexPath.row])
            }
            navigationController?.popViewController(animated: true)
        }
    }
    
}

extension SearchViewController: ReloadTableViewDelegate {
    func reloadTableView() {
        tableView.reloadData()
    }
}

extension SearchViewController {
    
    func showLoader() {
        progressView.isHidden = false
        progressView.startAnimating()
    }
    
    func hideLoader() {
        progressView.isHidden = true
        progressView.stopAnimating()
    }
    
}
