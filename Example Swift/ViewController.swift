/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */
import UIKit
import VoxImplantSDK

@objc class ViewController: UIViewController {
    #error("Enter Voximplant account credentials")
    let kUsername = ""
    let kPassword = ""

    @IBOutlet var callButton : UIButton?
    var client : VIClient?
    var currentCall : VICall?

    override func viewDidLoad() {
        super.viewDidLoad()

        VIClient.setLogLevel(.info)
        self.client = VIClient(delegateQueue: DispatchQueue.main)
        self.client?.sessionDelegate = self
        self.client?.callManagerDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.client?.connect()
    }

    @IBAction func callButtonTouched(_ sender: AnyObject?) {
        if let _ = self.currentCall {
            self.endCall()
        } else {
            self.call()
        }
    }

    func call() {
        guard self.currentCall == nil else {
            return
        }

        let callSettings = VICallSettings()
        callSettings.videoFlags = VIVideoFlags.videoFlags(receiveVideo: false, sendVideo: false)

        self.currentCall = self.client?.call("*", settings: callSettings)

        if let call = self.currentCall {
            call.add(self)

            call.start()
        }
    }

    func endCall() {
        guard self.currentCall != nil else {
            return
        }

        self.currentCall?.hangup(withHeaders: nil)
    }
}

extension ViewController : VIClientSessionDelegate {
    public func clientSessionDidConnect(_ client: VIClient) {
        NSLog("Connection established")
        self.client?.login(withUser: kUsername, password: kPassword, success: { (displayName, authParams) in

        }, failure: { (error) in
            NSLog("Login failed: %@", error.localizedDescription)
        })

    }

    public func clientSessionDidDisconnect(_ client: VIClient) {
        NSLog("Connection closed");
        DispatchQueue.main.async {
            self.callButton?.isSelected = false;
        }
    }

    public func client(_ client: VIClient, sessionDidFailConnectWithError error: Error) {
        NSLog("Connection failed: %@", error.localizedDescription);
        DispatchQueue.main.async {
            self.callButton?.isSelected = false;
        };
    }
}

extension ViewController : VIClientCallManagerDelegate {
    public func client(_ client: VIClient, didReceiveIncomingCall call: VICall, withIncomingVideo video: Bool, headers: [AnyHashable: Any]?) {
        guard self.currentCall == nil else {
            call.reject(with: .busy, headers: nil)
            return
        }
        self.currentCall = call
        self.currentCall?.add(self)

        let callSettings = VICallSettings()
        callSettings.videoFlags = VIVideoFlags.videoFlags(receiveVideo: false, sendVideo: false)
        self.currentCall?.answer(with: callSettings)
    }
}

extension ViewController: VICallDelegate {
    public func call(_ call: VICall, didConnectWithHeaders headers: [AnyHashable: Any]?) {
        NSLog("You can hear audio from the cloud");
        DispatchQueue.main.async {
            self.callButton?.isSelected = true;
        };
    }

    public func call(_ call: VICall, didDisconnectWithHeaders headers: [AnyHashable: Any]?, answeredElsewhere: NSNumber) {
        NSLog("The call has ended");
        call.remove(self)
        self.currentCall = nil
        DispatchQueue.main.async {
            self.callButton?.isSelected = false;
        };
    }

    public func call(_ call: VICall, didFailWithError error: Error, headers: [AnyHashable: Any]?) {
        NSLog("Call failed with error: %@", error.localizedDescription);
        call.remove(self)
        self.currentCall = nil
        DispatchQueue.main.async {
            self.callButton?.isSelected = false;
        };
    }
}
