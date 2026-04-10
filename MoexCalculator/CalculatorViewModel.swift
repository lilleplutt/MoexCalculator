import Foundation
import Combine

final class CalculatorViewModel: ObservableObject {
    
    private var model = CalculatorModel()
    
    enum State {
        case loading    // данные загружаются
        case content    // данные загружены
        case error      // ошибка при загрузке данных
    }
    
    @Published var state: State = .loading
    
    @Published var topCurrency: Currency = .CNY
    @Published var bottomCurrency: Currency = .RUB
    
    @Published var topAmount: Double = 0
    @Published var bottomAmount: Double = 0
    
    private let loader: MoexDataLoader
    private var subscriptions = Set<AnyCancellable>()
    
    init(with loader: MoexDataLoader = MoexDataLoader()) {
        self.loader = loader
        fetchData()
    }
    
    private func fetchData() {
        loader.fetch().sink(
            receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure = completion {
                    self.state = .error
                }
            },
            receiveValue: { [weak self] currencyRates in
                guard let self = self else { return }
                self.model.setCurrencyRates(currencyRates)
                self.state = .content
            })
        .store(in: &subscriptions)
    }
    
    func setTopAmount(_ amount: Double) {
        topAmount = amount
        updateBottomAmount()
    }
    
    func setBottomAmount(_ amount: Double) {
        bottomAmount = amount
        updateTopAmount()
    }
    
    func updateBottomAmount() {
        let topAmount = CurrencyAmount(currency: topCurrency, amount: topAmount)
        bottomAmount = model.convert(topAmount, to: bottomCurrency)
    }
    
    func updateTopAmount() {
        let bottomAmount = CurrencyAmount(currency: bottomCurrency, amount: bottomAmount)
        topAmount = model.convert(bottomAmount, to: topCurrency)
    }
    
}

