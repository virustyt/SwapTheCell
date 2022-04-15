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
        
        collectionView.addGestureRecognizer(longPress)
        
        return collectionView
    }()
    
    private lazy var longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized))
    
    private var sourceIndexPath: IndexPath?
    private var snapshot = UIView()
    
    // MARK: - life cycle
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
            
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
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
    
    @objc private func longPressGestureRecognized(sender: Any) {
        guard let longPress = sender as? UILongPressGestureRecognizer
        else { return }
        
        let state = longPress.state;
        let location: CGPoint = longPress.location(in: collectionView)
        let destinationIndexPath = collectionView.indexPathForItem(at: location)
        
        switch state {
        case .began:
            if destinationIndexPath != nil {
                sourceIndexPath = destinationIndexPath
                
                guard let cell = collectionView.cellForItem(at: destinationIndexPath!) as? SwappingCVCell
                else { return }
                
                // Take a snapshot of the selected item
                snapshot = customSnapshoFromView(inputView: cell)
                
                // Add the snapshot as subview, centered at cell's center
                var center: CGPoint = cell.center
                snapshot.center = center
                snapshot.alpha = 0.0
                collectionView.addSubview(snapshot)
                
                UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: { [self] in
                    center.y = location.y
                    self.snapshot.center = center
                    self.snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    snapshot.alpha = 0.98
                    
                    // Fade out.
                    cell.alpha = 0.0
                })
            }
        case .changed:
            var center:CGPoint = snapshot.center
            center.y = location.y
            snapshot.center = center
            
            // Is destination valid and is it different from source?
            if destinationIndexPath != nil && sourceIndexPath != destinationIndexPath {
                // Update data source.
                Squad.shared.team.swapAt(destinationIndexPath!.item, sourceIndexPath!.item)

                guard let cell = collectionView.cellForItem(at: sourceIndexPath!) as? SwappingCVCell
                else { return }
                
                cell.isHidden = true
                
                // Move the rows.
                applySnapshot(for: Squad.shared.team)

                // Update sourceIndexPath so it is in sync with UI changes.
                sourceIndexPath = destinationIndexPath
            }
        default:
            // Clean up.
            if sourceIndexPath != nil,
            let cell = collectionView.cellForItem(at: sourceIndexPath!) {
                cell.isHidden = false
                UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
                    self.snapshot.center = cell.center
                    self.snapshot.transform = .identity
                    self.snapshot.alpha = 0.0
                    
                    // Undo fade out.
                    cell.alpha = 1.0
                }, completion: {_ in
                    self.sourceIndexPath = nil;
                    self.snapshot.removeFromSuperview()
                    
                })
            }
        }
    }
    
    private func customSnapshoFromView(inputView: UIView) -> UIView {
        // Make an image from the input view.
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0);
        
        guard let currentContext = UIGraphicsGetCurrentContext()
        else { return UIView() }
        
        inputView.layer.render(in: currentContext)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Create an image view.
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false;
        snapshot.layer.cornerRadius = 0.0;
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot.layer.shadowRadius = 5.0;
        snapshot.layer.shadowOpacity = 0.4;
        
        return snapshot;
    }
}

