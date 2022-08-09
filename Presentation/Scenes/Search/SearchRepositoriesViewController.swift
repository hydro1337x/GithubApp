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
    typealias DataSource = UITableViewDiffableDataSource<String, SearchRepositoriesItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<String, SearchRepositoriesItem>

    let tableView = UITableView()
    let searchBar = UISearchBar()
    let refreshControl = UIRefreshControl()
    let activityIndicatorView = UIActivityIndicatorView()
    let emptyStateButton = UIButton()

    private lazy var dataSource = makeDataSource()
    private let disposeBag = DisposeBag()
    private let sectionIdentifier = "section"
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

    deinit {
        print("Deinited: \(String(describing: self))")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupStyle()
        registerCells()
        setupSubscriptions()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showKeyboard()
    }

    private func setupSubscriptions() {
        let refreshTrigger = refreshControl.rx
            .controlEvent(.valueChanged)
            .map { [unowned self] _ in searchBar.text ?? "" }
            .asSignal(onErrorSignalWith: .empty())

        let searchTrigger = searchBar.rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .skip(1)
            .asSignal(onErrorSignalWith: .empty())

        let subsequentTrigger = tableView.rx
            .willDisplayCell
            .compactMap { [unowned self] input -> SubsequentTriggerInput? in
                guard let last = dataSource.snapshot().itemIdentifiers.indices.last else { return nil }
                return SubsequentTriggerInput(currentIndex: input.indexPath.row, lastIndex: last)
            }
            .filter { input in
                input.currentIndex == input.lastIndex
            }
            .map { [unowned self] _ in searchBar.text ?? "" }
            .asSignal(onErrorSignalWith: .empty())

        let input = SearchRepositoriesViewModel.Input(
            searchTrigger: searchTrigger,
            refreshTrigger: refreshTrigger,
            subsequentTrigger: subsequentTrigger
        )

        let output = viewModel.transform(input: input)

        output.items
            .do(onNext: { [unowned self] items in
                emptyStateButton.isHidden = !items.isEmpty
                tableView.isScrollEnabled = !items.isEmpty
            }, onSubscribed: { [unowned self] in
                tableView.isScrollEnabled = false
            })
            .map { [unowned self] items in
                makeSnapshot(with: items)
            }
            .drive(onNext: { [unowned self] snapshot in
                dataSource.apply(snapshot)
            })
            .disposed(by: disposeBag)

        output.refreshActivity
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        output.searchActivity
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        output.failureMessage
            .emit(onNext: { [unowned self] message in
                showToast(with: message)
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
            .compactMap {
                guard case .item(let repository) = $0 else { return nil }
                return repository
            }
            .bind(to: selectionRelay)
            .disposed(by: disposeBag)

        emptyStateButton.rx
            .tap
            .asDriver()
            .drive(onNext: { [unowned self] _ in
                dismissKeyboard()
            })
            .disposed(by: disposeBag)

        tableView.rx
            .contentOffset
            .asDriver()
            .drive(onNext: { [unowned self] _ in
                dismissKeyboard()
            })
            .disposed(by: disposeBag)
    }

    private func showKeyboard() {
        if !searchBar.isFirstResponder {
            _ = searchBar.becomeFirstResponder()
        }
    }

    private func dismissKeyboard() {
        if searchBar.isFirstResponder {
            _ = searchBar.resignFirstResponder()
        }
    }
}

extension SearchRepositoriesViewController {

    private func registerCells() {
        tableView.register(RepositoryTableViewCell.self,
                           forCellReuseIdentifier: String(describing: RepositoryTableViewCell.self))
        tableView.register(ActivityIndicatorTableViewCell.self,
                           forCellReuseIdentifier: String(describing: ActivityIndicatorTableViewCell.self))
    }

    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .item(let viewModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepositoryTableViewCell.self),
                                                         for: indexPath) as? RepositoryTableViewCell
                cell?.configure(with: viewModel)
                return cell

            case .activity:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ActivityIndicatorTableViewCell.self), for: indexPath) as? ActivityIndicatorTableViewCell
                cell?.startAnimating()
                return cell
            }
        }

        dataSource.defaultRowAnimation = .fade

        return dataSource
    }

    private func makeSnapshot(with items: [SearchRepositoriesItem]) -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([sectionIdentifier])
        snapshot.appendItems(items, toSection: sectionIdentifier)
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
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        tableView.backgroundView = emptyStateButton
        emptyStateButton.center = tableView.center
    }

    func setupStyle() {
        view.backgroundColor = .systemBackground
        
        activityIndicatorView.style = .large

        emptyStateButton.setTitle("Nothing to show, for now...", for: .normal)
        emptyStateButton.setTitleColor(.systemGray, for: .normal)
    }
}
