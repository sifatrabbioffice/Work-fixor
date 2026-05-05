import SwiftUI
import UniformTypeIdentifiers

@main
struct WinHubApp: App {
    var body: some Scene {
        WindowGroup {
            MainContainer()
        }
    }
}

struct MainContainer: View {
    @State private var isEmulating = false
    @State private var environmentName = "None"
    @State private var isPickerPresented = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isEmulating {
                EmulatorEnvironment(envName: environmentName) {
                    isEmulating = false
                }
            } else {
                VStack(spacing: 30) {
                    Text("WINHUB INTERFACE").font(.system(.title, design: .monospaced)).foregroundColor(.blue).bold()
                    
                    Text("Loaded: \(environmentName)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                    
                    HStack(spacing: 20) {
                        Button(action: { isPickerPresented = true }) {
                            Label("Import File", systemImage: "square.and.arrow.down")
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        
                        if environmentName != "None" {
                            Button(action: { isEmulating = true }) {
                                Text("Execute")
                                    .padding()
                                    .frame(width: 120)
                                    .background(Color.green)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .fileImporter(isPresented: $isPickerPresented, allowedContentTypes: [.item]) { result in
            if let url = try? result.get() {
                environmentName = url.lastPathComponent
            }
        }
    }
}

// গেমপ্যাড ও এমাসিভ ভিউ
struct EmulatorEnvironment: View {
    let envName: String
    var onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color(white: 0.05).ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: onExit) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }.padding()
                    Spacer()
                    Text(envName).foregroundColor(.white.opacity(0.3)).padding()
                }
                
                Spacer()
                
                // কন্ট্রোলার লেআউট
                HStack {
                    VirtualStick()
                    Spacer()
                    ActionButtons()
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 40)
            }
        }
    }
}

struct VirtualStick: View {
    @State private var dragOffset = CGSize.zero
    var body: some View {
        Circle().fill(.white.opacity(0.1)).frame(width: 150, height: 150)
            .overlay(
                Circle().fill(.white.opacity(0.8)).frame(width: 70, height: 70)
                    .offset(dragOffset)
                    .gesture(DragGesture().onChanged { v in
                        let maxRange: CGFloat = 40
                        dragOffset = CGSize(
                            width: min(max(v.translation.width, -maxRange), maxRange),
                            height: min(max(v.translation.height, -maxRange), maxRange)
                        )
                    }.onEnded { _ in withAnimation { dragOffset = .zero } })
            )
    }
}

struct ActionButtons: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) { CircleBtn(t: "Y", c: .yellow) }
            HStack(spacing: 20) { CircleBtn(t: "X", c: .blue); CircleBtn(t: "B", c: .red) }
            HStack(spacing: 20) { CircleBtn(t: "A", c: .green) }
        }
    }
}

struct CircleBtn: View {
    let t: String; let c: Color
    var body: some View {
        Circle().fill(c.opacity(0.7)).frame(width: 70, height: 70).overlay(Text(t).bold().foregroundColor(.white))
    }
}
