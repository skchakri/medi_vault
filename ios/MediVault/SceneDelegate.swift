import UIKit
import Turbo

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let baseURL = URL(string: "http://localhost:3000")!

    // Turbo navigation
    private lazy var navigator: TurboNavigator = {
        return TurboNavigator(delegate: self)
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigator.rootViewController
        window?.makeKeyAndVisible()

        // Load path configuration
        PathConfiguration.shared.load()

        // Start at base URL
        visit(url: baseURL)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Handle deep links
        guard let url = URLContexts.first?.url else { return }
        visit(url: url)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    // MARK: - Navigation

    private func visit(url: URL) {
        let properties = PathConfiguration.shared.properties(for: url)

        if properties.presentation == .modal {
            navigator.route(url: url, action: .advance, properties: properties, modal: true)
        } else {
            navigator.route(url: url, action: .advance, properties: properties)
        }
    }
}

// MARK: - TurboNavigatorDelegate

extension SceneDelegate: TurboNavigatorDelegate {
    func controller(for proposal: VisitProposal, with session: Session) -> VisitableViewController {
        let viewController = WebViewController(url: proposal.url)

        // Configure pull to refresh based on path configuration
        let properties = PathConfiguration.shared.properties(for: proposal.url)
        viewController.refreshControl = properties.pullToRefreshEnabled ? UIRefreshControl() : nil

        return viewController
    }

    func handle(proposal: VisitProposal) -> ProposalResult {
        // Check if URL is external
        if proposal.url.host != baseURL.host {
            return .openExternally
        }

        // Get path configuration
        let properties = PathConfiguration.shared.properties(for: proposal.url)

        // Handle modals
        if properties.presentation == .modal {
            return .acceptCustom
        }

        return .accept
    }

    func sessionDidLoadWebView(_ session: Session) {
        // Configure session
        session.webView.configuration.applicationNameForUserAgent = "MediVault iOS"
    }

    func sessionDidFailRequest(_ session: Session, with error: Error) {
        // Handle errors
        print("Session failed: \(error.localizedDescription)")
    }
}
