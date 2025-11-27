class SubscriptionManager {
  static bool canCreateChannel(String tier) {
    return tier == 'elite' || tier == 'admin';
  }

  static bool canUseGhostMode(String tier) {
    return tier == 'elite';
  }

  static int getLoungeQuota(String tier) {
    if (tier == 'elite' || tier == 'admin') {
      return 999;
    }
    return 3;
  }
}
