//
//  QuoteService.swift
//  QuotesMVVM-IO
//
//  Created by Galileo Guzman on 14/10/23.
//

import Foundation
import Combine

protocol QuoteServiceType {
    func getRandomQuote() -> AnyPublisher<QuoteModel, Error>
}

class QuoteService: QuoteServiceType {
    func getRandomQuote() -> AnyPublisher<QuoteModel, Error> {
        //
        let url = URL(string: "https://api.quotable.io/random")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }
            .map({ $0.data })
            .decode(type: QuoteModel.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
