//
//  AssetCell.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 08.08.2021..
//

import UIKit
import SnapKit

class AssetCell: UITableViewCell {
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
}

extension AssetCell {
    func setupUI(){
        contentView.backgroundColor = .white
        contentView.addSubview(assetView)
        contentView.addSubview(assetName)
        contentView.addSubview(balanceInUSD)
        contentView.addSubview(balanceInCoin)
        setupConstraints()
    }
    
    func setupConstraints(){
        
        assetView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
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
    }
}

extension AssetCell {
    func configureCell(asset: Asset){
        
        assetName.text = asset.crypto.name + " Wallet"
        balanceInUSD.text = "$\(roundUp(asset.amountInUSD))"
        balanceInCoin.text = "\(roundUp(asset.amount)) \(asset.crypto.symbol)"
    }
}

extension AssetCell {
    func roundUp(_ double: Double)-> Double{
        return round(100*double)/100
    }
}
