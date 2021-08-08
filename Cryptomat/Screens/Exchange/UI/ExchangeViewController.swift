//
//  ExchangeViewModel.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 07.08.2021..
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ExchangeViewController: UIViewController {
    
    private var fromCrypto: Crypto?
    private var toCrypto: Crypto?
    
    var disposeBag = DisposeBag()
    var portfolioVM: PortfolioViewModel
    
    private var isUsingFiat: Bool {
        get {
            return fromCryptoSymbol.text == "Fiat"
        }
    }
    
    init(portfolioVM: PortfolioViewModel, fromCrypto: Crypto? = nil) {
        self.portfolioVM = portfolioVM
        self.fromCrypto = fromCrypto
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = "$"
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Amount in USD"
        textField.borderStyle = .line
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.font = .systemFont(ofSize: 32)
        
        return textField
    }()
    
    private let fromBox: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let fromTextLabel: UILabel = {
        let label = UILabel()
        label.text = "from:"
        return label
    }()
    
    private let fromCryptoSymbol: UILabel = {
        let label = UILabel()
        label.text = "Pick"
        return label
    }()
    
    private let toBox: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let toTextLabel: UILabel = {
        let label = UILabel()
        label.text = "to:"
        return label
    }()
    
    private let toCryptoSymbol: UILabel = {
        let label = UILabel()
        label.text = "Pick"
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("Confirm transaction", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPortfolio()
    }
    
}

extension ExchangeViewController {
    func setupUI(){
        
        view.backgroundColor = .white
        view.addSubview(currencyLabel)
        view.addSubview(amountTextField)
        view.addSubview(fromBox)
        view.addSubview(fromTextLabel)
        view.addSubview(fromCryptoSymbol)
        view.addSubview(toBox)
        view.addSubview(toTextLabel)
        view.addSubview(toCryptoSymbol)
        view.addSubview(confirmButton)
        setupConstraints()
        
        checkIfCryptoWasPassed()
        
        addDoneButtonOnKeyboard()
        setupClicks()
    }
    
    func checkIfCryptoWasPassed(){
        if let safeFromCrypto = fromCrypto {
            setFromCrypto(fromCrypto: safeFromCrypto)
        }
    }
    
    func setupConstraints(){
        let safeLayout = view.layoutMarginsGuide
        
        currencyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(amountTextField)
            make.trailing.equalTo(amountTextField.snp.leading).offset(-8)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(safeLayout).offset(60)
        }
        
        fromBox.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
            make.top.equalTo(amountTextField.snp.bottom).offset(120)
            make.height.equalTo(64)
        }
        
        fromTextLabel.snp.makeConstraints { make in
            make.centerY.equalTo(fromBox)
            make.leading.equalTo(fromBox).offset(16)
        }
        
        fromCryptoSymbol.snp.makeConstraints { make in
            make.centerY.equalTo(fromBox)
            make.trailing.equalTo(fromBox).offset(-16)
        }
        
        toBox.snp.makeConstraints { make in
            make.top.equalTo(fromBox.snp.bottom).offset(64)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
            make.height.equalTo(64)
        }
        
        toTextLabel.snp.makeConstraints { make in
            make.centerY.equalTo(toBox)
            make.leading.equalTo(toBox).offset(16)
        }

        toCryptoSymbol.snp.makeConstraints { make in
            make.centerY.equalTo(toBox)
            make.trailing.equalTo(toBox).offset(-16)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeLayout).offset(-60)
        }
    }
    
    func addDoneButtonOnKeyboard(){
        
        let toolbar = UIToolbar()
        let maxButton = UIBarButtonItem(title: "Max", style: .plain, target: self, action: #selector(maxButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        
        toolbar.setItems([maxButton, flexSpace, doneButton], animated: true)
        toolbar.sizeToFit()
        
        amountTextField.inputAccessoryView = toolbar
        
    }
    
    @objc func maxButtonTapped(){
        var maxValue: Double
        
        if isUsingFiat {
            maxValue = portfolioVM.getAmount()
        } else {
            maxValue = portfolioVM.getAmount(crypto: fromCrypto)
        }
        
        amountTextField.text = "\(maxValue)"
    }
    
    @objc func doneButtonTapped(){
        view.endEditing(true)
    }

    
}

extension ExchangeViewController {
    
    func loadPortfolio(){
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
            .subscribe(onNext: { _ in
                
            }, onError: { error in
                print("error: \(error)")
            })
    }
    
}


extension ExchangeViewController {
    func setupClicks(){
        
        fromBox.setOnClickListener {
            
            self.createAlert("Fund option", "Which asset do you want to use?",[
                UIAlertAction(title: "Fiat", style: .default, handler: { _ in
                    self.fromCryptoSymbol.text = "Fiat"
                    self.fromCrypto = nil
                }),
                UIAlertAction(title: "Crypto", style: .default, handler: { _ in
                    let pickCryptoVC = SearchViewController(viewModel: SearchViewModelImpl(repository: SearchRepositoryImpl(networkManager: NetworkManager())), isSelectScreen: true, type: .FROM, pickDelegate: self)
                    self.navigationController?.pushViewController(pickCryptoVC, animated: true)
                }),
                UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ])
            
           
        }
        
        toBox.setOnClickListener {
            let pickCryptoVC = SearchViewController(viewModel: SearchViewModelImpl(repository: SearchRepositoryImpl(networkManager: NetworkManager())), isSelectScreen: true, type: .TO, pickDelegate: self)

            self.navigationController?.pushViewController(pickCryptoVC, animated: true)
        }
        
        confirmButton.setOnClickListener {
            self.confirmTransaction()
        }
        
    }
}



extension ExchangeViewController {
    
    func confirmTransaction(){
    
        if (fromCrypto == nil && !isUsingFiat) || toCrypto == nil{
            createAlert("Error", "You need to pick assets")
        }
        
        
        if fromCrypto?.name == toCrypto?.name {
            createAlert("Error", "You can't pick two same cryptos")
            return
        }
        
        guard let amountText = amountTextField.text,
              let amountInUSD = Double(amountText) else {
            createAlert("Error", "You need to input a number")
            return
            
        }
        
        var checkResponse: TransactionResponse
            
        if fromCryptoSymbol.text == "Fiat" {
            checkResponse = portfolioVM.transferFunds(toCrypto!, amountInUSD)
        }else {
            checkResponse = portfolioVM.transferFunds(fromCrypto!, toCrypto!, amountInUSD)
        }
        
        switch checkResponse {
            case .insufficientAmount:
                createAlert("Insufficient balance", "You don't have enough \(fromCrypto?.symbol ?? "Fiat").")
            case .success:
                amountTextField.text = ""
                createAlert("Success", "You successfully transfered $\(amountText) of \(fromCryptoSymbol.text!) to \(toCryptoSymbol.text!)!")
            case .unknownError:
                createAlert("Error", "An unknown error occurred")
        }
        
    }
    
}

extension ExchangeViewController {
    func createAlert(_ title: String, _ message: String, _ actions: [UIAlertAction] = [UIAlertAction(title: "Ok", style: .default, handler: nil)]){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alert.addAction(action)
        }
        

        present(alert, animated: true, completion: nil)
    }
}

extension ExchangeViewController: PickCryptoDelegate {
    
    func setFromCrypto(fromCrypto: Crypto) {
        self.fromCrypto = fromCrypto
        fromCryptoSymbol.text = fromCrypto.symbol
    }
    
    func setToCrypto(toCrypto: Crypto) {
        self.toCrypto = toCrypto
        toCryptoSymbol.text = toCrypto.symbol
    }
    
    
}
