//
//  PickCryptoDelegate.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 08.08.2021..
//

protocol PickCryptoDelegate: AnyObject {
    func setFromCrypto(fromCrypto: Crypto)
    func setToCrypto(toCrypto: Crypto)
}
