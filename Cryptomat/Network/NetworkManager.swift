//
//  NetworkManager.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 26.07.2021..
//

import Alamofire
import RxSwift

class NetworkManager {
    
    func getAllCryptos() -> Observable<[Crypto]> {
        
        return Observable.create { observer in
            
            guard let safeUrl = URL(string: NetworkConstants.BASE_URL + NetworkConstants.ALL_CRYPTOS + NetworkConstants.apikey + NetworkConstants.LIMIT_OPTION) else {
                observer.onError(DataError.invalidUrl)
                return Disposables.create()
            }
            
            
            let request = AF.request(safeUrl).response { response in
                switch (response.result) {
                    case .success(_):
                        if let decodedObject: CryptoResponse = SerializationManager().parse(jsonData: response.data!) {
                            observer.onNext(decodedObject.data)
                            observer.onCompleted()
                        } else {
                            observer.onError(DataError.parsingError)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
            }
            
            return Disposables.create {
                request.cancel()
            }
            
        }
        
    }
    
}
