//
//  HomeViewController.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 26.07.2021..
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var sharedVM: HomeViewModel
    var portfolioVM: PortfolioViewModel
    
    init(viewModel: HomeViewModel, portfolioVM: PortfolioViewModel) {
        self.sharedVM = viewModel
        self.portfolioVM = portfolioVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let portfolioBalanceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = .black
        return label
    }()
    
    private let portfolioBalanceTextLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "Portfolio balance"
        return label
    }()
    
    private let watchListTextLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .black
        label.text = "Watchlist"
        return label
    }()
    
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.attributedTitle = NSAttributedString(string: "Pull to refresh")
        return control
    }()
    
    private let progressCryptoFavs: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .large)
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private let topMoversTextLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .black
        label.text = "Top movers"
        return label
    }()
    
    private let progressCryptoMovers: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .large)
    }()
    
    private let moversTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViewModel()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
}

private extension HomeViewController {
    
    func loadData() {
        sharedVM.loadCryptosSubject.onNext(())
        portfolioVM.loadPortfolioSubject.onNext(())
    }
    
}

private extension HomeViewController {
    
    func setupViewModel(){
        sharedVM.reloadTableDelegate = self
        
        disposeBag.insert(sharedVM.initializeObservables())
        disposeBag.insert(portfolioVM.initializeObservables())
        
        initPortfolioObservable(subject: portfolioVM.portfolioDataRelay).disposed(by: disposeBag)
        initializeCryptoDataObservable(subject: sharedVM.cryptosDataRelay).disposed(by: disposeBag)
        initializeFavsLoaderObservable(subject: sharedVM.loaderSubject).disposed(by: disposeBag)
        initCryptoMoversObs(subject: sharedVM.moversDataRelay).disposed(by: disposeBag)
    }
    
    func initPortfolioObservable(subject: BehaviorRelay<Portfolio>) -> Disposable {
        return subject
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .subscribe(onNext: { [unowned self] (portfolio) in
                portfolioBalanceLabel.text = "$\(round(portfolio.currPortfolioRecord.balance * 100)/100)"
            }, onError: { error in
                print("error: \(error)")
            })
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
    
    func initCryptoMoversObs(subject: BehaviorRelay<[Crypto]>) -> Disposable {
        return subject
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .subscribe(onNext: { [unowned self] (items) in
                if !items.isEmpty {
                    self.moversTableView.reloadData()
                }
            }, onError: { error in
                print("error: \(error)")
            })
    }
    
    func initializeFavsLoaderObservable(subject: ReplaySubject<Bool>) -> Disposable {
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

private extension HomeViewController {
    
    func setupUI(){
        view.addSubview(tableView)
        view.addSubview(watchListTextLabel)
        view.addSubview(progressCryptoFavs)
        view.addSubview(portfolioBalanceTextLabel)
        view.addSubview(portfolioBalanceLabel)
        view.addSubview(topMoversTextLabel)
        view.addSubview(moversTableView)
        view.addSubview(progressCryptoMovers)
        
        view.backgroundColor = .white
        setupTableViews()
        setupConstraints()
    }
    
    func setupConstraints() {
        let safeLayout = view.layoutMarginsGuide
        
        portfolioBalanceTextLabel.snp.makeConstraints{ make in
            make.top.equalTo(safeLayout).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        portfolioBalanceLabel.snp.makeConstraints{ make in
            make.leading.equalTo(portfolioBalanceTextLabel)
            make.top.equalTo(portfolioBalanceTextLabel.snp.bottom).offset(8)
        }
        
        watchListTextLabel.snp.makeConstraints{ make in
            make.leading.equalTo(portfolioBalanceLabel)
            make.top.equalTo(portfolioBalanceLabel.snp.bottom).offset(16)
        }
        
        progressCryptoFavs.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }
        
        tableView.snp.makeConstraints{ make in
            make.top.equalTo(watchListTextLabel.snp.bottom).offset(8)
            make.height.equalToSuperview().dividedBy(2.5)
            make.leading.trailing.equalToSuperview()
        }
        
        topMoversTextLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(tableView.snp.bottom).offset(16)
        }
        
        moversTableView.snp.makeConstraints { make in
            make.top.equalTo(topMoversTextLabel.snp.bottom).offset(16)
            make.bottom.equalTo(safeLayout)
            make.leading.trailing.equalToSuperview()
        }
        
        progressCryptoMovers.snp.makeConstraints { make in
            make.center.equalTo(moversTableView)
        }
    }
    
}

private extension HomeViewController {
    
    private func setupTableViews() {
        tableView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
        registerWatchlistCells()
        
        moversTableView.delegate = self
        moversTableView.dataSource = self
        registerMoversCells()
        
        setupRefreshControl()
    }
    
    private func registerWatchlistCells(){
        tableView.register(CryptoCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func registerMoversCells(){
        moversTableView.register(CryptoCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupRefreshControl(){
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    @objc func refreshData(_ sender: AnyObject){
        sharedVM.loadCryptosSubject.onNext(())
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return sharedVM.cryptosDataRelay.value.count
        }
        return sharedVM.moversDataRelay.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CryptoCell else {
            return UITableViewCell()
        }
        
        var crypto: Crypto
        
        if tableView == self.tableView {
            crypto = sharedVM.cryptosDataRelay.value[indexPath.row]
        } else {
            crypto = sharedVM.moversDataRelay.value[indexPath.row]
        }
        
        cell.configureCell(crypto: crypto)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var crypto: Crypto
        
        if tableView == self.tableView {
            crypto = sharedVM.cryptosDataRelay.value[indexPath.row]
        } else {
            crypto = sharedVM.moversDataRelay.value[indexPath.row]
        }
        
        let pickCryptoVC = DetailsViewController(portfolioVM: portfolioVM, detailsVM: DetailsViewModelImpl(), crypto: crypto)
        self.navigationController?.pushViewController(pickCryptoVC, animated: true)
    }
}


extension HomeViewController: ReloadTableViewDelegate {
    func reloadTableView() {
        tableView.reloadData()
        moversTableView.reloadData()
    }
}

extension HomeViewController {
    
    func showLoader() {
        progressCryptoFavs.isHidden = false
        progressCryptoFavs.startAnimating()
        
        progressCryptoMovers.isHidden = false
        progressCryptoMovers.startAnimating()
    }
    
    func hideLoader() {
        progressCryptoFavs.isHidden = true
        progressCryptoFavs.stopAnimating()
        
        progressCryptoMovers.isHidden = true
        progressCryptoMovers.stopAnimating()
        
        refreshControl.endRefreshing()
    }
}

