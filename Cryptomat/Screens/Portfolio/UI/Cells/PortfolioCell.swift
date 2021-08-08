//
//  PortfolioCell.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 08.08.2021..
//

import UIKit
import SnapKit

class PortfolioCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let balanceLabel = UILabel()
    private let dateLabel = UILabel()
    
    func setupUI(){
        contentView.backgroundColor = .white
        contentView.addSubview(balanceLabel)
        contentView.addSubview(dateLabel)
        setupConstraints()
    }
    
    func setupConstraints(){
        balanceLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.bottom.trailing.equalToSuperview().offset(-8)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
    }
    
    func configureCell(portfolioRecord: PortfolioRecord){
        balanceLabel.text = "$\(portfolioRecord.balance)"
        let date = Date(timeIntervalSince1970: portfolioRecord.timestamp)
        dateLabel.text = "\(date)"
    }
    
}
