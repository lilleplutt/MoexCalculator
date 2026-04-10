import SwiftUI

struct MainView: View {
    
    // Аналог ObservedObject. Создаётся в родительском объекте
    @EnvironmentObject var viewModel: CalculatorViewModel
    
    var body: some View {
        
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .error:
            VStack {
                Text("🤷‍♂️")
                    .font(.system(size: 100))
                    .padding()
                Text("Что-то пошло не так.\n Пожалуйста, попробуйте позже.")
                    .font(.body)
            }
            .multilineTextAlignment(.center)
        case .content:
            CalculatorView()
            
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
