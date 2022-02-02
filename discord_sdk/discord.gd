class_name Discord

const Core := preload("./core.gdns")

# Users
const User := preload("./user.gdns")
const UserManager := preload("./user_manager.gdns")

# Images
const ImageDimensions := preload("./image_dimensions.gdns")
const ImageHandle := preload("./image_handle.gdns")
const ImageManager := preload("./image_manager.gdns")

# Activities
const ActivityTimestamps := preload("./activity_timestamps.gdns")
const ActivityAssets := preload("./activity_assets.gdns")
const PartySize := preload("./party_size.gdns")
const ActivityParty := preload("./activity_party.gdns")
const ActivitySecrets := preload("./activity_secrets.gdns")
const Activity := preload("./activity.gdns")
const ActivityManager := preload("./activity_manager.gdns")

# Relationships
const Presence := preload("./presence.gdns")
const Relationship := preload("./relationship.gdns")
const RelationshipManager := preload("./relationship_manager.gdns")

# Networking
const NetworkManager := preload("./network_manager.gdns")

enum Result {
	OK = 0,
	SERVICE_UNAVAILABLE = 1,
	INVALID_VERSION = 2,
	LOCK_FAILED = 3,
	INTERNAL_ERROR = 4,
	INVALID_PAYLOAD = 5,
	INVALID_COMMAND = 6,
	INVALID_PERMISSIONS = 7,
	NOT_FETCHED = 8,
	NOT_FOUND = 9,
	CONFLICT = 10,
	INVALID_SECRET = 11,
	INVALID_JOIN_SECRET = 12,
	NO_ELIGIBLE_ACTIVITY = 13,
	INVALID_INVITE = 14,
	NOT_AUTHENTICATED = 15,
	INVALID_ACCESS_TOKEN = 16,
	APPLICATION_MISMATCH = 17,
	INVALID_DATA_URL = 18,
	INVALID_BASE_64 = 19,
	NOT_FILTERED = 20,
	LOBBY_FULL = 21,
	INVALID_LOBBY_SECRET = 22,
	INVALID_FILENAME = 23,
	INVALID_FILE_SIZE = 24,
	INVALID_ENTITLEMENT = 25,
	NOT_INSTALLED = 26,
	NOT_RUNNING = 27,
	INSUFFICIENT_BUFFER = 28,
	PURCHASE_CANCELED = 29,
	INVALID_GUILD = 30,
	INVALID_EVENT = 31,
	INVALID_CHANNEL = 32,
	INVALID_ORIGIN = 33,
	RATE_LIMITED = 34,
	OAUTH2_ERROR = 35,
	SELECT_CHANNEL_TIMEOUT = 36,
	GET_GUILD_TIMEOUT = 37,
	SELECT_VOICE_FORCE_REQUIRED = 38,
	CAPTURE_SHORTCUT_ALREADY_LISTENING = 39,
	UNAUTHORIZED_FOR_ACHIEVEMENT = 40,
	INVALID_GIFT_CODE = 41,
	PURCHASE_ERROR = 42,
	TRANSACTION_ABORTED = 43,
}

enum CreateFlags {
	DEFAULT = 0,
	NO_REQUIRE_DISCORD = 1,
}

enum LogLevel {
	ERROR = 1,
	WARN,
	INFO,
	DEBUG,
}

enum UserFlag {
	PARTNER = 2,
	HYPESQUAD_EVENTS = 4,
	HYPESQUAD_HOUSE_1 = 64,
	HYPESQUAD_HOUSE_2 = 128,
	HYPESQUAD_HOUSE_3 = 256,
}

enum PremiumType {
	NONE = 0,
	TIER_1 = 1,
	TIER_2 = 2,
}

enum ImageType {
	USER,
}

enum ActivityType {
	PLAYING,
	STREAMING,
	LISTENING,
	WATCHING,
}

enum ActivityActionType {
	JOIN = 1,
	SPECTATE,
}

enum ActivityJoinRequestReply {
	NO,
	YES,
	IGNORE,
}

enum Status {
	OFFLINE = 0,
	ONLINE = 1,
	IDLE = 2,
	DO_NOT_DISTURB = 3,
}

enum RelationshipType {
	NONE,
	FRIEND,
	BLOCKED,
	PENDING_INCOMING,
	PENDING_OUTGOING,
	IMPLICIT,
}

enum LobbyType {
	PRIVATE = 1,
	PUBLIC,
}

enum LobbySearchComparison {
	LESS_THAN_OR_EQUAL = -2,
	LESS_THAN,
	EQUAL,
	GREATER_THAN,
	GREATER_THAN_OR_EQUAL,
	NOT_EQUAL,
}

enum LobbySearchCast {
	STRING = 1,
	NUMBER,
}

enum LobbySearchDistance {
	LOCAL,
	DEFAULT,
	EXTENDED,
	GLOBAL,
}

enum EntitlementType {
	PURCHASE = 1,
	PREMIUM_SUBSCRIPTION,
	DEVELOPER_GIFT,
	TEST_MODE_PURCHASE,
	FREE_PURCHASE,
	USER_GIFT,
	PREMIUM_PURCHASE,
}

enum SkuType {
	APPLICATION = 1,
	DLC,
	CONSUMABLE,
	BUNDLE,
}

enum InputModeType {
	VOICE_ACTIVITY = 0,
	PUSH_TO_TALK,
}
