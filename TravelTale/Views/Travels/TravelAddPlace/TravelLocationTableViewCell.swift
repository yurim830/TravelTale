//
//  TravelLocationTableViewCell.swift
//  TravelTale
//
//  Created by SAMSUNG on 6/5/24.
//

import UIKit

final class TravelLocationTableViewCell: BaseTableViewCell {
    
    // MARK: - properties
    static let identifier = "LocationTableViewCell"
    
    let locationLabel = UILabel().then {
        $0.configureLabel(alignment: .left,
                          color: .blueBlack100,
                          font: .pretendard(size: 15, weight: .bold))
    }
    
    let locationButton = UIButton()
    
    // MARK: - methods
    override func prepareForReuse() {
        super.prepareForReuse()
        locationLabel.text = ""
    }
    
    override func configureUI() {
        super.configureUI()
    }
    
    override func configureHierarchy() {
        [locationLabel,
         locationButton].forEach {
            self.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        locationLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        locationButton.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
}

