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
        case still
        case cycle(agitationSeconds: Int, restSeconds: Int)
        case complex(phases: [AgitationPhase])
    }
    
    struct AgitationPhase {
        let minuteRange: ClosedRange<Int>
        let agitationType: PhaseAgitationType
    }
    
    enum PhaseAgitationType: Equatable {
        case continuous
        case still
        case cycle(agitationSeconds: Int, restSeconds: Int)
        case periodic(intervalSeconds: Int)
        case custom(description: String)
    }
    
    var description: String {
        switch type {
        case .continuous:
            return String(localized: "agitation_continuous")
        case .still:
            return String(localized: "agitation_still")
        case .cycle(let agitation, let rest):
            return String(format: String(localized: "agitation_cycle_format"), "\(agitation)", "\(rest)")
        case .complex:
            if name == String(localized: "agitation_orwo_name") {
                return String(localized: "agitation_orwo_description")
            }
            else if name == String(localized: "agitation_rae_name") {
                return String(localized: "agitation_rae_description")
            }
            else if name == String(localized: "agitation_fixer_name") {
                return String(localized: "agitation_fixer_description")
            }
            else {
                return " "
            }
        }
    }
    
    static let presets: [AgitationMode] = [
        AgitationMode(
            name: String(localized: "agitation_orwo_name"),
            type: .complex(phases: [
                AgitationPhase(minuteRange: 1...1, agitationType: .cycle(agitationSeconds: 45, restSeconds: 15)),
                AgitationPhase(minuteRange: 2...Int.max, agitationType: .cycle(agitationSeconds: 15, restSeconds: 45))
            ]),
            isCustom: false
        ),
        
        AgitationMode(
            name: String(localized: "agitation_xtol_name"),
            type: .cycle(agitationSeconds: 5, restSeconds: 25),
            isCustom: false
        ),
        
        AgitationMode(
            name: String(localized: "agitation_rae_name"),
            type: .complex(phases: [
                AgitationPhase(minuteRange: 1...1, agitationType: .continuous),
                AgitationPhase(minuteRange: 2...2, agitationType: .periodic(intervalSeconds: 10)),
                AgitationPhase(minuteRange: 3...3, agitationType: .custom(description: String(localized: "agitation_rae_phase_2_rotations"))),
                AgitationPhase(minuteRange: 4...5, agitationType: .custom(description: String(localized: "agitation_rae_phase_1_rotation_per_minute"))),
                AgitationPhase(minuteRange: 6...6, agitationType: .custom(description: String(localized: "agitation_rae_phase_1_rotation_7th_minute"))),
                AgitationPhase(minuteRange: 7...9, agitationType: .custom(description: String(localized: "agitation_rae_phase_1_rotation_10th_minute"))),
                AgitationPhase(minuteRange: 10...Int.max, agitationType: .custom(description: String(localized: "agitation_rae_phase_1_rotation_every_5_minutes")))
            ]),
            isCustom: false
        ),
        
        AgitationMode(
            name: String(localized: "agitation_fixer_name"),
            type: .complex(phases: [
                AgitationPhase(minuteRange: 1...1, agitationType: .continuous),
                AgitationPhase(minuteRange: 2...Int.max, agitationType: .cycle(agitationSeconds: 0, restSeconds: 60))
            ]),
            isCustom: false
        ),
        
        AgitationMode(
            name: String(localized: "agitation_continuous_name"),
            type: .continuous,
            isCustom: false
        ),
        
        AgitationMode(
            name: String(localized: "agitation_still_name"),
            type: .still,
            isCustom: false
        )
    ]
    
    static func createCustomMode(agitationSeconds: Int, restSeconds: Int) -> AgitationMode {
        return AgitationMode(
            name: String(format: String(localized: "agitation_custom_format"), "\(agitationSeconds)", "\(restSeconds)"),
            type: .cycle(agitationSeconds: agitationSeconds, restSeconds: restSeconds),
            isCustom: true
        )
    }
    
    func getAgitationForMinute(_ minute: Int) -> PhaseAgitationType? {
        switch type {
        case .continuous:
            return .continuous
        case .still:
            return .still
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
        case .still:
            return .still
        case .cycle(let agitation, let rest):
            return .cycle(agitationSeconds: agitation, restSeconds: rest)
        case .complex(let phases):
            if name == String(localized: "agitation_orwo_name") {
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
