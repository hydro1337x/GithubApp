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
    let searchBar = UISearchBar()
    let refreshControl = UIRefreshControl()
    let activityIndicatorView = UIActivityIndicatorView(style: .large)

    private lazy var dataSource = makeDataSource()
    private let disposeBag = DisposeBag()
    private let sectionIdentifier = "section"
    private let itemsIdentifier = "items"
    private let viewModel: SearchRepositoriesViewModel
    private let selectionRelay: PublishRelay<RepositoryViewModel>

    public init(
        viewModel: SearchRepositoriesViewModel,
        selectionRelay: PublishRelay<RepositoryViewModel>
    ) {
        self.viewModel = viewModel
        self.selectionRelay = selectionRelay
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
        let refreshTrigger = refreshControl.rx
            .controlEvent(.valueChanged)
            .map { [unowned self] in
                searchBar.text
            }
            .asSignal(onErrorSignalWith: .empty())

        let searchTrigger = searchBar.rx
            .text
            .asSignal(onErrorSignalWith: .empty())

        let subsequentTrigger = tableView.rx
            .willDisplayCell
            .map { [unowned self] input -> (text: String?, currentIndex: Int, lastIndex: Int?) in
                let currentIndex = input.indexPath.row
                let lastIndex = dataSource.snapshot().itemIdentifiers.indices.last
                return (text: searchBar.text, currentIndex: currentIndex, lastIndex: lastIndex)
            }
            .asSignal(onErrorSignalWith: .empty())

        let input = SearchRepositoriesViewModel.Input(
            searchTrigger: searchTrigger,
            refreshTrigger: refreshTrigger,
            subsequentTrigger: subsequentTrigger
        )

        let output = viewModel.transform(input: input)

        output.repositories
            .map { [unowned self] repositories in
                makeSnapshot(with: repositories)
            }
            .drive(onNext: { [unowned self] snapshot in
                dataSource.apply(snapshot)
            })
            .disposed(by: disposeBag)

        output.initialActivity
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        output.subsequentActivity
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        output.failureMessage
            .emit(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)

        /**
         itemSelected is used as a workaround for modelSelected(),
         since the later causes a runtime crash when used in conjunction with DiffableDataSource
         */
        tableView.rx
            .itemSelected
            .compactMap { [unowned self] indexPath in
                dataSource.itemIdentifier(for: indexPath)
            }
            .bind(to: selectionRelay)
            .disposed(by: disposeBag)
    }

    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, viewModel in

            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepositoryTableViewCell.self),
                                                     for: indexPath) as? RepositoryTableViewCell
            cell?.configure(with: viewModel)
            return cell
        }

        dataSource.defaultRowAnimation = .fade

        return dataSource
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
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 56)
        ])

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        tableView.refreshControl = refreshControl

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func setupStyle() {
        
    }
}
