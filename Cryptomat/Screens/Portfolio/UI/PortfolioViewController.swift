//
//  PortfolioViewController.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 07.08.2021..
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Charts

class PortfolioViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var portfolioVM: PortfolioViewModel
    
    init(viewModel: PortfolioViewModel) {
        portfolioVM = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        xAxis.setLabelCount(3, force: false)
        xAxis.valueFormatter = PortfolioDateFormatter()
        
        return chartView
    }()
    
    private let portfolioBalanceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = .black
        label.text = "fiat:"
        return label
    }()
    
    private let fiatBalanceText: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .gray
        return label
    }()
    
    private let fiatBalanceValue: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .darkGray
        return label
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("reset", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let assetsTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupChart()
        portfolioVM.loadPortfolioSubject.onNext(())
    }
    
}

extension PortfolioViewController {
    func setupChart(){
        
        var yValues = [ChartDataEntry]()
        
        for record in portfolioVM.portfolioDataRelay.value.portfolioRecords {
            yValues.append(ChartDataEntry(x: record.timestamp, y: record.balance))
        }
        
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

extension PortfolioViewController {
    func loadData(){
        portfolioVM.loadPortfolioSubject.onNext(())
        setupObservables()
    }
    
    func setupObservables(){
        disposeBag.insert(portfolioVM.initializeObservables())
        initPortfolioObservable(subject: portfolioVM.portfolioDataRelay).disposed(by: disposeBag)
    }
    
    func initPortfolioObservable(subject: BehaviorRelay<Portfolio>) -> Disposable {
        return subject
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .subscribe(onNext: { [unowned self] (portfolio) in
                self.putDataOnScreen(portfolio)
            }, onError: { error in
                print("error: \(error)")
            })
    }
}

extension PortfolioViewController {
    func putDataOnScreen(_ portfolio: Portfolio) {
        portfolioBalanceLabel.text = "$\(round(100*portfolio.currPortfolioRecord.balance)/100)"
        fiatBalanceValue.text = "$\(round(100*portfolio.currPortfolioRecord.fiatBalance)/100)"
        assetsTableView.reloadData()
    }
}

extension PortfolioViewController {
    
    func setupUI(){
        view.backgroundColor = .white
        view.addSubview(lineChartView)
        view.addSubview(portfolioBalanceLabel)
        view.addSubview(fiatBalanceText)
        view.addSubview(fiatBalanceValue)
        view.addSubview(resetButton)
        view.addSubview(assetsTableView)
        setupConstraints()
        setupTableView()
        setupClicks()
    }
    
    func setupConstraints(){
        let safeLayout = view.layoutMarginsGuide
        
        
        lineChartView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(32)
            make.width.equalToSuperview()
            make.top.equalTo(safeLayout).offset(16)
            make.height.equalTo(300)
        }
        
        portfolioBalanceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(lineChartView.snp.bottom).offset(16)
        }
        
        fiatBalanceText.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(portfolioBalanceLabel.snp.bottom).offset(8)
        }
        
        fiatBalanceValue.snp.makeConstraints { make in
            make.leading.equalTo(fiatBalanceText.snp.trailing).offset(8)
            make.centerY.equalTo(fiatBalanceText)
        }

        resetButton.snp.makeConstraints { make in
            make.top.equalTo(portfolioBalanceLabel).offset(12)
            make.bottom.equalTo(assetsTableView.snp.top).offset(-12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        assetsTableView.snp.makeConstraints { make in
            make.top.equalTo(portfolioBalanceLabel.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
}

extension PortfolioViewController {
    
    func setupTableView(){
        assetsTableView.delegate = self
        assetsTableView.dataSource = self
        registerAssetsCells()
    }
    func registerAssetsCells(){
        assetsTableView.register(AssetCell.self, forCellReuseIdentifier: "assetCell")
    }
    
}

extension PortfolioViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = portfolioVM.portfolioDataRelay.value.currPortfolioRecord.assets.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "assetCell", for: indexPath) as? AssetCell else {
                return UITableViewCell()
            }
            
            let assets = portfolioVM.portfolioDataRelay.value.currPortfolioRecord.assets
            let asset = assets[indexPath.row]
            cell.configureCell(asset: asset)
            return cell
        
        
       
    }
    
}

extension PortfolioViewController {
    func setupClicks(){
        resetButton.setOnClickListener {
            self.portfolioVM.reset()
            self.portfolioVM.loadPortfolioSubject.onNext(())
            self.setupChart()
        }
    }
}
