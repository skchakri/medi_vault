import UIKit
import Turbo
import WebKit

class WebViewController: VisitableViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure navigation bar
        configureNavigationBar()

        // Configure refresh control
        if let refreshControl = refreshControl {
            refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Update title from page
        navigationItem.title = visitableView.webView?.title
    }

    // MARK: - Configuration

    private func configureNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Actions

    @objc private func reload() {
        visitableView.webView?.reload()
        refreshControl?.endRefreshing()
    }

    // MARK: - Visitable

    override func visitableDidRender() {
        super.visitableDidRender()

        // Update title after page renders
        navigationItem.title = visitableView.webView?.title
    }

    override func visitableDidFailRequest(_ error: Error) {
        super.visitableDidFailRequest(error)

        // Show error alert
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load page: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.visitableView.webView?.reload()
        })
        present(alert, animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController {
    override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Handle external links
        if let url = navigationAction.request.url,
           url.host != visitableURL.host {
            decisionHandler(.cancel)
            UIApplication.shared.open(url)
            return
        }

        super.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
    }
}
