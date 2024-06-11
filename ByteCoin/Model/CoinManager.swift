//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoinManager(_ coinManager: CoinManager, coinModel: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "2D3EADFA-44E6-4246-AA43-64D6351549C3"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func fetchByteCoin(with currency: String) {
        let currencyURL = "\(baseURL)/\(currency)?apikey=\(apiKey)"
//        print("URL: \(currencyURL)")
        getCoinPrize(for: currencyURL)
    }
    
    func getCoinPrize(for currency: String) {
        if let url = URL(string: currency) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, respone, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let coinModel = self.parseJSON(safeData) {
                        self.delegate?.didUpdateCoinManager(self, coinModel: coinModel)
                    }
                }
            }
            task.resume()
        }
    }
    
    //    func parseJSON(_ byteCoinData: Data) -> Double? {
    //        let decoder = JSONDecoder()
    //        do {
    //            let decodedData = try decoder.decode(CoinData.self, from: byteCoinData)
    //            let byteRate = decodedData.rate
    //            return byteRate
    //        } catch {
    //            delegate?.didFailWithError(error: error)
    //            return nil
    //        }
    //    }
    
    func parseJSON(_ data: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            let coinModel = CoinModel(rate: lastPrice)
            return coinModel
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
