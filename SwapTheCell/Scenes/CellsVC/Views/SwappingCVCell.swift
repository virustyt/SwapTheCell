//
//  SwappingCollectionViewCell.swift
//  SwapTheCell
//
//  Created by Владимир Олейников on 15/4/2022.
//

import UIKit

fileprivate extension Consts {
    static let titleFontSize: CGFloat = 18
    
    static let titleLabelTopInset: CGFloat = 10
    static let titleLabelBottomInset: CGFloat = 10
    static let titleLabelLeadingInset: CGFloat = 10
    static let titleLabelTrailingInset: CGFloat = 10
    
    static let borderLineWidth: CGFloat = 1.5
    static let cornerRadius: CGFloat = 16
    static let shadowRadius: CGFloat = 163.6
    static let shadowOffset: CGSize = CGSize(width: 5, height: 5)
    
    static let backgroundGradirntStartPoint: CGPoint = CGPoint(x: 0, y: 0.5)
    static let backgroundGradientEndPoint: CGPoint = CGPoint(x: 1, y: 0.5)
    
    static let borderlineGradirntStartPoint: CGPoint = CGPoint(x: 0, y: 0.5)
    static let borderlineGradientEndPoint: CGPoint = CGPoint(x: 1, y: 0.5)
}

class SwappingCVCell: UICollectionViewCell {
    
    static let identifyer = String(describing: SwappingCVCell.self)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Consts.titleFontSize)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let backgroundGradientLayer = CAGradientLayer()
    private let borderLineGradient = CAGradientLayer()
    private let borderLineMaskLayer = CAShapeLayer()
    
    // MARK: - inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear.withAlphaComponent(0)
         
        setUpConstrainst()
        setUpShadows()
        setUpGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public funcs
    func setupCell(from person: Person) {
        titleLabel.text = person.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    override func layoutSubviews() {
           super.layoutSubviews()
           if backgroundGradientLayer.frame != bounds {
               backgroundGradientLayer.frame = bounds
               borderLineGradient.frame = bounds
               borderLineMaskLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: Consts.cornerRadius).cgPath
           }
       }
    
    // MARK: - private funcs
       private func setUpConstrainst() {
           contentView.addSubview(titleLabel)

           titleLabel.translatesAutoresizingMaskIntoConstraints = false
//           contentView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([
//               contentView.topAnchor.constraint(equalTo: topAnchor),
//               contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
//               contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//               contentView.leadingAnchor.constraint(equalTo: leadingAnchor),

               titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                               constant: Consts.titleLabelTopInset),
               titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                  constant: -Consts.titleLabelBottomInset),
               titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                          constant: Consts.titleLabelLeadingInset),
               titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                           constant: -Consts.titleLabelTrailingInset)
           ])
       }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
            layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize,
                                                                              withHorizontalFittingPriority: .required,
                                                                              verticalFittingPriority: .fittingSizeLevel)
            return layoutAttributes
        }
    
    private func setUpShadows() {
        layer.cornerRadius = Consts.cornerRadius
        layer.masksToBounds = true
        layer.shadowOffset = Consts.shadowOffset
        layer.shadowRadius = Consts.shadowRadius
        layer.shadowColor = UIColor.white.withAlphaComponent(0.05).cgColor
    }

    private func setUpGradient() {
        backgroundGradientLayer.startPoint = Consts.backgroundGradirntStartPoint
        backgroundGradientLayer.endPoint = Consts.backgroundGradientEndPoint
            backgroundGradientLayer.colors = [UIColor(red: 1, green: 1, blue: 0.984, alpha: 0.55).cgColor,
                                              UIColor(red: 1, green: 1, blue: 0.984, alpha: 0.15).cgColor]

        borderLineGradient.startPoint = Consts.borderlineGradirntStartPoint
        borderLineGradient.endPoint = Consts.borderlineGradientEndPoint
            borderLineGradient.colors = [UIColor(red: 1, green: 1, blue: 0.984, alpha: 0.4).cgColor,
                                         UIColor(red: 1, green: 1, blue: 0.984, alpha: 0.15).cgColor]
            borderLineMaskLayer.lineWidth = Consts.borderLineWidth
            borderLineMaskLayer.fillColor = nil
            borderLineMaskLayer.strokeColor = UIColor.black.cgColor
            borderLineGradient.mask = borderLineMaskLayer

            layer.addSublayer(borderLineGradient)
            layer.addSublayer(backgroundGradientLayer)
        }
}
