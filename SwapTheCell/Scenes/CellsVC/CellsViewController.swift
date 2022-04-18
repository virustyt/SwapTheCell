//
//  ViewController.swift
//  SwapTheCell
//
//  Created by Владимир Олейников on 15/4/2022.
//

import UIKit

fileprivate extension Consts {
    static let minLinearSpacing: CGFloat = 10
    
    static let shadowOffset: CGSize = CGSize(width: -5.0, height: 0.0)
    static let shadowRadius: CGFloat = 5.0
    static let shadowOpacity: Float = 0.4
}

class CellsViewController: UIViewController {
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Person>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Person>
    
    private enum Section: String, CaseIterable {
        case mainTeam
    }
    
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
    
    private lazy var backgroundGradientView = UIImageView(image: UIImage(named: "background"))
    
    private lazy var collectionView: UICollectionView = {
        let layout = CellsVCFlowLayout()
        layout.minimumInteritemSpacing = Consts.minInterItemSpacing
        layout.minimumLineSpacing = Consts.minLinearSpacing
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(SwappingCVCell.self, forCellWithReuseIdentifier: SwappingCVCell.identifyer)
        collectionView.contentInsetAdjustmentBehavior = .always
        
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
        setupNavigationItem()
        applyDataSourceSnapshot(from: Squad.shared.team)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeNavigationBarTransparent()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        makeNavigationBarOpaque()
    }
    
    // MARK: - private funcs
    private func applyDataSourceSnapshot(from newTeam: [Person], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.mainTeam])
        snapshot.appendItems(newTeam)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func setupSquadWithTestValues() {
        Squad.shared.team.append(Person(name: "Tom"))
        Squad.shared.team.append(Person(name: "Katty"))
        Squad.shared.team.append(Person(name: "Bob"))
        Squad.shared.team.append(Person(name: "Jinny"))
        Squad.shared.team.append(Person(name: "Hubert Blaine Wolfeschlegelsteinhausenbergerdorff Sr."))
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
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationItem() {
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
        applyDataSourceSnapshot(from: Squad.shared.team)
    }
    
    @objc private func longPressGestureRecognized(sender: Any) {
        guard let longPress = sender as? UILongPressGestureRecognizer
        else { return }
        
        let gestureState = longPress.state;
        let gestureLocation: CGPoint = longPress.location(in: collectionView)
        let destinationIndexPath = collectionView.indexPathForItem(at: gestureLocation)
        
        switch gestureState {
        case .began:
            if destinationIndexPath != nil {
                sourceIndexPath = destinationIndexPath
                
                guard let sourceCell = collectionView.cellForItem(at: sourceIndexPath!) as? SwappingCVCell
                else { return }
                
                // Make a view - snapshot of the selected item.
                snapshot = makeSnapshotView(from: sourceCell)
                
                // Add the snapshot as subview, centered at cell's center.
                let sourceCellCenter = sourceCell.center
                snapshot.center = sourceCellCenter
                snapshot.alpha = 0.0
                collectionView.addSubview(snapshot)
                
                UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: { [self] in
                    self.snapshot.center = sourceCellCenter
                    self.snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    snapshot.alpha = 0.98
                    
                    // Fade out.
                    sourceCell.alpha = 0.0
                }, completion: {_ in
                    sourceCell.isHidden = true
                })
            }
        case .changed:
            snapshot.center.y = gestureLocation.y
            
            // Is destination valid and is it different from source.
            if destinationIndexPath != nil && sourceIndexPath != nil && sourceIndexPath != destinationIndexPath {
                // Update data source.
                Squad.shared.team.swapAt(destinationIndexPath!.item, sourceIndexPath!.item)

                // Move the rows.
                applyDataSourceSnapshot(from: Squad.shared.team)

                // Update sourceIndexPath so it is in sync with UI changes.
                sourceIndexPath = destinationIndexPath
            }
        default:
            // Clean up.
            if sourceIndexPath != nil,
            let cell = collectionView.cellForItem(at: sourceIndexPath!) {
                cell.alpha = 0.0
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
                    cell.isHidden = false
                })
                
            }
        }
    }
    
    private func makeSnapshotView(from inputView: UIView) -> UIView {
        // Make an image from the input view.
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0);
        
        guard let currentContext = UIGraphicsGetCurrentContext()
        else { return UIView() }
        
        inputView.layer.render(in: currentContext)
        let inputViewsImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Create an image view.
        let viewSnapshot = UIImageView(image: inputViewsImage)
        viewSnapshot.layer.masksToBounds = false;
        viewSnapshot.layer.cornerRadius = inputView.layer.cornerRadius
        viewSnapshot.layer.shadowOffset = Consts.shadowOffset
        viewSnapshot.layer.shadowRadius = Consts.shadowRadius
        viewSnapshot.layer.shadowOpacity = Consts.shadowOpacity
        
        return viewSnapshot;
    }
    
    private func makeNavigationBarOpaque() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    private func makeNavigationBarTransparent() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
}
