//
//  OwnerSendContactViewController.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/5.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import DcCore

protocol OwnerSendContactViewControllerDelegate: AnyObject {
    
    func contactSelected(_ viewController: OwnerSendContactViewController, contactId: Int,name:String)

}

class OwnerSendContactViewController: UIViewController {

    private let context: DcContext
    private let chatId: Int
    private var chat: DcChat?
    private var contactIds: [Int]
    private var filteredContactIds: [Int]

    let tableView: UITableView

    var delegate: OwnerSendContactViewControllerDelegate?
    let searchController: UISearchController
    let emptySearchStateLabel: EmptyStateLabel
    private var emptySearchStateLabelWidthConstraint: NSLayoutConstraint?

    init(dcContext: DcContext,chatId:Int) {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ContactCell.self, forCellReuseIdentifier: ContactCell.reuseIdentifier)
        tableView.keyboardDismissMode = .onDrag

        self.chatId = chatId;
        context = dcContext
        contactIds = dcContext.getContacts(flags: DC_GCL_ADD_SELF)
        filteredContactIds = contactIds
        
        self.chat = self.chatId != 0 ? dcContext.getChat(chatId: self.chatId) : nil

        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = String.localized("search")
        searchController.searchBar.showsCancelButton = false
        searchController.hidesNavigationBarDuringPresentation = false

        emptySearchStateLabel = EmptyStateLabel()
        emptySearchStateLabel.isHidden = true

        super.init(nibName: nil, bundle: nil)

        tableView.dataSource = self
        tableView.delegate = self
        title = String.localized("contacts_title")

        view.addSubview(tableView)
        setupConstraints()

        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(SendContactViewController.cancel(_:)))
        navigationItem.rightBarButtonItem = closeButton

        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if let chat {
            contactIds = chat.getContactIds(dcContext)
            filteredContactIds = contactIds
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupConstraints() {
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
        ]

        emptySearchStateLabelWidthConstraint = emptySearchStateLabel.widthAnchor.constraint(equalTo: tableView.widthAnchor)

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions

    @objc func cancel(_ sender: Any) {
        searchController.isActive = false
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate
extension OwnerSendContactViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let contactId = filteredContactIds[indexPath.row]
        let viewModel = ContactCellViewModel.make(contactId: contactId, dcContext: context)

        delegate?.contactSelected(self, contactId: contactId,name: viewModel.title)

        searchController.isActive = false
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension OwnerSendContactViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContactIds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.reuseIdentifier, for: indexPath) as? ContactCell else { fatalError("Where's my ContactCell??") }

        let contactId = filteredContactIds[indexPath.row]
        let viewModel = ContactCellViewModel.make(contactId: contactId, dcContext: context)
        cell.updateCell(cellViewModel: viewModel)

        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension OwnerSendContactViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            filteredContactIds = contactIds
            return
        }

        filterContentForSearchText(searchText)
    }

    private func filterContentForSearchText(_ searchText: String) {
        filteredContactIds = filterContactIds(queryString: searchText)
        tableView.reloadData()
        tableView.scrollToTop()

        // handle empty searchstate
        if searchController.isActive && filteredContactIds.isEmpty {
            let text = String.localizedStringWithFormat(
                String.localized("search_no_result_for_x"),
                searchText
            )
            emptySearchStateLabel.text = text
            emptySearchStateLabel.isHidden = false
            tableView.tableHeaderView = emptySearchStateLabel
            emptySearchStateLabelWidthConstraint?.isActive = true
        } else {
            emptySearchStateLabel.text = nil
            emptySearchStateLabel.isHidden = true
            emptySearchStateLabelWidthConstraint?.isActive = false
            tableView.tableHeaderView = nil
        }
    }

    private func filterContactIds(queryString: String) -> [Int] {
        let allIDs = context.getContacts(flags: DC_GCL_ADD_SELF, queryString: queryString)
        var showIDs:[Int] = []
        allIDs.forEach { id in
            
            if self.contactIds.contains(id) == true{
                showIDs.append(id)
            }
        }
        return showIDs
    }
}
