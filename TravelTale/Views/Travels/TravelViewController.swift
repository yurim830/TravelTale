//
//  TravelViewController.swift
//  TravelTale
//
//  Created by 김정호 on 6/3/24.
//

import UIKit

final class TravelViewController: BaseViewController {
    
    // MARK: - properties
    private let travelView = TravelView()
    private let travelViewModel = TravelViewModel()
    
    //  childVC
    private let travelPlanVC = TravelPlanViewController()
    private let travelMemoryVC = TravelMemoryViewController()
    
    
    // MARK: - life cycles
    override func loadView() {
        addChildViews()
        view = travelView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        tappedButton(travelView.planButton)
    }
    
    
    // MARK: - methods
    override func configureAddTarget() {
        travelView.planButton.addTarget(
            self,
            action: #selector(tappedButton),
            for: .touchUpInside
        )
        travelView.planButton.tag = 0
        
        travelView.memoryButton.addTarget(
            self,
            action: #selector(tappedButton),
            for: .touchUpInside
        )
        travelView.memoryButton.tag = 1
    }
    
    private func addChildViews() {
        let childVCs = [
            travelPlanVC,
            travelMemoryVC
        ]
        
        childVCs.forEach {
            travelView.addConvertableView($0.view)
            self.addChild($0)
            $0.didMove(toParent: self)
        }
    }
    
    private func showOnlyView(viewToShow: UIView) {
        let views = [travelPlanVC.view,
                     travelMemoryVC.view]
        views.forEach { $0?.isHidden = $0 != viewToShow}
    }
    
    // MARK: - objc functions
    @objc func tappedButton(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            showOnlyView(viewToShow: travelPlanVC.view)
            travelView.changeButtonUI(tapped: .plan)
            
        case 1:
            showOnlyView(viewToShow: travelMemoryVC.view)
            travelView.changeButtonUI(tapped: .memory)
            
        default:
            showOnlyView(viewToShow: travelPlanVC.view)
            travelView.changeButtonUI(tapped: .plan)
        }
    }
}
