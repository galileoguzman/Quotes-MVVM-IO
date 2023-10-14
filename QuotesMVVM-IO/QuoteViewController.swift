//
//  ViewController.swift
//  QuotesMVVM-IO
//
//  Created by Galileo Guzman on 14/10/23.
//

import UIKit
import Combine

class QuoteViewController: UIViewController {

    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var lblQuote: UILabel!

    private let vm = QuoteViewModel()
    // Main object that will be connected with the VM to send the input events on the current `View`
    private let input: PassthroughSubject<QuoteViewModel.Input, Never> = .init()

    // All the results of the output should be stored in memory in a cancellable object that will be sinked by itself
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Inform to the `ViewModel` that the `viewDidAppear` event has just happened
        input.send(.viewDidAppear)
    }

    // MARK: Binding
    private func bind() {
        // Connection between the view input object with the VM output transformation result
        // The following line is the result (`output`) of what the `VM` would spit out
        let output = vm.transform(input: input.eraseToAnyPublisher())

        // Now with the output we decided what we would do with any of the results
        // Once the `VM` spit out something, we need to make the view react to it
        output
            .receive(on: DispatchQueue.main)
            .sink { event in
            switch event {
            case .fetchQuoteDidFail(let error):
                self.lblQuote.text = error.localizedDescription
            case .fetchQuoteDidSucceed(let quote):
                self.lblQuote.attributedText = NSMutableAttributedString()
                    .normal("\(quote.content)\n\n")
                    .bold(quote.author)
            case .toggleRefreshButton(let isEnabled):
                self.btnRefresh.isEnabled = isEnabled
            }
        }.store(in: &cancellables)
    }

    @IBAction func btnRefreshPressed(_ sender: Any) {
        // Inform to the `ViewModel` that the `refreshButtonDidTap` event has just happened
        input.send(.refreshButtonDidTap)
    }
    
}

