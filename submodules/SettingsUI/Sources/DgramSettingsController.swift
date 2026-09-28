import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import TelegramUIPreferences
import ItemListUI
import PresentationDataUtils
import AccountContext
import AlertUI

private final class DgramSettingsControllerArguments {
    let updateGhostRead: (Bool) -> Void
    let updateGhostTyping: (Bool) -> Void
    let updateGhostStories: (Bool) -> Void
    let updateAntiDelete: (Bool) -> Void
    let updateSaveViewOnce: (Bool) -> Void
    let updateHidePhone: (Bool) -> Void
    let updateShowIdDc: (Bool) -> Void
    let updatePluginsEnabled: (Bool) -> Void
    let openPlugins: () -> Void
    
    init(
        updateGhostRead: @escaping (Bool) -> Void,
        updateGhostTyping: @escaping (Bool) -> Void,
        updateGhostStories: @escaping (Bool) -> Void,
        updateAntiDelete: @escaping (Bool) -> Void,
        updateSaveViewOnce: @escaping (Bool) -> Void,
        updateHidePhone: @escaping (Bool) -> Void,
        updateShowIdDc: @escaping (Bool) -> Void,
        updatePluginsEnabled: @escaping (Bool) -> Void,
        openPlugins: @escaping () -> Void
    ) {
        self.updateGhostRead = updateGhostRead
        self.updateGhostTyping = updateGhostTyping
        self.updateGhostStories = updateGhostStories
        self.updateAntiDelete = updateAntiDelete
        self.updateSaveViewOnce = updateSaveViewOnce
        self.updateHidePhone = updateHidePhone
        self.updateShowIdDc = updateShowIdDc
        self.updatePluginsEnabled = updatePluginsEnabled
        self.openPlugins = openPlugins
    }
}

private enum DgramSettingsSection: Int32 {
    case ghost
    case chats
    case plugins
    case info
}

private enum DgramSettingsControllerEntry: ItemListNodeEntry {
    case ghostHeader
    case ghostRead(Bool)
    case ghostTyping(Bool)
    case ghostStories(Bool)
    case ghostFooter
    
    case chatsHeader
    case antiDelete(Bool)
    case saveViewOnce(Bool)
    case hidePhone(Bool)
    case showIdDc(Bool)
    case chatsFooter
    
    case pluginsHeader
    case pluginsEnabled(Bool)
    case pluginsManage
    case pluginsFooter
    
    case infoHeader
    case infoVersion
    case infoSourceCode
    case infoFooter
    
    var section: ItemListSectionId {
        switch self {
        case .ghostHeader, .ghostRead, .ghostTyping, .ghostStories, .ghostFooter:
            return DgramSettingsSection.ghost.rawValue
        case .chatsHeader, .antiDelete, .saveViewOnce, .hidePhone, .showIdDc, .chatsFooter:
            return DgramSettingsSection.chats.rawValue
        case .pluginsHeader, .pluginsEnabled, .pluginsManage, .pluginsFooter:
            return DgramSettingsSection.plugins.rawValue
        case .infoHeader, .infoVersion, .infoSourceCode, .infoFooter:
            return DgramSettingsSection.info.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .ghostHeader: return 0
        case .ghostRead: return 1
        case .ghostTyping: return 2
        case .ghostStories: return 3
        case .ghostFooter: return 4
        
        case .chatsHeader: return 10
        case .antiDelete: return 11
        case .saveViewOnce: return 12
        case .hidePhone: return 13
        case .showIdDc: return 14
        case .chatsFooter: return 15
        
        case .pluginsHeader: return 20
        case .pluginsEnabled: return 21
        case .pluginsManage: return 22
        case .pluginsFooter: return 23
        
        case .infoHeader: return 30
        case .infoVersion: return 31
        case .infoSourceCode: return 32
        case .infoFooter: return 33
        }
    }
    
