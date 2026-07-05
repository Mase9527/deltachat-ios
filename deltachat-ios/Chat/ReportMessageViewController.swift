import UIKit
import DcCore

class ReportMessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let msgId: Int
    private let dcContext: DcContext
    private let options: [String] = [
        "report_reason_dont_like",
        "report_reason_child_abuse",
        "report_reason_violence",
        "report_reason_illegal_goods",
        "report_reason_illegal_adult_content",
        "report_reason_personal_data",
        "report_reason_scam",
        "report_reason_copyright",
        "report_reason_spam",
        "report_reason_other",
        "report_reason_not_illegal"
    ]

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.separatorStyle = .singleLine
        table.tableFooterView = UIView()
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        return table
    }()

    init(msgId: Int, dcContext: DcContext) {
        self.msgId = msgId
        self.dcContext = dcContext
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = String.localized("report_message_title")

        // Close button (X icon)
        if #available(iOS 13.0, *) {
            let closeItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(dismissTapped))
            closeItem.tintColor = .label
            navigationItem.leftBarButtonItem = closeItem
        } else {
            let closeItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissTapped))
            navigationItem.leftBarButtonItem = closeItem
        }

        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func dismissTapped() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String.localized(options[indexPath.row])
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    // MARK: - Header
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = String.localized("report_message_header")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24), // More space on top like in screenshot
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let reason = String.localized(options[indexPath.row])
        let msg = dcContext.getMessage(id: msgId)
        let text = msg.text ?? ""
        let messageId = msg.messageId 
        
        let api = iFBaseAPI.reportMessage(message_id: messageId, text: text, reason: reason)
        
        // Show loading indicator if available, otherwise just send
        // Assuming ProgressHUD is available as seen in context
        // ProgressHUD.show() 
        ProgressHUD.animate()
        HttpClient.shareInstance.request(target: api) { [weak self] _ in
//            ProgressHUD.dismiss()
             ProgressHUD.succeed(String.localized("report_sucess_tips"), delay: 3)
        } failure: { code, errorMsg in
//             ProgressHUD.error(errorMsg)
//            ProgressHUD.dismiss()

            ProgressHUD.succeed(String.localized("report_sucess_tips"), delay: 3)

        }
        self.dismiss(animated: true, completion: nil)

    }
}
