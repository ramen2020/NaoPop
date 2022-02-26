//
//  ContentView.swift
//  dialog
//
//  Created by 宮本光直 on 2022/02/16.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            NavigationView {
                FirstPage()
                    .navigationBarTitle("Dialog / PopUp")
            }
            .tabItem {
                Image(systemName: "1.circle.fill")
            }
            
            NavigationView {
                SecondPage()
                    .navigationBarTitle("Half Modal")
            }
            .tabItem {
                Image(systemName: "2.circle.fill")
            }
        }
        
    }
}

struct FirstPage: View {
    
    @State var isPresented: Bool = false
    
    var body: some View {
        VStack {
            Button (action: {
                isPresented = true
            }) {
                Text("open")
                    .foregroundColor(Color.white)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 250, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .background(Color.white)
        .fullOverFullScreenView(isPresented: $isPresented){
            ModalView(isPresented: $isPresented)
        }
    }
}

struct SecondPage: View {
    
    @State var isPresented: Bool = false
    @State var isPresented2: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            Button (action: {
                self.isPresented = true
            }) {
                Text("Half Modal")
                    .foregroundColor(Color.white)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 250, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button (action: {
                self.isPresented2 = true
            }) {
                Text("Dialog")
                    .foregroundColor(Color.white)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 250, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

        }
        .naoPop(isPresented: $isPresented) {
            NaoHalfModal(modalBackground: Color.white, tapOutsideDismiss: false, dragDismiss: false, onDismiss: {
                //
            }) {
                ItemContent()
            }
        }
        .naoPop(isPresented: $isPresented2) {
            NaoPopUpModal {
                ItemContent()
            }
        }
    }
}

struct NaoPopUpModal<NaoPopupContent: View>: View {
    
    @State var modalHeight: CGFloat = UIScreen.main.bounds.height
    @Environment(\.naoModal) var isPresented

    var view: () -> NaoPopupContent

    var body: some View {
        Group {}
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .all)
            .onReceive(NaoModalNotification.modalDidPresentedSubject) { _ in
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.2)) {
                        modalHeight = 0
                    }
                }
            }
            .onReceive(NaoModalNotification.modalDidDismissedSubject) { _ in
                DispatchQueue.main.async {
                    withAnimation(.easeIn(duration: 0.2)) {
                        modalHeight = UIScreen.main.bounds.height
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isPresented.wrappedValue = false
            }
            .overlay(self.view().offset(y: modalHeight))
    }
}

struct NaoHalfModal<NaoPopupContent: View>: View {
    
    // MARK: - settings propaty
    
    /// Modal background color
    var modalBackground: Color
     
    /// Tap the outer frame to close it.
    var tapOutsideDismiss: Bool
    
    /// Can be closed by dragging.
    var dragDismiss: Bool
    
    /// Action when closed
    var onDismiss: (() -> Void)?
    
    var view: () -> NaoPopupContent
    
    init (
        modalBackground: Color = Color.white,
        tapOutsideDismiss: Bool = true,
        dragDismiss: Bool = true,
        onDismiss: (() -> Void)? = nil,
        view: @escaping () -> NaoPopupContent
    ){
        self.modalBackground = modalBackground
        self.tapOutsideDismiss = tapOutsideDismiss
        self.dragDismiss = dragDismiss
        self.onDismiss = onDismiss
        self.view = view
    }
    
    // MARK: - private propaty
    @Environment(\.naoModal) private var isPresented
    @State private var modalHeight: CGFloat = UIScreen.main.bounds.height
    
    private var defaultAnimation: Animation = .interpolatingSpring(
        stiffness: 400.0,
        damping: 25.0,
        initialVelocity: 5.0
    )
    
    private func onDragChanged(drag: DragGesture.Value) {
        let translationHeight = drag.translation.height
        let firstPosition = CGFloat(0)

        if dragDismiss && translationHeight > firstPosition {
            withAnimation(defaultAnimation) {
                modalHeight = drag.translation.height
            }
        }
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        let translationHeight = drag.translation.height

        if dragDismiss {
            if 110 > translationHeight {
                withAnimation(defaultAnimation) {
                    modalHeight = 0
                }
            } else {
                self.isPresented.wrappedValue = false
            }
        }
    }

    var body: some View {
        VStack {
            HStack{Spacer()}
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    if tapOutsideDismiss {
                        isPresented.wrappedValue = false
                    }
                }
            
            VStack {
                self.view()
                    .gesture(
                        DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                            .onChanged(onDragChanged)
                            .onEnded(onDragEnded)
                    )
            }
            .frame(maxWidth: .infinity)
            .background(modalBackground)
            .offset(y: modalHeight)
        }
        .ignoresSafeArea(edges: .all)
        .onReceive(NaoModalNotification.modalDidPresentedSubject) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.2)) {
                    modalHeight = 0
                }
            }
        }
        .onReceive(NaoModalNotification.modalDidDismissedSubject) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeIn(duration: 0.2)) {
                    modalHeight = UIScreen.main.bounds.height
                }
            }
            guard let onDismiss = onDismiss else {return}
            onDismiss()
        }
    }
}

struct ItemContent: View {

    @Environment(\.naoModal) var isPresented

    var body: some View {
        VStack {
            Button (action: {
                self.isPresented.wrappedValue = false
            }) {
                Text("close")
                    .foregroundColor(Color.white)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 250, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .frame(height: 300)
        .padding()
        .background(Color.white)
    }
}

extension View {
    func naoPop<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
        self.overlay(
            NaoModal(isPresented: isPresented, content: content)
                .frame(width: 0, height: 0)
        )
    }
}

private struct ModalEnvironmentKey: EnvironmentKey {
    static var defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var naoModal: Binding<Bool> {
        get {
            return self[ModalEnvironmentKey.self]
        }
        set {
            return self[ModalEnvironmentKey.self] = newValue
        }
    }
}

struct NaoNotificationConst {
    static let MODAL_PRESENTED: Notification.Name = Notification.Name("modalDidPresented")
    static let MODAL_DISMISSED: Notification.Name = Notification.Name("modalDidDismissed")
}

struct NaoModalNotification {
    static var modalDidPresentedSubject: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: NaoNotificationConst.MODAL_PRESENTED)
    }

    static func notifyModalDidPresented() {
        NotificationCenter.default
            .post(Notification(name: NaoNotificationConst.MODAL_PRESENTED))
    }

    static var modalDidDismissedSubject: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: NaoNotificationConst.MODAL_DISMISSED)
    }

    static func notifyModalDidDismissed() {
        NotificationCenter.default
            .post(Notification(name: NaoNotificationConst.MODAL_DISMISSED))
    }
}


private struct NaoModal<Content: View>: UIViewControllerRepresentable {
    typealias Context = UIViewControllerRepresentableContext<NaoModal>

    @Binding var isPresented: Bool

    let content: () -> Content

    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = UIViewController()
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if self.isPresented {
            let content = self.content()
                .environment(\.naoModal, self.$isPresented)

            let host = UIHostingController(rootView: content)
            host.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            host.modalPresentationStyle = .overFullScreen

            DispatchQueue.main.async {
                uiViewController.modalPresentationStyle = .overCurrentContext
                uiViewController.present(host, animated: false, completion: {
                    NaoModalNotification.notifyModalDidPresented()
                })
            }
        } else {
            NaoModalNotification.notifyModalDidDismissed()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                uiViewController.presentedViewController?.dismiss(animated: false, completion: nil)
            }
        }
    }
}