    static func <(lhs: DgramSettingsControllerEntry, rhs: DgramSettingsControllerEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! DgramSettingsControllerArguments
        switch self {
        case .ghostHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "НЕВИДИМКА (GHOST MODE)", sectionId: self.section)
        case let .ghostRead(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Не читать сообщения", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGhostRead(value)
            })
        case let .ghostTyping(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Скрыть статус «печатает...»", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGhostTyping(value)
            })
        case let .ghostStories(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Анонимный просмотр историй", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGhostStories(value)
            })
        case .ghostFooter:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Собеседники не узнают, что вы прочитали сообщение, набираете текст или просмотрели их историю."), sectionId: self.section)
            
        case .chatsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "ЧАТЫ И МЕДИА", sectionId: self.section)
        case let .antiDelete(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Анти-удаление сообщений", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateAntiDelete(value)
            })
        case let .saveViewOnce(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Сохранение одноразовых медиа", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateSaveViewOnce(value)
            })
        case let .hidePhone(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Скрыть номер телефона в профиле", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateHidePhone(value)
            })
        case let .showIdDc(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Показывать ID и DC в профиле", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateShowIdDc(value)
            })
        case .chatsFooter:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Удаленные собеседником сообщения остаются в чате с пометкой [🗑️ Удалено]. Одноразовые фото и видео не сгорают."), sectionId: self.section)
            
        case .pluginsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "ПЛАГИНЫ (JAVASCRIPT ENGINE)", sectionId: self.section)
        case let .pluginsEnabled(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Включить движок плагинов", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updatePluginsEnabled(value)
            })
        case .pluginsManage:
            return ItemListDisclosureItem(presentationData: presentationData, title: "Управление плагинами", label: "0 активно", sectionId: self.section, style: .blocks, action: {
                arguments.openPlugins()
            })
        case .pluginsFooter:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Поддержка расширений JavaScriptCore для автоматизации, кастомных команд и фильтров как в exteraGram."), sectionId: self.section)
            
        case .infoHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "О DGRAM", sectionId: self.section)
        case .infoVersion:
            return ItemListDisclosureItem(presentationData: presentationData, title: "Версия", label: "dgram 1.0", sectionId: self.section, style: .blocks, action: nil)
        case .infoSourceCode:
            return ItemListDisclosureItem(presentationData: presentationData, title: "Исходный код", label: "GitHub", sectionId: self.section, style: .blocks, action: {
                if let url = URL(string: "https://github.com/sheluvsw4g/my-telegram-ios") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
        case .infoFooter:
            return ItemListTextItem(presentationData: presentationData, text: .plain("dgram создан на базе Telegram iOS с классическим стилем и возможностями exteraGram."), sectionId: self.section)
        }
    }
}

private struct DgramSettingsState: Equatable {
    var ghostRead: Bool
    var ghostTyping: Bool
    var ghostStories: Bool
    var antiDelete: Bool
    var saveViewOnce: Bool
    var hidePhone: Bool
    var showIdDc: Bool
    var pluginsEnabled: Bool
}

private func dgramSettingsEntries(state: DgramSettingsState) -> [DgramSettingsControllerEntry] {
    var entries: [DgramSettingsControllerEntry] = []
    
    entries.append(.ghostHeader)
    entries.append(.ghostRead(state.ghostRead))
    entries.append(.ghostTyping(state.ghostTyping))
    entries.append(.ghostStories(state.ghostStories))
    entries.append(.ghostFooter)
    
    entries.append(.chatsHeader)
    entries.append(.antiDelete(state.antiDelete))
    entries.append(.saveViewOnce(state.saveViewOnce))
    entries.append(.hidePhone(state.hidePhone))
    entries.append(.showIdDc(state.showIdDc))
    entries.append(.chatsFooter)
    
    entries.append(.pluginsHeader)
    entries.append(.pluginsEnabled(state.pluginsEnabled))
    entries.append(.pluginsManage)
    entries.append(.pluginsFooter)
    
    entries.append(.infoHeader)
    entries.append(.infoVersion)
    entries.append(.infoSourceCode)
    entries.append(.infoFooter)
    
    return entries
}

