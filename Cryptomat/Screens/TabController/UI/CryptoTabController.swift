//
//  CryptoTabController.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 28.07.2021..
//

import UIKit

class CryptoTabController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupApp()
    }
    
    func setupApp() {
        
        let networkManager = NetworkManager()
        let cryptoRepository = CryptoRepositoryImpl(networkManager: networkManager)
        let homeVM = HomeViewModelImpl(cryptoRepository: cryptoRepository)
        let portfolioVM = PortfolioViewModelImpl(portfolioRepository: PortfolioRepositoryImpl())
        let searchVM = SearchViewModelImpl(repository: SearchRepositoryImpl(networkManager: networkManager))
        
        let homeScreen = HomeViewController(viewModel: homeVM, portfolioVM: portfolioVM)
        homeScreen.title = "Home"
        
        let exchangeScreen = ExchangeViewController(portfolioVM: portfolioVM)
        exchangeScreen.title = "Exchange"
    
        let portfolioScreen = PortfolioViewController(viewModel: portfolioVM)
        portfolioScreen.title = "Portfolio"
        
        let searchScreen = SearchViewController(viewModel: searchVM)
        searchScreen.title = "Search"
        
        self.viewControllers = [UINavigationController(rootViewController: homeScreen),
                                UINavigationController(rootViewController: exchangeScreen),
                                UINavigationController(rootViewController: portfolioScreen),
                                UINavigationController(rootViewController: searchScreen)]
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
}
