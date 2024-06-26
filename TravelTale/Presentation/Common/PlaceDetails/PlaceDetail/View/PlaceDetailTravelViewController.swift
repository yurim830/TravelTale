//
//  PlaceDetailTravelViewController.swift
//  TravelTale
//
//  Created by 배지해 on 6/26/24.
//

import MapKit
import UIKit

final class PlaceDetailTravelViewController: BaseViewController {
    
    // MARK: - properties
    private let placeDetailView = PlaceDetailView()
    
    private let realmManager = RealmManager.shared
    
    private var isBookMarked: Bool = false
    
    var completion: (() -> Void)?
    
    var placeDetailData: [PlaceDetail]? {
        didSet {
            guard let placeDetail = placeDetailData?[0] else { return }
            
            setBookmarkData()
            
            if let url = extractURL(from: placeDetailData?[0].homepage) {
                placeDetailView.bind(placeDetail: placeDetail, url: url, isBookMarked: isBookMarked)
            } else {
                placeDetailView.bind(placeDetail: placeDetail, url: nil, isBookMarked: isBookMarked)
            }
        }
    }
    
    // MARK: - life cycles
    override func loadView() {
        view = placeDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBookmarkData()
        placeDetailView.setAddButton(text: "장소 선택하기")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - methods
    override func configureDelegate() {
        placeDetailView.mapView.delegate = self
    }
    
    override func configureAddTarget() {
        placeDetailView.backButton.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
        placeDetailView.phoneNumberButton.addTarget(self, action: #selector(tappedPhoneNumberButton), for: .touchUpInside)
        placeDetailView.websiteButton.addTarget(self, action: #selector(tappedWebsiteButton), for: .touchUpInside)
        placeDetailView.copyAddressButton.addTarget(self, action: #selector(tappedCopyButton), for: .touchUpInside)
        placeDetailView.bookMarkButton.addTarget(self, action: #selector(tappedBookMarkButton), for: .touchUpInside)
        placeDetailView.addButton.addTarget(self, action: #selector(tappedAddButton), for: .touchUpInside)
    }
    
    @objc private func tappedBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func tappedPhoneNumberButton() {
        let PlaceDetailAlertVC = PlaceDetailAlertViewController()
        
        if let phoneNumber = placeDetailData?[0].tel {
            PlaceDetailAlertVC.setPhoneNumber(phoneNumber: phoneNumber)
        }
        
        PlaceDetailAlertVC.modalPresentationStyle = .overFullScreen
        present(PlaceDetailAlertVC, animated: false)
    }
    
    @objc private func tappedWebsiteButton() {
        if let homepage = extractURL(from: placeDetailData?[0].homepage), let url = URL(string: homepage){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func tappedCopyButton() {
        if let address = placeDetailView.copyAddress() {
            UIPasteboard.general.string = address
        }
        configureToast(text: "주소가 복사되었습니다.")
    }
    
    @objc private func tappedBookMarkButton() {
        guard let placeDetailData = placeDetailData?[0] else { return }
        
        if isBookMarked {
            placeDetailView.configureBookMarkButton(isBookMarked: false)
            isBookMarked = false
            
            realmManager.deleteBookmark(placeDetail: placeDetailData)
            
            configureToast(text: "북마크에서 삭제되었습니다.")
        } else {
            placeDetailView.configureBookMarkButton(isBookMarked: true)
            isBookMarked = true
            
            if let image = placeDetailData.firstImage, let image = URL(string: image) {
                Task {
                    do {
                        let request = URLRequest(url: image)
                        let (data, _) = try await URLSession.shared.data(for: request)
                        realmManager.createBookmark(placeDetail: placeDetailData, imageData: data)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } else {
                realmManager.createBookmark(placeDetail: placeDetailData, imageData: nil)
            }
            
            configureToast(text: "북마크에 추가되었습니다.")
        }
        
        completion?()
    }
    
    @objc private func tappedAddButton() {
        guard let placeDetail = placeDetailData?[0] else { return }
        
        // TODO: - 장소 추가와 장소 수정에 정보 전달
//        NotificationCenter.default.post(name: NSNotification.Name("placeSelected"), object: nil, userInfo: [NotificationKey.dataDetail : placeDetail])
        
        popToView(pages: 3)
    }
    
    private func popToView(pages: Int) {
        if let navigationController = self.navigationController {
            let viewControllers = navigationController.viewControllers
            let targetIndex = max(0, viewControllers.count - pages - 1)
            let targetViewController = viewControllers[targetIndex]
            navigationController.popToViewController(targetViewController, animated: true)
        }
    }
    
    private func setBookmarkData() {
        guard let placeDatailData = placeDetailData?[0] else { return }
        
        if realmManager.fetchBookmarks(contentTypeId: .total).filter({ $0.contentId == placeDatailData.contentId }).count > 0 {
            isBookMarked = true
        } else {
            isBookMarked = false
        }
    }
    
    private func configureToast(text: String) {
        let placeDetailToastView = PlaceDetailToastView()
        
        placeDetailToastView.setText(text: text)
        configureToastConstraints(toastView: placeDetailToastView)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            placeDetailToastView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                placeDetailToastView.alpha = 0.0
            }, completion: { _ in
                placeDetailToastView.removeFromSuperview()
            })
        })
    }
    
    private func configureToastConstraints(toastView: UIView) {
        view.addSubview(toastView)
        
        toastView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
    }
    
    private func extractURL(from htmlString: String?) -> String? {
        guard let htmlString = htmlString else { return nil }
        
        do {
            let regex = try NSRegularExpression(pattern: "<a href=\"([^\"]*)\"", options: [])
            let nsString = htmlString as NSString
            let results = regex.matches(in: htmlString, options: [], range: NSMakeRange(0, nsString.length))
            if let match = results.first {
                let url = nsString.substring(with: match.range(at: 1))
                return url
            }
        } catch let error {
            print("Error : \(error.localizedDescription)")
        }
        
        return nil
    }
}

// MARK: - extensions
extension PlaceDetailTravelViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        let identifier = "CustomAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
        } else {
            annotationView?.annotation = annotation
        }
        
        let annotationImage = UIImage.annotation
        
        let size = CGSize(width: 80, height: 100)
        UIGraphicsBeginImageContext(size)
        annotationImage.draw(in: CGRect(origin: .zero, size: size))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        annotationView?.image = resizedImage
        
        return annotationView
    }
}