public func dgramSettingsController(context: AccountContext) -> ViewController {
    let statePromise = ValuePromise<DgramSettingsState>(DgramSettingsState(
        ghostRead: DgramConfig.ghostModeNoReadReceipts,
        ghostTyping: DgramConfig.ghostModeHideTyping,
        ghostStories: DgramConfig.ghostModeStories,
        antiDelete: DgramConfig.antiDeleteMessages,
        saveViewOnce: DgramConfig.saveViewOnceMedia,
        hidePhone: DgramConfig.hidePhoneNumber,
        showIdDc: DgramConfig.showIdAndDc,
        pluginsEnabled: DgramConfig.pluginsEnabled
    ), ignoreRepeated: true)
    
    let stateValue = Atomic<DgramSettingsState>(value: DgramSettingsState(
        ghostRead: DgramConfig.ghostModeNoReadReceipts,
        ghostTyping: DgramConfig.ghostModeHideTyping,
        ghostStories: DgramConfig.ghostModeStories,
        antiDelete: DgramConfig.antiDeleteMessages,
        saveViewOnce: DgramConfig.saveViewOnceMedia,
        hidePhone: DgramConfig.hidePhoneNumber,
        showIdDc: DgramConfig.showIdAndDc,
        pluginsEnabled: DgramConfig.pluginsEnabled
    ))
    
    let updateState: ((DgramSettingsState) -> DgramSettingsState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }
    
    var presentControllerImpl: ((ViewController) -> Void)?
    
    let arguments = DgramSettingsControllerArguments(
        updateGhostRead: { value in
            DgramConfig.ghostModeNoReadReceipts = value
            updateState { state in
                var state = state
                state.ghostRead = value
                return state
            }
        },
        updateGhostTyping: { value in
            DgramConfig.ghostModeHideTyping = value
            updateState { state in
                var state = state
                state.ghostTyping = value
                return state
            }
        },
        updateGhostStories: { value in
            DgramConfig.ghostModeStories = value
            updateState { state in
                var state = state
                state.ghostStories = value
                return state
            }
        },
        updateAntiDelete: { value in
            DgramConfig.antiDeleteMessages = value
            updateState { state in
                var state = state
                state.antiDelete = value
                return state
            }
        },
        updateSaveViewOnce: { value in
            DgramConfig.saveViewOnceMedia = value
            updateState { state in
                var state = state
                state.saveViewOnce = value
                return state
            }
        },
        updateHidePhone: { value in
            DgramConfig.hidePhoneNumber = value
            updateState { state in
                var state = state
                state.hidePhone = value
                return state
            }
        },
        updateShowIdDc: { value in
            DgramConfig.showIdAndDc = value
            updateState { state in
                var state = state
                state.showIdDc = value
                return state
            }
        },
        updatePluginsEnabled: { value in
            DgramConfig.pluginsEnabled = value
            updateState { state in
                var state = state
                state.pluginsEnabled = value
                return state
            }
        },
        openPlugins: {
            let controller = textAlertController(
                context: context,
                title: "Плагины dgram",
                text: "Движок JavaScriptCore активен. Скрипты плагинов (.js) загружаются из папки Documents/dgram/plugins.",
                actions: [TextAlertAction(type: .defaultAction, title: "OK", action: {})]
            )
            presentControllerImpl?(controller)
        }
    )
    
    let signal = combineLatest(queue: .mainQueue(),
        context.sharedContext.presentationData,
        statePromise.get()
    )
    |> map { presentationData, state -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("dgram"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: dgramSettingsEntries(state: state),
            style: .blocks,
            animateChanges: true
        )
        return (controllerState, (listState, arguments))
    }
    
    let controller = ItemListController(context: context, state: signal)
    presentControllerImpl = { [weak controller] c in
        controller?.present(c, in: .window(.root))
    }
    return controller
}
