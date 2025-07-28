//
//  AgitationMode.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 23.07.2025.
//

import Foundation

struct AgitationMode {
    let id = UUID()
    let name: String
    let type: AgitationType
    let isCustom: Bool
    
    enum AgitationType {
        case continuous
        case cycle(agitationSeconds: Int, restSeconds: Int)
        case complex(phases: [AgitationPhase])
    }
    
    struct AgitationPhase {
        let minuteRange: ClosedRange<Int>
        let agitationType: PhaseAgitationType
    }
    
    enum PhaseAgitationType: Equatable {
        case continuous
        case cycle(agitationSeconds: Int, restSeconds: Int)
        case periodic(intervalSeconds: Int)
        case custom(description: String)
    }
    
    var description: String {
        switch type {
        case .continuous:
            return NSLocalizedString("agitation_continuous", comment: "Continuous agitation description")
        case .cycle(let agitation, let rest):
            return String(format: NSLocalizedString("agitation_cycle_format", comment: "Agitation cycle format"), "\(agitation)", "\(rest)")
        case .complex:
            if name == NSLocalizedString("agitation_orwo_name", comment: "ORWO agitation name") {
                return NSLocalizedString("agitation_orwo_description", comment: "ORWO agitation description")
            }
            else if name == NSLocalizedString("agitation_rae_name", comment: "RAE agitation name") {
                return NSLocalizedString("agitation_rae_description", comment: "RAE agitation description")
            }
            else if name == NSLocalizedString("agitation_fixer_name", comment: "Fixer agitation name") {
                return NSLocalizedString("agitation_fixer_description", comment: "Fixer agitation description")
            }
            else {
                return " "
            }
        }
    }
    
    static let presets: [AgitationMode] = [
        AgitationMode(
            name: NSLocalizedString("agitation_orwo_name", comment: "ORWO agitation name"),
            type: .complex(phases: [
                AgitationPhase(minuteRange: 1...1, agitationType: .cycle(agitationSeconds: 45, restSeconds: 15)),
                AgitationPhase(minuteRange: 2...Int.max, agitationType: .cycle(agitationSeconds: 15, restSeconds: 45))
            ]),
            isCustom: false
        ),
        
        AgitationMode(
            name: NSLocalizedString("agitation_xtol_name", comment: "XTOL agitation name"),
            type: .cycle(agitationSeconds: 5, restSeconds: 25),
            isCustom: false
        ),
        
        AgitationMode(
            name: NSLocalizedString("agitation_rae_name", comment: "RAE agitation name"),
            type: .complex(phases: [
                AgitationPhase(minuteRange: 1...1, agitationType: .continuous),
                AgitationPhase(minuteRange: 2...2, agitationType: .periodic(intervalSeconds: 10)),
                AgitationPhase(minuteRange: 3...3, agitationType: .custom(description: NSLocalizedString("agitation_rae_phase_2_rotations", comment: "RAE phase 2 rotations"))),
                AgitationPhase(minuteRange: 4...5, agitationType: .custom(description: NSLocalizedString("agitation_rae_phase_1_rotation_per_minute", comment: "RAE phase 1 rotation per minute"))),
                AgitationPhase(minuteRange: 6...6, agitationType: .custom(description: NSLocalizedString("agitation_rae_phase_1_rotation_7th_minute", comment: "RAE phase 1 rotation on 7th minute"))),
                AgitationPhase(minuteRange: 7...9, agitationType: .custom(description: NSLocalizedString("agitation_rae_phase_1_rotation_10th_minute", comment: "RAE phase 1 rotation on 10th minute"))),
                AgitationPhase(minuteRange: 10...Int.max, agitationType: .custom(description: NSLocalizedString("agitation_rae_phase_1_rotation_every_5_minutes", comment: "RAE phase 1 rotation every 5 minutes")))
            ]),
            isCustom: false
        ),
        
        AgitationMode(
            name: NSLocalizedString("agitation_fixer_name", comment: "Fixer agitation name"),
            type: .complex(phases: [
                AgitationPhase(minuteRange: 1...1, agitationType: .continuous),
                AgitationPhase(minuteRange: 2...Int.max, agitationType: .cycle(agitationSeconds: 0, restSeconds: 60))
            ]),
            isCustom: false
        ),
        
        AgitationMode(
            name: NSLocalizedString("agitation_continuous_name", comment: "Continuous agitation name"),
            type: .continuous,
            isCustom: false
        )
    ]
    
    static func createCustomMode(agitationSeconds: Int, restSeconds: Int) -> AgitationMode {
        return AgitationMode(
            name: String(format: NSLocalizedString("agitation_custom_format", comment: "Custom agitation format"), "\(agitationSeconds)", "\(restSeconds)"),
            type: .cycle(agitationSeconds: agitationSeconds, restSeconds: restSeconds),
            isCustom: true
        )
    }
    
    func getAgitationForMinute(_ minute: Int) -> PhaseAgitationType? {
        switch type {
        case .continuous:
            return .continuous
        case .cycle(let agitation, let rest):
            return .cycle(agitationSeconds: agitation, restSeconds: rest)
        case .complex(let phases):
            return phases.first { phase in
                phase.minuteRange.contains(minute)
            }?.agitationType
        }
    }
    
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> PhaseAgitationType? {
        switch type {
        case .continuous:
            return .continuous
        case .cycle(let agitation, let rest):
            return .cycle(agitationSeconds: agitation, restSeconds: rest)
        case .complex(let phases):
            if name == NSLocalizedString("agitation_orwo_name", comment: "ORWO agitation name") {
                if minute == 1 {
                    return .cycle(agitationSeconds: 45, restSeconds: 15)
                } else if minute == totalMinutes {
                    return .cycle(agitationSeconds: 45, restSeconds: 15)
                } else {
                    return .cycle(agitationSeconds: 15, restSeconds: 45)
                }
            }
            
            return phases.first { phase in
                phase.minuteRange.contains(minute)
            }?.agitationType
        }
    }
}
