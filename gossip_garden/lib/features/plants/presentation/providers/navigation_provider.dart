import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ✅ DEFINIMOS TabId SOLO AQUÍ (fuente única)
enum TabId { dashboard, chat, garden, profile }

class NavigationState {
  final TabId activeTab;
  final String selectedPlantId;
  final String? selectedFriendId;
  final bool showChat;
  final bool showPlantProfile;
  final bool showOnboarding;

  const NavigationState({
    this.activeTab = TabId.dashboard,
    this.selectedPlantId = '1',
    this.selectedFriendId,
    this.showChat = false,
    this.showPlantProfile = false,
    this.showOnboarding = true,
  });

  NavigationState copyWith({
    TabId? activeTab,
    String? selectedPlantId,
    String? selectedFriendId,
    bool? showChat,
    bool? showPlantProfile,
    bool? showOnboarding,
  }) {
    return NavigationState(
      activeTab: activeTab ?? this.activeTab,
      selectedPlantId: selectedPlantId ?? this.selectedPlantId,
      selectedFriendId: selectedFriendId,
      showChat: showChat ?? this.showChat,
      showPlantProfile: showPlantProfile ?? this.showPlantProfile,
      showOnboarding: showOnboarding ?? this.showOnboarding,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void completeOnboarding() {
    state = state.copyWith(showOnboarding: false);
  }

  void selectPlant(String id) {
    state = state.copyWith(
      selectedPlantId: id,
      showPlantProfile: true,
      showChat: false,
    );
  }

  void openChat(String id) {
    state = state.copyWith(
      selectedPlantId: id,
      showChat: true,
      showPlantProfile: false,
    );
  }

  void openFriendGarden(String id) {
    state = state.copyWith(selectedFriendId: id);
  }

  void changeTab(TabId tab) {
    state = state.copyWith(
      activeTab: tab,
      showChat: false,
      showPlantProfile: false,
      selectedFriendId: null,
    );
  }

  bool handleBack() {
    if (state.showChat) {
      state = state.copyWith(showChat: false);
      return false;
    }
    if (state.showPlantProfile) {
      state = state.copyWith(showPlantProfile: false);
      return false;
    }
    if (state.selectedFriendId != null) {
      state = state.copyWith(selectedFriendId: null);
      return false;
    }
    return true;
  }
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});
