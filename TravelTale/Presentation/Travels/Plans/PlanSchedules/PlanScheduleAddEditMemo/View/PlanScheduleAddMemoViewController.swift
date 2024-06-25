//
//  PlanScheduleAddMemoViewController.swift
//  TravelTale
//
//  Created by Kinam on 6/5/24.
//

import UIKit

final class PlanScheduleAddMemoViewController: BaseViewController {
    
    // MARK: - properties
    private let memoView = PlanScheduleAddEditMemoView()
    private let realmManager = RealmManager.shared
    
    var day: String?
    var travel: Travel? = nil
    
    // MARK: - life cycles
    override func loadView() {
        view = memoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAddTarget()
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - methods
    override func configureDelegate() {
        memoView.memoTV.delegate = self
    }
    
    override func configureAddTarget() {
        memoView.completeBtn.addTarget(self, action: #selector(tapCompleteButton), for: .touchUpInside)
        memoView.backButton.target = self
        memoView.backButton.action = #selector(tapBackButton)
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "메모 추가"
        navigationItem.leftBarButtonItem = memoView.backButton
    }
    
    private func configureBackAlert(navigationController: UINavigationController?) {
        let alert = UIAlertController(title: "경고", message: memoView.alertMessage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "확인", style: .default) {_ in
            navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
        self.present(alert, animated: true)
    }
    
    @objc private func tapBackButton() {
        configureBackAlert(navigationController: navigationController)
    }
    
    @objc private func tapCompleteButton() {
        realmManager.createMemo(day: day!, travel: travel!, memo: memoView.memoTV.text)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - extensions
extension PlanScheduleAddMemoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        memoView.setBeginText(textView: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        memoView.setEndText(textView: textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        memoView.checkTextViewContent()
    }
}
