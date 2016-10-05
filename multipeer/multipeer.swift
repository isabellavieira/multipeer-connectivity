//
//  multipeer.swift
//  multipeer
//
//  Created by Isabella Vieira on 10/5/16.
//  Copyright © 2016 Isabella Vieira. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ColorServiceManager: NSObject {
    private let ColorServiceType = "image"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    var images:[UIImage] = []

    static var managerSingleton = ColorServiceManager()
    static func getHASingleton() -> ColorServiceManager {
        return managerSingleton
    }
    
    // advertiser
    private var serviceAdvertiser : MCNearbyServiceAdvertiser
    
    // browser
    private var serviceBrowser : MCNearbyServiceBrowser
    
    // delegate do protocolo que criamos la embaixos
    var delegate : ColorServiceManagerDelegate?
    
    // so vai rodar quando em algum momento do codigo eu chamar essa session
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
        return session
    } ()
    
    override init () {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser (peer: myPeerId, discoveryInfo: nil, serviceType: ColorServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser (peer: myPeerId, serviceType: ColorServiceType)
        
        super.init ()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    // desconstrutor - quando a instancia parar de existir, vai parar de procurar servocos
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    /*func sendColor (_ colorName:String) {
        print ("sendColor: \(colorName)")
        if (session.connectedPeers.count > 0) {
            do {
                try self.session.send(colorName.data(using: String.Encoding.utf8, allowLossyConversion: false)!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
            } catch {
                print ("error sending data")
            }
        }
    }*/
    
    var mcSession: MCSession!
    func sendImage(img: UIImage) {
        print(">>>>>>>>>>>>>>>ENTREI")
        if mcSession.connectedPeers.count > 0 {
            print("CONNECTED PEERS: \(mcSession.connectedPeers.count)")
            if let imageData = UIImagePNGRepresentation(img) {
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch let error as NSError {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                   // present(ac, animated: true)
                }
            }
        }
    }

    
}

extension ColorServiceManager: MCNearbyServiceAdvertiserDelegate {
    // voce esta anunciando um servico, foi la e recebeu convites
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        print ("didReceiveInvitationFromPeer: \(peerID)")
        invitationHandler (true, self.session)
    }
}

extension ColorServiceManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        print ("foundPeer: \(peerID)")
        print ("invitePeer: \(peerID)")
        
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print ("lost peer: \(peerID)")
    }
}

extension MCSessionState {
    func stringValue() -> String {
        switch(self) {
        case .notConnected: return "NotConnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }
}

extension MCSessionState: CustomDebugStringConvertible {
    public var debugDescription:String {
        switch(self) {
        case .notConnected: return "NotConnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }
}

extension ColorServiceManager: MCSessionDelegate {
    func session (_ session:MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // print ("peer: \(peerID) didChangeState: \(state))")
        print ("peer: \(peerID) didChangeState: \(state.stringValue()))")
        
        self.delegate?.connectedDeviceChanged(manager:self, connectedDevices: session.connectedPeers.map({$0.displayName}))
    }
    
   /* func session (_ session:MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print ("didReceiveData: \(data.count) bytes")
        let str = NSString(data:data, encoding: String.Encoding.utf8.rawValue) as! String
        self.delegate?.colorChanged(manager:self, colorString: str)
    } */
    
    // Receiving data from the other side
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let image = UIImage(data: data) {
            DispatchQueue.main.async { [unowned self] in
                // do something with the image
                self.images.append(image)
            }
        }
        print ("Images: \(images)")
    }

    
    func session (_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session (_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with Progress: Progress) {}
    
    func session (_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError ERROR: Error?) {}
}

protocol ColorServiceManagerDelegate {
    func connectedDeviceChanged (manager : ColorServiceManager, connectedDevices: [String])
    func colorChanged(manager : ColorServiceManager, colorString: String)
}
