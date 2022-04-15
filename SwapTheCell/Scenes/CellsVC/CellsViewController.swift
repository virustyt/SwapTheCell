//
//  ViewController.swift
//  SwapTheCell
//
//  Created by Владимир Олейников on 15/4/2022.
//

import UIKit

fileprivate extension Consts {
    static let minLinearSpacing: CGFloat = 10
}

class CellsViewController: UIViewController {
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Person>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Person>
    
    private enum Section: String, CaseIterable {
        case mainTeam
    }
    
    private lazy var backgroundGradientView = UIImageView(image: UIImage(named: "background"))
    
    private lazy var dataSource: DataSource = {
        let difffableDataSource = DataSource(collectionView: collectionView,
                                             cellProvider: { [weak self] (recievedCollectionView, indexPath, person) -> UICollectionViewCell? in
            guard let cell = recievedCollectionView.dequeueReusableCell( withReuseIdentifier: SwappingCVCell.identifyer,
                                                                         for: indexPath) as? SwappingCVCell
            else {return UICollectionViewCell() }
            
            cell.setupCell(from: person)
            return cell
        })
        return difffableDataSource
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Consts.minInterItemSpacing
        layout.minimumLineSpacing = Consts.minLinearSpacing
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(SwappingCVCell.self, forCellWithReuseIdentifier: SwappingCVCell.identifyer)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSquadWithTestValues()
        setupConstraints()
        setUpNavigationItem()
        applySnapshot(for: Squad.shared.team)
    }
    
    // MARK: - private funcs
    private func applySnapshot(for newPhotos: [Person], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.mainTeam])
        snapshot.appendItems(newPhotos)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func setupSquadWithTestValues() {
        Squad.shared.team.append(Person(name: "Tom"))
        Squad.shared.team.append(Person(name: "Katty"))
        Squad.shared.team.append(Person(name: "Bob"))
        Squad.shared.team.append(Person(name: "Jinny"))
        Squad.shared.team.append(Person(name: "Markus"))
    }
    
    private func setupConstraints() {
        view.addSubview(backgroundGradientView)
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundGradientView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setUpNavigationItem(){
        let shuffleBarButtonItem = UIBarButtonItem(image: UIImage(named: "shuffle"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(shuffleCollectionViewCells))
        shuffleBarButtonItem.tintColor = UIColor.slateGray.withAlphaComponent(0.7)
        navigationItem.rightBarButtonItem = shuffleBarButtonItem
    }
    
    @objc private func shuffleCollectionViewCells() {
        var newSquad = Squad(team: [])
        var personsCount = Squad.shared.team.count
        for _ in 0..<personsCount {
            let randomPerson = Squad.shared.team.remove(at: Int.random(in: 0..<personsCount))
            personsCount -= 1
            newSquad.team.append(randomPerson)
        }
        Squad.shared.team = newSquad.team
        applySnapshot(for: Squad.shared.team)
    }
}

