//
//  CryptoCell.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 26.07.2021..
//

import UIKit
import SnapKit

class CryptoCell: UITableViewCell {
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let change24Label = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(change24Label)
        
        setupConstraints()
    }
    
    
    func setupConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(16)
        }
        
        
        symbolLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.equalTo(nameLabel)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(nameLabel)
        }
        
        change24Label.snp.makeConstraints { make in
            make.right.equalTo(priceLabel)
            make.top.equalTo(symbolLabel)
        }
        
    }
    
    func configureCell(crypto: Crypto) {
        nameLabel.text = crypto.name
        symbolLabel.text = crypto.symbol
        if var price = crypto.quote?.USD.price {
            price = round(price * 100) / 100
            priceLabel.text = "\(price)"
        } else {
            priceLabel.text = ""
        }
        
        if var percentChange = crypto.quote?.USD.percentChange24h {
            percentChange = round(percentChange * 100) / 100
            change24Label.text = "\(percentChange)%"
            change24Label.updateColor()
        } else {
            change24Label.text = ""
        }
        
    }
    
}
