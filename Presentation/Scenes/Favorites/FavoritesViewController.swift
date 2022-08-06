//
//  FavoritesViewController.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import UIKit
import RxCocoa
import RxSwift

public final class FavoritesViewController: UIViewController {
    typealias DataSource = UITableViewDiffableDataSource<String, RepositoryViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<String, RepositoryViewModel>

    let tableView = UITableView()
    let activityIndicatorView = UIActivityIndicatorView()
    let emptyStateButton = UIButton()

    private lazy var dataSource = makeDataSource()
    private let disposeBag = DisposeBag()
    private let sectionIdentifier = "section"
    private let viewModel: FavoritesViewModel
    private let selectionRelay: PublishRelay<RepositoryViewModel>
    private let refreshRelay: PublishRelay<Void>

    public init(
        viewModel: FavoritesViewModel,
        selectionRelay: PublishRelay<RepositoryViewModel>,
        refreshRelay: PublishRelay<Void>
    ) {
        self.viewModel = viewModel
        self.selectionRelay = selectionRelay
        self.refreshRelay = refreshRelay
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

    private func setupSubscriptions() {

        let trigger = Observable.merge(refreshRelay.asObservable(), .just(()))

        let input = FavoritesViewModel.Input(trigger: trigger.asSignal(onErrorSignalWith: .empty()))

        let output = viewModel.transform(input: input)

        output.state
            .drive(onNext: { [unowned self] state in
                switch state {
                case .initial:
                    break
                case .loading:
                    activityIndicatorView.startAnimating()
                case .failed(let message):
                    print("ERROR: ", message)
                    activityIndicatorView.stopAnimating()
                case .loaded(let viewModels):
                    activityIndicatorView.stopAnimating()
                    let snapshot = makeSnapshot(with: viewModels)
                    dataSource.apply(snapshot)
                }
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
}

extension FavoritesViewController {

    private func registerCells() {
        tableView.register(RepositoryTableViewCell.self,
                           forCellReuseIdentifier: String(describing: RepositoryTableViewCell.self))
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

    private func makeSnapshot(with items: [RepositoryViewModel]) -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([sectionIdentifier])
        snapshot.appendItems(items, toSection: sectionIdentifier)
        return snapshot
    }
}

extension FavoritesViewController: ViewConstructing {
    func setupLayout() {

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

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

        emptyStateButton.setTitle("Liked repositories will show up here", for: .normal)
        emptyStateButton.setTitleColor(.systemGray, for: .normal)
    }
}
