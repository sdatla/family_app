//
//  ScannerViewController.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 3/10/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
protocol communicationControllerQrScanner {
    func qrCodeValueAcquired(_ profile: Profile)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var delegate: communicationControllerQrScanner? = nil
    var video = AVCaptureVideoPreviewLayer()
    var session: AVCaptureSession?
    var square: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.green.cgColor
        return view
    }()
    let backButtonInScanner: UIButton = {
        let btn = UIButton()
        btn.setTitle("Back", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(onScannerBackButtonClick), for: .touchUpInside)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        turnOnCamera()
        view.addSubview(square)
        view.addSubview(backButtonInScanner)
        setupViewsInScanner()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        session?.stopRunning()
    }
    
    func turnOnCamera() {
        session = AVCaptureSession()
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            if captureDevice == nil {
                return;
            }
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session!.addInput(input)
        } catch let err {
            print("device failed", err)
            return;
        }
        
        let output = AVCaptureMetadataOutput()
        session!.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.qr]
        video = AVCaptureVideoPreviewLayer(session:session!)
        video.frame = view.bounds
        view.layer.addSublayer(video)
        session!.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == .qr {
                    guard var familyId = object.stringValue else {return}
                    guard let range = familyId.range(of: "whee_") else {return}
                    familyId = String(familyId[range.upperBound..<familyId.endIndex])
                    session?.stopRunning()
                    Auth.auth().signInAnonymously { (user, error) in
                        if error != nil {
                            print("error occured", error?.localizedDescription as Any)
                            self.dismiss(animated: true, completion: nil)
                            return
                        }
                        guard let user = user else {return}
                        let profile = Profile(user)
                        profile.familyId = familyId
                        profile.createProfileInDatabase()
                        self.delegate?.qrCodeValueAcquired(profile)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    private func setupViewsInScanner() {
        square.translatesAutoresizingMaskIntoConstraints = false
        backButtonInScanner.translatesAutoresizingMaskIntoConstraints = false
        square.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        square.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        square.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        square.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backButtonInScanner.topAnchor.constraint(equalTo: square.bottomAnchor).isActive = true
        backButtonInScanner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    
    @objc func onScannerBackButtonClick() {
        session?.stopRunning()
        self.dismiss(animated: true, completion: nil)
    }

}
