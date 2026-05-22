import SwiftUI

struct HomeView: View {

    @StateObject private var vm = HomeViewModel()
    @StateObject private var habitStore = HabitStore()
    @StateObject private var sectionStore = SectionStore()
    @StateObject private var noteStore = NoteStore()          // ✅ lifted here so it persists

    @State private var showOverlay = false
    @State private var showHabits = false
    @State private var showControlCentre = false
    @State private var selectedSection: AppSection? = nil

    var body: some View {

        ZStack {

            BackgroundView(timeOfDay: vm.backgroundTimeOfDay)
                .ignoresSafeArea()

            // MARK: - Main content
            VStack(spacing: 0) {

                Spacer()

                VStack(spacing: 8) {
                    Text(vm.timeOfDay.greeting)
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    if vm.weather.isLoading {
                        ProgressView().tint(.white).padding(.top, 4)
                    } else {
                        HStack(spacing: 6) {
                            if let temp = vm.weather.temperature { Text("\(temp)°C") }
                            if !vm.weather.cityName.isEmpty {
                                Text("•")
                                Text(vm.weather.cityName)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                        if !vm.weather.conditionNow.isEmpty {
                            Text(vm.weather.conditionNow)
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        if !vm.weather.conditionTonight.isEmpty {
                            Text(vm.weather.conditionTonight)
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }

                Spacer()

                VStack(spacing: 20) {
                    Text("TODAY")
                        .font(.caption)
                        .tracking(4)
                        .foregroundColor(.white.opacity(0.7))

                    Text(vm.thoughtOfDay)
                        .font(.system(size: 38, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                }

                Spacer()
                Spacer()
            }

            // MARK: - Three Buttons
            VStack {
                Spacer()
                HStack {

                    // Checklist — LEFT
                    Button {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                            showHabits = true
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 62, height: 62)
                            Image(systemName: "checklist")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.leading, 28)
                    .padding(.bottom, 48)

                    Spacer()

                    // Control Centre — CENTRE
                    Button {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                            showControlCentre = true
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 72, height: 72)
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.2), lineWidth: 1.5)
                                )
                            Image(systemName: "square.grid.2x2")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 44)

                    Spacer()

                    // Gallery — RIGHT
                    Button {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                            showOverlay.toggle()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 62, height: 62)
                            Image(systemName: showOverlay ? "xmark" : "plus")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(showOverlay ? 90 : 0))
                                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: showOverlay)
                        }
                    }
                    .padding(.trailing, 28)
                    .padding(.bottom, 48)
                }
            }

//            // MARK: - Photo Gallery
//            if showOverlay {
//                PhotoGalleryOverlay {
//                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
//                        showOverlay = false
//                    }
//                }
//                .zIndex(5)
//            }

            // MARK: - Control Centre
            if showControlCentre {
                ControlCentreView(
                    sectionStore: sectionStore,
                    vm: vm,
                    onDismiss: {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            showControlCentre = false
                        }
                    },
                    onSelectSection: { section in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            selectedSection = section
                        }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(8)
            }

            // MARK: - Section Detail
            if let section = selectedSection {
                SectionDetailView(
                    sectionName: section.title,
                    sectionIcon: section.icon,
                    sectionColor: section.colorHex,
                    tasks: Binding(
                        get: { vm.allTasks[section.title] ?? [] },
                        set: { vm.allTasks[section.title] = $0 }
                    ),
                    noteStore: noteStore,                      // ✅ passed in, not recreated
                    onDismiss: {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            selectedSection = nil
                        }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(10)
            }

            // MARK: - Habit Checklist
            if showHabits {
                HabitChecklistView(store: habitStore) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        showHabits = false
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(10)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: selectedSection?.id)
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: showHabits)
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: showControlCentre)
    }
}

#Preview {
    HomeView()
}
