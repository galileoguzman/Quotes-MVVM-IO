//
//  QuoteViewModel.swift
//  QuotesMVVM-IO
//
//  Created by Galileo Guzman on 14/10/23.
//

import Foundation
import Combine

class QuoteViewModel {

    // Dependency injection
    private let service: QuoteServiceType

    // Object that will be used to store and pass the values as output
    private let output: PassthroughSubject<Output, Never> = .init()

    // All the results of the output should be stored in memory in a cancellable object that will be sinked by itself
    private var cancellables = Set<AnyCancellable>()

    init(service: QuoteServiceType = QuoteService()) {
        self.service = service
    }

    // MARK: INPUT
    // What is the current `ViewModel` getting from the `View` (ViewController) as an event
    // Usually something like the user interaction i.e. button tapped, view opened, gesture event
    //
    enum Input {
        case viewDidAppear
        case refreshButtonDidTap
    }

    // MARK: OUTPUT
    // What is the current `ViewModel` giving to the `View` (ViewController) as a result of a input event
    // Usually a value to show to the user that affects some how the view
    //
    enum Output {
        case fetchQuoteDidFail(error: Error)
        case fetchQuoteDidSucceed(quote: QuoteModel)
        case toggleRefreshButton(isEnabled: Bool)
    }

    // MARK: Transformation
    // Every VM should have a transformation method that will configure the reaction/output of any input event
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        // The current ViewModel will react to any input event
        input.sink { [weak self] event in
            switch event {
            case .viewDidAppear, .refreshButtonDidTap:
                self?.handleGetRandomQuote()
            }
        }.store(in: &cancellables)

        // Returning the main output object of the current VM
        return output.eraseToAnyPublisher()
    }

    func handleGetRandomQuote() {
        // Inform to the view that a network request is in progress with the `toggleRefreshButton` event
        output.send(.toggleRefreshButton(isEnabled: false))

        // We are calling the http request and handle the response with combine
        service.getRandomQuote().sink { [weak self] completion in

            // Inform to the view that the network request was completed using the `toggleRefreshButton`
            self?.output.send(.toggleRefreshButton(isEnabled: true))

            // If there is a failure as result we send the `fetchQuoteDidFail` message to the `View`
            if case .failure(let error) = completion {
                // Inform to the view that an error happens with the `fetchQuoteDidFail` message
                self?.output.send(.fetchQuoteDidFail(error: error))
            }

        } receiveValue: { [weak self] quote in

            // If the service succeeded we need to send the `fetchQuoteDidSucceed` with the corresponding object
            self?.output.send(.fetchQuoteDidSucceed(quote: quote))
            
        }.store(in: &cancellables)
    }


}
