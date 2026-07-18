/// Generic outcome for a ViewModel action. The View reads this to decide
/// what to do next (navigate, show a snackbar, etc.) -- ViewModels never
/// navigate or touch BuildContext directly.
enum AuthActionResult { success, error }
