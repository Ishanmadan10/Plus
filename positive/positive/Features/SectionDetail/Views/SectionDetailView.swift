import SwiftUI

struct SectionDetailView: View {

    let sectionName: String
    let sectionIcon: String
    let sectionColor: String

    @Binding var tasks: [String]

    @ObservedObject var noteStore: NoteStore

    var onDismiss: () -> Void

    var body: some View {

        switch sectionName {

        case "Work":
            WorkSectionView(
                sectionColor: sectionColor,
                tasks: $tasks,
                noteStore: noteStore,
                onDismiss: onDismiss
            )

        case "Groceries":
            GroceriesSectionView(
                sectionColor: sectionColor,
                onDismiss: onDismiss
            )

        case "Gym":
            GymSectionView(
                sectionColor: sectionColor,
                onDismiss: onDismiss
            )

        case "Journal":
            JournalSectionView(
                sectionColor: sectionColor,
                noteStore: noteStore,
                onDismiss: onDismiss
            )

        case "Spirituality":
            SpiritualitySectionView(
                sectionColor: sectionColor,
                onDismiss: onDismiss
            )

        default:
            GenericSectionView(
                sectionName: sectionName,
                sectionIcon: sectionIcon,
                sectionColor: sectionColor,
                tasks: $tasks,
                noteStore: noteStore,
                onDismiss: onDismiss
            )
        }
    }
}
