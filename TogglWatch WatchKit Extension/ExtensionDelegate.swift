//
//  ExtensionDelegate.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import WatchKit
import UserNotifications
import TogglTrack

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        WKExtension.shared().registerForRemoteNotifications()
    }

    func applicationDidBecomeActive() {
        guard let initialController = WKExtension.shared().rootInterfaceController as? HostingController else {
            return
        }
        
        initialController.didBecomeActive()
        
        reloadComplications()
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        reloadComplications()
    }
    
    @objc func reloadComplications()
    {
        let server = CLKComplicationServer.sharedInstance()
        for comp in (server.activeComplications ?? []) {
            server.reloadTimeline(for: comp)
        }
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                reloadComplications()
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data)
    {
        guard let initialController = WKExtension.shared().rootInterfaceController as? HostingController else { return }
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        initialController.store.send(.user(.subscribeToPushNotifications(deviceTokenString)))
    }
    
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void)
    {
        guard let initialController = WKExtension.shared().rootInterfaceController as? HostingController else { return }
        initialController.store.send(.loadAll(force: true))
        NotificationCenter.default.addObserver(self, selector: #selector(reloadComplications), name: UserDefaults.didChangeNotification, object: nil)
        completionHandler(.noData)
    }
}
