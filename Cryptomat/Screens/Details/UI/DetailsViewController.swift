//
//  DetailsViewController.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 08.08.2021..
//

import UIKit
import SnapKit
import Charts

class DetailsViewController: UIViewController {
    
    
    private var portfolioVM: PortfolioViewModel
    private var detailsVM: DetailsViewModel
    private var crypto: Crypto
    private var isCryptoFav = false
    
    
    init(portfolioVM: PortfolioViewModel, detailsVM: DetailsViewModel, crypto: Crypto) {
        self.portfolioVM = portfolioVM
        self.detailsVM = detailsVM
        self.crypto = crypto
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let favButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "StarEmpty"), for: .normal)
        return button
    }()
    
    private let lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        
        let yAxis = chartView.leftAxis
        yAxis.drawAxisLineEnabled = false
        yAxis.drawGridLinesEnabled = false
    
        
        let xAxis = chartView.xAxis
        xAxis.drawGridLinesEnabled = false
        xAxis.labelPosition = .bottom
        xAxis.setLabelCount(6, force: false)
        xAxis.valueFormatter = MyCustomFormatter()
        
        return chartView
    }()
    
    private let assetView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 12
        return view
    }()
    private let assetName: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let balanceInUSD = UILabel()
    
    private let balanceInCoin = UILabel()
    
    private let tradeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("TRADE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let maxSupplyTitle: UILabel = {
        let label = UILabel()
        label.text = "Max supply"
        return label
    }()
    
    private let maxSupplyValue = UILabel()
    
    private let circulatingSupplyTitle: UILabel = {
        let label = UILabel()
        label.text = "Circulating supply"
        return label
    }()
    
    private let circulatingSupplyValue = UILabel()
    
    private let totalSupplyTitle: UILabel = {
        let label = UILabel()
        label.text = "Total supply"
        return label
    }()
    
    private let totalSupplyValue = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
}

extension DetailsViewController {
    func loadData(){
        let asset = portfolioVM.getAsset(crypto: crypto)
        
        assetName.text = crypto.name + " Wallet"
        balanceInUSD.text = "$\(roundUp(asset?.amountInUSD ?? 0))"
        balanceInCoin.text = "\(roundUp(asset?.amount ?? 0)) \(crypto.symbol)"
        maxSupplyValue.text = "\(crypto.max_supply ?? 0)"
        circulatingSupplyValue.text = "\(crypto.circulating_supply ?? 0)"
        totalSupplyValue.text = "\(crypto.total_supply ?? 0)"
        
        
        setupChart()
    }
    
    func setupChart(){
        let yValues = detailsVM.getGeneratedData(startingValue: crypto.quote?.USD.price ?? 0)
        
        let set1 = LineChartDataSet(entries: yValues)
        set1.drawCirclesEnabled = false
        set1.mode = .cubicBezier
        set1.lineWidth = 3
        set1.setColor(.systemBlue)
        set1.fill = Fill(color: .systemBlue)
        set1.fillAlpha = 0.6
        set1.drawFilledEnabled = true
        set1.highlightColor = .black
        set1.highlightLineWidth = 1

        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }
}

extension DetailsViewController {
    func roundUp(_
                    double: Double)-> Double{
        return round(100*double)/100
    }
}

extension DetailsViewController {
    
    func setupUI(){
        view.backgroundColor = .white
        view.addSubview(favButton)
        view.addSubview(lineChartView)
        view.addSubview(assetView)
        view.addSubview(assetName)
        view.addSubview(balanceInUSD)
        view.addSubview(balanceInCoin)
        view.addSubview(tradeButton)
        view.addSubview(maxSupplyTitle)
        view.addSubview(maxSupplyValue)
        view.addSubview(circulatingSupplyTitle)
        view.addSubview(circulatingSupplyValue)
        view.addSubview(totalSupplyTitle)
        view.addSubview(totalSupplyValue)
        setupConstraints()
        setupClicks()
        setupFavButton()
    }
    
    func setupConstraints(){
        let safeLayout = view.layoutMarginsGuide
        
        
        lineChartView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(32)
            make.width.equalToSuperview()
            make.top.equalTo(safeLayout).offset(8)
            make.height.equalTo(300)
        }
        
        assetView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(lineChartView.snp.bottom).offset(16)
            make.height.equalTo(60)
            
        }
        
        assetName.snp.makeConstraints { make in
            make.centerY.equalTo(assetView)
            make.leading.equalTo(assetView).offset(16)
        }
        
        balanceInUSD.snp.makeConstraints { make in
            make.bottom.equalTo(assetView.snp.centerY)
            make.trailing.equalTo(assetView).offset(-12)
        }
        
        balanceInCoin.snp.makeConstraints { make in
            make.top.equalTo(assetView.snp.centerY)
            make.trailing.equalTo(assetView).offset(-12)
        }
        
        tradeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(assetView.snp.bottom).offset(16)
            make.height.equalTo(60)
        }
        
        maxSupplyTitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(tradeButton.snp.bottom).offset(16)
        }
        
        maxSupplyValue.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(maxSupplyTitle)
        }
        
        circulatingSupplyTitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(maxSupplyTitle.snp.bottom).offset(16)
        }
        
        circulatingSupplyValue.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(circulatingSupplyTitle)
        }
        
        totalSupplyTitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(circulatingSupplyTitle.snp.bottom).offset(16)
        }
        
        totalSupplyValue.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(totalSupplyTitle)
        }
        
    }
    
    
    
}

extension DetailsViewController {
    
    func setupClicks(){
        tradeButton.setOnClickListener {
            let pickCryptoVC = ExchangeViewController(portfolioVM: self.portfolioVM, fromCrypto: self.crypto)
            self.navigationController?.pushViewController(pickCryptoVC, animated: true)
        }
        
        favButton.setOnClickListener {
            let defaults = UserDefaults.standard
            self.isCryptoFav = !self.isCryptoFav
            if !self.isCryptoFav {
                self.favButton.setImage(UIImage(named: "StarEmpty"), for: .normal)
                defaults.setValue(false, forKey: self.crypto.name)
            }else {
                self.favButton.setImage(UIImage(named: "StarFull"), for: .normal)
                defaults.setValue(true, forKey: self.crypto.name)
            }
        }
    }
    
    func refreshFavButton(){
        if isCryptoFav {
            favButton.setImage(UIImage(named: "StarFull"), for: .normal)
        } else {
            favButton.setImage(UIImage(named: "StarEmpty"), for: .normal)
        }
        
    }
    
    func setupFavButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favButton)
        checkIfFav()
    }
    
    func checkIfFav(){
        let defaults = UserDefaults.standard
        isCryptoFav = defaults.bool(forKey: crypto.name)
        refreshFavButton()
        
    }
    
}
