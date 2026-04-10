import SwiftUI

struct CurrencyPicker: View {

    // Байндинг для валюты, который помогает читать и записывать её значение
    @Binding var currency: Currency
    
    // Функция, которая вызывается при выборе валюты из списка
    let onChange: (Currency) -> Void
    
    var body: some View {
        
        // Picker — элемент SwiftUI для выбора значения из списка
        Picker("", selection: $currency) {
                        
            // ForEach - элемент SwiftUI, который генерирует набор View
            // из коллекции значений с уникальными идентификаторами
            ForEach(Currency.allCases) { currency in
                Text(currency.rawValue.uppercased())
            }
        }
        // Задаёт стиль Picker «колесо» или «барабан»
        .pickerStyle(.wheel)
        
        // Определяет функцию, которая вызывается при выборе нового значения
        .onChange(of: currency, perform: onChange)
    }
}

// Структура, которая определяет отображение компонента в панели preview
struct CurrencyPicker_Previews: PreviewProvider {
    
    static let currencyBinding = Binding<Currency>(
        get: { .RUB },
        set: { _ = $0 }
    )
    
    static var previews: some View {
        CurrencyPicker(currency: currencyBinding, onChange: { _ in })
    }
}
