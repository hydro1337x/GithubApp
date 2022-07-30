//
//  SearchRepositoriesViewController.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import UIKit
import RxCocoa
import RxSwift

public final class SearchRepositoriesViewController: UIViewController {
    typealias DataSource = UITableViewDiffableDataSource<String, RepositoryViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<String, RepositoryViewModel>

    let tableView = UITableView()

    private lazy var dataSource = makeDataSource()
    private let disposeBag = DisposeBag()
    private let sectionIdentifier = "section"
    private let itemsIdentifier = "items"

    private let viewModel: SearchRepositoriesViewModel

    public init(viewModel: SearchRepositoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupStyle()
        registerCells()
        setupSubscriptions()
    }

    private func registerCells() {
        tableView.register(RepositoryTableViewCell.self,
                           forCellReuseIdentifier: String(describing: RepositoryTableViewCell.self))
    }

    private func setupSubscriptions() {
        let initialTrigger = Signal.just(())

        let input = SearchRepositoriesViewModel.Input(initialTrigger: initialTrigger)

        let output = viewModel.transform(input: input)

        output.repositories
            .map(makeSnapshot(with:))
            .drive(onNext: { [unowned self] snapshot in
                dataSource.apply(snapshot)
            })
            .disposed(by: disposeBag)
    }

    private func makeDataSource() -> DataSource {
        DataSource(tableView: tableView) { tableView, indexPath, viewModel in

            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepositoryTableViewCell.self),
                                                     for: indexPath) as? RepositoryTableViewCell
            cell?.configure(with: viewModel)
            return cell
        }
    }

    private func makeSnapshot(with repositories: [RepositoryViewModel]) -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([sectionIdentifier])
        snapshot.appendItems(repositories, toSection: sectionIdentifier)
        return snapshot
    }

}

extension SearchRepositoriesViewController: ViewConstructing {
    func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func setupStyle() {
        view.backgroundColor = .red
    }
}
