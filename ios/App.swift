import UIKit
import WebKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: BrowserController())
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

final class BrowserController: UIViewController, WKNavigationDelegate {
    private var web: WKWebView!
    private var didStart = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HGhub"
        view.backgroundColor = .black
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = true
        web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = self
        web.allowsBackForwardNavigationGestures = true
        web.isOpaque = false
        web.backgroundColor = .black
        web.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(web)
        NSLayoutConstraint.activate([
            web.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            web.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            web.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            web.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "服务器", style: .plain, target: self, action: #selector(settings)),
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        ]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didStart else { return }
        didStart = true
        if let url = configuredURL() { web.load(URLRequest(url: url)) }
        else { settings() }
    }
    private func configuredURL() -> URL? {
        let text = UserDefaults.standard.string(forKey: "ServerURL")
            ?? (Bundle.main.object(forInfoDictionaryKey: "HGServerURL") as? String ?? "")
        return validated(text)
    }
    private func validated(_ text: String) -> URL? {
        guard let url = URL(string: text.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme),
              url.host != nil, url.user == nil, url.password == nil else { return nil }
        return url
    }
    @objc private func settings() {
        let dialog = UIAlertController(title: "服务器地址", message: "填写你自己部署的 HGhub 网页地址。", preferredStyle: .alert)
        dialog.addTextField { field in
            field.text = self.configuredURL()?.absoluteString
            field.placeholder = "http://服务器IP:8081/"
            field.keyboardType = .URL
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
        }
        dialog.addAction(UIAlertAction(title: "取消", style: .cancel))
        dialog.addAction(UIAlertAction(title: "保存并打开", style: .default) { _ in
            guard let url = self.validated(dialog.textFields?.first?.text ?? "") else {
                self.message("地址无效", "请输入完整的 http:// 或 https:// 地址。")
                return
            }
            UserDefaults.standard.set(url.absoluteString, forKey: "ServerURL")
            self.web.load(URLRequest(url: url))
        })
        present(dialog, animated: true)
    }
    @objc private func back() { if web.canGoBack { web.goBack() } }
    @objc private func refresh() {
        if web.url != nil { web.reload() }
        else if let url = configuredURL() { web.load(URLRequest(url: url)) }
        else { settings() }
    }
    private func message(_ title: String, _ body: String) {
        let dialog = UIAlertController(title: title, message: body, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "好", style: .default))
        present(dialog, animated: true)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard (error as NSError).code != NSURLErrorCancelled else { return }
        message("连接失败", "请检查网络和服务器地址，可点击右上角重试或修改服务器。")
    }
}
