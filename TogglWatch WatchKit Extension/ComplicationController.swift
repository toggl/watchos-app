//
//  ComplicationController.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import ClockKit
import TogglTrack
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let hour: TimeInterval = 60 * 60
    let minute: TimeInterval = 60
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        UserDefaultsConfig.currentComplicationStartTime = UserDefaultsConfig.runngingTEStartTime
        UserDefaultsConfig.currentComplicationDescription = UserDefaultsConfig.runningTEDescription
        
        let template: CLKComplicationTemplate?
        
        if let start = UserDefaultsConfig.runngingTEStartTime {
            template = templateForRunningTEWithInfo(complication: complication, start: start, description:  UserDefaultsConfig.runningTEDescription)
        } else {
            template = templateForNonRunningTE(complication: complication)
        }
                
        guard let templateToUse = template else { handler(nil); return }
        
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: templateToUse)
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = templateForRunningTEWithInfo(complication: complication, start: Date(), description: "Preparing presentation for conference...")
        handler(template)
    }
    
    // MARK: - Complication Templates
    
    private func templateForRunningTEWithInfo(complication: CLKComplication, start: Date, description: String?) -> CLKComplicationTemplate?
    {
        var template: CLKComplicationTemplate?
        
        let defaultTextProvider = CLKSimpleTextProvider(text: "Toggl", shortText: "Toggl")
        defaultTextProvider.tintColor = Color.togglRed.toUIColor()
        
        let timerTextProvider = CLKRelativeDateTextProvider(date: start, style: .timer, units: [.hour, .minute, .second])
        let descriptionTextProvider = CLKSimpleTextProvider(text: description ?? "No Description")
        print(complication.family.rawValue)
        switch complication.family {
        case .modularSmall:
            let imageProvider = CLKImageProvider(onePieceImage: UIImage(imageLiteralResourceName: "Complication/Modular"))
            imageProvider.tintColor = Color.togglRed.toUIColor()
            let modularSmallTemplate = CLKComplicationTemplateModularSmallStackImage()
            modularSmallTemplate.line1ImageProvider = imageProvider
            modularSmallTemplate.line2TextProvider = timerTextProvider
            template = modularSmallTemplate
        case .modularLarge:
            let imageProvider = CLKImageProvider(onePieceImage: UIImage(imageLiteralResourceName: "Complication/Modular"))
            imageProvider.tintColor = Color.togglRed.toUIColor()
            let modularLargeTemplate = CLKComplicationTemplateModularLargeStandardBody()
            modularLargeTemplate.headerImageProvider = imageProvider
            modularLargeTemplate.headerTextProvider = timerTextProvider
            modularLargeTemplate.body1TextProvider = descriptionTextProvider
            template = modularLargeTemplate
        case .utilitarianSmallFlat, .utilitarianSmall:
            let imageProvider = CLKImageProvider(onePieceImage: UIImage(imageLiteralResourceName: "Complication/Utilitarian"))
            imageProvider.tintColor = Color.togglRed.toUIColor()
            let utilitarianSmallTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitarianSmallTemplate.textProvider = timerTextProvider
            utilitarianSmallTemplate.imageProvider = imageProvider
            template = utilitarianSmallTemplate
        case .utilitarianLarge:
            let imageProvider = CLKImageProvider(onePieceImage: UIImage(imageLiteralResourceName: "Complication/Utilitarian"))
            imageProvider.tintColor = Color.togglRed.toUIColor()
            let utilitarianLargeTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            utilitarianLargeTemplate.textProvider = CLKTextProvider(format: "%@ %@", timerTextProvider, descriptionTextProvider)
            utilitarianLargeTemplate.imageProvider = imageProvider
            template = utilitarianLargeTemplate
        case .circularSmall:
            let imageProvider = CLKImageProvider(onePieceImage: UIImage(imageLiteralResourceName: "Complication/Circular"))
            imageProvider.tintColor = Color.togglRed.toUIColor()
            let circularSmallTemplate = CLKComplicationTemplateCircularSmallStackImage()
            circularSmallTemplate.line1ImageProvider = imageProvider
            circularSmallTemplate.line2TextProvider = timerTextProvider
            template = circularSmallTemplate
        case .extraLarge:
            let extraLargeTemplate = CLKComplicationTemplateExtraLargeStackImage()
            extraLargeTemplate.line1ImageProvider = CLKImageProvider(onePieceImage: UIImage(imageLiteralResourceName: "Complication/Extra Large"))
            extraLargeTemplate.line2TextProvider = timerTextProvider
            template = extraLargeTemplate
        case .graphicCorner:
            let graphicCornerTemplate = CLKComplicationTemplateGraphicCornerStackText()
            graphicCornerTemplate.outerTextProvider = timerTextProvider
            graphicCornerTemplate.innerTextProvider = descriptionTextProvider
            template = graphicCornerTemplate
        case .graphicBezel:
            let graphicBezelTemplate = CLKComplicationTemplateGraphicBezelCircularText()
            let graphicCircularTemplate = CLKComplicationTemplateGraphicCircularStackImage()
            graphicCircularTemplate.line1ImageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(imageLiteralResourceName: "Graphic Circular Small"))
            graphicCircularTemplate.line2TextProvider = timerTextProvider
            graphicBezelTemplate.circularTemplate = graphicCircularTemplate
            graphicBezelTemplate.textProvider = descriptionTextProvider
            template = graphicBezelTemplate
        case .graphicCircular:
            let graphicCircularTemplate = CLKComplicationTemplateGraphicCircularStackImage()
            graphicCircularTemplate.line1ImageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(imageLiteralResourceName: "Graphic Circular Small"))
            graphicCircularTemplate.line2TextProvider = timerTextProvider
            template = graphicCircularTemplate
        case .graphicRectangular:
            let graphicRectangularTemplate = CLKComplicationTemplateGraphicRectangularStandardBody()
            graphicRectangularTemplate.headerImageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(imageLiteralResourceName: "Complication/Graphic Large Rectangular"))
            graphicRectangularTemplate.headerTextProvider = timerTextProvider
            graphicRectangularTemplate.body1TextProvider = descriptionTextProvider
        @unknown default:
            template = nil
        }
        
        return template
    }
    
    private func templateForNonRunningTE(complication: CLKComplication) -> CLKComplicationTemplate?
    {
        var template: CLKComplicationTemplate?
        
        let defaultTextProvider = CLKSimpleTextProvider(text: "Toggl", shortText: "Toggl")
        defaultTextProvider.tintColor = Color.togglRed.toUIColor()
        
        let defaultBodyTextProvider = CLKSimpleTextProvider(text: "Tap to open", shortText: "Open")
        print(complication.family.rawValue)
        switch complication.family {
        case .modularSmall:
            let imageProvider = CLKImageProvider(onePieceImage: UIImage(imageLiteralResourceName: "Complication/Modular"))
            imageProvider.tintColor = Color.togglRed.toUIColor()
            let modularSmallTemplate = CLKComplicationTemplateModularSmallSimpleImage()
            modularSmallTemplate.imageProvider = imageProvider
            template = modularSmallTemplate
        case .modularLarge:
            let imageProvider = CLKImageProvider(onePieceImage: UIImage(imageLiteralResourceName: "Complication/Modular"))
            imageProvider.tintColor = Color.togglRed.toUIColor()
            let modularLargeTemplate = CLKComplicationTemplateModularLargeStandardBody()
            modularLargeTemplate.headerImageProvider = imageProvider
            modularLargeTemplate.headerTextProvider = defaultTextProvider
            modularLargeTemplate.body1TextProvider = defaultBodyTextProvider
            template = modularLargeTemplate
        case .utilitarianSmallFlat, .utilitarianSmall:
            let imageProvider = CLKImageProvider(onePieceImage: UIImage(imageLiteralResourceName: "Complication/Utilitarian"))
            imageProvider.tintColor = Color.togglRed.toUIColor()
            let utilitarianSmallTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitarianSmallTemplate.textProvider = defaultTextProvider
            utilitarianSmallTemplate.imageProvider = imageProvider
            template = utilitarianSmallTemplate
        case .utilitarianLarge:
            let imageProvider = CLKImageProvider(onePieceImage: UIImage(imageLiteralResourceName: "Complication/Utilitarian"))
            imageProvider.tintColor = Color.togglRed.toUIColor()
            let utilitarianLargeTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            utilitarianLargeTemplate.textProvider = defaultTextProvider
            utilitarianLargeTemplate.imageProvider = imageProvider
            template = utilitarianLargeTemplate
        case .circularSmall:
            let imageProvider = CLKImageProvider(onePieceImage: UIImage(imageLiteralResourceName: "Complication/Circular"))
            imageProvider.tintColor = Color.togglRed.toUIColor()
            let circularSmallTemplate = CLKComplicationTemplateCircularSmallSimpleImage()
            circularSmallTemplate.imageProvider = imageProvider
            template = circularSmallTemplate
        case .extraLarge:
            let extraLargeTemplate = CLKComplicationTemplateExtraLargeSimpleImage()
            extraLargeTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(imageLiteralResourceName: "Complication/Extra Large"))
            template = extraLargeTemplate
        case .graphicCorner:
            let graphicCornerTemplate = CLKComplicationTemplateGraphicCornerCircularImage()
            graphicCornerTemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(imageLiteralResourceName: "Complication/Graphic Corner"))
            template = graphicCornerTemplate
        case .graphicBezel:
            let graphicBezelTemplate = CLKComplicationTemplateGraphicBezelCircularText()
            let graphicCircularTemplate = CLKComplicationTemplateGraphicCircularImage()
            graphicCircularTemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(imageLiteralResourceName: "Complication/Graphic Bezel"))
            graphicBezelTemplate.circularTemplate = graphicCircularTemplate
            graphicBezelTemplate.textProvider = defaultTextProvider
            template = graphicBezelTemplate
        case .graphicCircular:
            let graphicCircularTemplate = CLKComplicationTemplateGraphicCircularImage()
            graphicCircularTemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(imageLiteralResourceName: "Complication/Graphic Circular"))
            template = graphicCircularTemplate
        case .graphicRectangular:
            let graphicRectangularTemplate = CLKComplicationTemplateGraphicRectangularStandardBody()
            graphicRectangularTemplate.headerImageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(imageLiteralResourceName: "Complication/Graphic Large Rectangular"))
            graphicRectangularTemplate.headerTextProvider = defaultTextProvider
            graphicRectangularTemplate.body1TextProvider = defaultBodyTextProvider
        @unknown default:
            template = nil
        }
        
        return template
    }
}
