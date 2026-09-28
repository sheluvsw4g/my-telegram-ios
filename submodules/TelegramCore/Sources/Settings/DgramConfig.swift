import Foundation

public final class DgramConfig {
    private static let defaults = UserDefaults.standard
    
    public static let settingsChangedNotification = Notification.Name("DgramSettingsChangedNotification")
    
    private enum Keys {
        static let ghostModeNoReadReceipts = "dgram_ghost_read"
        static let ghostModeHideTyping = "dgram_ghost_typing"
        static let ghostModeStories = "dgram_ghost_stories"
        static let antiDeleteMessages = "dgram_anti_delete"
        static let saveViewOnceMedia = "dgram_save_view_once"
        static let hidePhoneNumber = "dgram_hide_phone"
        static let showIdAndDc = "dgram_show_id_dc"
        static let pluginsEnabled = "dgram_plugins_enabled"
    }
    
    public static var ghostModeNoReadReceipts: Bool {
        get { return defaults.bool(forKey: Keys.ghostModeNoReadReceipts) }
        set {
            defaults.set(newValue, forKey: Keys.ghostModeNoReadReceipts)
            NotificationCenter.default.post(name: settingsChangedNotification, object: nil)
        }
    }
    
    public static var ghostModeHideTyping: Bool {
        get { return defaults.bool(forKey: Keys.ghostModeHideTyping) }
        set {
            defaults.set(newValue, forKey: Keys.ghostModeHideTyping)
            NotificationCenter.default.post(name: settingsChangedNotification, object: nil)
        }
    }
    
    public static var ghostModeStories: Bool {
        get { return defaults.bool(forKey: Keys.ghostModeStories) }
        set {
            defaults.set(newValue, forKey: Keys.ghostModeStories)
            NotificationCenter.default.post(name: settingsChangedNotification, object: nil)
        }
    }
    
    public static var antiDeleteMessages: Bool {
        get {
            // Enabled by default for best user experience
            if defaults.object(forKey: Keys.antiDeleteMessages) == nil {
                return true
            }
            return defaults.bool(forKey: Keys.antiDeleteMessages)
        }
        set {
            defaults.set(newValue, forKey: Keys.antiDeleteMessages)
            NotificationCenter.default.post(name: settingsChangedNotification, object: nil)
        }
    }
    
    public static var saveViewOnceMedia: Bool {
        get {
            if defaults.object(forKey: Keys.saveViewOnceMedia) == nil {
                return true
            }
            return defaults.bool(forKey: Keys.saveViewOnceMedia)
        }
        set {
            defaults.set(newValue, forKey: Keys.saveViewOnceMedia)
            NotificationCenter.default.post(name: settingsChangedNotification, object: nil)
        }
    }
    
    public static var hidePhoneNumber: Bool {
        get { return defaults.bool(forKey: Keys.hidePhoneNumber) }
        set {
            defaults.set(newValue, forKey: Keys.hidePhoneNumber)
            NotificationCenter.default.post(name: settingsChangedNotification, object: nil)
        }
    }
    
    public static var showIdAndDc: Bool {
        get {
            if defaults.object(forKey: Keys.showIdAndDc) == nil {
                return true
            }
            return defaults.bool(forKey: Keys.showIdAndDc)
        }
        set {
            defaults.set(newValue, forKey: Keys.showIdAndDc)
            NotificationCenter.default.post(name: settingsChangedNotification, object: nil)
        }
    }
    
    public static var pluginsEnabled: Bool {
        get { return defaults.bool(forKey: Keys.pluginsEnabled) }
        set {
            defaults.set(newValue, forKey: Keys.pluginsEnabled)
            NotificationCenter.default.post(name: settingsChangedNotification, object: nil)
        }
    }
}
