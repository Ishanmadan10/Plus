import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        ZStack {
            // ── Animated background (always full screen)
            BackgroundView(timeOfDay: vm.timeOfDay)
                .ignoresSafeArea()

            // ── Phase 1: centred greeting (fades out as it moves up)
            if vm.greetingPhase == .centred {
                GreetingView(timeOfDay: vm.timeOfDay, isHeader: false)
                    .transition(.opacity)
                    .ignoresSafeArea()
            }

            // ── Phase 2: header + card flow
            if vm.greetingPhase == .header {
                VStack(spacing: 0) {

                    // Compact header at top
                    GreetingView(timeOfDay: vm.timeOfDay, isHeader: true)

                    Spacer()

                    // Card carousel
                    TabView(selection: $vm.currentCard) {
                        ScratchCardView(
                            thought: vm.thoughtOfDay,
                            timeOfDay: vm.timeOfDay,
                            hasScratched: $vm.hasScratched
                        )
                        .tag(HomeViewModel.CardIndex.scratch)

                        ReminderCardView(
                            reminder: vm.reminder,
                            timeOfDay: vm.timeOfDay
                        )
                        .tag(HomeViewModel.CardIndex.reminder)

                        JokeCardView(
                            joke: vm.joke,
                            timeOfDay: vm.timeOfDay
                        )
                        .tag(HomeViewModel.CardIndex.joke)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 300)
                    .transition(.move(edge: .bottom).combined(with: .opacity))

                    // Pagination dots
                    PaginationDotsView(
                        current: vm.currentCard.rawValue,
                        total: HomeViewModel.CardIndex.allCases.count,
                        timeOfDay: vm.timeOfDay
                    )
                    .padding(.top, 18)

                    // Swipe hint
                    SwipeHintView(timeOfDay: vm.timeOfDay)
                        .padding(.top, 10)
                        .opacity(vm.currentCard == .scratch ? 1 : 0)

                    Spacer()
                }
                .transition(.opacity)
            }

            // ── Pill button (always visible, bottom-right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    PillButton(timeOfDay: vm.timeOfDay, isOpen: $vm.pillIsOpen)
                        .padding(.trailing, 28)
                        .padding(.bottom, 52)
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .statusBarHidden(vm.greetingPhase == .centred)   // clean during hero
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
